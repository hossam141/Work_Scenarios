# 📌 Datadog Integration with AWS Account & EKS Cluster

## **🔹 1️⃣ Integrating Datadog with AWS Account**
To monitor AWS services in **Datadog**, you need to set up **IAM roles & permissions** for Datadog to pull metrics.

### ✅ **Step 1: Create an IAM Role for Datadog in AWS**
1. **Go to AWS Console** → IAM → Roles → **Create role**.
2. Select **AWS Service** → Choose **Another AWS Account**.
3. **Enter Datadog AWS Account ID** (found in Datadog integrations).
4. **Attach the AWS Managed Policy**:
   ```bash
   arn:aws:iam::aws:policy/ReadOnlyAccess
   ```
5. **Add Inline Policy for Security Metrics** (CloudTrail, VPC Flow Logs, etc.):
   ```json
   {
     "Version": "2012-10-17",
     "Statement": [
       {
         "Effect": "Allow",
         "Action": ["cloudtrail:LookupEvents", "ec2:DescribeInstances"],
         "Resource": "*"
       }
     ]
   }
   ```
6. **Save & Copy the Role ARN**.

### ✅ **Step 2: Connect AWS Account to Datadog**
1. **Go to Datadog → Integrations → AWS**.
2. Click **Configure AWS Integration**.
3. Paste the **IAM Role ARN** created in Step 1.
4. Select the **AWS services to monitor** (e.g., EC2, RDS, Lambda, etc.).
5. Click **Install Integration**.
✅ Datadog now starts monitoring AWS services!

---

## **🔹 2️⃣ Integrating Datadog with EKS Cluster**
To monitor **EKS workloads**, install the **Datadog Agent** inside the cluster.

### ✅ **Step 1: Create an IAM Role for Datadog Agent in EKS**
1. **Enable IAM OIDC Provider for EKS**:
   ```bash
   eksctl utils associate-iam-oidc-provider --region us-east-1 --cluster my-cluster --approve
   ```
2. **Create IAM Policy for Datadog Agent**:
   ```bash
   aws iam create-policy --policy-name DatadogEKSAgentPolicy --policy-document file://datadog-policy.json
   ```
3. **Create IAM Service Account for Datadog Agent**:
   ```bash
   eksctl create iamserviceaccount \
     --name datadog-agent \
     --namespace kube-system \
     --cluster my-cluster \
     --attach-policy-arn arn:aws:iam::aws:policy/DatadogEKSAgentPolicy \
     --approve
   ```
✅ This grants Datadog permissions to monitor EKS cluster resources.

---

### ✅ **Step 2: Install the Datadog Agent in EKS**
**Using Helm:**
```bash
helm repo add datadog https://helm.datadoghq.com
helm repo update
helm install datadog-agent datadog/datadog \
  --set datadog.apiKey=<DATADOG_API_KEY> \
  --set clusterAgent.enabled=true \
  --set kubelet.serviceAccount.name=datadog-agent
```
✅ The **Datadog Agent is now running in the EKS cluster!**

---

### ✅ **Step 3: Verify Datadog Agent Installation**
1. **Check if the agent pods are running:**
   ```bash
   kubectl get pods -n kube-system | grep datadog
   ```
2. **Check logs for errors:**
   ```bash
   kubectl logs -n kube-system -l app.kubernetes.io/name=datadog-agent
   ```
✅ If the agent is running successfully, **metrics from EKS will appear in Datadog**.

---

## **🚀 Summary: AWS & EKS Integration with Datadog**
| **Integration** | **Steps** |
|---------------|---------|
| **AWS Account Integration** | Create an **IAM Role**, attach Datadog permissions, and link AWS to Datadog. |
| **EKS Cluster Integration** | Create **IAM Service Account**, install Datadog Agent using Helm. |
| **Verify Installation** | Check **Datadog Agent logs & metrics** in Datadog UI. |

✅ With these steps, Datadog can monitor both **AWS services and EKS workloads**, providing deep observability into infrastructure health! 🚀
