# Case Study: Troubleshooting Vodafone "Handy" SD-WAN Provisioning

## 📖 Enterprise Scenario & Business Context
At **_VOIS**, I supported **Handy**, a proprietary SD-WAN orchestration and provisioning solution used to configure Customer Premises Equipment (CPE) across Vodafone's enterprise network. The platform relies on a central **Python/FastAPI** microservice (`sdwan-orchestrator`) that coordinates with other internal domains.

**The Problem:** 
Network Operations Center (NOC) engineers reported two critical issues during enterprise rollouts:
1. **Severe Latency:** The site provisioning API was incredibly slow, causing timeout alerts on the frontend.
2. **Silent Failures:** Some sites appeared as "Provisioned" on the dashboard but had no IP addresses assigned, leading to routing failures.

Standard logging was too noisy and fragmented across different teams to quickly identify the bottleneck.

**The Solution:** 
I instrumented the `sdwan-orchestrator` FastAPI application using the **OpenTelemetry (OTel) Python SDK** and exported the traces to **Jaeger** to visualize the exact execution timeline and inter-service HTTP calls.

---

## 🏗️ Observability Architecture Diagram

*(The following diagram renders automatically on GitHub)*

```mermaid
graph TD
    %% Define styles
    classDef client fill:#f9f,stroke:#333,stroke-width:2px;
    classDef service fill:#bbf,stroke:#333,stroke-width:2px;
    classDef external fill:#eee,stroke:#333,stroke-width:2px,stroke-dasharray: 5 5;
    classDef observability fill:#f96,stroke:#333,stroke-width:2px;
    classDef error fill:#fcc,stroke:#f00,stroke-width:2px;

    %% Nodes
    UI["Frontend / NOC Dashboard"]:::client
    
    subgraph Vodafone Handy SD-WAN Platform
        Orchestrator["sdwan-orchestrator (FastAPI)"]:::service
        OTel_SDK["OpenTelemetry SDK (Instrumentation)"]:::observability
    end

    OSS["oss-fulfillment-api (Legacy System)"]:::external
    IPAM["ipam-manager (IP Address Management)"]:::error

    Collector["OTel Collector"]:::observability
    Jaeger["Jaeger UI (Trace Visualization)"]:::observability

    %% Traffic Flow
    UI -- "1. POST /provision" --> Orchestrator
    
    Orchestrator -- "2. POST /validate (1.5s Latency!)" --> OSS
    Orchestrator -- "3. POST /allocate (Silent 500 Error!)" --> IPAM
    
    %% Telemetry Flow
    Orchestrator -. "Generates Spans" .-> OTel_SDK
    OTel_SDK -. "Exports Traces (gRPC/HTTP)" .-> Collector
    Collector -. "Forwards Data" .-> Jaeger

    %% Notes
    note1[Bottleneck: 1.5s delay]
    note1 -.-> OSS
    
    note2[Failure: IP_POOL_EXHAUSTED]
    note2 -.-> IPAM
---

## 🔍 The Investigation & Jaeger Findings

After generating traces during a live provisioning request, I analyzed the trace timeline in the Jaeger UI. The total request took ~2.003 seconds.

### Finding 1: The Latency Bottleneck (1.5s Delay)
By analyzing the span timeline, I identified the exact source of the delay.
- **The Culprit Span:** `POST /api/v1/oss/validate`
- **Peer Service:** `oss-fulfillment-api`
- **Root Cause:** The orchestrator was making a synchronous HTTP call to a legacy Operations Support System (OSS) to validate the customer's contract. This legacy system took exactly **1.5 seconds** to respond, blocking the entire provisioning thread.

### Finding 2: The Silent Failure (`IP_POOL_EXHAUSTED`)
While inspecting the spans, I noticed an error tag on the IP allocation span, even though the main request returned an HTTP 200 OK.
- **The Culprit Span:** `POST /api/v1/ipam/allocate`
- **Peer Service:** `ipam-manager`
- **The Evidence (OTel Attributes):**
  * `error = true`
  * `error.code = "IP_POOL_EXHAUSTED"`
  * `ipam.vrf = "vrf-enterprise-main"`
- **Root Cause:** The IP Address Management (`ipam-manager`) service ran out of available `/30` subnets for that specific VRF. It returned a 500 error, but the `sdwan-orchestrator` had a flawed `try/except` block that swallowed the exception, proceeding with the provisioning flow and returning a false success to the UI.

---

## ⚙️ The Fix & SRE Impact

1. **Performance Tuning:** We collaborated with the OSS team to implement a Redis caching layer for contract validations, dropping the orchestrator's waiting time from **1.5s to ~40ms**.
2. **Error Handling & Reliability:** Fixed the exception handling in the `sdwan-orchestrator`. Now, if the `ipam-manager` fails, the orchestrator rolls back the transaction, returns an explicit 500 HTTP response, and triggers a PagerDuty alert to the network engineering team.
3. **Observability Culture:** Distributed tracing via OpenTelemetry is now a mandatory standard for all interactions within the Handy SD-WAN ecosystem, drastically reducing MTTR (Mean Time to Resolution) for inter-service communication issues.