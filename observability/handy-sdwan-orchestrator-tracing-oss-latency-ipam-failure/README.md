# 📡 Distributed Tracing & Bottleneck Resolution in Vodafone "Handy" SD-WAN

Welcome to the **FastAPI OpenTelemetry Tracing** project folder.

This directory documents a real-world Site Reliability Engineering (SRE) scenario from my tenure at **_VOIS (Vodafone Intelligent Solutions)**. It demonstrates how I implemented Distributed Tracing to diagnose and resolve critical latency and silent failure issues in Vodafone's internal SD-WAN orchestration platform, **Handy**.

## 📁 Directory Contents

* 📄 [Detailed Case Study & Tracing Analysis](handy-sdwan-tracing-case-study.md)
  * The core documentation detailing the business context, the debugging process using Jaeger, and the root-cause analysis of the microservice bottlenecks (`oss-fulfillment-api` and `ipam-manager`).
* 🐍 [app/main.py](app/main.py)
  * A simplified FastAPI code snippet demonstrating how the OpenTelemetry Python SDK was instrumented to trace inter-service communication.

## 🎯 Key Engineering Highlights

* **Full-Stack Observability:** Implemented `OpenTelemetry` instrumentation in Python/FastAPI microservices and exported traces to **Jaeger**.
* **Performance Optimization:** Identified a critical 1.5s latency bottleneck in legacy OSS integration and guided its resolution.
* **Error Visibility:** Uncovered a silent failure (`IP_POOL_EXHAUSTED`) during IPAM allocation that was causing partial SD-WAN site provisioning without alerting the network engineers.
