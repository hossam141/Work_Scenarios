# 🏗️ Terraform Architecture: IPv6 Egress-Only Gateway

This document outlines the Infrastructure as Code (IaC) setup used to provision the Zero-Trust IPv6 Egress architecture.

## 📁 File Structure & Resource Mapping

* **`providers.tf`**: Configures the AWS provider and sets global default tags for resource tracking (`Project = "IPv6-Zero-Trust-Egress"`).
* **`variables.tf`**: Centralizes parameters like AWS region and VPC CIDR blocks for reusability.
* **`network.tf`**: 
  * Provisions a **Dual-Stack VPC** (`assign_generated_ipv6_cidr_block = true`).
  * Creates the **Private Subnet** and dynamically calculates both IPv4 and IPv6 CIDR blocks using the `cidrsubnet()` function.
  * Configures the Private Route Table.
* **`egress_only_gateway.tf`**: 
  * The core of this task. Provisions the `aws_egress_only_internet_gateway` (EIGW).
  * Creates the critical `aws_route` that directs all IPv6 traffic (`::/0`) from the private subnet to the EIGW.

## 🚀 Usage

```bash
terraform init
terraform plan
terraform apply -auto-approve
```