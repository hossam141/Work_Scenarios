# **Case Study: Reducing Disk Latency in a Database-Heavy Application**

## **🚀 Scenario: High Disk I/O Latency Impacting Database Performance**  

### **1️⃣ Problem: Slow Queries Observed in Datadog Dashboard**  
#### **Datadog Widget Indicating a Potential Issue**
- While monitoring our **Datadog dashboard**, we noticed a **widget displaying high database query response times**.  
- The **Datadog metric `aws.rds.read_latency`** was consistently **above 200ms**, causing **slow query execution**.  

✅ **Datadog Widget Setup:**  
- **Metric:** `aws.rds.read_latency` → Measures **time taken for read operations** in RDS.  
- **Widget Type:** **Timeseries Graph** tracking **disk read latency over time**.  
- **Alert Trigger:** **Read latency > 150ms for more than 5 minutes**.  

---

## **2️⃣ Investigating the Root Cause: High Disk I/O Latency**  

### **Step 1: Checking Slow Queries in PostgreSQL**  
- Ran the following SQL query to identify **long-running queries**:  
  ```sql
  SELECT pid, age(clock_timestamp(), query_start) AS runtime, usename, query 
  FROM pg_stat_activity 
  WHERE state != 'idle' ORDER BY query_start ASC;
  ```  
  **Output (before tuning):**  
  ```
   pid | runtime | usename | query
  -----+----------+---------+--------------------------------
  1234 | 00:01:10 | app_user | SELECT * FROM orders WHERE status = 'PENDING';
  5678 | 00:00:55 | app_user | SELECT * FROM transactions WHERE user_id = 1001;
  ```  
  🔴 **Issue:** Queries were running **for over a minute**, indicating potential indexing or disk latency problems.  

---

### **Step 2: Checking Disk I/O Usage on RDS**  
- Used **Amazon RDS Performance Insights** to monitor query execution time.  
- Verified **disk I/O performance** using `iostat`:  
  ```bash
  iostat -dx 1 10
  ```  
  **Output (before tuning):**  
  ```
  Device:     rrqm/s   wrqm/s    r/s    w/s    await    svctm    %util
  /dev/xvda      0.00    0.00  200.00  150.00   250.00   150.00    95.00
  ```  
  🔴 **Issue:** The `await` column showed **250ms+ read latency**, which is **very high** for database workloads.  

---

## **3️⃣ Solution: Optimizing Database & Storage Configuration**  

✅ **Step 1: Added Indexing to Improve Query Performance**  
- Identified **frequently queried columns** and **added an index**:  
  ```sql
  CREATE INDEX idx_orders_status ON orders(status);
  ```  
- This allowed PostgreSQL to **quickly filter data**, reducing query time.  

✅ **Step 2: Upgraded RDS Instance Class for Better Disk IOPS**  
- Upgraded RDS from **`db.t3.medium` → `db.m5.large`**:  
  ```bash
  aws rds modify-db-instance --db-instance-identifier mydb --db-instance-class db.m5.large --apply-immediately
  ```  
- The **new instance had higher IOPS (Input/Output Operations Per Second)**, reducing disk read latency.  

✅ **Step 3: Enabled Read Replicas for Load Balancing**  
- Created a **read replica** to handle heavy read queries:  
  ```bash
  aws rds create-db-instance-read-replica     --db-instance-identifier mydb-replica     --source-db-instance-identifier mydb     --region us-east-1
  ```  
- Updated application logic to **send read queries to the replica**, reducing load on the primary database.  

✅ **Step 4: Enabled Amazon RDS Performance Insights**  
- Enabled **query monitoring** to detect future slow queries:  
  ```bash
  aws rds modify-db-instance --db-instance-identifier mydb --performance-insights-enabled
  ```  

---

## **4️⃣ Results & Impact**  

✅ **Faster Query Execution:**  
  - **Before:** Queries taking **60+ seconds**.  
  - **After:** Queries executing **in <5 seconds**.  

✅ **Reduced Disk Latency:**  
  - **Before:** `aws.rds.read_latency` **250ms+**.  
  - **After:** Read latency dropped to **50ms**.  

✅ **Improved Database Performance:**  
  - **Primary DB load reduced by 40%** after introducing **read replicas**.  
  - **IOPS usage reduced**, preventing high disk contention.  

✅ **Datadog Widget Now Shows:**  
  - **Lower disk I/O wait times** (`aws.rds.read_latency`).  
  - **Optimized query response times** (`pg_stat_statements.mean_time`).  

---

## **5️⃣ Final Interview Answer**  
**Interviewer:** *How did you detect and resolve a disk latency issue in a database-heavy application?*  

✅ **Your Answer:**  
*"While monitoring our Datadog dashboard, I noticed `aws.rds.read_latency` exceeding 250ms, causing slow database queries. I analyzed slow queries using `pg_stat_activity`, found full table scans, and improved performance by adding indexes. Additionally, I upgraded the RDS instance to `db.m5.large` for better IOPS, introduced a read replica to distribute read traffic, and enabled RDS Performance Insights for continuous monitoring. These optimizations reduced query execution time from 60+ seconds to <5 se...

🚀 **With this answer, you showcase:**  
- **Database performance monitoring skills** (using Datadog & RDS Performance Insights).  
- **Troubleshooting expertise** (identifying slow queries, analyzing disk I/O usage).  
- **Optimization knowledge** (indexing, scaling DB instances, adding read replicas).  
- **Real impact awareness** (query execution time improved 10x, reduced disk latency).  

---

✅ **Now, you're fully prepared to explain this performance optimization case in your SRE interview!** 🚀

