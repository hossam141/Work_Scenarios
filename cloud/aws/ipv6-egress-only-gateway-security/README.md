# 🛡️ AWS Zero-Trust: IPv6 Egress-Only Internet Gateway (EIGW)

Welcome to the **IPv6 Secure Egress via EIGW** project folder.

This directory contains a complete enterprise scenario demonstrating how to provide isolated backend microservices with secure, outbound-only IPv6 internet access for API updates, without exposing them to inbound threats or incurring IPv4 NAT Gateway charges.

## 📁 Directory Contents

* 📄 [Detailed Case Study & Architecture](ipv6-egress-only-gateway-security.md)
  * The core documentation file. Read this for the full business context, Mermaid.js architecture diagrams, and the zero-trust traffic flow sequence.

* 🛠️ [terraform/](terraform/)
  * Infrastructure as Code (IaC) files used to provision the Dual-Stack VPC, Private Subnets with auto-assigned IPv6, Route Tables, and the Egress-Only Internet Gateway (EIGW).

* 📖 [terraform_documentation.md](terraform/terraform_documentation.md)
  * The technical documentation explaining the Terraform architecture, resources, and deployment instructions.

## 🎯 Key Engineering Highlights

* **Strict Zero-Trust Isolation:** Allows backend instances to initiate outbound connections (e.g., fetching packages/updates) while implicitly blocking 100% of inbound internet traffic.
* **FinOps & Cost Elimination:** Egress-Only Internet Gateways are completely free. This architecture eliminates the need for expensive IPv4 NAT Gateways (saving hourly and per-GB processing fees).
* **Modern IPv6 Architecture:** Built for future-proof, dual-stack enterprise environments where globally routable IPv6 addresses are used within private subnets.