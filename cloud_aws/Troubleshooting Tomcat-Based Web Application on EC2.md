## 🚀 Troubleshooting Tomcat-Based Web Application on EC2

If your **Tomcat-based web application on EC2** is inaccessible, the **first point of failure to check is the ALB Health Checks**. If an instance is marked **unhealthy** by ALB, it will not receive traffic. Let’s troubleshoot step by step.

---

## **🔍 Step 1: Check ALB Health Status**
1️⃣ Navigate to **AWS Console → EC2 → Target Groups**.  
2️⃣ Select the **Target Group** associated with your ALB.  
3️⃣ Check the **Registered Targets** section:
   - **Healthy** ✅ → ALB is successfully reaching Tomcat. Issue may be elsewhere (e.g., app error).  
   - **Unhealthy** ❌ → ALB cannot reach Tomcat. Move to Step 2.  

💡 **Command to check ALB health status using AWS CLI:**
```bash
aws elbv2 describe-target-health --target-group-arn arn:aws:elasticloadbalancing:region:account-id:targetgroup/name/xxxxxxx
```

---

## **🔍 Step 2: Verify ALB Health Check Configuration**
1️⃣ Go to **ALB → Target Group → Health Checks**.  
2️⃣ Ensure the following are correctly set:
   - **Protocol:** HTTP  
   - **Port:** `8080` (default for Tomcat)  
   - **Path:** `/health` (or `/actuator/health` if using Spring Boot)  
   - **Timeout:** `5s`  
   - **Interval:** `10s`  
   - **Unhealthy threshold:** `3`  

💡 **Command to check ALB health check settings via AWS CLI:**
```bash
aws elbv2 describe-target-groups --target-group-arns arn:aws:elasticloadbalancing:region:account-id:targetgroup/name/xxxxxxx
```

---

## **🔍 Step 3: Manually Test Health Check Endpoint**
### **1️⃣ Verify Tomcat is Running**
SSH or SSM into the instance:
```bash
aws ssm start-session --target i-xxxxxxxx
```
Check Tomcat status:
```bash
systemctl status tomcat
```
If **Tomcat is not running**, restart it:
```bash
sudo systemctl restart tomcat
```

### **2️⃣ Test Connectivity from ALB to EC2**
Run **cURL from another instance or local machine**:
```bash
curl -I http://<EC2-IP>:8080/health
```
💪 **Expected output (200 OK)** → Tomcat is responding correctly.  
🚫 **Failure (Connection Refused or Timeout)** → Move to Step 4.

---

## **🔍 Step 4: Check Security Group & Network ACLs**
### **1️⃣ Verify EC2 Security Group (SG)**
Ensure ALB is allowed to reach Tomcat:
```bash
aws ec2 describe-security-groups --group-ids sg-xxxxxxx
```
💪 **Required SG Rules:**
- **Inbound Rule (Allow ALB → EC2)**
  ```bash
  aws ec2 authorize-security-group-ingress --group-id sg-ec2xxxxxx --protocol tcp --port 8080 --source-group sg-albxxxxxx
  ```
- **Outbound Rule (Allow EC2 → Database, Internet, etc.)**

### **2️⃣ Verify Network ACLs**
Check if NACL rules are blocking traffic:
```bash
aws ec2 describe-network-acls
```
💪 Ensure **inbound & outbound rules** allow traffic **on port 8080**.

---

## **🔍 Step 5: Check EC2 Health & Status Checks**  
If ALB health checks **fail** but security settings are correct, the EC2 instance itself may have **underlying OS or hardware issues**.

### **1️⃣ Check EC2 Status in AWS Console**
- Navigate to **EC2 → Instances**  
- Find the affected instance and check:
  - **Instance State**: `Running` or `Stopped`
  - **Status Checks**:
    - ✅ **System Status Check Passes** → AWS infrastructure is fine.
    - ❌ **System Status Check Fails** → Underlying AWS issue (e.g., host failure).
    - ✅ **Instance Status Check Passes** → OS is working correctly.
    - ❌ **Instance Status Check Fails** → Possible OS/kernel crash.

💡 **AWS CLI Command to Check EC2 Health:**
```bash
aws ec2 describe-instance-status --instance-ids i-xxxxxxxx
```

---

## **🔍 Step 6: Configure CloudWatch Agent & Alarms**

