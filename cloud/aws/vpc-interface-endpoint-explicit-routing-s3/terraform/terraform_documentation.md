# 🛠️ Terraform Infrastructure Code: Zero-Trust S3 PrivateLink

This directory contains the Infrastructure as Code (IaC) definitions required to provision the Zero-Trust network topology and the VPC Interface Endpoints for secure Amazon S3 access.

## 📁 Code Structure & Execution Flow

The Terraform configuration is modularized into logical components to ensure maintainability and adherence to enterprise best practices.

### 1. `providers.tf`
* **Purpose:** Configures the AWS provider and defines the required Terraform versions.
* **Key Feature:** Implements `default_tags` to ensure all provisioned resources automatically inherit the `Environment`, `Project`, and `ManagedBy` tags for proper billing and resource tracking (FinOps).

### 2. `variables.tf`
* **Purpose:** Parameterizes the deployment, avoiding hardcoded values.
* **Key Feature:** Allows easy replication of this architecture across different environments (e.g., `dev`, `staging`, `prod`) and AWS regions.

### 3. `network.tf`
* **Purpose:** Provisions the foundational network layer (VPC, Private Subnets, Route Tables).
* **Key Feature (Zero-Trust):** Intentionally omits Internet Gateways (IGWs) and NAT Gateways to enforce strict network isolation.

### 4. `security.tf`
* **Purpose:** Defines Security Groups applying the Principle of Least Privilege.
* **Key Feature:** 
  * `backend_sg`: Restricts ingress to the VPC CIDR.
  * `endpoint_sg`: Restricts ingress strictly to traffic originating from `backend_sg` on port 443, securing the PrivateLink interface.

### 5. `endpoints.tf` (The Core Engine)
* **Purpose:** Deploys the AWS PrivateLink resources.
* **Key Feature:** 
  * Provisions the **VPC Interface Endpoint** for S3.
  * Explicitly sets `private_dns_enabled = false` to prevent overriding the VPC-wide DNS resolver, mandating explicit endpoint routing for enhanced control.
  * Deploys the **EC2 Instance Connect Endpoint (EICE)** for secure, agentless SSH access to private instances.

### 6. `outputs.tf`
* **Purpose:** Exports critical deployment data.
* **Key Feature:** Outputs the `s3_endpoint_dns_names`. This exact DNS name is required by the backend application configurations to explicitly target the endpoint.

---

## 🚀 How to Execute (Usage)

To deploy this infrastructure locally, ensure you have the AWS CLI configured with appropriate credentials, then run the following commands:

```bash
# 1. Initialize the working directory and download provider plugins
terraform init

# 2. Preview the execution plan (Verify no IGW/NATs are being created)
terraform plan

# 3. Provision the resources
terraform apply -auto-approve

# Note the Output:
# Extract the 's3_endpoint_dns_names' from the output to configure your application.
```

## 🧹 Cleanup
To avoid unnecessary AWS charges, destroy the infrastructure once testing is complete:
```bash
terraform destroy -auto-approve
```