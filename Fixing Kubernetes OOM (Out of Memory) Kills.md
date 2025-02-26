# **Case Study: Fixing Kubernetes OOM (Out of Memory) Kills**

## **🚀 Scenario: Frequent OOM Kills in Kubernetes Pods**  

### **1️⃣ Problem: Pods Frequently Restarting Due to OOM Kills**  
- While monitoring our **Datadog dashboard**, we noticed that some **Kubernetes pods** were **frequently restarting**.  
- The **Datadog metric `kubernetes.container_memory.oom_killed`** showed a **high number of OOM (Out of Memory) kills** in certain microservices.  

✅ **Recommended Datadog Widgets for Kubernetes Memory Monitoring:**  
1. **`Kubernetes Pod Restarts - OOM Kill Tracking`**  
   - **Metric:** `kubernetes.container_memory.oom_killed` → Tracks **OOM kills per container**.  
   - **Widget Type:** **Timeseries Graph** tracking OOM kills over time.  
   - **Alert Trigger:** **If OOM kills exceed 5 per hour for a specific pod.**  

2. **`Container Memory Usage - EKS Workloads`**  
   - **Metric:** `kubernetes.memory.usage` → Tracks **container memory consumption**.  
   - **Widget Type:** **Timeseries Graph** tracking memory usage over time.  
   - **Alert Trigger:** **If memory usage exceeds 90% of the allocated limit.**  

🔍 **Initial Investigation:**  
- **Confirmed that affected pods were exceeding their allocated memory limits.**  
- **Used `kubectl describe pod` to check termination reasons:**  
  ```bash
  kubectl describe pod <pod-name> -n <namespace>
  ```  
  🔴 **Issue:** `OOMKilled` messages were present in pod events, confirming memory exhaustion.  

---

## **2️⃣ Root Cause Analysis: Identifying Memory Leaks & Misconfigured Limits**  

✅ **Step 1: Checking Resource Limits in Kubernetes Manifests**  
- We analyzed the pod's **resource requests & limits** in its Kubernetes deployment.  
- **Example problematic deployment:**  
  ```yaml
  resources:
    requests:
      memory: "256Mi"
    limits:
      memory: "512Mi"
  ```  
- **Observation:** Pods were consuming **600-700Mi memory** but were limited to `512Mi`, causing frequent OOM kills.  

✅ **Step 2: Identifying High Memory Usage with `kubectl top`**  
- Ran the following command to **check real-time pod memory usage**:  
  ```bash
  kubectl top pod -n <namespace>
  ```  
  **Output:**  
  ```
  NAME                 CPU(cores)   MEMORY(bytes)   
  service-pod-1       100m         600Mi   
  service-pod-2       150m         680Mi  
  ```  
  🔴 **Issue:** These services **exceeded their memory limits**, leading to crashes.  

✅ **Step 3: Analyzing Memory Usage Over Time in Datadog**  
- **Datadog Metric:** `kubernetes.memory.usage`  
- **Observation:** **Gradual memory increase**, indicating a potential memory leak.  

---

## **3️⃣ Solution: Fixing OOM Kills by Optimizing Resource Limits & Identifying Memory Leaks**  

🚨 **Action Plan:**  
1. **Increase memory limits** to accommodate actual usage.  
2. **Identify & fix memory leaks** in affected microservices.  
3. **Implement better resource monitoring in Datadog.**  

✅ **Step 1: Adjusting Kubernetes Resource Limits Based on Real Usage**  
- We **updated memory limits** in Kubernetes manifests:  
  ```yaml
  resources:
    requests:
      memory: "512Mi"   # Increased request
    limits:
      memory: "1024Mi"  # Increased limit
  ```  
- **Applied changes:**  
  ```bash
  kubectl apply -f deployment.yaml
  ```  

✅ **Step 2: Enabling Memory Profiling to Detect Leaks**  
- Developers enabled **heap dumps & profiling tools** to find memory leaks.  
- Used **`pprof` (Go), `memory_profiler` (Python), or `JVM heap dumps` (Java) to analyze memory growth.**  

✅ **Step 3: Setting Up Datadog Alerts for Early Detection**  
📌 **Datadog Alarm Configuration:**  
- **Monitor Type:** **Metric Alert**  
- **Metric to Monitor:** `kubernetes.memory.usage`  
- **Condition:** **Trigger if container memory usage exceeds 90% of the allocated limit**  
- **Query for Datadog Monitor:**  
  ```text
  avg(last_5m):avg:kubernetes.memory.usage{namespace:my-namespace} > 90
  ```  
- **Trigger Thresholds:**  
  - **Warning Level:** `80%` (sends early warning)  
  - **Critical Level:** `90%` (triggers PagerDuty & Slack alerts)  

✅ **Datadog Alarm Setup Steps:**  
1. **Go to Datadog → Monitors → Create New Monitor.**  
2. **Choose "Metric" Monitor Type.**  
3. **Set Query: `avg:kubernetes.memory.usage{namespace:my-namespace} > 90 over last 5 minutes`.**  
4. **Set Warning Threshold at `80%`, Critical Threshold at `90%`.**  
5. **Trigger notification to Slack & PagerDuty on critical alerts.**  
6. **Save & Activate the Monitor.**  

📌 **Impact:**  
- **Instant alerts when memory usage gets too high.**  
- **Prevents OOM kills before they cause pod crashes.**  
- **Helps track memory leaks in microservices.**  

---

## **4️⃣ Results & Impact**  

✅ **Reduced OOM Kills:**  
  - **Before:** Pods were crashing **5-10 times per day**.  
  - **After:** **0 crashes after increasing limits & fixing leaks**.  

✅ **Improved Memory Allocation:**  
  - **Before:** Requests/Limits were **too low**, causing OOM kills.  
  - **After:** **Properly tuned limits (1GB instead of 512MB).**  

✅ **Better Monitoring with Datadog:**  
  - **Added alerts for high memory usage (`kubernetes.memory.usage`).**  
  - **Tracked memory over time to detect gradual leaks.**  

✅ **Datadog Widgets & Alarm Now Cover:**  
  - **Pod OOM Kills (`kubernetes.container_memory.oom_killed`)**  
  - **Container Memory Usage (`kubernetes.memory.usage`)**  
  - **Instant alerts if memory exceeds safe limits**  

---

## **5️⃣ Final Interview Answer**  
**Interviewer:** *How did you detect and fix Kubernetes OOM (Out of Memory) issues?*  

✅ **Your Answer:**  
*"While monitoring our **Datadog dashboard**, we noticed frequent **OOM kills** in certain pods. The **`kubernetes.container_memory.oom_killed` metric** showed that affected services were **exceeding their allocated memory limits**. Using **`kubectl top pod`**, we confirmed that **actual memory usage was 600-700Mi**, but limits were set to **512Mi**, causing crashes.  

To fix this, we **increased memory limits in Kubernetes manifests** and **worked with developers to analyze potential memory leaks** using heap dumps and profiling tools. Additionally, we **created a Datadog alarm** that triggers if memory usage exceeds **90% of the allocated limit**. These optimizations **completely eliminated OOM kills and improved overall system stability.**"*  

🚀 **With this answer, you showcase:**  
- **Kubernetes troubleshooting skills** (`kubectl top pod`, `kubectl describe pod`).  
- **Monitoring & alerting expertise** (Datadog metrics, custom alerts).  
- **Capacity planning skills** (Adjusting memory limits based on actual usage).  
- **Cross-team collaboration** (Working with Devs to fix memory leaks).  

---

✅ **Now, you're fully prepared to explain this Kubernetes OOM Kill case in your SRE interview!** 🚀

