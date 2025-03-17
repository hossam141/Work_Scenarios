# 📌 Deploying Elasticsearch as a Stateful Application in AWS EKS with EBS Storage

## **🔹 Overview**
When deploying **Elasticsearch in EKS**, we need to:
1️⃣ **Authorize EKS to manage EBS volumes** (IAM authentication & CSI driver setup).  
2️⃣ **Provision and manage persistent storage** (StatefulSets, PVCs, and StorageClasses).  

This guide ensures **EKS and EBS** are properly integrated to persist Elasticsearch data across node failures.

---

# **1️⃣ Ensuring AWS EKS and EBS Are Authorized & Authenticated**

Before provisioning storage, EKS must have permissions to create, attach, and manage **EBS volumes**.

## **🔹 Step 1: Create an IAM Role for EKS Nodes**
### **1️⃣ Create IAM Role for Worker Nodes**
```bash
aws iam create-role --role-name AmazonEKSWorkerNodeRole \
  --assume-role-policy-document file://eks-trust-policy.json
```
✅ **This allows EC2 instances (EKS nodes) to assume the required IAM role.**

### **2️⃣ Attach IAM Policies to Allow EBS Access**
```bash
aws iam attach-role-policy --role-name AmazonEKSWorkerNodeRole \
  --policy-arn arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy

aws iam attach-role-policy --role-name AmazonEKSWorkerNodeRole \
  --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy
```
✅ **Grants EKS permissions to provision and attach EBS volumes.**

---

## **🔹 Step 2: Enable the AWS EBS CSI Driver in EKS**

### **1️⃣ Associate the IAM OIDC Provider with EKS**
```bash
eksctl utils associate-iam-oidc-provider --cluster my-cluster --approve
```
✅ **Allows Kubernetes to assume IAM roles for managing EBS storage.**

### **2️⃣ Create IAM Role for EBS CSI Driver**
```bash
eksctl create iamserviceaccount \
  --name ebs-csi-controller-sa \
  --namespace kube-system \
  --cluster my-cluster \
  --attach-policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy \
  --approve \
  --role-only \
  --role-name AmazonEKS_EBS_CSI_DriverRole
```
✅ **Allows Kubernetes to create and attach EBS storage dynamically.**

### **3️⃣ Deploy the EBS CSI Driver in Kubernetes**
```bash
kubectl apply -k "github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable/ecr/?ref=release-1.19"
```
✅ **Now, EKS is fully authorized to manage EBS volumes.**

---

# **2️⃣ Managing Storage for Elasticsearch in EKS**

Now that **EKS and EBS are authorized**, we can deploy **Elasticsearch as a StatefulSet** with persistent storage.

## **🔹 Step 3: Define a StorageClass for AWS EBS**
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: gp2
provisioner: kubernetes.io/aws-ebs
parameters:
  type: gp2
  fsType: ext4
reclaimPolicy: Retain
```
✅ **Dynamically provisions EBS volumes for Elasticsearch.**

---

## **🔹 Step 4: Create a Persistent Volume Claim (PVC) for Elasticsearch**
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: elasticsearch-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 50Gi
  storageClassName: gp2
```
✅ **Each Elasticsearch pod gets its own EBS-backed persistent volume.**

---

## **🔹 Step 5: Deploy Elasticsearch as a StatefulSet**
```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: elasticsearch
spec:
  serviceName: elasticsearch
  replicas: 3
  selector:
    matchLabels:
      app: elasticsearch
  template:
    metadata:
      labels:
        app: elasticsearch
    spec:
      containers:
      - name: elasticsearch
        image: docker.elastic.co/elasticsearch/elasticsearch:7.10.2
        ports:
        - containerPort: 9200
        volumeMounts:
        - name: data
          mountPath: /usr/share/elasticsearch/data
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: [ "ReadWriteOnce" ]
      storageClassName: gp2
      resources:
        requests:
          storage: 50Gi
```
✅ **Ensures persistent storage for each Elasticsearch pod.**

---

## **🔹 Step 6: Verify EBS Volumes Are Attached**
### **1️⃣ Check Persistent Volume Claims (PVCs)**
```bash
kubectl get pvc
```
✅ **Each Elasticsearch pod should have its own PVC.**

### **2️⃣ Check Persistent Volumes (PVs)**
```bash
kubectl get pv
```
✅ **Each PV should be bound to a corresponding PVC.**

### **3️⃣ Verify Elasticsearch Pods Are Running**
```bash
kubectl get pods -l app=elasticsearch
```
✅ **Pods should be `Running` with storage properly attached.**

---

## **🔹 Step 7: Scaling & Expanding Storage**
### **1️⃣ Scale Elasticsearch StatefulSet**
```bash
kubectl scale statefulset elasticsearch --replicas=5
```
✅ **New Elasticsearch nodes will automatically receive EBS storage.**

### **2️⃣ Expand Storage Capacity**
```bash
kubectl edit pvc elasticsearch-pvc
```
✅ **Modify `storage: 50Gi` to a larger value, then restart pods.**

---

## **🚀 Summary**

### **🔹 Part 1: Ensuring EKS and EBS Authorization**
| **Step** | **Action** |
|----------|-----------|
| **1️⃣ Create IAM Role for EKS Nodes** | Grants permission to manage EBS. |
| **2️⃣ Attach IAM Policies** | Ensures nodes can provision and attach volumes. |
| **3️⃣ Enable IAM OIDC Provider** | Allows Kubernetes to assume IAM roles. |
| **4️⃣ Create IAM Role for EBS CSI Driver** | Enables Kubernetes to manage EBS storage. |
| **5️⃣ Deploy EBS CSI Driver** | Installs the driver inside the EKS cluster. |

### **🔹 Part 2: Managing Storage for Elasticsearch**
| **Step** | **Action** |
|----------|-----------|
| **6️⃣ Define StorageClass** | Provisions EBS-backed volumes dynamically. |
| **7️⃣ Create PVCs** | Ensures each pod gets persistent storage. |
| **8️⃣ Deploy StatefulSet** | Ensures stable storage and networking. |
| **9️⃣ Verify Storage Binding** | Check PVC and PV associations. |
| **🔟 Scale & Expand Storage** | Scale pods and increase storage size dynamically. |

✅ **Now, Elasticsearch in EKS is fully stateful and persists data across pod restarts!** 🚀
