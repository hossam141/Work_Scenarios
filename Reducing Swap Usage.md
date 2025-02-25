# **Linux Performance Optimization: Reducing Swap Usage with `vm.swappiness`**

## **🚀 Case Study: Troubleshooting High Swap Usage Using Datadog & Tuning `vm.swappiness`**  

### **1️⃣ Problem: Performance Degradation Observed on Datadog Dashboard**  
#### **Datadog Widget Indicating a Potential Issue**
- While monitoring our **Datadog dashboard**, we noticed a **widget displaying high disk I/O wait time**.  
- The **Datadog metric `system.io.await`** was unusually high, indicating **slow disk operations**.  

✅ **Datadog Widget Setup:**  
- **Metric:** `system.io.await` → Shows **I/O wait time per disk operation**.  
- **Widget Type:** **Timeseries Graph** tracking **disk latency over time**.  
- **Alert Trigger:** I/O wait exceeding **100ms** (Threshold exceeded).  

### **2️⃣ Investigating the Root Cause: High Swap Usage**  
#### **Step 1: Checking Swap Usage**
- Ran the following command to check memory and swap usage:  
  ```bash
  free -m
  ```  
  **Output (before tuning):**  
  ```
                total        used        free      shared  buff/cache   available
  Mem:           8000        6200         500         100        1300        1400
  Swap:          4000        3000        1000
  ```  
  🔴 **Issue:** The system was aggressively swapping, even though there was still available RAM.  

#### **Step 2: Checking the Current `vm.swappiness` Value**
- Verified the current kernel swap policy:  
  ```bash
  cat /proc/sys/vm/swappiness
  ```  
  **Output:** `60` (default in most Linux distributions).  
  🔴 **Finding:** A `swappiness` value of **60** causes the system to prefer swapping data to disk even when RAM is available.  

#### **Step 3: Identifying Swap Activity**
- Used `vmstat` to observe swap-in and swap-out activity:  
  ```bash
  vmstat 1 10
  ```  
  **Output (before tuning):**  
  ```
  procs -----------memory---------- ---swap-- -----io---- -system- ------cpu-----
   r  b    swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa
   1  0  3000000   500   1300   1400    2   10    50    80  500  600 10  5 75 10
  ```  
  🔴 **Issue:** Constant `si` (swap-in) and `so` (swap-out) activity, meaning data was being frequently swapped in and out of RAM.  

### **3️⃣ Solution: Tuning `vm.swappiness`**  
To **reduce unnecessary swap usage**, we adjusted the `vm.swappiness` value to **10** (favor RAM usage).  

#### **Step 1: Apply Temporary Change (For Testing)**
```bash
sudo sysctl -w vm.swappiness=10
```
✅ **Now, the system will prefer keeping data in RAM rather than swapping to disk.**  

#### **Step 2: Make the Change Permanent**
```bash
echo "vm.swappiness=10" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```
✅ **Ensures that the setting persists after a system reboot.**  

### **4️⃣ Results & Impact**  
✅ **Reduced Swap Usage:**  
  - **Before:** Swap usage **3GB out of 4GB**.  
  - **After:** Swap usage dropped to **500MB**.  

✅ **Lower Disk I/O Wait Times:**  
  - **Before:** `system.io.await` **120-150ms** (high latency).  
  - **After:** `system.io.await` **< 50ms** (disk responsiveness improved).  

✅ **Faster Application Response Times:**  
  - Web requests latency dropped from **500ms → 150ms**.  
  - Database queries executed **40% faster**.  

✅ **Datadog Widget Now Shows:**  
  - **Decreased swap usage** (`system.swap.pct_used`).  
  - **Lower disk I/O wait times** (`system.io.await`).  

### **5️⃣ Final Interview Answer**  
**Interviewer:** *How did you detect and resolve a swap-related performance issue in production?*  

✅ **Your Answer:**  
*"While monitoring our Datadog dashboard, I noticed a widget tracking `system.io.await` showing abnormally high disk I/O wait times. Upon investigation, I found excessive swap usage, even though RAM was available. Checking `vm.swappiness`, I discovered it was set to `60`, causing the system to swap aggressively. By tuning it down to `10`, I significantly reduced swap activity, improved disk performance, and restored application responsiveness. This change was made persistent across reboots, ensuring long-term stability."*  

🚀 **With this answer, you showcase:**  
- **Monitoring expertise** (using Datadog widgets to detect system issues).  
- **Troubleshooting skills** (identifying high swap usage with `free`, `vmstat`).  
- **Performance tuning knowledge** (modifying `vm.swappiness` to reduce swap dependency).  
- **Impact awareness** (measuring results and optimizing infrastructure performance).  

---

✅ **Now, you're fully prepared to explain this performance optimization case in your SRE interview!** 🚀

