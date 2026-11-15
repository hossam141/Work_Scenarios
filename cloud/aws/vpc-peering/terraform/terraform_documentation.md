# 🏗️ Terraform Architecture: VPC Peering & Routing

This document outlines the Infrastructure as Code (IaC) setup used to provision the multi-VPC environment and establish peering connections.

## 📁 File Structure & Resource Mapping

* **`providers.tf`**: Configures the AWS provider.
* **`variables.tf`**: Centralizes parameters for the three VPC CIDR blocks to ensure no overlap (`10.16.0.0/16`, `10.17.0.0/16`, `10.18.0.0/16`).
* **`network.tf`**: 
  * Provisions VPCA, VPCB, and VPCC.
  * Creates Private Subnets and Route Tables for each VPC.
* **`peering.tf`**: 
  * The core of this task. Provisions the `aws_vpc_peering_connection` resources (`AEM-VPCA-TO-VPCB` & `AEM-VPCB-TO-VPCC`).
  * Creates the critical `aws_route` entries in the respective Route Tables to direct traffic across the peering links in both directions.
* **`security.tf`**: Provisions Security Groups allowing cross-VPC communication (ICMP for ping testing) strictly from the peered network CIDRs.

---

## 🚀 How to Execute (Usage)

To deploy this infrastructure locally, ensure you have the AWS CLI configured with appropriate credentials, then run the following commands:

```bash
# 1. Initialize the working directory and download provider plugins
terraform init

# 2. Preview the execution plan 
terraform plan

# 3. Provision the resources
terraform apply -auto-approve

```

## 🧹 Cleanup
To avoid unnecessary AWS charges, destroy the infrastructure once testing is complete:
```bash
terraform destroy -auto-approve
```