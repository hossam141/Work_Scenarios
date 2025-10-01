
# Scenario: CoreDNS Service Issues in EKS Cluster

## Initial Situation:

You are managing a Kubernetes cluster in Amazon EKS, and you've recently deployed several microservices. Suddenly, services start failing to connect with each other using their DNS names (e.g., my-service.default.svc.cluster.local). Pods in the cluster cannot resolve internal Kubernetes service names, leading to network connectivity issues between pods.

The issue only affects the pods running inside the cluster; external DNS resolution seems to work fine (e.g., www.google.com resolves correctly). This suggests a problem with the CoreDNS service, which is responsible for internal DNS resolution in EKS.

## Step 1: Check CoreDNS Pods' Status

The first step is to check the status of the CoreDNS pods. Since CoreDNS handles all internal DNS queries in the cluster, any issue here would lead to service resolution failures.

Command:

```bash
kubectl get pods -n kube-system -l k8s-app=coredns
```

The output shows that one of the CoreDNS pods is failing to start, and the other is running:

```
NAME                       READY   STATUS    RESTARTS   AGE
coredns-7f9f8f4c9-j2xxl    1/1     Running   3          20m
coredns-7f9f8f4c9-l2t8f    0/1     Error     5          25m
```

You can see that the second pod (coredns-7f9f8f4c9-l2t8f) is in an Error state, while the first one is running fine. CoreDNS has two replicas for high availability, so the failure of one pod is still manageable. However, you need to find out why this pod is failing.

## Step 2: Check the Logs of the Failing CoreDNS Pod

You need to examine the logs of the failing CoreDNS pod to understand the underlying issue. You check the logs of the second pod to see if there are any error messages or clues.

Command:

```bash
kubectl logs coredns-7f9f8f4c9-l2t8f -n kube-system
```

The logs show the following error:

```
plugin/ready: Health check failed: failed to read from UDP connection
```

The error failed to read from UDP connection suggests a network connectivity issue that prevents CoreDNS from properly handling DNS queries. This could indicate a configuration issue, network issue, or even insufficient resources assigned to the CoreDNS pods.

## Step 3: Describe the CoreDNS Pod

Next, you describe the CoreDNS pod to gather more detailed information about any events or issues related to the pod's lifecycle.

Command:

```bash
kubectl describe pod coredns-7f9f8f4c9-l2t8f -n kube-system
```

The output shows the following key events:

```
Events:
  Type     Reason     Age   From               Message
  ----     ------     ----  ----               -------
  Normal   Scheduled  25m   default-scheduler  Successfully assigned kube-system/coredns-7f9f8f4c9-l2t8f to ip-192-168-10-12.ec2.internal
  Normal   Pulled     25m   kubelet, ip-192-168-10-12.ec2.internal  Container image "amazon/k8s-dns-kube-dns:1.14.10" already present on machine
  Normal   Created    25m   kubelet, ip-192-168-10-12.ec2.internal  Created container coredns
  Warning  BackOff    10m   kubelet, ip-192-168-10-12.ec2.internal  Back-off restarting failed container
```

The key point here is the BackOff event, which indicates that the container has failed and Kubernetes is trying to restart it but keeps hitting the same error. The issue seems related to network connectivity or resource allocation.

## Step 4: Inspect Resource Allocation

Given that the error may be related to resources, you check the CoreDNS deployment configuration to see if it has adequate resource requests and limits defined. EKS uses Amazon EC2 instances as worker nodes, and misconfigured resource requests can cause issues with service availability.

You describe the CoreDNS deployment to check resource allocation.

Command:

```bash
kubectl describe deployment coredns -n kube-system
```

The resource configuration in the deployment looks like this:

```yaml
resources:
  requests:
    memory: "100Mi"
    cpu: "200m"
  limits:
    memory: "200Mi"
    cpu: "500m"
```

In this case, the resource allocation seems reasonable for a small-scale setup, but CoreDNS might need more memory or CPU resources, especially if the cluster is larger or has high traffic.

