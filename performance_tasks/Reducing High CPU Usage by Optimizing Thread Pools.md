# **Case Study: Reducing High CPU Usage by Optimizing Thread Pools**

## **🚀 Scenario: High CPU Usage Impacting Application Performance**  

### **1️⃣ Problem: CPU Spikes Observed on Datadog Dashboard**  
#### **Datadog Widget Indicating a Potential Issue**
- While monitoring our **Datadog dashboard**, we noticed a **widget displaying high CPU utilization**.  
- The **Datadog metric `system.cpu.user`** was consistently above **90%**, causing **request timeouts** and degraded application performance.  

✅ **Datadog Widget Setup:**  
- **Metric:** `system.cpu.user` → Tracks **percentage of CPU time used by user processes**.  
- **Widget Type:** **Timeseries Graph** tracking **CPU spikes over time**.  
- **Alert Trigger:** CPU usage exceeding **85% for more than 5 minutes**.  

---

### **2️⃣ Investigating the Root Cause: Unoptimized Thread Pools**  

#### **Step 1: Checking High CPU Usage on Kubernetes Pods**  
- Ran the following command to **identify the pods consuming excessive CPU**:  
  ```bash
  kubectl top pods --sort-by=cpu
  ```  
  **Output (before tuning):**  
  ```
  NAME              CPU(cores)   MEMORY(bytes)
  my-app-pod-1     800m         256Mi
  my-app-pod-2     750m         300Mi
  ```  
  🔴 **Issue:** A Java-based microservice was using **too much CPU**, indicating inefficient request handling.  

#### **Step 2: Checking Thread Utilization**  
- Used `top` to check CPU-hogging processes:  
  ```bash
  top -H -p $(pgrep -d',' -f java)
  ```  
  - Observed **too many active threads** consuming CPU.  

- Used `jstack` to analyze thread states:  
  ```bash
  jstack -l <PID> | grep -i "runnable"
  ```  
  - Found excessive **runnable threads**, causing **CPU contention**.  

#### **Step 3: Root Cause - Unoptimized Thread Pool Configuration**  
- The application was using a **thread-per-request** model, leading to **too many concurrent threads**.  
- This was causing **CPU saturation** and slowing down response times.  

---

### **3️⃣ Solution: Optimizing Thread Pool Configuration**  

✅ **Step 1: Adjusted Java Thread Pool Settings**  
Modified the `ExecutorService` configuration in the application:  
```java
ExecutorService executor = new ThreadPoolExecutor(
    10, 50, 60, TimeUnit.SECONDS, new LinkedBlockingQueue<>(100)
);
```
- **Core Threads:** `10` (Minimum active threads)  
- **Max Threads:** `50` (Prevents excessive thread spawning)  
- **Keep-Alive Time:** `60s` (Idle threads are removed after 60s)  
- **Queue Size:** `100` (Limits queued tasks, preventing thread explosion)  

✅ **Step 2: Set CPU Limits in Kubernetes Deployment**  
Updated the Kubernetes **resource requests and limits** to prevent excessive CPU consumption:  
```yaml
resources:
  requests:
    cpu: "500m"
  limits:
    cpu: "1000m"
```
- Ensures that **each pod gets at least 500m CPU** but **never exceeds 1000m CPU**.  

✅ **Step 3: Enabled Horizontal Pod Autoscaling (HPA)**  
Configured Kubernetes **HPA to scale pods dynamically** when CPU usage spikes:  
```bash
kubectl autoscale deployment my-app --cpu-percent=75 --min=2 --max=5
```
- **If CPU > 75%**, Kubernetes **adds more pods automatically**.  
- Prevents a single pod from being overwhelmed.  

---

### **4️⃣ Results & Impact**  

✅ **Lowered CPU Utilization:**  
  - **Before:** CPU usage **90%+** consistently.  
  - **After:** CPU usage stabilized **around 50%**.  

✅ **Faster Response Times:**  
  - **Before:** API latency **500ms+ under load**.  
  - **After:** Latency dropped to **150ms**.  

✅ **Increased Application Stability:**  
  - No more **CPU saturation or request timeouts**.  
  - **Kubernetes HPA automatically scaled pods** when needed.  

✅ **Datadog Widget Now Shows:**  
  - **Reduced CPU spikes** (`system.cpu.user`).  
  - **Stable request processing** (`kubernetes.container.cpu.usage`).  

---

### **5️⃣ Final Interview Answer**  
**Interviewer:** *How did you detect and resolve a high CPU utilization issue in production?*  

✅ **Your Answer:**  
*"While monitoring our Datadog dashboard, I noticed a widget tracking `system.cpu.user` showing sustained CPU usage above 90%. Investigating further using `kubectl top pods` and `jstack`, I found excessive runnable threads due to an unoptimized thread pool. I optimized the Java thread pool configuration, set Kubernetes CPU limits, and implemented autoscaling using HPA. These changes reduced CPU usage from 90% to 50%, improved request response times, and ensured application stability under load."*  

🚀 **With this answer, you showcase:**  
- **Monitoring expertise** (using Datadog widgets to detect high CPU usage).  
- **Troubleshooting skills** (using `kubectl top pods`, `top`, and `jstack`).  
- **Performance tuning knowledge** (optimizing thread pools and setting CPU limits).  
- **Scalability best practices** (implementing Kubernetes HPA for automatic scaling).  

---

✅ **Now, you're fully prepared to explain this performance optimization case in your SRE interview!** 🚀

