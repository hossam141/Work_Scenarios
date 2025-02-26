# **Case Study: Reducing Disk Latency in an EKS-Based Application with RDS**

## **🚀 Scenario: Frequent RDS CPU Spikes Leading to Performance Issues in EKS**  

### **1️⃣ Problem: High RDS CPU Spikes Observed in Datadog Dashboard**  
#### **Datadog Widget Indicating a Potential Issue**
- While monitoring our **Datadog dashboard**, we noticed frequent **CPU spikes on Amazon RDS**.  
- The **Datadog metric `aws.rds.cpu_utilization`** was reaching **80-90% utilization**, but we needed to confirm whether CPU was the root cause.  

✅ **Recommended Datadog Widget Name:** `RDS CPU Utilization - EKS Cluster`  
- **Metric:** `aws.rds.cpu_utilization` → Tracks **CPU usage percentage** in RDS.  
- **Widget Type:** **Timeseries Graph** tracking CPU usage over time.  
- **Alert Trigger:** CPU **exceeding 85% for more than 5 minutes**.  

🔍 **Initial Investigation:**  
- Since CPU was spiking, we checked **Datadog RDS Performance Insights** to analyze the most expensive queries.  
- **Finding:** The slowest queries were **not CPU-bound** but were waiting on **disk I/O operations**, meaning **high CPU was a symptom, not the root cause**.  

🚨 **Conclusion:** RDS CPU spikes were **caused by slow disk reads** (high `aws.rds.read_latency`), not by inefficient query execution on CPU.  
✅ **Action:** Focused our investigation on **disk latency issues** instead of CPU utilization.  

---

## **2️⃣ Investigating the Root Cause: High Disk I/O Latency (Using Amazon RDS Performance Insights & Datadog)**  

### **Step 1: Identifying the Slowest Queries Using Amazon RDS Performance Insights**  
🔹 **Since `pg_stat_statements` is NOT enabled in our RDS, we relied entirely on Amazon RDS Performance Insights.**  

✅ **Steps to Analyze Queries in Performance Insights:**  
1. **Go to AWS Console → RDS → Performance Insights.**  
2. **Select the RDS Instance → View Top Queries.**  
3. **Sort by “Total Execution Time” to find the most expensive queries.**  
4. **Check the "DB Load by Wait Event Type" to see if queries are waiting on I/O.**  

🔴 **Issue:** We identified two key queries consuming excessive disk reads.  
✅ **Action:** Shared slow queries with the **Dev Team** for optimization.  

---

### **Step 2: Confirming Disk I/O Latency in Datadog (RDS Metrics)**  
- Since our AWS account is **integrated with Datadog**, we **monitored RDS metrics directly in Datadog**.  
- Key metric observed:  
  - **`aws.rds.read_latency` → consistently above 200ms**, confirming slow disk reads.  

✅ **Recommended Datadog Widget Name:** `RDS Read Latency - Query Performance`  
- **Metric:** `aws.rds.read_latency` → Measures **time taken for read operations** in RDS.  
- **Widget Type:** **Timeseries Graph** tracking disk read latency over time.  
- **Alert Trigger:** **Read latency > 150ms for more than 5 minutes**.  

🔴 **Issue:** High read latency was **directly impacting application performance in EKS**.

---

## **3️⃣ Solution: Optimizing Queries Instead of Upgrading RDS**  

🚨 **Note:** Instead of upgrading the RDS instance from `db.t3.medium` → `db.m5.large` (due to cost constraints), we focused on **query optimization and indexing**.

✅ **Step 1: Shared Slow Queries with Developers**  
- Provided a **detailed report** from **RDS Performance Insights**.  
- Suggested **query optimizations** (e.g., replacing full table scans with indexed searches).  

✅ **Step 2: Recommended Query Indexing**  
- Suggested adding indexes to **reduce full table scans** and **optimize query execution**.  
- Example of an indexed query recommendation:  
  ```sql
  CREATE INDEX idx_orders_status ON orders(status);
  ```  

