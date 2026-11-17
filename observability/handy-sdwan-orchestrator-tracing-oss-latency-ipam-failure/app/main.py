import asyncio
from fastapi import FastAPI
from opentelemetry import trace
from opentelemetry.trace import SpanKind
from opentelemetry.sdk.resources import Resource
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter

# ==========================================
# 1. OpenTelemetry Setup (Handy SD-WAN)
# ==========================================
resource = Resource.create({
    "service.name": "sdwan-orchestrator",
    "service.version": "3.1.0"
})

otlp_exporter = OTLPSpanExporter(endpoint="http://localhost:4317", insecure=True)
tracer_provider = TracerProvider(resource=resource)
span_processor = BatchSpanProcessor(otlp_exporter)
tracer_provider.add_span_processor(span_processor)
trace.set_tracer_provider(tracer_provider)

tracer = trace.get_tracer(__name__)

# ==========================================
# 2. FastAPI Application
# ==========================================
app = FastAPI(title="Handy SD-WAN Orchestrator")

@app.post("/api/v1/sdwan/provision")
async def provision_site():
    """Main entry point for SD-WAN site provisioning."""
    with tracer.start_as_current_span("provision_site") as span:
        span.set_attribute("site.id", "SIT-98765")
        span.set_attribute("customer.id", "VODA-CORP-5678")
        
        # Step 1: Validate Contract via OSS API (The Latency Bottleneck)
        await validate_oss_contract()

        # Step 2: Allocate IP via IPAM API (The Silent Failure)
        await allocate_vrf_subnet()

        span.set_attribute("provisioning.status", "submitted")
        return {"status": "success", "message": "SD-WAN Site Provisioning Initiated"}

async def validate_oss_contract():
    """Calls the legacy OSS Fulfillment API (Simulates 1.5s latency)."""
    with tracer.start_as_current_span("POST /api/v1/oss/validate", kind=SpanKind.CLIENT) as span:
        span.set_attribute("peer.service", "oss-fulfillment-api")
        span.set_attribute("validation.phase", "contract-check")
        
        # Simulating the exact 1.5s delay discovered in Jaeger
        await asyncio.sleep(1.5)
        span.set_attribute("http.status_code", 200)

async def allocate_vrf_subnet():
    """Calls the IPAM Manager API (Simulates the silent IP_POOL_EXHAUSTED error)."""
    with tracer.start_as_current_span("POST /api/v1/ipam/allocate", kind=SpanKind.CLIENT) as span:
        span.set_attribute("peer.service", "ipam-manager")
        span.set_attribute("ipam.requested_subnet", "/30")
        span.set_attribute("ipam.vrf", "vrf-enterprise-main")
        
        # Simulating the error found in Jaeger
        span.set_attribute("error", True)
        span.set_attribute("error.code", "IP_POOL_EXHAUSTED")
        span.set_attribute("http.status_code", 500)
        
        await asyncio.sleep(0.5)
        # BUG: The Orchestrator silently catches this IPAM failure instead of aborting.