### **1️⃣ Install CloudWatch Agent**

The **Amazon CloudWatch Agent** allows us to collect logs and metrics from our EC2 instances, providing deeper monitoring and alerting capabilities.

#### **1️⃣ Install the CloudWatch Agent**
On each EC2 instance where Tomcat is running, install the CloudWatch Agent:
```bash
sudo yum install amazon-cloudwatch-agent -y
```
Run the **CloudWatch Agent Configuration Wizard** to set up basic configurations:
```bash
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-config-wizard
```

#### **2️⃣ Configure CloudWatch Agent to Collect Tomcat Logs**
The CloudWatch Agent needs to be configured to **scrape logs from the following locations:**
- `/var/log/tomcat/catalina.out` (Tomcat logs)
- `/app/ThingWorx/logs/application.logs` (Application-specific logs)

Modify the **CloudWatch Agent configuration file** located at:
```bash
/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
```
Add the following configuration:
```json
{
    "logs": {
        "logs_collected": {
            "files": {
                "collect_list": [
                    {
                        "file_path": "/var/log/tomcat/catalina.out",
                        "log_group_name": "/tomcat/app/instance-$(hostname)",
                        "log_stream_name": "{instance_id}"
                    },
                    {
                        "file_path": "/app/ThingWorx/logs/application.logs",
                        "log_group_name": "/tomcat/app/instance-$(hostname)",
                        "log_stream_name": "{instance_id}"
                    }
                ]
            }
        }
    }
}
```
#### **3️⃣ Restart the CloudWatch Agent**
After modifying the configuration file, restart the agent to apply changes:
```bash
sudo systemctl restart amazon-cloudwatch-agent
```

---

### **2️⃣ Use Metric Dimensions to Differentiate EC2 Instances**
Since multiple EC2 instances are running Tomcat, we need to track errors per **EC2 instance** using **metric dimensions**.

#### **1️⃣ Create a CloudWatch Metric Filter to Track Errors Per Instance**
```bash
aws logs put-metric-filter --log-group-name "/var/log/tomcat/catalina.out" \
 --filter-name "TomcatErrorFilter" --filter-pattern "ERROR" \
 --metric-transformations metricName=TomcatErrorCount,metricNamespace=Tomcat,metricValue=1,dimensions=InstanceId
```
✅ **What It Does:**
- Uses a **single log group for all instances**.
- **Adds `InstanceId` as a filter**, so we can still track errors **per EC2 instance**.
- Helps differentiate errors from **different servers running the same application**.

💡 **When to Use:**  
👉 If multiple EC2 instances run **the same application**, but we need to know **which instance is failing**.

---

### **3️⃣ Notify SRE Team & Developers via SNS**
When a critical issue is detected, an **Amazon SNS (Simple Notification Service) topic** can be used to send notifications to the SRE and development teams.

#### **1️⃣ Create an SNS Topic for Notifications**
```bash
aws sns create-topic --name TomcatAlerts
```
#### **2️⃣ Subscribe Team Members to SNS Notifications**
Send alerts to the SRE and developers' email addresses:
```bash
aws sns subscribe --topic-arn arn:aws:sns:us-east-1:xxxxxxx:TomcatAlerts --protocol email --notification-endpoint dev-team@example.com
```
#### **3️⃣ Create a CloudWatch Alarm for Log-Based Errors**
Once log-based error tracking is in place, an **alarm** can be set up to trigger notifications when a threshold is reached:
```bash
aws cloudwatch put-metric-alarm --alarm-name "TomcatErrorAlarm" \
 --metric-name "TomcatErrorCount" --namespace "Tomcat" \
 --statistic "Sum" --threshold 1 --comparison-operator "GreaterThanThreshold" \
 --dimensions "Name=InstanceId,Value=i-xxxxx" \
 --evaluation-periods 2 --alarm-actions arn:aws:sns:us-east-1:xxxxxxx:notify
```
This alarm **monitors the error count** in the Tomcat logs and **triggers an SNS notification** if the error threshold is exceeded.

---

🚀 **This setup ensures deep monitoring, proactive alerts, and log-based error tracking for multiple Tomcat instances and applications. Let me know if you need further refinements!**


🚀 **This setup ensures deep monitoring and proactive alerts for multiple Tomcat instances and applications running across different EC2 instances. Let me know if you need further refinements!**