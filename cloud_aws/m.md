# 📡 Integrating Datadog with Slack & Conditional Notification Routing

## **🔹 Objective**
This guide explains how to:
1. **Integrate Datadog with Slack** to send alerts to different Slack channels.
2. **Use conditional logic** in Datadog notifications to route alerts based on the environment (e.g., `prod`, `staging`, `dev`).
3. **Understand the templating language** used in Datadog monitors.

---

## **1️⃣ Enable Slack Integration in Datadog**
1. Go to **Datadog Console** → **Integrations** → Search for **Slack**.
2. Click **Install** and authorize Datadog to access your Slack workspace.
3. Add the **Slack Webhook URL** to Datadog.

✅ **Now, Datadog can send alerts to Slack.**

---

## **2️⃣ Configure Slack as a Notification Channel**
1. Go to **Datadog Console** → **Monitors** → **Manage Notification Channels**.
2. Click **New Notification** → Select **Slack**.
3. Enter the **Slack Channel Name** (e.g., `#alerts-production`).
4. Save the configuration.

✅ **Datadog can now send alerts to a specific Slack channel.**

---

## **3️⃣ Use Conditional Logic for Different Slack Channels**
Datadog supports **conditional routing** based on environment variables (`prod`, `staging`, `dev`).

### **🔹 Example: Routing Alerts to Different Slack Channels**
When creating a monitor, in the **Notification Message** section, use:
```yaml
{{#is_alert}}
  {{#is_match environment "prod"}} 
    @slack-alerts-production
  {{/is_match}}
  {{#is_match environment "staging"}}
    @slack-alerts-staging
  {{/is_match}}
  {{#is_match environment "dev"}}
    @slack-alerts-development
  {{/is_match}}
{{/is_alert}}
```
✅ **This ensures:**
- Alerts from `prod` go to `@slack-alerts-production`.
- Alerts from `staging` go to `@slack-alerts-staging`.
- Alerts from `dev` go to `@slack-alerts-development`.

### **🔹 Example: Custom Alert Message with Environment-Based Routing**
```yaml
🚨 Alert: High CPU Usage on {{host.name}} in {{environment}} 🚨

{{#is_match environment "prod"}} @slack-alerts-production {{/is_match}}
{{#is_match environment "staging"}} @slack-alerts-staging {{/is_match}}
{{#is_match environment "dev"}} @slack-alerts-development {{/is_match}}
```
✅ **Datadog will dynamically send alerts to the correct Slack channel based on the environment tag.**

---

## **4️⃣ What is This Language Called?**
The language used in **Datadog monitor notifications** is called **Datadog Monitor Notification Templating**, which is based on a **Handlebars-like syntax**.

### **🔹 Key Features of Datadog Templating**
1️⃣ **Conditional Logic**
```yaml
{{#is_match environment "prod"}} @slack-alerts-production {{/is_match}}
```
✅ **Routes alerts based on environment.**

2️⃣ **Dynamic Variables**
```yaml
Alert: High CPU Usage on {{host.name}} in {{environment}}
```
✅ **Replaces `{{host.name}}` with the affected host.**

3️⃣ **Loops & Filtering**
```yaml
{{#each tags}} - {{.}} {{/each}}
```
✅ **Iterates over all tags in an alert.**

### **🔹 What is This Language Called?**
This **is not pure Handlebars.js**, but a **Datadog-specific templating language inspired by Handlebars**.

✅ You can refer to it as:
- **Datadog Monitor Notification Templating**
- **Datadog Templating Language (Handlebars-like syntax)**

🔗 **Official Docs:** [Datadog Monitor Notification Variables](https://docs.datadoghq.com/monitors/notify/variables/)

---

## **🚀 Summary**
| **Step** | **Task** |
|----------|---------|
| **1️⃣ Enable Slack Integration** | Connect Datadog to Slack. |
| **2️⃣ Configure Slack as Notification Channel** | Add Slack as a Datadog notification method. |
| **3️⃣ Use Conditional Logic** | Route alerts to different Slack channels based on environment. |
| **4️⃣ Understand Datadog Templating** | Uses a Handlebars-like syntax for dynamic alerts. |

✅ **Now, Datadog will dynamically send alerts to Slack based on the environment!** 🚀
