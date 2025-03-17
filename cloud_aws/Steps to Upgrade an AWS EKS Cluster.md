# 📌 Steps to Upgrade an AWS EKS Cluster

## **🔹 Overview**
Upgrading an **Amazon EKS Cluster** ensures that your Kubernetes environment remains secure, stable, and has access to the latest features. The upgrade process involves updating the **control plane**, **worker nodes**, and **add-ons**.

---

## **🔹 Step 1: Check Current Cluster Version**
Before upgrading, check the existing cluster version.
```bash
aws eks describe-cluster --name my-cluster --query "cluster.version" --output text
```
✅ **Example Output:**
```
1.23
```
✅ **Ensure your add-ons (CNI, CoreDNS, Kube-proxy) are compatible with the next version.**

---

## **🔹 Step 2: Upgrade the EKS Control Plane**

### **1️⃣ Initiate Control Plane Upgrade**
```bash
aws eks update-cluster-version --name my-cluster --kubernetes-version 1.24
```
✅ **AWS will upgrade the control plane automatically.** This process can take **10-30 minutes**.

### **2️⃣ Monitor Upgrade Progress**
```bash
aws eks describe-cluster --name my-cluster --query "cluster.status" --output text
```
✅ **The status should change from `UPDATING` → `ACTIVE`.**

---

## **🔹 Step 3: Upgrade Managed Node Groups** (if applicable)

### **1️⃣ List Current Node Groups**
```bash
aws eks list-nodegroups --cluster-name my-cluster
```
✅ **Example Output:**
```
[ "worker-node-group-1" ]
```

### **2️⃣ Upgrade Node Group**
```bash
aws eks update-nodegroup-version --cluster-name my-cluster --nodegroup-name worker-node-group-1
```
✅ **AWS will replace old worker nodes with new ones automatically.**

### **3️⃣ Verify New Nodes Are Ready**
```bash
kubectl get nodes
```
✅ **Ensure all nodes are in `Ready` state.**

---

## **🔹 Step 4: Upgrade Self-Managed Worker Nodes** (if applicable)
If you use self-managed EC2 worker nodes, follow these steps:

### **1️⃣ Upgrade the AMI**
Get the latest Amazon EKS-optimized AMI:
```bash
aws ssm get-parameters --names /aws/service/eks/optimized-ami/1.24/amazon-linux-2/recommended/image_id --query "Parameters[0].Value"
```

### **2️⃣ Update the Auto Scaling Group (ASG)**
```bash
aws autoscaling update-auto-scaling-group --auto-scaling-group-name my-asg --launch-template "LaunchTemplateName=my-template,Version=2"
```
✅ **New nodes will be added with the upgraded version.**

### **3️⃣ Drain Old Nodes and Terminate**
```bash
kubectl drain <old-node-name> --ignore-daemonsets --delete-emptydir-data
kubectl delete node <old-node-name>
```
✅ **Ensures workloads are safely moved to new nodes before removal.**

---

## **🔹 Step 5: Upgrade Add-ons (CNI, CoreDNS, Kube-Proxy)**

### **1️⃣ Upgrade AWS VPC CNI**
```bash
kubectl set image daemonset aws-node -n kube-system aws-node=602401143452.dkr.ecr.us-east-1.amazonaws.com/amazon-k8s-cni:v1.12.2
```
✅ **Ensures networking remains compatible with the new Kubernetes version.**

### **2️⃣ Upgrade CoreDNS**
```bash
kubectl set image deployment coredns -n kube-system coredns=coredns/coredns:1.9.4
```
✅ **Keeps DNS resolution functional inside the cluster.**

### **3️⃣ Upgrade Kube-Proxy**
```bash
kubectl set image daemonset kube-proxy -n kube-system kube-proxy=602401143452.dkr.ecr.us-east-1.amazonaws.com/eks/kube-proxy:v1.24.0
```
✅ **Maintains compatibility between worker nodes and the control plane.**

---

## **🔹 Step 6: Validate the Upgrade**
### **1️⃣ Ensure All Components Are Healthy**
```bash
kubectl get nodes
kubectl get pods -n kube-system
```
✅ **All nodes should be in `Ready` state and system pods should be `Running`.**

### **2️⃣ Test Application Workloads**
```bash
kubectl get all -A
```
✅ **Ensure no applications are stuck in `Pending` or `CrashLoopBackOff`.**

### **3️⃣ Check Logs for Any Errors**
```bash
kubectl logs -l app=my-app
```
✅ **Fix any issues if necessary before marking the upgrade complete.**

---

## **🚀 Summary of EKS Upgrade Steps**
| **Step** | **Action** |
|---------|-----------|
| **1️⃣ Check Cluster Version** | Ensure compatibility with the next Kubernetes version. |
| **2️⃣ Upgrade Control Plane** | Upgrade EKS control plane to the latest version. |
| **3️⃣ Upgrade Worker Nodes** | Upgrade managed node groups or manually update EC2 instances. |
| **4️⃣ Upgrade Self-Managed Nodes** | Update the AMI, drain old nodes, and launch new ones. |
| **5️⃣ Upgrade Add-ons** | Update AWS VPC CNI, CoreDNS, and Kube-Proxy. |
| **6️⃣ Validate the Upgrade** | Ensure nodes are healthy, applications are running, and logs show no errors. |

✅ **Following these steps ensures a smooth EKS cluster upgrade with minimal downtime!** 🚀