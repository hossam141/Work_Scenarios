# 📌 AWS S3 Reference Guide for SRE Engineers

## **🔹 Overview of Amazon S3**
Amazon **Simple Storage Service (S3)** is an object storage service that provides **scalability, security, durability, and availability**. It is widely used for storing and retrieving any amount of data, making it ideal for backup, logging, data lakes, and web hosting.

---

## **🔹 Key Features of S3**
| **Feature**               | **Description** |
|---------------------------|----------------|
| **Unlimited Storage**     | Stores unlimited objects (each up to **5TB**). |
| **High Durability**       | 99.999999999% (11 9’s) durability, data stored across multiple AZs. |
| **Security**              | Supports IAM policies, bucket policies, encryption, and MFA delete. |
| **Versioning**            | Keeps multiple versions of an object to protect against accidental deletions. |
| **Lifecycle Policies**    | Moves data to **cheaper storage tiers** (S3 Glacier, IA). |
| **Cross-Region Replication (CRR)** | Replicates objects to another AWS region for **disaster recovery**. |
| **Event Notifications**   | Triggers **SNS, SQS, Lambda** when objects are created or deleted. |
| **Data Encryption**       | Supports **SSE-S3, SSE-KMS, SSE-C, and client-side encryption**. |
| **Object Lock & Compliance** | Protects objects from being modified or deleted for a retention period. |

---

## **🔹 S3 Storage Classes**
| **Storage Class**       | **Use Case** |
|-------------------------|-------------|
| **S3 Standard**         | Frequent access, low-latency, high-performance (default). |
| **S3 Intelligent-Tiering** | Auto-moves objects between storage tiers based on access patterns. |
| **S3 Standard-IA**      | Infrequent access but needs fast retrieval (e.g., backups). |
| **S3 One Zone-IA**      | Lower-cost IA storage in a single AZ (not multi-AZ redundant). |
| **S3 Glacier**          | Long-term archival, retrieval in minutes to hours. |
| **S3 Glacier Deep Archive** | Lowest-cost storage, retrieval in 12+ hours. |

---

## **🔹 Security Best Practices for S3**
1️⃣ **Enable Bucket Policies & IAM Policies**
   ```json
   {
     "Version": "2012-10-17",
     "Statement": [
       {
         "Effect": "Deny",
         "Principal": "*",
         "Action": "s3:*",
         "Resource": "arn:aws:s3:::sensitive-bucket/*",
         "Condition": {
           "Bool": {"aws:SecureTransport": "false"}
         }
       }
     ]
   }
   ```
   ✅ **Forces HTTPS-only access to prevent unencrypted data transfers.**

2️⃣ **Enable S3 Bucket Encryption** (Using AWS KMS)
   ```bash
   aws s3api put-bucket-encryption --bucket my-secure-bucket --server-side-encryption-configuration '{"Rules": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "aws:kms"}}]}'
   ```
   ✅ **Ensures all stored objects are encrypted.**

3️⃣ **Enable MFA Delete to Prevent Accidental Deletions**
   ```bash
   aws s3api put-bucket-versioning --bucket my-secure-bucket --versioning-configuration Status=Enabled,MFADelete=Enabled --mfa "SERIAL_NUMBER MFA_CODE"
   ```
   ✅ **Prevents accidental deletion by requiring MFA for delete operations.**

4️⃣ **Use VPC Endpoints for Secure Private Access**
   ```bash
   aws ec2 create-vpc-endpoint --vpc-id vpc-12345 --service-name com.amazonaws.us-east-1.s3 --route-table-ids rtb-67890
   ```
   ✅ **Keeps S3 traffic inside AWS without going over the public internet.**

---

## **🔹 Performance Optimization Tips**
✅ **Use Multipart Uploads for Large Files** (Recommended for files > 100MB)
```bash
aws s3 cp large-file.zip s3://my-bucket/ --storage-class STANDARD --multipart-chunk-size 10MB
```
✅ **Enable Transfer Acceleration for Faster Uploads**
```bash
aws s3api put-bucket-accelerate-configuration --bucket my-bucket --accelerate-configuration Status=Enabled
```
✅ **Use S3 Select to Query Data Without Downloading the Full Object**
```sql
SELECT s.name, s.price FROM S3Object s WHERE s.category = 'electronics';
```
✅ **Enable Object Expiry with Lifecycle Rules** (Example: Auto-delete old logs)
```json
{
  "Rules": [
    {
      "ID": "DeleteOldLogs",
      "Prefix": "logs/",
      "Status": "Enabled",
      "Expiration": {"Days": 30}
    }
  ]
}
```

---

## **🔹 S3 Event-Driven Architecture**
Amazon S3 can trigger events when objects are created, deleted, or modified.

✅ **Example: Auto-processing New Files with AWS Lambda**
```json
{
  "LambdaFunctionConfigurations": [
    {
      "Id": "ProcessNewUploads",
      "LambdaFunctionArn": "arn:aws:lambda:us-east-1:123456789012:function:process-files",
      "Events": ["s3:ObjectCreated:*"]
    }
  ]
}
```
✅ **Example: Notify Teams When an Object is Deleted** (Using SNS)
```bash
aws s3api put-bucket-notification-configuration --bucket my-bucket --notification-configuration '{"TopicConfigurations": [{"TopicArn": "arn:aws:sns:us-east-1:123456789012:NotifyTeam", "Events": ["s3:ObjectRemoved:*"]}]}'
```

---

## **🚀 S3 CLI Commands for Quick Reference**
| **Command** | **Description** |
|------------|----------------|
| `aws s3 ls s3://my-bucket/` | List objects in a bucket. |
| `aws s3 cp file.txt s3://my-bucket/` | Upload a file to S3. |
| `aws s3 sync /local/path s3://my-bucket/` | Sync local folder to S3. |
| `aws s3 rm s3://my-bucket/file.txt` | Delete a file from S3. |
| `aws s3 presign s3://my-bucket/file.txt --expires-in 300` | Generate a temporary pre-signed URL. |

---

## **🚀 Summary for SRE Engineers**
| **Aspect** | **Best Practice** |
|-----------|------------------|
| **Security** | Use encryption, IAM roles, bucket policies, and VPC endpoints. |
| **Cost Optimization** | Use **S3 Lifecycle Rules** to move objects to **Glacier** for long-term storage. |
| **High Performance** | Enable **Transfer Acceleration**, use **Multipart Uploads**, and **S3 Select**. |
| **Reliability** | Enable **Versioning & Replication** to prevent data loss. |
| **Automation** | Use **Event Notifications** to trigger **Lambda, SNS, or SQS**. |

✅ **With these best practices, an SRE engineer can efficiently manage and optimize S3 storage while ensuring security, reliability, and cost-efficiency.** 🚀
