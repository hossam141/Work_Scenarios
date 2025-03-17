## **🔹 3️⃣ Configuring Prometheus AlertManager for CPU Utilization Alerts**

### ✅ **Step 1: Define a Prometheus Alert Rule**
1. Create a rule file **`alert-rules.yaml`**:
   ```yaml
   groups:
   - name: node-exporter
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
2. Apply the alert rule to Prometheus:
   ```bash
   kubectl apply -f alert-rules.yaml
   ```
✅ **This rule triggers an alert if CPU utilization exceeds 80% for 2 minutes.**

---

### ✅ **Step 2: Configure AlertManager to Send Notifications**
1. Edit or create **`alertmanager.yaml`**:
   ```yaml
   route:
     receiver: 'slack-notifications'
   receivers:
     - name: 'slack-notifications'
       slack_configs:
       - channel: '#alerts'
         send_resolved: true
         api_url: 'https://hooks.slack.com/services/XXXXXXXXX'
   ```
2. Apply the AlertManager configuration:
   ```bash
   kubectl apply -f alertmanager.yaml
   ```
✅ **This configuration sends high CPU alerts to Slack.**

---

## **🚀 Summary: AWS, EKS, and Alerting with Prometheus & AlertManager**
| **Integration** | **Steps** |
|---------------|---------|
| **AWS Account Integration** | Create an **IAM Role**, attach Datadog permissions, and link AWS to Datadog. |
| **EKS Cluster Integration** | Create **IAM Service Account**, install Datadog Agent using Helm. |
| **CPU Utilization Alerts** | Create **Prometheus alert rules**, configure AlertManager to send alerts (Slack, Email, etc.). |
| **Verify Installation** | Check **Datadog Agent logs & metrics** in Datadog UI. |

✅ With these steps, Datadog can monitor **AWS services & EKS**, and Prometheus AlertManager can **send alerts on high CPU usage!** 🚀
