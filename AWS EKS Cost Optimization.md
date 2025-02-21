# AWS EKS Cost Optimization

## Business Problem
Your company is running an **EKS cluster** across two **separate AWS accounts**:
  - **STG/PROD Account** → Stable, long-running workloads (**must be cost-efficient** and highly available).
  - **DEV/TEST Account** → Temporary, fault-tolerant workloads (**cost savings needed**).

Initially, all EC2 instances were **On-Demand**, leading to **high costs**.

## Initial Cost Breakdown (Before Optimization)
| **Environment** | **Instance Type** | **Instance Pricing Model (Before)** | **Cost Per Month (Before)** |
|----------------|------------------|----------------------------------|----------------------|
| **STG & PROD** | `m5.large` / `m6g.large` | **On-Demand** | **$757.74** |
| **DEV & TEST** | `m5.large` / `m6g.large` | **On-Demand** | **$757.74** |
| **Total Cost (Before Optimization)** | **$1,515.48 per month** |

## Cost Optimization Plan
- **STG/PROD**: Switch to **Reserved Instances (RI)** to reduce costs while ensuring stability.
- **DEV/TEST**: Move to **Spot Instances** for cost savings since interruptions are acceptable.
- Automate the infrastructure using **Terraform & Terragrunt**.
- Ensure workloads are properly scheduled using **Helm and Kubernetes labels**.
- **Create and configure EKS Node Groups** to ensure instances are properly utilized.

## Step 1: Configure Reserved Instances (RI) for STG/PROD
```bash
aws ec2 purchase-reserved-instances-offering \
    --instance-type m5.large \
    --reserved-instances-offering-id OFFERING_ID \
    --instance-count 6
```

## Step 2: Configure Spot Instances for DEV/TEST
```hcl
resource "aws_spot_instance_request" "dev_test" {
  provider = aws.dev
  count = 6
  ami = "ami-0abcdef1234567890"
  instance_type = var.dev_test_instance_type
  spot_price = "0.05"
  subnet_id = var.subnet_id
}
```

## Step 3: Creating EKS Node Groups

### Creating Node Group for STG/PROD (Reserved Instances)
```hcl
resource "aws_eks_node_group" "stg_prod_node_group" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "stg-prod-group"
  node_role_arn   = aws_iam_role.eks_node.arn
  subnet_ids      = var.subnet_ids
  instance_types  = ["m5.large", "m6g.large"]
  capacity_type   = "ON_DEMAND"
}
```

### Creating Node Group for DEV/TEST (Spot Instances)
```hcl
resource "aws_eks_node_group" "dev_test_node_group" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "dev-test-group"
  node_role_arn   = aws_iam_role.eks_node.arn
  subnet_ids      = var.subnet_ids
  instance_types  = ["m5.large", "m6g.large"]
  capacity_type   = "SPOT"
}
```

## Step 4: Automating Multi-Account Setup Using Terragrunt
### STG/PROD Account Configuration
```hcl
terraform {
  source = "../../../modules/eks_instances"
}

inputs = {
  env = "stg"
  stg_prod_instance_type = "m5.large"
  subnet_id = "subnet-xxxxxx"
}
```

### DEV/TEST Account Configuration
```hcl
terraform {
  source = "../../../modules/eks_instances"
}

inputs = {
  env = "dev"
  dev_test_instance_type = "m5.large"
  subnet_id = "subnet-yyyyyy"
}
```

## Step 5: Configuring Kubernetes & Helm for Proper Workload Scheduling
```bash
kubectl label nodes <stg-prod-node-name> eks.amazonaws.com/nodegroup=stg-prod
kubectl label nodes <dev-test-node-name> eks.amazonaws.com/nodegroup=dev-test
```

### Modify `values.yaml` in Helm for App Deployments
#### STG/PROD Apps
```yaml
nodeSelector:
  eks.amazonaws.com/nodegroup: stg-prod
```

#### DEV/TEST Apps
```yaml
nodeSelector:
  eks.amazonaws.com/nodegroup: dev-test
```

## Final Cost Breakdown (After Optimization)
| **Environment** | **Instance Type** | **Instance Pricing Model (After)** | **Cost Per Month (After)** |
|----------------|------------------|----------------------------------|----------------------|
| **STG & PROD** | `m5.large` / `m6g.large` | **Reserved Instances (RI)** | **$315.36** |
| **DEV & TEST** | `m5.large` / `m6g.large` | **Spot Instances** | **$192.72** |
| **Total Cost (After Optimization)** | **$508.08 per month** |

**Total Savings:** **$1,515.48 → $508.08 (67% cost reduction!)**

## Interview Answer: Explaining the Optimization
"In my recent project, I was responsible for optimizing EC2 costs in an EKS cluster across **two AWS accounts**—one for **STG/PROD** and one for **DEV/TEST**.

Initially, all instances were **On-Demand**, costing **$1,515 per month**. I analyzed usage patterns and implemented a new strategy:
- **For STG & PROD**, I switched to **Reserved Instances (RI)**, reducing costs by **58%**.
- **For DEV & TEST**, I moved to **Spot Instances**, achieving **75% cost savings**.
- I automated the deployment using **Terraform & Terragrunt** to ensure a **seamless multi-account setup**.
- I created **EKS Node Groups** to properly handle Reserved and Spot instances.
- I updated **Helm values** to **properly schedule workloads** in Kubernetes.

As a result, we reduced EC2 costs by **67% ($1,515 → $508 per month)** while maintaining reliability for STG/PROD workloads and flexibility for DEV/TEST workloads."

