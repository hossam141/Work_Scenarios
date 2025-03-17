# 📌 AWS EKS Reference Guide for SRE Engineers

## **🔹 Overview of Amazon EKS**
Amazon **Elastic Kubernetes Service (EKS)** is a **managed Kubernetes service** that enables running containerized applications on AWS without needing to manually operate the control plane or worker nodes.

---

## **🔹 Key Components of EKS**
| **Component** | **Description** |
|--------------|----------------|
| **Control Plane** | Managed by AWS, responsible for Kubernetes API and scheduling. |
| **Worker Nodes** | EC2 instances or Fargate nodes that run application pods. |
| **Cluster Autoscaler** | Adjusts the number of worker nodes based on demand. |
| **VPC & Networking** | Uses AWS VPC CNI for networking and security groups for traffic control. |
| **IAM Integration** | IAM roles control access to EKS API and workloads. |
| **Storage** | Uses EBS for persistent storage, EFS for shared storage. |
| **Logging & Monitoring** | Integrated with CloudWatch, Prometheus, and Datadog. |

---

## **🔹 How EKS Works**
1️⃣ **Create an EKS Cluster** → Control plane is provisioned by AWS.
2️⃣ **Attach Worker Nodes** → Use **EC2 instances** or **AWS Fargate** for running workloads.
3️⃣ **Deploy Applications** → Use **kubectl** to deploy applications via **Helm or Kubernetes manifests**.
4️⃣ **Manage Scaling** → Use **Cluster Autoscaler** or **Karpenter** to optimize node utilization.
5️⃣ **Monitor & Secure** → Use **CloudWatch, Prometheus, IAM roles, and Network Policies**.

---

## **🔹 EKS Deployment Strategies for SREs**
| **Strategy** | **Use Case** |
|-------------|-------------|
| **Rolling Updates** | Minimize downtime by gradually updating pods. |
| **Blue/Green Deployment** | Deploy a new version while keeping the old version live. |
| **Canary Deployment** | Test a small percentage of traffic before full rollout. |
| **Spot Instance Strategy** | Use Spot Instances for cost optimization. |

---

## **🔹 Security Best Practices for EKS**
✅ **Use IAM Roles for Service Accounts (IRSA)** → Grant least privilege access to workloads.
✅ **Enable Encryption for EBS & Secrets** → Use **KMS encryption** for persistent storage.
✅ **Implement Network Policies** → Restrict pod-to-pod communication using **Calico** or **Cilium**.
✅ **Use AWS WAF & ALB Security Groups** → Protect Kubernetes services exposed via **ALB Ingress**.
✅ **Scan Images for Vulnerabilities** → Use **Amazon ECR scanning** or **Trivy**.

---

## **🔹 EKS Monitoring & Logging**
✅ **Use CloudWatch Container Insights** → Monitors CPU, memory, and disk usage of EKS workloads.
✅ **Integrate Prometheus & Grafana** → Provides in-depth metrics and visualization.
✅ **Use Fluentd/FluentBit for Log Aggregation** → Forward logs to CloudWatch, Elasticsearch, or Datadog.
✅ **Enable Kubernetes Audit Logging** → Detects security risks and unauthorized access.

---

## **🔹 Troubleshooting EKS Issues**
| **Issue** | **Possible Cause** | **Solution** |
|----------|-----------------|------------|
| **Pods Stuck in Pending** | Insufficient worker nodes | Scale nodes using Cluster Autoscaler |
| **CrashLoopBackOff** | Misconfigured application | Check logs (`kubectl logs pod-name`) and events (`kubectl describe pod`) |
| **High Latency in Services** | Network misconfiguration | Check VPC CNI settings and ensure correct security groups |
| **Node Not Joining Cluster** | IAM permissions issue | Verify node IAM role has correct permissions |

---

## **🔹 Key AWS CLI Commands for EKS**
✅ **Create an EKS Cluster**
```bash
aws eks create-cluster --name my-cluster --role-arn arn:aws:iam::123456789012:role/EKSRole --resources-vpc-config subnetIds=subnet-123,subnet-456,securityGroupIds=sg-789
```
✅ **Get Cluster Credentials**
```bash
aws eks update-kubeconfig --name my-cluster --region us-east-1
```
✅ **List Worker Nodes**
```bash
kubectl get nodes
```
✅ **Deploy an Application**
```bash
kubectl apply -f deployment.yaml
```
✅ **Monitor Pods & Logs**
```bash
kubectl get pods -A
kubectl logs pod-name
```

---

## **🚀 Summary for SRE Engineers**
| **Aspect** | **Best Practice** |
|-----------|------------------|
| **Security** | Use IAM Roles, Network Policies, and Secrets Encryption. |
| **Cost Optimization** | Use **Cluster Autoscaler** & **Spot Instances** for savings. |
| **High Availability** | Deploy across **multiple AZs** with Auto Scaling Groups. |
| **Observability** | Use **CloudWatch, Prometheus, and FluentBit** for monitoring. |
| **Scaling** | Use **HPA (Horizontal Pod Autoscaler) & Karpenter** for optimized scaling. |

✅ **With these strategies, an SRE engineer can efficiently manage, secure, and optimize Amazon EKS clusters!** 🚀
