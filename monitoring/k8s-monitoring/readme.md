The Kubernetes Monitoring Helm chart is used for gathering, scraping, and forwarding Kubernetes telemetry data to a Grafana stack. This includes the ability to collect metrics, logs, traces, and continuous profiling data. The scope of this tutorial is to deploy the Kubernetes Monitoring Helm chart to collect pod logs and Kubernetes events.

```
helm upgrade --install --values values.yaml k8s grafana/k8s-monitoring -n monitoring