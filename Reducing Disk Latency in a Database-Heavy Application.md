# **Case Study: Reducing Disk Latency in an EKS-Based Application with RDS**

## **🚀 Scenario: High Disk Latency Impacting Database Performance in EKS**  

### **1️⃣ Problem: Slow Queries Observed in Datadog Dashboard**  
#### **Datadog Widget Indicating a Potential Issue**
- While monitoring our **Datadog dashboard**, we noticed a **widget displaying high database query response times**.  
- The **Datadog metric `aws.rds.read_latency`** was consistently **above 200ms**, causing **slow query execution** and degrading application performance.  

✅ **Datadog Widget Setup:**  
- **Metric:** `aws.rds.read_latency` → Measures **time taken for read operations** in RDS.  
- **Widget Type:** **Timeseries Graph** tracking **disk read latency over time**.  
- **Alert Trigger:** **Read latency > 150ms for more than 5 minutes**.  

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
- Key metrics observed:  
  - **`aws.rds.read_latency` → consistently above 200ms**.  
  - **`aws.rds.disk_queue_depth` → high, indicating slow disk reads**.  

✅ **Datadog Alert Setup:**  
- **Alert on `aws.rds.read_latency > 150ms` for more than 5 minutes.**  
- **Alert on `aws.rds.disk_queue_depth > 10`, indicating delayed disk operations.**  

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

✅ **Datadog Widget & Alarm Now Covers:**  
  - **Lower disk I/O wait times** (`aws.rds.read_latency`).  
  - **Optimized query response times** (via RDS Performance Insights).  
  - **Instant alerts if read latency exceeds 150ms.**  

---

## **5️⃣ Final Interview Answer**  
**Interviewer:** *How did you detect and resolve a disk latency issue in a database-heavy application on EKS?*  

✅ **Your Answer:**  
*"While monitoring our Datadog dashboard, we noticed high `aws.rds.read_latency` values, indicating slow query execution in our EKS-based application. Since `pg_stat_statements` was not enabled, we used **Amazon RDS Performance Insights** to identify slow queries. Instead of upgrading RDS due to cost constraints, we worked with the **Dev Team to optimize queries and add indexing**. Additionally, we implemented a **Datadog alarm** to monitor `aws.rds.read_latency`, sending alerts to Slack and PagerDuty if it ex...

🚀 **With this answer, you showcase:**  
- **Cloud-native monitoring skills** (Datadog RDS metrics, AWS Performance Insights).  
- **Database query performance troubleshooting** (Using RDS Performance Insights instead of `pg_stat_statements`).  
- **Cost-aware optimization strategies** (Improved query efficiency instead of upgrading RDS).  
- **Cross-team collaboration** (Working with Devs to optimize queries).  
- **Proactive alerting** (Datadog alarm setup for future prevention).  

---

✅ **Now, you're fully prepared to explain this performance optimization case in your SRE interview!** 🚀

