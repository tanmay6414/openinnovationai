
# Setup Monitoring and alerting on application
- I used prometheus stack for alerting and monitoring purpose
- Prometheus collect metrics thjroughout the cluster with help of its exporter.
- I have define a [PrometheusRule](cluster-setup/monitoring/rule.yaml) bases on out requirnment and can confiugure prometheus to send alert to alertmanagert.
- I have configured configure alert manager to send notification on different channel like slack, email pagerduty.
- Also Newrelic and pingdom to have synthetic check on out application URL and Newrelic scripted browser to ensure out application is up and running
- Finally we make use of Newrelic dashboard and grafana dashboard for data visualization
- We can use newrelic logs for observability purpose.
- We can also create a a on call schedule in pagerduty and route this alert to pagerduty, so that on call person get to know about any outages.

# Install Prometheus Stack
- Prometheus stack is installed as helm chart
- It include prometheus controller, alermanager controller, grafana, and thanos.
- **Helm values file for prometheus setup**
```
prometheus:
  ingress:
    enabled: true
    ingressClassName: nginx
    annotations: 
      kubernetes.io/ingress.class: nginx
    hosts:
    - metrics.mycluster.com
  prometheusSpec:
    externalUrl: "https://metrics.mycluster.com"
    alerting:
      alertmanagers:
        - namespace: monitoring
          name: alertmanager-main
          port: web
```
- **Helm values for alertmanager with sample receiver**
```
alertmanager:
  ingress:
    enabled: true
    ingressClassName: nginx
    annotations: 
      kubernetes.io/ingress.class: nginx
    hosts:
      - alerts.mycluster.com
  alertmanagerSpec: 
    externalUrl: "https://alerts.mycluster.com"
    config:
      global:
        slack_api_url: ""
        resolve_timeout: 5m
      route:
        receiver: "slack-receiver"
        group_by: ["alertname"]
        group_wait: 30s
        group_interval: 1m
        repeat_interval: 5m
        routes:
        - match:
          severity: critical
      receivers:
        - name: "slack-receiver"
          slack_configs:
            - api_url: ""
              channel: "#testchannel"
              send_resolved: true
              title: "[{{ .Status }}] {{ .GroupLabels.alertname }} {{ .CommonLabels.severity }}"
              text: "{{ .Annotations.summary }}\n{{ .Annotations.description }}"
```
- Apply default prometheus rule for kubenrtes (easily available on google)
- [Sample Rule](/cluster-setup/monitoring/rule.yaml)<br>
- Alert get trigger in alertmanager
![Manager](/assets/monitoring/alerts.png)<br>
- After intentinally draining a node we got below notification on slack.
![Alert](/assets/monitoring/alert.png)<br>


- [Main Page](/README.md)
- **Process explanation**
  - [Creating Cluster and its required resources](/ClusterSetup.md)
  - [Explaining CD process for Cluster](/ClusterDeploymentCD.md)
  - [Explaining CD process for Application](/AppDeploymentCD.md)
  - [Explain monitoring and alerting process](/Monitoring.md)
  - [Integration of Vault](/VAULT.md)