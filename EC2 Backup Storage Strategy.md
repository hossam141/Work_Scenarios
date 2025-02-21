    # EC2 Backup Storage Strategy

## Business Problem
Your company manages **50 EC2 instances** running critical workloads. However, there is **no structured backup plan**, leading to potential data loss in case of:
- Accidental deletions
- Instance or volume failures
- Cyberattacks or ransomware incidents

To mitigate risks, we implement a **three-tier backup storage strategy** that balances **data protection and cost optimization**.

## Backup Strategy Overview
| **Backup Tier**           | **Method**                     | **Retention** | **Storage Tier** |
|---------------------------|--------------------------------|--------------|-----------------|
| **Daily Backups**         | EBS Snapshots (Automated)      | 7 Days       | Amazon EBS      |
| **Weekly Backups**        | AWS Backup (EBS → S3)         | 4 Weeks      | Amazon S3       |
| **Long-Term Backups**     | S3 Glacier Archival           | 30+ Days     | Amazon S3 Glacier |

## **Step 1: Automating Daily EBS Snapshots (7-Day Retention)**
We use **Amazon EBS Snapshots** for **fast volume recovery**, ensuring recent backups are available.

### **Terraform Configuration for Daily Snapshots**
```hcl
resource "aws_backup_vault" "ebs_backup_vault" {
  name = "ec2-ebs-backup-vault"
}

resource "aws_backup_plan" "daily_backup_plan" {
  name = "daily-ebs-backup"

  rule {
    rule_name         = "daily-ebs-backup-rule"
    target_vault_name = aws_backup_vault.ebs_backup_vault.name
    schedule          = "cron(0 2 * * ? *)" # Daily at 2 AM UTC
    lifecycle {
      delete_after = 7 # Retain for 7 days
    }
  }
}
```
✅ **This setup automates daily EBS snapshots** and ensures they are **deleted after 7 days** to save costs.

## **Step 2: Automating Weekly Backups to S3 (4 Weeks Retention)**
We use **AWS Backup** to move weekly backups from **EBS to S3**.

### **Terraform Configuration for Weekly S3 Backup**
```hcl
resource "aws_backup_plan" "weekly_backup_plan" {
  name = "weekly-s3-backup"

  rule {
    rule_name         = "weekly-s3-backup-rule"
    target_vault_name = aws_backup_vault.ebs_backup_vault.name
    schedule          = "cron(0 3 ? * SUN *)" # Every Sunday at 3 AM UTC
    lifecycle {
      delete_after = 28 # Retain for 4 weeks
    }
  }
}
```
✅ **This ensures that a full EC2 backup is retained weekly in S3 for up to 4 weeks.**

## **Step 3: Moving Backups to S3 Glacier for Long-Term Archival**
To save costs, we move backups to **S3 Glacier** after **30 days**.

### **Terraform Configuration for S3 Glacier Lifecycle Policy**
```hcl
resource "aws_s3_bucket" "backup_bucket" {
  bucket = "ec2-backups-bucket"
  acl    = "private"
}

resource "aws_s3_bucket_lifecycle_configuration" "backup_lifecycle" {
  bucket = aws_s3_bucket.backup_bucket.id

  rule {
    id     = "move-to-glacier"
    status = "Enabled"

    transition {
      days          = 30  # Move to Glacier after 30 days
      storage_class = "GLACIER"
    }
  }
}
```
✅ **Ensures that older backups are automatically moved to S3 Glacier for cost-efficient storage.**

## **Step 4: Restoring Backups**

### **1️⃣ Restoring EC2 from an EBS Snapshot**
```bash
aws ec2 create-volume --region us-east-1 \
    --snapshot-id snap-1234567890abcdef0 \
    --availability-zone us-east-1a
```
✅ **Restores an EC2 instance’s volume from a snapshot.**

### **2️⃣ Restoring Weekly Backup from AWS Backup Vault**
```bash
aws backup start-restore-job \
    --recovery-point-arn arn:aws:backup:us-east-1:123456789012:recovery-point:abcdef123456 \
    --metadata file://restore-metadata.json
```
✅ **Restores an entire EC2 instance from AWS Backup.**

## **Step 5: Cost Optimization Summary**
| **Backup Storage**       | **Cost Efficiency** |
|--------------------------|--------------------|
| **EBS Snapshots**        | High cost for fast recovery (retained for 7 days) |
| **S3 Backup Storage**    | Medium cost for weekly backups (4 weeks) |
| **S3 Glacier**           | Lowest cost for long-term archival (30+ days) |

## **🚀 Final Interview Answer**
### **Interviewer:** *How did you implement a backup strategy for EC2 instances?*  
✅ **Your Answer:**  
*"I designed a **three-tier backup strategy** balancing **data protection and cost optimization** for 50 EC2 instances. The strategy included:*"

- **Daily EBS snapshots** for fast recovery (**retained for 7 days**).
- **Weekly backups using AWS Backup**, stored in **S3 with a lifecycle policy**.
- **Long-term backups moved to S3 Glacier** after **30 days**, reducing storage costs.
- **Automated backups using Terraform & AWS Backup**, ensuring consistency.

*"This solution enabled fast recovery, minimized costs, and ensured compliance with business continuity requirements."*  

✅ **Now, you're fully prepared to present this backup strategy in your interview!** 🚀

