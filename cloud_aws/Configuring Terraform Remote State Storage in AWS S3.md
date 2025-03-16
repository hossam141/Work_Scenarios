# 📌 Configuring Terraform Remote State Storage in AWS S3

## **🔹 Objective**
This guide explains how to **store Terraform state files (`terraform.tfstate`) in AWS S3** and use **DynamoDB for state locking** to enable **secure team collaboration**.

---

## **1️⃣ Step 1: Create an S3 Bucket for Remote State Storage**
1. **Go to AWS Console** → **S3** → **Create Bucket**.
2. **Enter Bucket Name** (e.g., `terraform-state-bucket`).
3. **Block Public Access** → Keep all settings **enabled** (for security).
4. **Enable Versioning** → Helps track state changes and rollback if needed.
5. Click **Create Bucket**.

✅ **Now, Terraform can use this bucket for storing state files.**

---

## **2️⃣ Step 2: Create a DynamoDB Table (For State Locking)**
AWS **DynamoDB** prevents simultaneous Terraform runs from modifying the state file.

1. **Go to AWS Console** → **DynamoDB** → **Create Table**.
2. **Table Name**: `terraform-state-locking`.
3. **Primary Key**: `LockID` (Type: **String**).
4. Click **Create Table**.

✅ **Now, Terraform can use this table to lock the state file during deployments.**

---

## **3️⃣ Step 3: Configure Terraform to Use S3 Backend**
Modify the `backend` configuration in Terraform.

```hcl
terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket"   # Your S3 bucket
    key            = "env/prod/terraform.tfstate" # Path inside S3
    region         = "us-east-1"               # AWS Region
    encrypt        = true                      # Encrypt state file
    dynamodb_table = "terraform-state-locking" # For state locking
  }
}
```

✅ **What this does:**
- **Stores the Terraform state file in S3.**
- **Uses DynamoDB for state locking (prevents conflicts in team environments).**
- **Encrypts the state file for security.**

---

## **4️⃣ Step 4: Initialize the Remote State**
Run:
```bash
terraform init
```
✅ **This configures Terraform to use S3 as the remote backend.**

---

## **5️⃣ Step 5: Verify Remote State Storage**
Run:
```bash
terraform apply
```
1. Check **S3 Bucket** → You should see `terraform.tfstate` stored inside.
2. Check **DynamoDB Table** → A `LockID` entry appears when Terraform is running.

---

## **🚀 Summary**
| **Step** | **Task** |
|----------|---------|
| **1️⃣ Create S3 Bucket** | Stores Terraform state securely. |
| **2️⃣ Create DynamoDB Table** | Enables state locking to prevent conflicts. |
| **3️⃣ Configure Terraform Backend** | Points Terraform to use S3 for state storage. |
| **4️⃣ Run `terraform init`** | Initializes remote state storage. |
| **5️⃣ Run `terraform apply`** | Deploys infrastructure and verifies remote state. |

✅ **Now, your Terraform state is securely stored in AWS S3, and locking is enabled via DynamoDB!** 🚀
