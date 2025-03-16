# 🛠 EC2 Backup Storage Strategy (AWS Console Setup)

## **🔧 Business Problem**
Your company manages **50 EC2 instances** running critical workloads. However, there is **no structured backup plan**, leading to potential data loss in case of:
- Accidental deletions
- Instance or volume failures
- Cyberattacks or ransomware incidents

To mitigate risks, we implement a **three-tier backup storage strategy** that balances **data protection and cost optimization**.

## **🔄 Backup Strategy Overview**
| **Backup Tier**           | **Method**                     | **Retention** | **Storage Tier** |
|---------------------------|--------------------------------|--------------|-----------------|
| **Daily Backups**         | EBS Snapshots (Automated)      | 7 Days       | Amazon EBS      |
| **Weekly Backups**        | AWS Backup (EBS → S3)         | 4 Weeks      | Amazon S3       |
| **Long-Term Backups**     | S3 Glacier Archival           | 30+ Days     | Amazon S3 Glacier |

---

## **🔄 Step 1: Creating an S3 Bucket for Weekly Backups (AWS Console)**

1. Go to **AWS Console** → **S3** → **Create bucket**.
2. Enter a **Bucket name**: `ec2-weekly-backups-bucket`.
3. Choose **Block Public Access settings** ➜ **Keep default settings (highly recommended).**
4. Click **Create bucket**.

✅ **Now, AWS Backup has a dedicated S3 storage location.**

---

## **🔄 Step 2: Automating Daily EBS Snapshots (7-Day Retention) via AWS Backup**

1. Go to **AWS Console** → **AWS Backup**.
2. Navigate to **Backup plans** → **Create backup plan**.
3. Choose **Build a new plan** and set:
   - **Backup plan name**: `daily-ebs-backup`
   - **Backup rule name**: `daily-ebs-backup-rule`
   - **Backup frequency**: Daily
   - **Backup window**: Default (2 AM UTC recommended)
   - **Lifecycle**: Delete after **7 days**
4. Click **Create plan**.
5. Under **Resource Assignments**, select **EBS volumes** associated with your EC2 instances.

✅ **This setup automates daily EBS snapshots and ensures they are deleted after 7 days to save costs.**

---

## **🔄 Step 3: Automating Weekly Backups to S3 (4 Weeks Retention)**

1. Go to **AWS Console** → **AWS Backup**.
2. Navigate to **Backup plans** → **Create backup plan**.
3. Enter **Backup plan name**: `weekly-s3-backup`.
4. Under **Backup Rule**, set:
   - **Backup frequency**: Weekly (Every Sunday at 3 AM UTC)
   - **Lifecycle**: Delete after **4 weeks**
   - **Backup vault**: **Create a new vault (`s3-backup-vault`)**
5. Click **Create plan**.
6. Under **Resource Assignments**, select **EBS volumes**.
7. Go to **AWS Backup → Settings** and enable **S3 backup storage**.

✅ **Now, weekly backups are explicitly stored in the S3 bucket (`ec2-weekly-backups-bucket`).**

---

## **🔄 Step 4: Moving Backups to S3 Glacier for Long-Term Archival**

1. Go to **AWS Console** → **S3**.
2. Click on your **backup bucket (`ec2-weekly-backups-bucket`)**.
3. Navigate to **Management** → **Lifecycle rules** → **Create rule**.
4. Enter **Rule name**: `move-to-glacier`.
5. Choose **Apply to all objects in bucket**.
6. Under **Transitions**, set:
   - Move to **Glacier** after **30 days**.
7. Click **Create rule**.

✅ **Ensures that older backups are automatically moved to S3 Glacier for cost-efficient storage.**

---

## **🔄 Step 5: Restoring Backups (AWS Console)**

### **1️⃣ Restoring EC2 from an EBS Snapshot**
1. Go to **AWS Console** → **EC2** → **Snapshots**.
2. Select the **snapshot you want to restore**.
3. Click **Actions** ➜ **Create volume from snapshot**.
4. Choose the **Availability Zone** where the EC2 instance is running.
5. Click **Create volume**.
6. Attach the volume to the required EC2 instance.

✅ **Restores an EC2 instance’s volume from a snapshot.**

### **2️⃣ Restoring Weekly Backup from AWS Backup Vault**
1. Go to **AWS Console** → **AWS Backup** → **Backup vaults**.
2. Select `s3-backup-vault`.
3. Locate the required backup recovery point.
4. Click **Actions** ➜ **Restore backup**.
5. Follow the wizard to restore the backup to an EC2 instance.

✅ **Restores an entire EC2 instance from AWS Backup.**

---

## **🔄 Step 6: Cost Optimization Summary**
| **Backup Storage**       | **Cost Efficiency** |
|--------------------------|--------------------|
| **EBS Snapshots**        | High cost for fast recovery (retained for 7 days) |
| **S3 Backup Storage**    | Medium cost for weekly backups (4 weeks) |
| **S3 Glacier**           | Lowest cost for long-term archival (30+ days) |

---

## **🚀 Final Interview Answer**

### **Interviewer:** *Where are the weekly backups stored?*  
✅ **Your Answer:**  
*"By default, AWS Backup stores data in an AWS Backup Vault, but to explicitly send backups to **Amazon S3**, I created a dedicated **S3 bucket (`ec2-weekly-backups-bucket`)** and configured AWS Backup to store backups there. Additionally, I set up an **S3 Lifecycle Policy** to move backups to **S3 Glacier after 30 days** for cost savings."*  

### **Interviewer:** *What is AWS Backup Vault and how does it store data?*  
✅ **Your Answer:**  
*"AWS Backup Vault is a **logical storage container** in AWS Backup that stores **backup recovery points**. It does not store raw data but instead references actual backups stored in AWS services like **EBS, S3, RDS, and DynamoDB**."*  

*"For example, when an **EC2 instance is backed up**, AWS Backup Vault **stores a recovery point**, and the actual snapshot is saved in **Amazon EBS Snapshots**. This allows for centralized backup management with features like **encryption, retention policies, and cross-region replication**."*  

✅ **Now, you're fully prepared to present this backup strategy in your interview!** 🚀
