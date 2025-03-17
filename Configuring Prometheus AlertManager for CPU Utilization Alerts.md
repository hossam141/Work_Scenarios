# 📌 Configuring Prometheus AlertManager for CPU Utilization Alerts (Without Kubernetes)

## **🔹 Overview**
In this guide, we set up an **alerting system** for CPU utilization using:
- **Node Exporter** (collects CPU metrics from the machine)
- **Prometheus** (stores and queries CPU metrics)
- **AlertManager** (sends notifications based on alert rules)

---

## **🔹 1️⃣ System Architecture & File Placements**
```
/etc/prometheus/
  ├── prometheus.yml  # Prometheus main configuration
  ├── alert-rules.yml  # Alerting rules for CPU utilization
  ├── alertmanager.yml  # AlertManager configuration
/usr/local/bin/
  ├── node_exporter  # Node Exporter binary
/var/lib/prometheus/
  ├── prometheus.db  # Prometheus storage
```
✅ **Each component works as follows:**
- **Node Exporter** → Collects CPU usage & exposes it on `http://<host>:9100/metrics`
- **Prometheus** → Scrapes Node Exporter metrics & evaluates alert rules
- **AlertManager** → Sends alerts when CPU exceeds a defined threshold

---

## **🔹 2️⃣ Install & Configure Node Exporter**
### ✅ **Step 1: Install Node Exporter**
```bash
wget https://github.com/prometheus/node_exporter/releases/latest/download/node_exporter-linux-amd64.tar.gz
tar xvf node_exporter-linux-amd64.tar.gz
mv node_exporter-linux-amd64/node_exporter /usr/local/bin/
```

### ✅ **Step 2: Start Node Exporter Service**
```bash
nohup node_exporter &
```
✅ Node Exporter is now running on `http://localhost:9100/metrics`.

---

## **🔹 3️⃣ Configure Prometheus to Scrape Node Exporter**
### ✅ **Step 1: Edit `prometheus.yml`**
```yaml
scrape_configs:
  - job_name: 'node_exporter'
    static_configs:
      - targets: ['localhost:9100']
```
✅ Prometheus will scrape CPU metrics from Node Exporter every 15 seconds.

### ✅ **Step 2: Restart Prometheus**
```bash
systemctl restart prometheus
```
✅ **Verify** by checking `http://localhost:9090/targets` (should list `node_exporter`).

---

## **🔹 4️⃣ Define CPU Utilization Alert Rule in Prometheus**
### ✅ **Step 1: Create `alert-rules.yml`**
```yaml
groups:
  - name: node-alerts
    rules:
      - alert: HighCPUUsage
        expr: 100 * (1 - avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m]))) > 80
        for: 2m
        labels:
          severity: critical
        annotations:
          summary: "High CPU Usage on {{ $labels.instance }}"
          description: "CPU usage is above 80% for more than 2 minutes."
```
✅ **This alert will trigger if CPU usage exceeds 80% for 2 minutes.**

### ✅ **Step 2: Modify `prometheus.yml` to Load Alert Rules**
```yaml
rule_files:
  - "/etc/prometheus/alert-rules.yml"
```
### ✅ **Step 3: Restart Prometheus**
```bash
systemctl restart prometheus
```
✅ **Verify alert activation in Prometheus UI → `http://localhost:9090/alerts`**

---

## **🔹 5️⃣ Configure AlertManager to Send Notifications**
### ✅ **Step 1: Create `alertmanager.yml`**
```yaml
route:
  receiver: 'slack'
receivers:
  - name: 'slack'
    slack_configs:
      - channel: '#alerts'
        send_resolved: true
        api_url: 'https://hooks.slack.com/services/XXXXXXXXX'
```
### ✅ **Step 2: Start AlertManager**
```bash
nohup alertmanager --config.file=/etc/prometheus/alertmanager.yml &
```
✅ **Now, when CPU usage exceeds 80%, an alert is sent to Slack.**

---

## **🚀 Summary: Alerting Flow**
| **Step** | **Component** | **Action** |
|----------|-------------|------------|
| **1** | **Node Exporter** | Collects CPU metrics from the server |
| **2** | **Prometheus** | Scrapes CPU metrics & evaluates alert rules |
| **3** | **AlertManager** | Triggers alert if CPU > 80% for 2 mins |
| **4** | **Notification** | Sends alert to Slack |

✅ **With this setup, CPU utilization is continuously monitored, and alerts are sent when thresholds are breached! 🚀**
