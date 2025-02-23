# **Apache Kafka Quick Reference Guide**

## **1️⃣ What is Kafka?**
Apache Kafka is a **distributed event streaming platform** used for **real-time data processing**. It enables applications to publish, subscribe, store, and process streams of records efficiently.

✅ **Core Features:**  
- **High Throughput** → Handles millions of messages per second  
- **Fault-Tolerant** → Data replication across brokers  
- **Scalability** → Can be expanded dynamically  
- **Durability** → Uses disk storage for reliable event retention  

---

## **2️⃣ Kafka Core Concepts**

### **1. Topics & Partitions**  
- **Topic** → Logical channel where events are sent (e.g., `user_signups`).  
- **Partition** → Topics are divided into **multiple partitions** for parallel processing.  
- **Offset** → Each message in a partition gets a unique ID (**offset**) to track its position.  

### **2. Producers & Consumers**  
- **Producers** → Publish messages to a topic.  
- **Consumers** → Read messages from topics.  
- **Consumer Groups** → Consumers in a group **split the load** of reading messages.  

### **3. Brokers & Zookeeper**  
- **Broker** → A Kafka server that **stores and serves messages**.  
- **Cluster** → Multiple brokers working together.  
- **Zookeeper** → Manages **broker metadata** and **leader election** for partitions.  

---

## **3️⃣ Kafka Consumer Groups & Streams API**  
- **Consumer Groups** → Messages are distributed across multiple consumers for scalability.  
- **Kafka Streams API** → Real-time data processing framework for transforming and aggregating data.  

---

## **4️⃣ Kafka Connect & Schema Registry**  
- **Kafka Connect** → Integrates Kafka with external databases, cloud storage, etc.  
- **Schema Registry** → Ensures message structure consistency across topics.  

---

## **5️⃣ Monitoring MSK Kafka with Datadog**
As an **SRE**, monitoring **Amazon MSK (Managed Kafka)** is crucial to ensure performance, availability, and reliability. Using **Datadog**, we can create **custom dashboards** that visualize MSK metrics.

📌 **Key AWS MSK Metrics to Monitor** → [AWS MSK Metrics Documentation](https://docs.aws.amazon.com/msk/latest/developerguide/metrics-details.html)

### **1️⃣ Kafka Broker Health (Cluster Stability)**
| **Metric**                | **Datadog Widget Type** | **Purpose** |
|---------------------------|-----------------------|-------------|
| `Kafka.BrokerCount`       | **Timeseries Graph**  | Monitor the number of active brokers in the cluster. |
| `Kafka.ActiveControllerCount` | **Gauge Widget** | Shows how many controllers are active (should be **1 per cluster**). |
| `Kafka.OfflinePartitionsCount` | **Alert Widget** | Detects if any partitions are **offline** (critical alert). |

✅ **Dashboard Setup:**  
- **Timeseries Widget** → `Kafka.BrokerCount` to track brokers over time.  
- **Gauge Widget** → `Kafka.ActiveControllerCount` to ensure only **1 active controller** exists.  
- **Alert Rule** → Notify if `Kafka.OfflinePartitionsCount > 0` (Partitions are down).  

---

### **2️⃣ Kafka Topic Performance (Producer & Consumer Activity)**
| **Metric**                  | **Datadog Widget Type** | **Purpose** |
|-----------------------------|-----------------------|-------------|
| `Kafka.RecordsPerSecond`    | **Timeseries Graph**  | Measures messages written per second. |
| `Kafka.BytesInPerSec`       | **Timeseries Graph**  | Tracks incoming message throughput. |
| `Kafka.BytesOutPerSec`      | **Timeseries Graph**  | Monitors outbound message throughput. |

✅ **Dashboard Setup:**  
- **Timeseries Graph** → Show `Kafka.RecordsPerSecond` to track producer speed.  
- **Comparison Graphs** → `Kafka.BytesInPerSec` vs. `Kafka.BytesOutPerSec` (Identify bottlenecks).  

---

### **3️⃣ Consumer Lag (Message Processing Delay)**
| **Metric**                | **Datadog Widget Type** | **Purpose** |
|---------------------------|-----------------------|-------------|
| `Kafka.ConsumerLag`       | **Timeseries Graph**  | Shows how far consumers are behind producers. |
| `Kafka.MaxLag`            | **Alert Widget**      | Triggers if lag is too high (delayed processing). |

✅ **Dashboard Setup:**  
- **Timeseries Graph** → Monitor `Kafka.ConsumerLag` for all consumer groups.  
- **Alert Rule** → Notify if `Kafka.MaxLag` exceeds a threshold.  

---

### **4️⃣ Kafka Broker Resource Utilization**
| **Metric**                     | **Datadog Widget Type** | **Purpose** |
|---------------------------------|-----------------------|-------------|
| `Kafka.CpuUtilization`          | **Gauge Widget**      | Tracks CPU usage of brokers. |
| `Kafka.MemoryUsage`             | **Gauge Widget**      | Monitors JVM memory consumption. |
| `Kafka.DiskUsed`                | **Timeseries Graph**  | Tracks disk space used per broker. |

✅ **Dashboard Setup:**  
- **Gauge Widget** → Display CPU and memory usage per broker.  
- **Timeseries Graph** → Track `Kafka.DiskUsed` over time (prevent out-of-space errors).  

---

### **5️⃣ Kafka Replication & Reliability**
| **Metric**                  | **Datadog Widget Type** | **Purpose** |
|-----------------------------|-----------------------|-------------|
| `Kafka.UnderReplicatedPartitions` | **Alert Widget** | Detects partitions missing replicas. |
| `Kafka.IsrShrinksPerSec`    | **Timeseries Graph**  | Measures in-sync replica fluctuations. |

✅ **Dashboard Setup:**  
- **Alert Rule** → Notify if `Kafka.UnderReplicatedPartitions > 0` (indicates failures).  
- **Timeseries Graph** → Show `Kafka.IsrShrinksPerSec` to detect replication instability.  

---

## **6️⃣ How This Datadog Dashboard Helps an SRE**  
As an **SRE**, this **Datadog dashboard** provides:  
✅ **Real-time Kafka health monitoring** (Brokers, partitions, active controllers).  
✅ **Producer & consumer activity visualization** (Throughput, message flow).  
✅ **Consumer Lag tracking** (Detect processing slowdowns).  
✅ **Kafka resource utilization insights** (CPU, Memory, Disk usage).  
✅ **Replication & reliability alerts** (Detect under-replicated partitions).  

🚀 **With this setup, an SRE can proactively detect & resolve Kafka performance issues!**  

---

## **✅ Final Summary (Interview Ready Guide)**
| **Concept**             | **Key Takeaways** |
|-------------------------|------------------|
| **Topics & Partitions** | Data is divided into partitions for scalability |
| **Producers & Consumers** | Producers write, Consumers read, **Consumer Groups** balance load |
| **Kafka Streams API** | Real-time data transformation and aggregation |
| **Kafka Connect** | Integrates Kafka with databases, cloud storage, etc. |
| **Schema Registry** | Ensures data structure consistency across topics |
| **Transactions** | Provides exactly-once message delivery |
| **MSK Monitoring** | **Datadog Dashboard** tracks Kafka performance and health |

🚀 **Now you're fully prepared for Kafka SRE interviews!**  