✅ **Step 3: Recommended an RDS Upgrade for Future Scaling**  
- Suggested upgrading from **`db.t3.medium` → `db.m5.large`** for **higher IOPS performance**.  
- Logged a **cost-benefit analysis** for management to approve future upgrades.  

✅ **Step 4: Created a Datadog Alarm for Future Prevention**  
To **prevent this issue from happening again**, we created a **Datadog alarm** that triggers when disk latency is high.

📌 **Datadog Alarm Configuration:**  
- **Monitor Type:** **Metric Alert**  
- **Metric to Monitor:** `aws.rds.read_latency`  
- **Condition:** **Trigger if the average read latency is above 150ms for more than 5 minutes**  
- **Query for Datadog Monitor:**  
  ```text
  avg(last_5m):avg:aws.rds.read_latency{db-instance:mydb} > 150
  ```  
- **Trigger Thresholds:**  
  - **Warning Level:** `120ms` (sends early warning)  
  - **Critical Level:** `150ms` (triggers PagerDuty & Slack alerts)  

✅ **Datadog Alarm Setup Steps:**  
1. **Go to Datadog → Monitors → Create New Monitor.**  
2. **Choose "Metric" Monitor Type.**  
3. **Set Query: `avg:aws.rds.read_latency{db-instance:mydb} > 150 over last 5 minutes`.**  
4. **Set Warning Threshold at `120ms`, Critical Threshold at `150ms`.**  
5. **Trigger notification to Slack & PagerDuty on critical alerts.**  
6. **Save & Activate the Monitor.**  

📌 **Impact:**  
- **Immediate alerts if read latency goes above 150ms.**  
- **Proactive monitoring instead of reactive troubleshooting.**  
- **Reduces performance issues before they affect users.**  

---

## **4️⃣ Results & Impact**  

✅ **Faster Query Execution:**  
  - **Before:** Queries taking **60+ seconds**.  
  - **After:** Queries executing **in <5 seconds** after indexing.  

✅ **Reduced Disk Latency:**  
  - **Before:** `aws.rds.read_latency` **250ms+**.  
  - **After:** Read latency dropped to **80ms**.  

✅ **Improved Application Performance in EKS:**  
  - **Database queries no longer caused application slowdowns.**  
  - **EKS pods handled requests faster without unnecessary waiting.**  

✅ **Datadog Widgets & Alarm Now Cover:**  
  - **RDS CPU Spikes (`aws.rds.cpu_utilization`)**  
  - **Lower disk I/O wait times (`aws.rds.read_latency`)**  
  - **Optimized query response times (via RDS Performance Insights)**  
  - **Instant alerts if read latency exceeds 150ms**  

---

## **5️⃣ Final Interview Answer**  
**Interviewer:** *How did you detect and resolve a disk latency issue in a database-heavy application on EKS?*  

✅ **Your Answer:**  
*"While monitoring our Datadog dashboard, we noticed frequent **RDS CPU spikes** in our `RDS CPU Utilization - EKS Cluster` widget. However, after analyzing **Amazon RDS Performance Insights**, we discovered that the real issue was **high read latency (`aws.rds.read_latency`) rather than CPU contention**. Since `pg_stat_statements` was not enabled, we used **Performance Insights** to find slow queries. Instead of upgrading RDS due to cost constraints, we optimized queries with indexing and implemented a ...

🚀 **With this answer, you showcase:**  
- **Cloud-native monitoring skills** (Datadog RDS metrics, AWS Performance Insights).  
- **Database performance troubleshooting** (Focusing on disk I/O instead of CPU).  
- **Cost-aware optimization strategies** (Improving query efficiency instead of upgrading RDS).  
- **Proactive alerting** (Datadog alarm setup for future prevention).  

---

✅ **Now, you're fully prepared to explain this performance optimization case in your SRE interview!** 🚀

