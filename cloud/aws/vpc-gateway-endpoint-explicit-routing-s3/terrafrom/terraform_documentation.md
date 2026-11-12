# 🛠️ Terraform Code: Cost-Optimized Gateway Endpoint

This directory contains the Infrastructure as Code (IaC) to provision a Zero-Cost S3 Gateway Endpoint architecture.

## 🏗️ Architectural Differences (Gateway vs. Interface)

When reviewing this Terraform code, note the fundamental differences compared to our Interface Endpoint implementation:

1. **No Security Groups for the Endpoint:** Gateway Endpoints act as a Route Table target, not a network interface. Therefore, `security_group_ids` are not used on the endpoint itself. Security is managed via VPC Endpoint Policies.
2. **No Subnet IDs on the Endpoint:** Instead of injecting ENIs into subnets, we associate the endpoint with **Route Tables**.
3. **`vpc_endpoint_type`:** Explicitly set to `"Gateway"`.

## 📁 Key Files Overview

* `endpoints.tf`: Contains the `aws_vpc_endpoint` resource configured as a Gateway. Crucially, it includes the `aws_vpc_endpoint_route_table_association` resource, which automatically injects the AWS Managed Prefix List for S3 into our private route tables.
* `network.tf`: Provisions the strictly isolated private subnets and route tables.
* `security.tf`: Provisions the instance-level security groups (allowing EICE SSH access).

## 🚀 Usage

```bash
terraform init
terraform plan
terraform apply -auto-approve
```