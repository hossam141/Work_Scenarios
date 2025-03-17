# 📌 Integrating Auto Scaling Group (ASG) with Launch Template & ALB Target Group

## **🔹 Goal**
We want an **Auto Scaling Group (ASG)** to **dynamically launch EC2 instances** based on a **Launch Template**, and **register them to an Application Load Balancer (ALB) Target Group** for traffic distribution.

---

## **🔹 Simplified Flow**
```plaintext
1️⃣ Create a Launch Template → Defines EC2 instance settings (AMI, Instance Type, Security Group).
2️⃣ Create a Target Group → ALB uses this to distribute traffic to ASG instances.
3️⃣ Create an Application Load Balancer (ALB) → Routes incoming requests to the Target Group.
4️⃣ Create an Auto Scaling Group (ASG) → Uses the Launch Template to launch instances and register them to the Target Group.
5️⃣ Define Scaling Policies → Automatically increase/decrease instances based on demand.
```

---

## **🔹 Step-by-Step Implementation**

### **1️⃣ Create a Launch Template**
```bash
aws ec2 create-launch-template \
  --launch-template-name MyWebAppTemplate \
  --version-description "Version 1" \
  --launch-template-data '{
    "ImageId": "ami-0abcdef1234567890",
    "InstanceType": "t3.medium",
    "SecurityGroupIds": ["sg-12345678"],
    "IamInstanceProfile": { "Name": "EC2Role" },
    "UserData": "IyEvYmluL2Jhc2ggZWNobyAnU3RhcnRpbmcgd2ViIHNlcnZlcic="  # (Base64-encoded startup script)
  }'
```
✅ **This template ensures new instances launch with pre-defined configurations.**

---

### **2️⃣ Create an ALB Target Group**
```bash
aws elbv2 create-target-group \
  --name MyWebAppTG \
  --protocol HTTP \
  --port 80 \
  --vpc-id vpc-12345678 \
  --target-type instance
```
✅ **This target group will register EC2 instances launched by ASG.**

---

### **3️⃣ Create an Application Load Balancer**
```bash
aws elbv2 create-load-balancer \
  --name MyWebAppALB \
  --subnets subnet-11111111 subnet-22222222 \
  --security-groups sg-12345678
```
✅ **The ALB routes incoming traffic to the target group.**

---

### **4️⃣ Create an Auto Scaling Group Using the Launch Template**
```bash
aws autoscaling create-auto-scaling-group \
  --auto-scaling-group-name MyWebAppASG \
  --launch-template "LaunchTemplateName=MyWebAppTemplate,Version=1" \
  --min-size 2 \
  --max-size 5 \
  --desired-capacity 2 \
  --target-group-arns arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/MyWebAppTG/abcdef123456 \
  --vpc-zone-identifier "subnet-11111111,subnet-22222222"
```
✅ **This ASG:**
- Launches **at least 2 instances** and scales up to **5**.
- Registers new instances into the **ALB Target Group** for load balancing.

---

### **5️⃣ Define a Scaling Policy (Optional)**
```bash
aws autoscaling put-scaling-policy \
  --auto-scaling-group-name MyWebAppASG \
  --policy-name ScaleUp \
  --adjustment-type ChangeInCapacity \
  --scaling-adjustment 1 \
  --cooldown 60
```
✅ **ASG now increases instances by `+1` if triggered by load metrics.**

---

## **🔹 Final Flow Summary**
```plaintext
1️⃣ Launch Template  → Defines EC2 instance configurations.
2️⃣ Target Group     → Registers healthy instances for ALB.
3️⃣ ALB              → Routes incoming traffic to Target Group.
4️⃣ Auto Scaling     → Dynamically launches/removes EC2 instances.
5️⃣ Scaling Policy   → Ensures availability by adjusting instance count.
```
🚀 **Now, our ASG launches instances dynamically and registers them to the ALB Target Group for traffic distribution!**
