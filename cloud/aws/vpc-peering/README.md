# 🌐 Inter-VPC Connectivity: VPC Peering & Non-Transitive Routing

Welcome to the **VPC Peering** project folder.

This directory demonstrates the implementation of secure, private network connectivity between isolated Virtual Private Clouds (VPCs) using AWS VPC Peering. It specifically addresses the architectural constraint of non-transitive routing in AWS.

## 📁 Directory Contents

* 📄 [Detailed Case Study & Architecture](vpc-peering-non-transitive-routing.md)
  * The core documentation detailing the business problem, network architecture, and the step-by-step resolution of transitive routing failures.
* 🛠️ [terraform/](terraform/)
  * Infrastructure as Code (IaC) files to provision the multiple VPCs, subnets, peering connections, route tables, and security groups.
* 📖 [terraform_documentation.md](terraform/terraform_documentation.md)
  * Technical documentation for the Terraform implementation.

## 🎯 Key Engineering Highlights

* **Secure Inter-VPC Communication:** Establishing direct network links between VPCs using the AWS backbone, ensuring traffic never traverses the public internet.
* **Architecting for Constraints:** Actively demonstrating and resolving the non-transitive nature of AWS VPC Peering (A -> B and B -> C does *not* imply A -> C).
* **Granular Traffic Control:** Managing complex routing tables, Security Groups, and Network ACLs across multiple peered environments to maintain a strict security posture.