# **Case Study: Database Connection Scaling & Monitoring in RDS Using Datadog & HikariCP**

## **🚀 Scenario: Hitting Maximum Database Connections in RDS**  

### **1️⃣ Problem: Database Connection Limit Reached**  
- Our RDS database had a **maximum connection limit of 400**, and we observed frequent **connection exhaustion**.  
- **Datadog monitoring** showed **`aws.rds.database_connections` peaking at 390-400**, causing **application slowdowns & failed requests**.  

✅ **Recommended Datadog Widgets for RDS Monitoring:**  
1. **`RDS Database Connections - Usage`**  
   - **Metric:** `aws.rds.database_connections` → Tracks **current active connections**.  
   - **Widget Type:** **Timeseries Graph** tracking connection usage over time.  
   - **Alert Trigger:** **If database connections exceed 380 for more than 5 minutes**.  

2. **`RDS Connection Saturation - API Wise`** *(Optional - Future Enhancement)*  
   - **Metric:** Custom metric to monitor **connections used per API service**.  
   - **Widget Type:** **Timeseries Graph / Top List** showing highest-consuming services.  

🔍 **Initial Investigation:**  
- We confirmed **which microservices were consuming the highest number of connections**.  
- To **quickly reduce load**, we adjusted **replica scaling** in staging & production.

---

## **2️⃣ Immediate Fix: Scaling Down Replicas to Reduce Connection Load**  

✅ **Step 1: Reduce the Number of Replicas in Staging & Production**  
- **Staging:** Reduced **replicas from 2 to 1** for high-consuming microservices.  
- **Production:** Reduced **replicas from 3 to 2** for the same services.  
- **Applied changes using Kubernetes (EKS) Deployment scaling:**  
  ```bash
  kubectl scale deployment <microservice-name> --replicas=1 -n staging
  kubectl scale deployment <microservice-name> --replicas=2 -n production
  ```  

✅ **Step 2: Create a Datadog Alarm for Connection Saturation**  
To monitor **when connections exceed 380**, we created a Datadog alert.

📌 **Datadog Alarm Configuration:**  
- **Monitor Type:** **Metric Alert**  
- **Metric to Monitor:** `aws.rds.database_connections`  
- **Condition:** **Trigger if active connections exceed 380 for more than 5 minutes**  
- **Query for Datadog Monitor:**  
  ```text
  avg(last_5m):avg:aws.rds.database_connections{db-instance:mydb} > 380
  ```  
- **Trigger Thresholds:**  
  - **Warning Level:** `350` (sends early warning)  
  - **Critical Level:** `380` (triggers PagerDuty & Slack alerts)  

✅ **Datadog Alarm Setup Steps:**  
1. **Go to Datadog → Monitors → Create New Monitor.**  
2. **Choose "Metric" Monitor Type.**  
3. **Set Query: `avg:aws.rds.database_connections{db-instance:mydb} > 380 over last 5 minutes`.**  
4. **Set Warning Threshold at `350`, Critical Threshold at `380`.**  
5. **Trigger notification to Slack & PagerDuty on critical alerts.**  
6. **Save & Activate the Monitor.**  

📌 **Impact:**  
- **Immediate alerts if connections exceed 380.**  
- **Prevents DB connection exhaustion & service failures.**  
- **Helps teams react before full saturation.**  

---

## **3️⃣ Recommended Approaches for Fetching Database Connections per API in Datadog**  

🚨 **The team asked me to explore how we could monitor database connections per API.**  
✅ **I provided two options:**  

### **🔹 Option 1: Using RDS Performance Insights** *(Future Implementation - Costly)*  
- **Amazon RDS Performance Insights** can track **query-level and session-level database connections**.  
- **Steps to enable API-wise DB connection monitoring:**  
  1. **Enable Performance Insights** in AWS RDS.  
  2. **Analyze queries per API by filtering session identifiers.**  
  3. **Send query execution stats to Datadog.**  
- 📌 **Downside:** This approach **incurs extra AWS costs**, so it was put **on hold for future implementation**.  

### **🔹 Option 2: Logging Connection Usage from Application (HikariCP Approach - Implemented)**  
- **Instead of AWS Performance Insights, we used HikariCP’s built-in logging.**  
- Developers **instrumented HikariCP** to log:  
  - **Total connections**  
  - **Active connections**  
  - **Idle connections**  
- ✅ **Benefit:** No extra AWS costs—**all monitoring is done in Datadog logs**.  

---

## **4️⃣ Implementing HikariCP-Based Database Connection Monitoring in Datadog**  

✅ **Step 1: Created a Grok Parser for HikariCP Logs in Datadog Pipelines**  
To extract **Total, Active, and Idle** connections, I created a **Grok Parser** in **Datadog log pipelines** using sample logs.

📌 **Example HikariCP Log Sample:**  
```text
HikariPool-1 - Total: 100, Active: 70, Idle: 30, Waiting: 5
```  

📌 **Datadog Grok Parsing Rule:**  
```text
HikariPool-%{number:pool_id} - Total: %{number:total_connections}, Active: %{number:active_connections}, Idle: %{number:idle_connections}, Waiting: %{number:waiting_connections}
```  

✅ **Step 2: Created Measurement Facets in Datadog**  
- **Extracted values from logs:**  
  - `@total_connections`
  - `@active_connections`
  - `@idle_connections`  
- These were added as **measurement facets** to filter logs based on database connection state.  

✅ **Step 3: Created Metrics from Parsed Facets**  
- Converted extracted values into **Datadog metrics**:  
  - `custom.rds.hikaricp.total_connections`  
  - `custom.rds.hikaricp.active_connections`  
  - `custom.rds.hikaricp.idle_connections`  

✅ **Step 4: Displayed HikariCP Metrics on Datadog RDS Dashboard**  
- **Widget:** Timeseries Graph to **track connection usage trends**.  
- **Threshold Alerts:** Triggered if **active connections exceeded a safe threshold**.  

📌 **Impact:**  
- **Full visibility into total, active, and idle DB connections.**  
- **Reduced connection saturation issues.**  
- **No extra AWS cost—purely Datadog log-based monitoring.**  

---

## **5️⃣ Final Interview Answer**  
**Interviewer:** *How did you detect and resolve a database connection issue in RDS?*  

✅ **Your Answer:**  
*"Our team noticed that we were reaching the **maximum allowed database connections (400)** in RDS. We first implemented a **Datadog alarm** on `aws.rds.database_connections` to alert when usage exceeded **380 connections**. To quickly reduce load, we **scaled down high-consuming microservices in staging and production**.  

Next, the team requested a way to **track database connections per API**. I provided **two recommendations**:  
1. **Using RDS Performance Insights (future option, extra AWS cost).**  
2. **Using HikariCP connection pooling logs (implemented, no extra cost).**  

We then **created a Grok parser in Datadog** to extract **Total, Active, Idle connections** from **HikariCP logs**. These parsed values were converted into **Datadog metrics** and displayed on our **RDS dashboard**. This provided **real-time visibility into database connection usage** without incurring extra costs."*  

🚀 **With this answer, you showcase:**  
- **Cloud-native monitoring skills** (Datadog alarms, log parsing, custom metrics).  
- **Database connection optimization** (Scaling replicas, optimizing connection pooling).  
- **Cost-awareness in monitoring decisions** (Log-based vs. AWS-based solutions).  
- **Cross-team collaboration** (Providing monitoring insights to Dev & Ops teams).  

---

✅ **Now, you're fully prepared to explain this database connection case in your SRE interview!** 🚀

