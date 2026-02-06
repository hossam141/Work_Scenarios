# AWS EKS Multi-Account Cost Optimization (67% Savings) - E

## 1. The Problem
An EKS cluster was running across two AWS accounts (**STG/PROD** and **DEV/TEST**) using only **On-Demand** instances. This resulted in a monthly bill of **$1,515.48**, which was unsustainable for non-production environments and inefficient for stable production workloads.

## 2. The Investigation
To identify the waste, I used **AWS Cost Explorer** and the following CLI command to analyze current instance usage and pricing models:

```bash
# List all instances in the cluster and their lifecycle (On-Demand vs Spot)
kubectl get nodes -o custom-columns=NAME:.metadata.name,INSTANCE-TYPE:.item.metadata.labels.'node\.kubernetes\.io/instance-type',LIFECYCLE:.metadata.labels.'eks\.amazonaws\.com/capacityType'
```

The analysis confirmed that **100%** of the fleet was **ON_DEMAND**, even for the fault-tolerant DEV workloads.

## 3. The Solution
I implemented a dual-strategy optimization: **Reserved Instances (RI)** for stability and **Spot Instances** for cost-sensitive testing.

### A. Production: Reserved Instances (All Upfront)
Purchased RIs for the **STG/PROD** account to cover the “baseline” load.

```bash
aws ec2 purchase-reserved-instances-offering \
    --instance-type m5.large \
    --reserved-instances-offering-id $(aws ec2 describe-reserved-instances-offerings --instance-type m5.large --query 'ReservedInstancesOfferings[0].ReservedInstancesOfferingId' --output text) \
    --instance-count 6 --offering-type "All Upfront"
```

### B. Dev/Test: Spot Managed Node Groups
Used Terraform to provision Spot instances for **DEV/TEST**. I included instance diversification to ensure availability if `m5.large` is reclaimed.

```hcl
resource "aws_eks_node_group" "dev_test_spot" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "dev-test-spot-group"
  node_role_arn   = aws_iam_role.eks_node.arn
  subnet_ids      = var.private_subnets

  capacity_type   = "SPOT"
  # Best Practice: Mix instance types to increase Spot availability
  instance_types  = ["m5.large", "m5a.large", "m4.large"]

  scaling_config {
    desired_size = 3
    max_size     = 6
    min_size     = 1
  }
}
```

### C. Workload Scheduling (Helm/Kubernetes)
Updated the Helm `values.yaml` to ensure pods land on the correct cost-optimized nodes.

```yaml
nodeSelector:
  eks.amazonaws.com/capacityType: SPOT # For Dev/Test apps
```

## 4. The Result (ROI)

| Environment | Before (On-Demand) | After (RI/Spot) | Savings % |
|---|---:|---:|---:|
| STG & PROD | $757.74 | $315.36 | ~58% |
| DEV & TEST | $757.74 | $192.72 | ~74% |
| **Total** | **$1,515.48** | **$508.08** | **67% Total Savings** |

## 5. The Lesson
Diversify your Spot Instance types. Never rely on a single instance type (like `m5.large`) for Spot. If AWS reclaims that specific type in that AZ, your Dev environment will go down. By providing a list (`m5.large`, `m5a.large`, `m4.large`), EKS can always find a cheap alternative to keep the cluster running.