# 🛡️ AWS Zero-Trust: VPC Interface Endpoint for S3

Welcome to the **Secure S3 Access via PrivateLink** project folder. 

This directory contains a complete, production-grade enterprise scenario demonstrating how to securely route isolated backend traffic to Amazon S3 without using Internet Gateways, NAT Gateways, or exposing sensitive data to the public internet.

## 📁 Directory Contents

* 📄 **[Detailed Case Study & Architecture](./vpc-interface-endpoint-explicit-routing-s3.md)**
  * The core documentation file. Read this for the full business context, architecture diagrams (Mermaid.js), and the step-by-step traffic flow sequence (Control & Data planes).
* 🛠️ **[terraform/](./terraform/)**
  * Modular Infrastructure as Code (IaC) files used to provision the isolated VPC, Private Subnets, Security Groups, and the VPC Interface Endpoints.

## 🎯 Key Engineering Highlights
* **Zero-Trust Networking**: Strict network isolation keeping all traffic on the AWS Global Backbone.
* **Cost Optimization (FinOps)**: Eliminating NAT Gateway hourly provisioning and per-GB data processing fees.
* **Explicit DNS Routing**: Preventing VPC-wide DNS conflicts by intentionally disabling `private_dns_enabled` and using endpoint-specific URLs for granular microservice control.

---
*⬅️ Return to the [Main Repository](../../../README.md)*