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
```bash
sudo yum install amazon-cloudwatch-agent -y
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-config-wizard
```
Configure the agent to **scrape logs from:**
- `/var/log/tomcat/catalina.out`
- `/app/ThingWorx/logs/application.logs`

#### **🔄 Separate Log Groups per Application & Instance**
Modify the **CloudWatch Agent config** (`/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json`):
```json
{
    "logs": {
        "logs_collected": {
            "files": {
                "collect_list": [
                    {
                        "file_path": "/var/log/tomcat/catalina.out",
                        "log_group_name": "/tomcat/app1/instance-$(hostname)",
                        "log_stream_name": "{instance_id}"
                    },
                    {
                        "file_path": "/app/ThingWorx/logs/application.logs",
                        "log_group_name": "/tomcat/app2/instance-$(hostname)",
                        "log_stream_name": "{instance_id}"
                    }
                ]
            }
        }
    }
}
```
Restart the agent:
```bash
sudo systemctl restart amazon-cloudwatch-agent
```

### **2️⃣ Create CloudWatch Alarms for Log Patterns**
Example: Detecting "ERROR" in logs for specific applications:
```bash
aws logs put-metric-filter --log-group-name "/tomcat/app1/instance-i-xxxxx" \
 --filter-name "TomcatErrorFilter-App1" --filter-pattern "ERROR" \
 --metric-transformations metricName=TomcatErrorCount,metricNamespace=Tomcat,metricValue=1
```
```bash
aws logs put-metric-filter --log-group-name "/tomcat/app2/instance-i-yyyyy" \
 --filter-name "TomcatErrorFilter-App2" --filter-pattern "ERROR" \
 --metric-transformations metricName=TomcatErrorCount,metricNamespace=Tomcat,metricValue=1
```

### **3️⃣ Use Metric Dimensions for EC2 Instances**
```bash
aws logs put-metric-filter --log-group-name "/var/log/tomcat/catalina.out" \
 --filter-name "TomcatErrorFilter" --filter-pattern "ERROR" \
 --metric-transformations metricName=TomcatErrorCount,metricNamespace=Tomcat,metricValue=1,dimensions=InstanceId
```

### **4️⃣ Notify SRE Team & Developers via SNS**
Create an SNS topic:
```bash
aws sns create-topic --name TomcatAlerts
```
Subscribe email recipients:
```bash
aws sns subscribe --topic-arn arn:aws:sns:us-east-1:xxxxxxx:TomcatAlerts --protocol email --notification-endpoint dev-team@example.com
```
Create an alarm based on **instance-specific logs**:
```bash
aws cloudwatch put-metric-alarm --alarm-name "TomcatErrorAlarm-App1" \
 --metric-name "TomcatErrorCount" --namespace "Tomcat" \
 --statistic "Sum" --threshold 1 --comparison-operator "GreaterThanThreshold" \
 --dimensions "Name=InstanceId,Value=i-xxxxx" \
 --evaluation-periods 2 --alarm-actions arn:aws:sns:us-east-1:xxxxxxx:notify
```

---

🚀 **This setup ensures deep monitoring and proactive alerts for multiple Tomcat instances and applications running across different EC2 instances. Let me know if you need further refinements!**