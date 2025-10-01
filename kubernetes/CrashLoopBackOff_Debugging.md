# Scenario: CrashLoopBackOff Issue with a Web Application Pod

## Step 1: The Initial Situation

You deployed a web application to a Kubernetes cluster, but after a few minutes, the pod enters a CrashLoopBackOff state. The application works locally, but in the Kubernetes cluster, it continuously restarts and fails.

## Step 2: Investigating the Pod Logs

To understand why the pod is failing, you start by inspecting the pod logs to look for error messages or exceptions. You use the following command:

```bash
kubectl logs <pod-name> --previous
```

The logs show this error message:

```
Error: Cannot find module 'express'
```

This indicates that the application is unable to locate a required dependency (express), suggesting that it might not have been installed correctly.

## Step 3: Describing the Pod

Next, you describe the pod to gather more context. You run:

```bash
kubectl describe pod <pod-name>
```

The output shows this key event:

```
Events:
  Type     Reason     Age   From               Message
  ----     ------     ----  ----               -------
  Normal   Scheduled  3m    default-scheduler  Successfully assigned default/web-app-pod to node-1
  Normal   Pulled     3m    kubelet, node-1    Container image "web-app:latest" already present on machine
  Normal   Created    3m    kubelet, node-1    Created container web-app-container
  Normal   Started    3m    kubelet, node-1    Started container web-app-container
  Warning  BackOff    2m    kubelet, node-1    Back-off restarting failed container
```

From this, you can see the pod was initially created successfully, but it is repeatedly failing to restart. The error message isn't conclusive about why, so you suspect it might be a dependency issue or a misconfiguration.

## Step 4: Check Resource Requests and Limits

You decide to check the pod's resource allocation to ensure it's not being killed due to resource constraints, such as out of memory. You see the following resource section in the pod specification:

```yaml
resources:
  requests:
    memory: "64Mi"
    cpu: "250m"
  limits:
    memory: "128Mi"
    cpu: "500m"
```

After seeing this, you realize that the resources might be insufficient for your application. While this doesn't seem to be the immediate cause of the CrashLoopBackOff, it's still good to ensure that your pod has enough resources to avoid issues in the future.

## Step 5: Examine Docker Image and Configuration

Now, you focus on the image itself. Based on the error in the logs, it seems that the express module wasn't installed. This suggests that there might have been an issue with the image build.

You check the Dockerfile used to build the image and realize that the npm install command wasn't running correctly during the build process. The Dockerfile contains this step:

```dockerfile
RUN npm install
```

Upon closer inspection, you realize that there was no COPY command to bring over the package.json file into the container during the build. This is likely why the dependencies (including express) were not installed correctly.

## Step 6: Rebuild and Redeploy the Image

You fix the Dockerfile by adding the missing COPY command:

```dockerfile
COPY package.json /app/
RUN npm install
```

You rebuild the image and push it to the container registry:

```bash
docker build -t web-app:latest .
docker push web-app:latest
```

After that, you update the Kubernetes deployment to use the new image:

```bash
kubectl set image deployment/web-app-deployment web-app-container=web-app:latest
```

## Step 7: Confirm Pod Restart and Health

You then check if the pod is still in the CrashLoopBackOff state. Running:

```bash
kubectl get pods
```

The output shows that the pod is now in the Running state, and the CrashLoopBackOff error is gone.

```
NAME                           READY   STATUS    RESTARTS   AGE
web-app-pod-xyz                1/1     Running   0          4m
```

This confirms that the image is now working correctly.

## Step 8: Monitoring and Alerts with Datadog

To avoid future issues, you set up monitoring and alerting for the pod's resource usage using **Datadog**. Datadog automatically collects metrics from Kubernetes, including CPU, memory, and pod restarts.

Here’s how you can set up alerts in Datadog:

1. **Ensure the Datadog Agent is installed on your Kubernetes cluster**. Follow the [official Datadog Kubernetes integration guide](https://docs.datadoghq.com/integrations/kubernetes/) to install and configure the Datadog Agent.

2. **Create a Datadog Monitor for Pod Restarts**.
   - Go to **Monitors > New Monitor** in Datadog and choose the **Kubernetes** integration.
   - Use the **`kubernetes.pod.restart.count`** metric to create an alert for pod restarts.

3. **Monitor Query**: Create a query to check if the pod has restarted more than 5 times in the last 10 minutes:

   ```plaintext
   sum:kubernetes.pod.restart.count{*} by {pod_name, cluster_name} > 5
   ```

4. **Alert Configuration**:
   - Trigger the alert if the pod restart count exceeds 5 in the past 10 minutes.
   - Set the severity to **Critical**.
   - Add the following annotations:
     - **Summary**: "Pod restarted more than 5 times in 10 minutes"
     - **Description**: "Check the application logs and resource usage."

5. **Set Notification Channels**: Choose how you’d like to be notified, e.g., email, Slack, or other integrations.
```

## Final Conclusion

**Cause**: The pod failed because the necessary dependency (express module) wasn’t installed in the image.

**Solution**: The issue was resolved by fixing the Dockerfile to ensure the npm install command worked correctly by copying the package.json file into the container.

**Prevention**: Set up monitoring and alerts using Prometheus to detect pod restarts early, and consider setting appropriate resource limits to avoid future resource-related issues.

## Follow-Up Questions from Interviewer:

### Scaling:
"How would you handle scaling the application if it begins to receive more traffic than a single pod can handle?"

### Resilience:
"What steps would you take if the pod still remains in a CrashLoopBackOff state even after fixing the resource limits?"

### Configuration Management:
"How would you ensure that the environment variables and configuration files are properly injected into the pods in Kubernetes?"