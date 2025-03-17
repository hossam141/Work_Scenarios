# 📌 Troubleshooting Kubernetes Applications & Connectivity Issues

## **🔹 Overview**
When an application fails in Kubernetes, or there are connectivity issues with containers, pods, or services, you need a **systematic approach** to troubleshooting. Below are common failure scenarios and step-by-step diagnostics for each case.

---

## **1️⃣ Scenario: Pod is Stuck in `Pending` State**
### **🚀 Issue:**
- `kubectl get pods` shows pods in `Pending` state, meaning they are not scheduled on a node.

### **🛠 Steps to Troubleshoot & Fix**
1️⃣ **Check Pod Events for Errors**
```bash
kubectl describe pod <pod-name>
```
✅ **Look for messages like `FailedScheduling`, `Insufficient CPU/Memory`**.

2️⃣ **Check Available Worker Nodes**
```bash
kubectl get nodes
```
✅ **Ensure there are active and ready nodes.**

3️⃣ **Check Resource Requests & Limits**
```bash
kubectl describe pod <pod-name> | grep -i requests -A5
```
✅ **Ensure the pod's resource requests are within node capacity.**

4️⃣ **Check Cluster Autoscaler Logs (if enabled)**
```bash
kubectl logs -n kube-system deployment/cluster-autoscaler
```
✅ **See if autoscaler is adding new nodes.**

---

## **2️⃣ Scenario: Pod is Stuck in `CrashLoopBackOff`**
### **🚀 Issue:**
- The pod is continuously restarting due to an application error.

### **🛠 Steps to Troubleshoot & Fix**
1️⃣ **Check Logs for Errors**
```bash
kubectl logs <pod-name>
```
✅ **Identify application errors causing the crash.**

2️⃣ **Check Pod Events for Failures**
```bash
kubectl describe pod <pod-name>
```
✅ **Look for `OOMKilled`, `FailedMount`, or `ImagePullBackOff`.**

3️⃣ **Access the Container & Debug**
```bash
kubectl exec -it <pod-name> -- /bin/sh
```
✅ **Manually inspect logs, environment variables, and configurations.**

4️⃣ **Check Deployment Configuration**
```bash
kubectl get deployment <deployment-name> -o yaml
```
✅ **Ensure correct image version, environment variables, and resource limits.**

---

## **3️⃣ Scenario: Pod is Running, but the Application is Unreachable**
### **🚀 Issue:**
- The pod is running, but the application inside the container is not accessible.

### **🛠 Steps to Troubleshoot & Fix**
1️⃣ **Check Service & Endpoint Mapping**
```bash
kubectl get services
kubectl get endpoints
```
✅ **Ensure the service is pointing to the correct pod IP.**

2️⃣ **Test Internal Connectivity (From Another Pod)**
```bash
kubectl run -it --rm busybox --image=busybox -- /bin/sh
wget <service-name>:<port>
```
✅ **Verify if the service is reachable inside the cluster.**

3️⃣ **Check Application Listening Ports**
```bash
kubectl exec -it <pod-name> -- netstat -tulnp
```
✅ **Ensure the app is listening on the correct port inside the container.**

4️⃣ **Check Network Policies**
```bash
kubectl get networkpolicy
```
✅ **Confirm that no restrictive network policies are blocking traffic.**

---

## **4️⃣ Scenario: Pod is Not Getting External Traffic (Ingress Issue)**
### **🚀 Issue:**
- Application is accessible inside the cluster but not from the internet.

### **🛠 Steps to Troubleshoot & Fix**
1️⃣ **Check Ingress Controller Logs**
```bash
kubectl logs -n kube-system -l app.kubernetes.io/name=ingress-nginx
```
✅ **Look for routing errors.**

2️⃣ **Check Ingress Resource Configuration**
```bash
kubectl describe ingress <ingress-name>
```
✅ **Ensure correct host and path rules.**

3️⃣ **Check Cloud Load Balancer Status (If Used)**
```bash
kubectl get svc -n kube-system
```
✅ **Confirm external load balancer has a public IP assigned.**

4️⃣ **Check Firewall & Security Groups** (For AWS, GCP, Azure)
```bash
aws ec2 describe-security-groups
```
✅ **Ensure security groups allow inbound traffic on the required ports (e.g., 80, 443).**

---

## **5️⃣ Scenario: DNS Resolution Fails Inside Cluster**
### **🚀 Issue:**
- Application pods cannot resolve internal services by name.

### **🛠 Steps to Troubleshoot & Fix**
1️⃣ **Check CoreDNS Pods**
```bash
kubectl get pods -n kube-system -l k8s-app=kube-dns
```
✅ **Ensure CoreDNS pods are running.**

2️⃣ **Test DNS Resolution**
```bash
kubectl exec -it <pod-name> -- nslookup <service-name>
```
✅ **If DNS fails, restart CoreDNS pods:**
```bash
kubectl rollout restart deployment coredns -n kube-system
```
✅ **Check CoreDNS logs for errors.**

---

## **🚀 Summary: Common Kubernetes Troubleshooting Scenarios**
| **Scenario** | **Issue** | **Solution** |
|-------------|---------|-----------|
| **Pods stuck in `Pending`** | No available nodes or insufficient resources | Check events, node capacity, and Cluster Autoscaler |
| **Pods in `CrashLoopBackOff`** | Application crash or misconfiguration | Check logs, describe pod events, inspect environment variables |
| **Pod running but unreachable** | Application or networking issue | Check service endpoints, test connectivity from another pod, inspect network policies |
| **External traffic not reaching app** | Ingress misconfiguration | Check Ingress logs, security groups, firewall settings |
| **DNS resolution fails inside cluster** | CoreDNS failure | Restart CoreDNS, check logs, test DNS with `nslookup` |

✅ **By following these troubleshooting steps, an SRE engineer can quickly diagnose and resolve Kubernetes failures!** 🚀
