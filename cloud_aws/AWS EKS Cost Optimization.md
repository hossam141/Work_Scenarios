# AWS EKS Multi-Account Cost Optimization (67% Savings) - E

> **Real-world setup**
> - Two AWS accounts:
>   - **STG/PROD**: stable customer-facing services with strict uptime/SLOs.
>   - **DEV/TEST**: CI-driven, ephemeral testing workloads; interruptions acceptable.
> - Each account runs an **EKS cluster** with **Managed Node Groups**.
> - Node fleet was accidentally left as **100% On-Demand** during initial rollout.

---

## 1) The Problem
Both clusters used only **On-Demand** nodes, producing a combined monthly bill of **$1,515.48**:

- **STG/PROD** paid full On-Demand even though usage was predictable and steady.
- **DEV/TEST** paid premium pricing even though workloads were fault-tolerant and could run on Spot.

**Goal:** reduce cost without changing application code, and without risking production reliability.

---

## 2) The Investigation (prove what’s running and what costs money)

### A) Cost Explorer (billing perspective)
**Aim:** confirm the primary cost driver (it’s almost always EC2 for node capacity in EKS).

What we looked for:
- EC2 spend dominating total cost
- Flat, always-on usage in DEV/TEST (indicating waste)

---

### B) Kubernetes node inspection (runtime perspective)
Billing tells you “what costs.” Kubernetes tells you “what is actually running.”

#### Command
```bash
# Aim:
# - List all worker nodes currently registered in the cluster
# - Extract:
#   1) node name
#   2) instance type (what you're paying for)
#   3) capacity type (ON_DEMAND or SPOT)
kubectl get nodes   -o custom-columns=NAME:.metadata.name,INSTANCE-TYPE:.metadata.labels.node\.kubernetes\.io/instance-type,LIFECYCLE:.metadata.labels.eks\.amazonaws\.com/capacityType
```

#### What exactly we’re doing (field-by-field)
- `kubectl get nodes`: asks the Kubernetes API server for the list of nodes that are part of the cluster.
- `-o custom-columns=...`: formats output into specific columns instead of default output.
- `NAME:.metadata.name`: prints each node object name (useful for follow-up inspection).
- `INSTANCE-TYPE:...node.kubernetes.io/instance-type`: reads the node label that indicates the EC2 instance type.
- `LIFECYCLE:...eks.amazonaws.com/capacityType`: reads the EKS label that indicates whether the node was created as **SPOT** or **ON_DEMAND**.

#### Practical outcome
This confirmed **every node** was `LIFECYCLE=ON_DEMAND` — even in DEV/TEST.

> Note: Your original command used `.item.metadata.labels...` which is a common slip. Nodes are returned as a list, but `kubectl` custom-columns maps per node object, so it should use `.metadata.labels...` (as above).

---

## 3) The Solution (two-track strategy)
### Design decision (realistic)
- **STG/PROD**: commit to a baseline discount (predictable usage → best ROI).
- **DEV/TEST**: move to Spot + enforce scheduling rules so only dev/test workloads land there.

---

### A) STG/PROD: Reserved Instances (All Upfront) for baseline
**Aim:** reduce cost for the stable “always-on” portion of production capacity.

Realistic assumption:
- After reviewing peak vs baseline usage, baseline ≈ **6 x m5.large** nodes.

#### Command
```bash
# Aim:
# - Purchase Reserved Instances to discount baseline EC2 usage in STG/PROD
# - Steps:
#   1) Find a matching RI offering ID for m5.large
#   2) Purchase 6 RIs as All Upfront

aws ec2 purchase-reserved-instances-offering   --instance-type m5.large   --reserved-instances-offering-id $(
    aws ec2 describe-reserved-instances-offerings       --instance-type m5.large       --query 'ReservedInstancesOfferings[0].ReservedInstancesOfferingId'       --output text
  )   --instance-count 6   --offering-type "All Upfront"
```

#### What exactly we’re doing (step-by-step)
- `describe-reserved-instances-offerings`: finds purchasable RI offers (each has an ID).
- `--query ...OfferingId`: extracts one offering ID from the results.
- `purchase-reserved-instances-offering`: buys the commitment.
- `--instance-count 6`: covers baseline capacity.
- `All Upfront`: largest discount but requires paying upfront.

**Important operational note:**  
This does **not** change Kubernetes or node behavior. It only changes **billing** for matching usage.

---

### B) DEV/TEST: Spot Managed Node Group (Terraform)
**Aim:** run dev/test on low-cost capacity that can be interrupted, without losing the environment.

Key realistic controls:
- Diversify instance types (avoid single-type outages).
- Keep a small baseline; allow scale when CI runs.

#### Terraform
```hcl
# Aim:
# - Create a Spot node group for DEV/TEST
# - Diversify instance types to reduce interruption risk
resource "aws_eks_node_group" "dev_test_spot" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "dev-test-spot-group"
  node_role_arn   = aws_iam_role.eks_node.arn
  subnet_ids      = var.private_subnets

  capacity_type   = "SPOT"

  # Best practice:
  # Mix instance families so EKS can find capacity when one type is reclaimed.
  instance_types  = ["m5.large", "m5a.large", "m4.large"]

  scaling_config {
    desired_size = 3
    max_size     = 6
    min_size     = 1
  }
}
```

#### What exactly we’re doing (why each block matters)
- `capacity_type = "SPOT"`: tells EKS to provision Spot capacity.
- `instance_types = [...]`: increases availability by expanding the pool of acceptable Spot types.
- `scaling_config`: controls cost by keeping minimum capacity low and scaling only when needed.

---

### C) Workload scheduling (Helm/Kubernetes)
**Aim:** ensure only dev/test workloads land on Spot nodes (and production stays on stable nodes).

#### Helm values.yaml
```yaml
# Aim:
# - Force specific workloads (dev/test apps) onto Spot nodes only
nodeSelector:
  eks.amazonaws.com/capacityType: SPOT
```

#### What exactly we’re doing
- `nodeSelector` tells the scheduler: “place this pod only on nodes that match this label.”
- This prevents accidental placement of sensitive workloads on Spot.

> In stricter environments, teams also add **taints** to Spot nodes + **tolerations** only on dev/test pods, to enforce isolation even harder.

---

## 4) The Result (ROI)

| Environment | Before (On-Demand) | After (RI/Spot) | Savings % |
|---|---:|---:|---:|
| STG & PROD | $757.74 | $315.36 | ~58% |
| DEV & TEST | $757.74 | $192.72 | ~74% |
| **Total** | **$1,515.48** | **$508.08** | **67% Total Savings** |

---

## 5) The Lesson (what makes this hold up in real life)
1. **Validate with `kubectl`, not assumptions.** Cost tools show spend; cluster tools show configuration reality.
2. **Commit only to the baseline.** Overbuying RIs creates waste.
3. **Spot must be diversified.** Single-type Spot is fragile; mixed types are survivable.
4. **Enforce scheduling controls.** Without selectors/taints, workloads drift and you lose the benefit (or risk prod).

---

## Optional “Real” Add-ons (if you want to extend the case study)
- Add a **Spot interruption handling** section (Pod disruption budgets, graceful termination).
- Add **Cluster Autoscaler / Karpenter** notes for better scaling and instance selection.
- Add a **rollback plan** (temporarily switch DEV node group back to On-Demand during a major incident).
