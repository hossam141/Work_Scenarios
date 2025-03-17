# 📌 Troubleshooting Kubernetes Applications & Connectivity Issues

## **🔹 Understanding Kubernetes Pod Status**
A Kubernetes pod can enter different states based on its lifecycle and issues encountered during execution. Below are common pod states:

| **Pod Status** | **Description** |
|--------------|---------------|
| **Pending** | The pod has been accepted by the cluster but is waiting for resource allocation. |
| **Running** | The pod has been scheduled on a node and all containers are running. |
| **Succeeded** | The pod has completed execution successfully (used in Jobs). |
| **Failed** | One or more containers in the pod terminated with an error. |
| **CrashLoopBackOff** | A container is repeatedly crashing and restarting. |
| **ImagePullBackOff** | Kubernetes failed to pull the container image. |
| **Init:Error** | The `initContainer` failed to execute properly. |
| **ContainerCreating** | Kubernetes is pulling the image or mounting volumes before starting the container. |

---

## **🔹 Troubleshooting Scenarios & Pod Status**

### **1️⃣ Scenario: InitContainer (`Liquibase` for JAVA app) Fails**
### **🚀 Issue:**
- `kubectl get pods` shows the pod stuck in **`Init:Error`** or `CrashLoopBackOff`.
- The InitContainer fails before the main application starts.

### **🛠 Possible Causes & Fixes**
1️⃣ **Check InitContainer Logs for Errors**
```bash
kubectl logs <pod-name> -c <init-container-name>
```
✅ Look for database connectivity issues, permission errors, or missing migrations.

2️⃣ **Verify Database Connection**
```bash
kubectl exec -it <pod-name> -- /bin/sh
nc -zv <db-host> <db-port>
```
✅ Ensure Liquibase can reach the database.

3️⃣ **Check InitContainer Command & Exit Code**
```bash
kubectl describe pod <pod-name>
```
✅ Ensure the command executed successfully (`exit code 0`).

---

### **2️⃣ Scenario: Secret Not Sealed Correctly & Mounted in Deployment**
### **🚀 Issue:**
- `kubectl get pods` shows the pod stuck in **`CrashLoopBackOff`** or **`ContainerCreating`**.
- The application fails due to missing environment variables or mounted secrets.

### **🛠 Possible Causes & Fixes**
1️⃣ **Check Pod Events for Mounting Issues**
```bash
kubectl describe pod <pod-name>
```
✅ Look for messages like `MountVolume.SetUp failed for volume`.

2️⃣ **Verify Secret Exists**
```bash
kubectl get secret <secret-name> -o yaml
```
✅ Ensure the secret is properly created and available.

3️⃣ **Confirm Deployment is Correctly Mounting the Secret**
```yaml
volumes:
  - name: app-secret
    secret:
      secretName: my-secret
```
✅ Ensure the secret name matches the Kubernetes resource.

---

### **3️⃣ Scenario: Missing ConfigMap in Deployment**
### **🚀 Issue:**
- `kubectl get pods` shows the pod in **`CrashLoopBackOff`** or **`ContainerCreating`** state.
- The application fails due to missing configuration files.

### **🛠 Possible Causes & Fixes**
1️⃣ **Check Pod Events for ConfigMap Issues**
```bash
kubectl describe pod <pod-name>
```
✅ Look for `MountVolume.SetUp failed for volume` errors.

2️⃣ **Verify ConfigMap Exists**
```bash
kubectl get configmap <configmap-name> -o yaml
```
✅ Ensure the ConfigMap exists and contains the required values.

3️⃣ **Confirm Deployment References the Correct ConfigMap Name**
```yaml
volumes:
  - name: app-config
    configMap:
      name: my-config
```
✅ Ensure the ConfigMap name matches what is defined in the deployment.

---

### **4️⃣ Scenario: Readiness or Liveness Probe Issues**
### **🚀 Issue:**
- `kubectl get pods` shows the pod in **`Running`** state, but the app is unreachable.
- `kubectl describe pod <pod-name>` shows **liveness probe failures**.

### **🛠 Possible Causes & Fixes**
1️⃣ **Check Readiness & Liveness Probe Logs**
```bash
kubectl describe pod <pod-name>
```
✅ Look for errors related to failed health checks.

2️⃣ **Test Application Health Check Manually**
```bash
kubectl exec -it <pod-name> -- curl http://localhost:8080/health
```
✅ Ensure the endpoint returns a **200 OK** response.

3️⃣ **Fix Incorrect Probe Configurations**
```yaml
livenessProbe:
  httpGet:
    path: /health
    port: 8080
  initialDelaySeconds: 10
  periodSeconds: 5
```
✅ Ensure the app has enough startup time before running the probe.

---

## **🚀 Summary: Common Kubernetes Troubleshooting Scenarios & Pod Status**
| **Scenario** | **Issue** | **Pod Status** | **Solution** |
|-------------|---------|-----------|------------|
| **InitContainer (`Liquibase`) failure** | Database connection issues, migration failure | `Init:Error`, `CrashLoopBackOff` | Check logs, validate DB connection, fix init script |
| **Secret not mounted correctly** | Incorrectly sealed or missing secret | `CrashLoopBackOff`, `ContainerCreating` | Verify secret exists, check volume mounts |
| **Missing ConfigMap in Deployment** | ConfigMap not found or misconfigured | `CrashLoopBackOff`, `ContainerCreating` | Ensure ConfigMap exists, update deployment YAML |
| **Readiness/Liveness Probe failure** | Health check failures | `Running`, but failing probes | Check probe logs, increase `initialDelaySeconds`, validate endpoint |

✅ **By following these troubleshooting steps, an SRE engineer can quickly diagnose and resolve Kubernetes failures!** 🚀
