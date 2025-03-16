# 🛠️ VPC Peering via AWS Transit Gateway Across Multiple Accounts

## 🔍 **Overview**
In this setup, we establish **VPC peering via AWS Transit Gateway** between **different AWS accounts**, ensuring seamless communication while preventing **subnet overlap conflicts**. 

### **📌 Flow of Implementation**
1️⃣ **Create a Transit Gateway in the Central AWS Account.**
2️⃣ **Attach VPCs from Different AWS Accounts to the Transit Gateway.**
3️⃣ **Configure Route Tables to Enable Cross-VPC Communication.**
4️⃣ **Ensure Security Groups and Network ACLs Allow Traffic.**
5️⃣ **Test Connectivity to Verify Peering is Successful.**

---

## **1️⃣ Step 1: Create a Transit Gateway in the Central Account**
```hcl
resource "aws_ec2_transit_gateway" "main_tgw" {
  description                     = "Main Transit Gateway for Multi-Account Peering"
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"
}
```
✅ **Creates a shared Transit Gateway that will facilitate VPC communication.**

---

## **2️⃣ Step 2: Attach VPCs from Different AWS Accounts**
```hcl
resource "aws_ec2_transit_gateway_vpc_attachment" "vpc_attachment_1" {
  transit_gateway_id = aws_ec2_transit_gateway.main_tgw.id
  vpc_id             = aws_vpc.vpc_1.id
  subnet_ids         = aws_subnet.vpc_1_subnets[*].id
}

resource "aws_ec2_transit_gateway_vpc_attachment" "vpc_attachment_2" {
  transit_gateway_id = aws_ec2_transit_gateway.main_tgw.id
  vpc_id             = aws_vpc.vpc_2.id
  subnet_ids         = aws_subnet.vpc_2_subnets[*].id
}
```
✅ **Attaches VPCs from different AWS accounts to the Transit Gateway.**

---

## **3️⃣ Step 3: Configure Route Tables for Peering**
### **Add Routes in Transit Gateway Route Table**
```hcl
resource "aws_ec2_transit_gateway_route" "route_to_vpc_1" {
  destination_cidr_block         = aws_vpc.vpc_1.cidr_block
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc_attachment_1.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway.main_tgw.association_default_route_table_id
}

resource "aws_ec2_transit_gateway_route" "route_to_vpc_2" {
  destination_cidr_block         = aws_vpc.vpc_2.cidr_block
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc_attachment_2.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway.main_tgw.association_default_route_table_id
}
```
✅ **Configures routes so that traffic between VPCs can flow through the Transit Gateway.**

---

## **4️⃣ Step 4: Ensure Security Group & Network ACLs Allow Communication**
- **Update Security Groups** to allow inbound/outbound traffic between VPCs.
- **Check Network ACLs** to ensure no rules block inter-VPC communication.

✅ **Ensures traffic is allowed between connected VPCs.**

---

## **5️⃣ Step 5: Test Connectivity & Verify Peering Success**
1️⃣ **From an EC2 instance in VPC 1, ping an instance in VPC 2:**
```bash
ping <private-IP-of-EC2-in-VPC-2>
```
2️⃣ **Use traceroute to verify routing through Transit Gateway:**
```bash
traceroute <private-IP-of-EC2-in-VPC-2>
```
✅ **If the packets route correctly, the VPC peering via Transit Gateway is successfully configured.**

---

## **🚀 Final Summary of VPC Peering via Transit Gateway**
| **Step**                      | **Action** |
|--------------------------------|------------|
| **Create a Transit Gateway**   | Acts as the central communication hub |
| **Attach VPCs from AWS Accounts** | Connects VPCs across multiple accounts |
| **Configure Route Tables**     | Enables traffic flow between VPCs |
| **Update Security Groups & ACLs** | Ensures smooth and secure communication |
| **Test & Verify Connectivity** | Confirms successful VPC peering setup |

✅ **With this setup, VPCs from different AWS accounts communicate securely via AWS Transit Gateway, avoiding subnet overlap issues.** 🚀
