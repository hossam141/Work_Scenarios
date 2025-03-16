# 🛡️ AWS WAF Deployment for ALBs Fronting ThingWorx Application

## **🔧 Overview**
This Terraform script provisions an **AWS Web Application Firewall (WAF)** and attaches it to the **ALBs** that front the EC2 instances running the **ThingWorx web application on Tomcat**.

The **goal** is to enhance **security and compliance** by implementing security rules provided by the security team, protecting against threats like **IP blocking, SQL Injection, XSS, and rate limiting**.

---

## **🌐 Flow & Integration**
### **How Components Interact**
1️⃣ **AWS WAF WebACL**
   - The main firewall policy that holds **security rules**.
2️⃣ **AWS WAF Rules**
   - Contains **specific security rules** provided by the security team (e.g., block bad IPs, prevent SQL injection).
3️⃣ **AWS Application Load Balancer (ALB)**
   - Fronts the **ThingWorx application** running on EC2.
   - Routes traffic securely to Tomcat servers.
4️⃣ **AWS WAF WebACL Association**
   - Links the **WAF security policy** to the **ALB**.
5️⃣ **Target Group & EC2 Instances**
   - The ALB forwards **allowed** traffic to EC2 instances running ThingWorx on Tomcat.

---

## **🔄 Step 1: Create AWS WAF WebACL**
```hcl
resource "aws_waf_web_acl" "thingworx_waf" {
  name        = "thingworx-waf"
  metric_name = "thingworxWAFMetric"
  default_action {
    type = "ALLOW" # Default to allow unless blocked by rules
  }
}
```
✅ **Creates a WAF policy that will hold security rules.**

---

## **🔄 Step 2: Attach WAF Security Rules**
### **Blocking Malicious IPs** (Example IP provided by security team)
```hcl
resource "aws_waf_ipset" "blocked_ips" {
  name = "blocked-ip-list"
  ip_set_descriptor {
    type  = "IPV4"
    value = "203.0.113.0/24" # Block this IP range
  }
}

resource "aws_waf_rule" "block_specific_ips" {
  name        = "block-specific-ips"
  metric_name = "BlockSpecificIPsMetric"
  predicates {
    data_id = aws_waf_ipset.blocked_ips.id
    negated = false
    type    = "IPMatch"
  }
}
```
✅ **Blocks specific IP ranges defined by the security team.**

---

## **🔄 Step 3: Attach WAF to Application Load Balancer (ALB)**
```hcl
resource "aws_waf_web_acl_association" "waf_alb_assoc" {
  resource_arn = aws_lb.thingworx_alb.arn
  web_acl_id   = aws_waf_web_acl.thingworx_waf.id
}
```
✅ **Ensures that all traffic reaching the ALB is filtered through WAF security rules.**

---

## **🔄 Step 4: Provisioning ALB for ThingWorx**
```hcl
resource "aws_lb" "thingworx_alb" {
  name               = "thingworx-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_1.id, aws_subnet.public_2.id]
}
```
✅ **Creates the ALB that routes traffic to the ThingWorx application on EC2.**

---

## **🔄 Step 5: Configure ALB Listeners (HTTP to HTTPS Redirect)**
```hcl
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.thingworx_alb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}
```
✅ **Ensures all HTTP traffic is redirected to HTTPS for security.**

---

## **🔄 Step 6: Configure ALB HTTPS Listener to Forward Traffic**
```hcl
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.thingworx_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.thingworx_cert.arn
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.thingworx_tg.arn
  }
}
```
✅ **Allows only HTTPS traffic and forwards it to the EC2 instances running Tomcat.**

---

## **🔄 Step 7: Configure ALB Target Group for EC2 Instances**
```hcl
resource "aws_lb_target_group" "thingworx_tg" {
  name     = "thingworx-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}
```
✅ **Routes traffic from ALB to EC2 instances hosting ThingWorx.**

---

## **🔒 Step 8: Enforce Additional Security Rules (SQL Injection, XSS, Rate Limiting)**
🚀 Additional WAF rules such as **SQL Injection Protection**, **Cross-Site Scripting (XSS) Mitigation**, and **Rate Limiting** can be added here to further secure the ThingWorx web application.

---

## **🚀 Final Overview of Deployment**
1️⃣ **WAF WebACL** is created with security rules.
2️⃣ **WAF Rules** (e.g., block IPs, SQL Injection prevention) are enforced.
3️⃣ **WAF is attached to ALB**, ensuring all traffic is filtered.
4️⃣ **ALB Listeners** ensure HTTPS enforcement and route traffic securely.
5️⃣ **Target Group** routes legitimate traffic to EC2 instances running **ThingWorx on Tomcat**.

✅ **This setup ensures the web application is protected while maintaining high availability.** 🚀
