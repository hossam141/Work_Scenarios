# 📊 Integrating PostgreSQL Schema Metrics (pg_activity) with Datadog

## 🔍 **Objective**
Monitor **PostgreSQL API connections** using `pg_activity` and send **real-time metrics** to Datadog for visualization and alerting.

---

## 🏛 **1️⃣ Database Side: PostgreSQL Configuration**
### **Enable Monitoring of Active Connections**
Run the following SQL query to allow PostgreSQL to track active connections:
```sql
ALTER SYSTEM SET track_activity_query_size = 2048;
SELECT pg_reload_conf();
```
✅ **Ensures PostgreSQL collects query-level activity.**

### **Create a View to Track API Connections**
```sql
CREATE VIEW api_connections AS 
SELECT datname AS database_name, 
       application_name AS api_name, 
       count(*) AS active_connections 
FROM pg_stat_activity 
GROUP BY datname, application_name;
```
✅ **Creates a structured view to fetch active connections per API.**

### **Grant Datadog User Read-Only Access**
```sql
CREATE USER datadog WITH PASSWORD 'your_secure_password';
GRANT CONNECT ON DATABASE your_db TO datadog;
GRANT SELECT ON api_connections TO datadog;
```
✅ **Allows Datadog to read API connection metrics securely.**

---

## 📡 **2️⃣ Datadog Side: PostgreSQL Integration**
### **Enable PostgreSQL Integration in Datadog**
1. Go to **Datadog Console** → **Integrations** → **PostgreSQL**.
2. Install and enable the **PostgreSQL integration**.

### **Modify Datadog Agent Configuration**
Edit the PostgreSQL config file **`postgres.d/conf.yaml`**:
```yaml
init_config:
instances:
  - host: <POSTGRES_HOST>
    port: 5432
    username: datadog
    password: your_secure_password
    dbname: your_db
    collect_activity_metrics: true  # Enables pg_stat_activity collection
    custom_queries:
      - query: "SELECT database_name, api_name, active_connections FROM api_connections;"
        columns:
          - name: database_name
            type: tag
          - name: api_name
            type: tag
          - name: active_connections
            type: gauge
```
✅ **Fetches API connection metrics and sends them to Datadog.**

### **Restart Datadog Agent**
```bash
sudo systemctl restart datadog-agent
```
✅ **Applies changes and starts sending data to Datadog.**

---

## 📊 **3️⃣ Visualizing Metrics in Datadog**
1. Go to **Datadog Dashboard** → **Create New Dashboard**.
2. Add a **Timeseries Graph**.
3. Select **Metric: `postgresql.active_connections`**.
4. Group by **`api_name`** to track API-specific connections.
5. Save and Monitor! 🚀

---

## 🔔 **4️⃣ Setting Up Alerts**
To get notified when API connections exceed a threshold:
1. Go to **Datadog Alerts** → **New Monitor**.
2. Choose **Metric Monitor**.
3. Select **Metric: `postgresql.active_connections`**.
4. Set **Threshold** (e.g., alert if > 100 connections).
5. Define **Notification Channels** (Slack, Email, etc.).
6. Click **Create Monitor**.

✅ **Now, you'll receive alerts if API connections spike!** 🚀

---

## **✅ Summary of Steps**
| **Step** | **Task** |
|----------|---------|
| **1️⃣ PostgreSQL Setup** | Enable `pg_stat_activity` & create a `VIEW` for API connections. |
| **2️⃣ Datadog Agent Setup** | Configure PostgreSQL integration & custom queries. |
| **3️⃣ Visualization** | Create a Datadog dashboard to monitor API connections. |
| **4️⃣ Alerting** | Set up Datadog alerts for connection spikes. |

🔹 **With this setup, Datadog will track PostgreSQL API connections in real-time!** 🚀
