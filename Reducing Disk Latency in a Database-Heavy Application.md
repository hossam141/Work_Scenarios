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
- Opened **Amazon RDS Performance Insights** to **analyze query performance**.  
- Found that specific **queries were consuming high I/O and execution time**.  

✅ **Query to list slowest queries in PostgreSQL:**  
  ```sql
  SELECT query, calls, total_exec_time, mean_exec_time 
  FROM pg_stat_statements 
  ORDER BY total_exec_time DESC 
  LIMIT 5;
  ```  
  **Output (before tuning):**  
  ```
     query                                      | calls | total_exec_time | mean_exec_time 
  ----------------------------------------------+-------+----------------+----------------
  SELECT * FROM orders WHERE status = 'PENDING' | 10500 | 60000ms         | 5.7ms
  SELECT * FROM transactions WHERE user_id=1001 | 8500  | 55000ms         | 6.5ms
  ```  
  🔴 **Issue:** The `orders` and `transactions` queries were frequently executed but had **no proper indexing**, causing **full table scans** and increasing disk I/O.  

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

## **3️⃣ Solution: Optimizing Queries & Indexing Instead of Upgrading RDS**  

🚨 **Note:** Instead of upgrading the RDS instance from `db.t3.medium` → `db.m5.large` (due to cost constraints), we focused on **query optimization and indexing**.

✅ **Step 1: Added Indexing to Optimize Query Performance**  
- Created **indexes on frequently queried columns**:  
  ```sql
  CREATE INDEX idx_orders_status ON orders(status);
  CREATE INDEX idx_transactions_user ON transactions(user_id);
  ```  
- **Impact:** This allowed PostgreSQL to **filter data efficiently instead of scanning entire tables**, significantly reducing disk I/O.  

✅ **Step 2: Shared Slow Queries with Developers**  
- Provided a **detailed report to the Dev Team**, listing queries with the highest execution time.  
- Suggested **query refactoring** using **pagination and optimized joins** instead of `SELECT *` queries.

✅ **Step 3: Recommended an RDS Upgrade for Future Scaling**  
- Suggested upgrading from **`db.t3.medium` → `db.m5.large`** to get **higher IOPS performance**.  
- Logged a **cost-benefit analysis** for management to approve future upgrades.  

✅ **Step 4: Created a Datadog Alarm to Detect Future Issues**  
To **prevent this issue from happening again**, we created a **Datadog alert** that triggers when disk latency is high.

📌 **Datadog Alarm Configuration:**  
- **Metric:** `aws.rds.read_latency`  
- **Condition:** **Above 150ms for 5 minutes**  
- **Query for Datadog Monitor:**  
  ```text
  avg(last_5m):avg:aws.rds.read_latency{db-instance:mydb} > 150
  ```  
- **Notification:** Sends an alert to **Slack & PagerDuty** if triggered.

✅ **Datadog Alarm Setup Steps:**  
1. **Go to Datadog → Monitors → Create New Monitor.**  
2. **Choose "Metric" Monitor Type.**  
3. **Set Query: `avg:aws.rds.read_latency{db-instance:mydb} > 150 over last 5 minutes`.**  
4. **Trigger alert when condition is met.**  
5. **Set notifications (Slack, PagerDuty, Email).**  
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
  - **Optimized query response times** (`pg_stat_statements.mean_exec_time`).  
  - **Instant alerts if read latency exceeds 150ms.**  

---

## **5️⃣ Final Interview Answer**  
**Interviewer:** *How did you detect and resolve a disk latency issue in a database-heavy application on EKS?*  

✅ **Your Answer:**  
*"While monitoring our Datadog dashboard, we noticed high `aws.rds.read_latency` values, indicating slow query execution in our EKS-based application. Using **Amazon RDS Performance Insights**, we identified specific slow queries that were responsible for high disk I/O. Instead of upgrading the RDS instance (due to cost constraints), we optimized the queries by **adding indexes** and **refactoring queries with the Dev Team**. Additionally, we implemented a **Datadog alarm** that alerts us if read latency exce...

🚀 **With this answer, you showcase:**  
- **Cloud-native monitoring skills** (Datadog RDS metrics, AWS Performance Insights).  
- **Database query performance troubleshooting** (Using `pg_stat_statements` to find slow queries).  
- **Cost-aware optimization strategies** (Improved query efficiency instead of upgrading RDS).  
- **Cross-team collaboration** (Working with Devs to optimize queries).  
- **Proactive alerting** (Datadog alarm setup for future prevention).  

---

✅ **Now, you're fully prepared to explain this performance optimization case in your SRE interview!** 🚀

