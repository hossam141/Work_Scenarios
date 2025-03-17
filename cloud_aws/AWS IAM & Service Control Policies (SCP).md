# 📌 AWS IAM & Service Control Policies (SCP) Reference Guide

## **🔹 Overview of AWS IAM**
AWS **Identity and Access Management (IAM)** is used to **securely control access** to AWS resources by managing **users, groups, roles, and policies**.

---

## **🔹 Key IAM Components**
| **IAM Component** | **Purpose** |
|-------------------|------------|
| **IAM User** | A specific AWS identity for an individual with access credentials. |
| **IAM Group** | A collection of IAM users sharing the same permissions. |
| **IAM Role** | An identity assumed by AWS services or external entities for temporary access. |
| **IAM Policy** | A document that defines allowed or denied actions on AWS resources. |

### **🔗 Mapping Between IAM Users, Groups, Roles, and Policies**
| IAM Component | Purpose | How Policies are Attached |
|--------------|---------|-------------------------|
| **User** | A person with AWS credentials (Access Key/Password) | Attached directly or via a group |
| **Group** | A collection of users with the same permissions | Policies attached to the group, affecting all users in it |
| **Role** | Used by AWS services or other accounts to assume permissions temporarily | Policies attached directly to roles |
| **Policy** | Defines what actions are allowed or denied on AWS resources | Attached to users, groups, or roles |

---

## **🔹 Understanding IAM Policies**
IAM policies are **JSON-based** documents that define what actions are **allowed or denied** on AWS resources.

### **📝 Example IAM Policy**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeInstances",
        "s3:ListBucket"
      ],
      "Resource": "*"
    }
  ]
}
```
✅ **What This Policy Does:**
- Allows **listing EC2 instances** (`ec2:DescribeInstances`).
- Allows **listing S3 buckets** (`s3:ListBucket`).
- Applies to **all AWS resources** (`"Resource": "*"`).

---

## **🔹 AWS Service Control Policies (SCPs)**
### **📌 What is an SCP?**
- **Service Control Policies (SCPs)** are applied at the **AWS Organization level** to enforce global restrictions.
- Unlike IAM policies, **SCPs do not grant permissions** but **restrict or allow permissions** for AWS accounts.
- SCPs affect **all IAM identities** (users, roles, groups) within the **AWS Organization or Organizational Unit (OU)**.

### **📌 SCP vs IAM Policy**
| Feature | IAM Policy | SCP |
|---------|-----------|-----|
| **Grants permissions?** | ✅ Yes | ❌ No (Only restricts) |
| **Attached to** | Users, Groups, Roles | AWS Accounts or Organizational Units (OUs) |
| **Overrides IAM policies?** | ❌ No | ✅ Yes (IAM permission allowed but SCP denied = action is blocked) |
| **Affects Root User?** | ❌ No | ✅ Yes (Root cannot override SCP) |

---

## **🔹 Example SCPs for Common Use Cases**

### **📝 SCP to Deny IAM Users from Disabling CloudTrail** (For Security Compliance)
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Deny",
      "Action": "cloudtrail:StopLogging",
      "Resource": "*"
    }
  ]
}
```
✅ **Prevents all AWS accounts in the organization from disabling CloudTrail logging.**

### **📝 SCP to Restrict AWS Region Usage**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Deny",
      "Action": "*",
      "Resource": "*",
      "Condition": {
        "StringNotEquals": {
          "aws:RequestedRegion": ["us-east-1", "us-west-2"]
        }
      }
    }
  ]
}
```
✅ **Blocks resource creation outside `us-east-1` and `us-west-2`.**

### **📝 SCP to Prevent Public S3 Buckets**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Deny",
      "Action": "s3:PutBucketAcl",
      "Resource": "*",
      "Condition": {
        "StringEquals": {"s3:x-amz-acl": "public-read"}
      }
    }
  ]
}
```
✅ **Prevents accounts from making S3 buckets publicly accessible.**

---

## **🔹 Managing IAM and SCPs Effectively**
✅ **Best Practices for IAM**
- **Follow the Principle of Least Privilege** → Grant only required permissions.
- **Use IAM Roles Instead of Long-Lived Access Keys** → More secure for AWS services.
- **Enable MFA for All Users** → Adds an extra layer of security.
- **Rotate IAM Access Keys Regularly** → Reduces security risks.
- **Use IAM Conditions for Granular Access** → Restrict permissions based on IP, time, and resource.

✅ **Best Practices for SCPs**
- **Apply SCPs at the Organizational Unit (OU) Level** → Ensures proper restriction hierarchy.
- **Use Deny Statements to Enforce Compliance** → Prevent security misconfigurations.
- **Regularly Review and Test SCPs** → Avoid blocking essential operations.
- **Combine SCPs with IAM for Enhanced Security** → SCPs restrict, IAM policies grant permissions.

---

## **🚀 Summary for SRE Engineers**
| **Aspect** | **Best Practice** |
|-----------|------------------|
| **IAM Users & Groups** | Assign least privilege access using groups. |
| **IAM Roles** | Use for AWS services and temporary access. |
| **IAM Policies** | Define **fine-grained** permissions for users and roles. |
| **SCPs** | Restrict AWS account-level permissions in AWS Organizations. |
| **Security Best Practices** | Enable MFA, rotate access keys, and avoid root user access. |

✅ **With IAM and SCP best practices, an SRE engineer can enforce strong access control, improve security posture, and ensure AWS compliance.** 🚀
