# 📌 Fixing EKS Pods Stuck in Pending Due to Insufficient Worker Nodes

## **🔹 Scenario**
A **Site Reliability Engineer (SRE)** notices that new application pods are **stuck in a `Pending` state** in an AWS EKS cluster.

---

## **🔹 Step 1: Identify the Issue**

### **1️⃣ Check Pod Status**
```bash
kubectl get pods -A
```
🔹 **Example Output:**
```
NAMESPACE     NAME                          READY   STATUS    RESTARTS   AGE
default       web-app-57cdb987cd-xyz12      0/1     Pending   0          10m
```
✅ **Pods are stuck in `Pending` for more than 10 minutes.**

---

### **2️⃣ Check Pod Events for More Details**
```bash
kubectl describe pod web-app-57cdb987cd-xyz12
```
🔹 **Example Output:**
```
Events:
  Type     Reason              Age                From               Message
  ----     ------              ----               ----               -------
  Warning  FailedScheduling    10m                default-scheduler  0/3 nodes are available: insufficient cpu, insufficient memory.
```
✅ **The error message shows that there are not enough compute resources (CPU, Memory) available.**

---

## **🔹 Step 2: Check Worker Node Capacity**

### **1️⃣ List All Nodes**
```bash
kubectl get nodes
```
🔹 **Example Output:**
```
NAME                                      STATUS   ROLES    AGE    VERSION
ip-192-168-10-100.ec2.internal   Ready    <none>   10d   v1.26.2
ip-192-168-10-101.ec2.internal   Ready    <none>   10d   v1.26.2
ip-192-168-10-102.ec2.internal   Ready    <none>   10d   v1.26.2
```
✅ **Nodes are healthy but are at full capacity.**

---

## **🔹 Step 3: Verify Auto Scaling Configuration**

### **1️⃣ Check Cluster Autoscaler Logs**
```bash
kubectl logs -f deployment/cluster-autoscaler -n kube-system
```
🔹 **Example Output:**
```
No upcoming scale-up event detected.
Cluster is at maximum node capacity.
```
✅ **Autoscaler is not increasing nodes because the maximum capacity is reached.**

---

## **🔹 Step 4: Increase ASG Capacity for Worker Nodes**

### **1️⃣ Modify the Auto Scaling Group (ASG) to Allow Scaling**
```bash
aws autoscaling update-auto-scaling-group \
  --auto-scaling-group-name my-eks-node-group \
  --min-size 3 \
  --desired-capacity 5 \
  --max-size 10
```
✅ **Now, the ASG will launch more worker nodes when needed.**

---

## **🔹 Step 5: Verify New Nodes Are Added**

### **1️⃣ Check Available Nodes Again**
```bash
kubectl get nodes
```
🔹 **Example Output:**
```
NAME                                      STATUS   ROLES    AGE    VERSION
ip-192-168-10-100.ec2.internal   Ready    <none>   10d   v1.26.2
ip-192-168-10-101.ec2.internal   Ready    <none>   10d   v1.26.2
ip-192-168-10-102.ec2.internal   Ready    <none>   10d   v1.26.2
ip-192-168-10-103.ec2.internal   Ready    <none>   1m    v1.26.2
ip-192-168-10-104.ec2.internal   Ready    <none>   1m    v1.26.2
```
✅ **New nodes are now available!**

---

## **🔹 Step 6: Verify Pods Are Running**

### **1️⃣ Check Pods Again**
```bash
kubectl get pods -A
```
🔹 **Example Output:**
```
NAMESPACE     NAME                          READY   STATUS    RESTARTS   AGE
default       web-app-57cdb987cd-xyz12      1/1     Running   0          2m
```
✅ **Pods are now running successfully on new worker nodes! 🚀**

---

## **📌 Summary of the Issue & Fix**

| **Step** | **Command Used** | **Outcome** |
|----------|----------------|-------------|
| **Check Pod Status** | `kubectl get pods -A` | Identified that pods were in `Pending`. |
| **Check Scheduling Issues** | `kubectl describe pod <pod-name>` | Found `insufficient cpu, insufficient memory`. |
| **Check Available Nodes** | `kubectl get nodes` | Nodes were at full capacity. |
| **Check Autoscaler Logs** | `kubectl logs -f deployment/cluster-autoscaler -n kube-system` | No upcoming scale-up event detected. |
| **Increase ASG Capacity** | `aws autoscaling update-auto-scaling-group` | Allowed new worker nodes to be added. |
| **Verify New Nodes** | `kubectl get nodes` | New nodes successfully added. |
| **Verify Pods Running** | `kubectl get pods -A` | Pods moved from `Pending` to `Running`. |

🚀 **Now the cluster is scaling properly, and the application is running smoothly!**
