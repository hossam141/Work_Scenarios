# 💰 AWS FinOps: VPC Gateway Endpoint for S3 (Zero-Cost Routing)

Welcome to the **S3 Cost Optimization via Gateway Endpoint** project folder.

This directory contains a complete enterprise scenario demonstrating how to provide isolated backend microservices with secure, high-throughput access to Amazon S3 without incurring NAT Gateway data processing charges or VPC Interface Endpoint hourly fees.

## 📁 Directory Contents

* 📄 [**Detailed Case Study & Architecture**](./vpc-gateway-endpoint-cost-optimization-s3.md)
  * The core documentation file. Read this for the full business context, Mermaid.js architecture diagrams, and the transparent traffic flow sequence via Route Table Prefix Lists.

* 🛠️ [**terraform/**](./terraform/)
  * Infrastructure as Code (IaC) files used to provision the VPC, Private Subnets, Route Tables, and the VPC Gateway Endpoint associations.

## 🎯 Key Engineering Highlights

* **FinOps & Cost Elimination**: 100% free data transfer to S3. Gateway Endpoints do not charge hourly fees or per-GB processing fees (unlike Interface Endpoints or NAT Gateways).
* **Transparent Application Routing**: Applications use standard public S3 URLs. No code changes or custom DNS names are required.
* **High Throughput**: Ideal for heavy data workloads (backups, big data analytics) as Gateway Endpoints are not bound by ENI bandwidth limits.

*⬅️ Return to the [Main Repository](../../../README.md)*