## Step 5: Check Network Policy and Configuration

CoreDNS is deployed as a set of pods inside the kube-system namespace, and it uses UDP to communicate. If there is an incorrect network policy or misconfigured Security Group in Amazon VPC, it could block communication.

You check the Security Groups associated with the EKS worker nodes and ensure they allow UDP traffic on port 53, which CoreDNS needs to communicate.

VPC Security Group: Ensure the worker nodes can communicate with each other on the required ports.

Kubernetes Network Policy: Ensure no restrictive network policies are blocking the communication.

To verify the EKS VPC settings, you log into the AWS Management Console and check the VPC’s Security Groups. You verify that UDP port 53 is open between the worker nodes.

## Step 6: Update CoreDNS ConfigMap

After checking the resource allocation and networking, you notice that the CoreDNS ConfigMap could also be a potential issue. If the CoreDNS settings are incorrect, such as improper forwarding or caching settings, it could lead to failures.

You inspect the CoreDNS ConfigMap to look for issues with configuration.

Command:

```bash
kubectl get configmap coredns -n kube-system -o yaml
```

Upon reviewing, you find the following entry:

```
Corefile: |
  .:53 {
    errors
    health
    kube-dns.kube-system.svc.cluster.local
    cache 30
    forward . /etc/resolv.conf
  }
```

The line kube-dns.kube-system.svc.cluster.local is misconfigured and needs to be corrected. It should refer to kube-dns.kube-system.svc instead.

## Step 7: Apply Configuration Changes

You edit the CoreDNS ConfigMap to fix the DNS forwarding address and apply the changes.

Command:

```bash
kubectl edit configmap coredns -n kube-system
```

Correct the forwarding address in the Corefile:

```
Corefile: |
  .:53 {
    errors
    health
    kube-dns.kube-system.svc
    cache 30
    forward . /etc/resolv.conf
  }
```

After editing the ConfigMap, you restart the CoreDNS pods to apply the updated configuration.

Command:

```bash
kubectl rollout restart deployment coredns -n kube-system
```

## Step 8: Confirm Pod Restart and Health

Once the pods are restarted, you verify if the issue has been resolved.

Command:

```bash
kubectl get pods -n kube-system -l k8s-app=coredns
```

The output should now show that both CoreDNS pods are running correctly:

```
NAME                       READY   STATUS    RESTARTS   AGE
coredns-7f9f8f4c9-j2xxl    1/1     Running   3          45m
coredns-7f9f8f4c9-l2t8f    1/1     Running   5          45m
```

This confirms that CoreDNS is now functional, and DNS resolution should work.

## Step 9: Verify DNS Resolution

Finally, you test DNS resolution from within the cluster to ensure that the issue has been fully resolved.

Command:

```bash
kubectl run -i --tty --rm testpod --image=busybox --restart=Never --namespace=default -- /bin/sh
```

Inside the pod, test the DNS resolution for a Kubernetes service:

```bash
nslookup my-service.default.svc.cluster.local
```

If this resolves correctly and returns the service IP, then the DNS issue is fully resolved.

## Conclusion

**Cause**: The issue was caused by an incorrect CoreDNS configuration and networking issues.

**Solution**: Fixed the CoreDNS ConfigMap, updated DNS forwarding settings, and ensured proper network connectivity and resource allocation for CoreDNS pods.

**Prevention**: Set up monitoring and alerts using CloudWatch or Prometheus to detect DNS failures early and ensure CoreDNS is always available.

## Follow-Up Questions from Interviewer:

### Scaling DNS Services:
"How would you scale CoreDNS in EKS to handle increased traffic or a larger number of services?"

### Resilience and Failover:
"What steps would you take to ensure CoreDNS remains highly available in the event of a pod failure or network issue?"

### Monitoring:
"How would you monitor CoreDNS performance and detect DNS resolution failures in real-time?"
