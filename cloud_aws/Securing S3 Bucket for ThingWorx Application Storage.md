# 🛡️ Securing S3 Bucket for ThingWorx Application Storage

## **🔧 Business Requirement**
Your company hosts a **ThingWorx web application** running on **Tomcat**. All necessary files, including **JARs, images, extensions, and configuration files**, are stored in an **S3 bucket** to be used during the **CloudFormation-based deployment**.

To ensure security, we need to:
- **Restrict access** to only authorized users and applications.
- **Encrypt files** to prevent unauthorized reading.
- **Prevent accidental or malicious deletions.**
- **Implement logging and monitoring** for access tracking.

---

## **🔄 Step 1: Create a Secure S3 Bucket**
1. Go to **AWS Console** → **S3** → Click **Create bucket**.
2. Set **Bucket Name**: `thingworx-app-storage`.
3. **Block Public Access**: Ensure **all public access is blocked**.
4. Click **Create bucket**.

✅ **Now, the bucket exists but needs security configurations.**

---

## **🔒 Step 2: Restrict Access Using S3 Bucket Policy**
We will allow access only to:
- **ThingWorx Application IAM Role** (used by EC2/Tomcat)
- **Authorized developers and CI/CD pipelines**

1. Go to **AWS Console** → **S3** → Select `thingworx-app-storage`.
2. Click **Permissions** → **Bucket Policy**.
3. Add the following policy:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::123456789012:role/ThingWorx-App-Role"
      },
      "Action": ["s3:GetObject", "s3:ListBucket"],
      "Resource": [
        "arn:aws:s3:::thingworx-app-storage",
        "arn:aws:s3:::thingworx-app-storage/*"
      ]
    },
    {
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:*",
      "Resource": "arn:aws:s3:::thingworx-app-storage/*",
      "Condition": {
        "Bool": {"aws:SecureTransport": "false"}
      }
    }
  ]
}
```

✅ **What This Does:**
- **Allows only the ThingWorx IAM role** to access the bucket.
- **Denies all access if requests are not using HTTPS** (secure transport enforced).

---

## **🛡️ Step 3: Enable Encryption for Stored Files**
To protect files at rest, we enable **AES-256 server-side encryption (SSE-S3) or AWS KMS**.

1. Go to **AWS Console** → **S3** → Select `thingworx-app-storage`.
2. Click **Properties** → **Default Encryption**.
3. Choose **AES-256 (SSE-S3)** or **AWS KMS (recommended for extra security)**.
4. Click **Save changes**.

✅ **Now, all files stored in the bucket are encrypted automatically.**

---

## **🔨 Step 4: Prevent Accidental or Malicious Deletions**
### **Enable MFA Delete**
1. Go to **AWS Console** → **S3** → Select `thingworx-app-storage`.
2. Click **Permissions** → **Bucket Policy**.
3. Add the following:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:DeleteObject",
      "Resource": "arn:aws:s3:::thingworx-app-storage/*",
      "Condition": {
        "BoolIfExists": { "aws:MultiFactorAuthPresent": "false" }
      }
    }
  ]
}
```

✅ **This prevents file deletions unless MFA (Multi-Factor Authentication) is enabled.**

---

## **📝 Step 5: Enable Logging & Monitoring**
To track access and detect unauthorized attempts, we enable **CloudTrail logging and S3 Access Logs**.

### **Enable CloudTrail for S3 Bucket Access Logs**
1. Go to **AWS Console** → **CloudTrail**.
2. Click **Create trail**.
3. Set **Trail name**: `thingworx-s3-access-trail`.
4. Select **Management events** and **Read/Write events: Read & Write**.
5. Under **Storage Location**, choose **S3 bucket for CloudTrail logs**.
6. Click **Create**.

### **Enable S3 Access Logging**
1. Go to **AWS Console** → **S3** → Select `thingworx-app-storage`.
2. Click **Properties** → **Server access logging**.
3. Choose a **different S3 bucket** to store logs (e.g., `s3-logs-bucket`).
4. Click **Save changes**.

✅ **Now, all access to the ThingWorx S3 bucket is logged.**

---

## **🚀 Final Summary of Security Controls**
| **Security Feature**             | **Purpose** |
|----------------------------------|-------------|
| **S3 Bucket Policy**             | Restricts access to only ThingWorx IAM Role |
| **Encryption (AES-256 or KMS)**   | Encrypts all files at rest |
| **MFA Delete**                    | Prevents unauthorized deletions |
| **HTTPS-Only Access**             | Ensures secure transport of files |
| **CloudTrail & S3 Access Logs**   | Tracks all access and modifications |

✅ **With these controls, your ThingWorx application files are highly secure!** 🚀
