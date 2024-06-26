
# Creating Cluster and its required resources

For creating Kubernetes cluster along with its network and other component, I am using Terraform.
We have different tool as well like Ansible, Cloud formation but each one have its own limitation.
Ansible can not store the state of infrastructure and cloud formation is paid tool by AWS which having limitation to AWS resources.
On other hand Terraform is free tool which supporting storing statefile at different location along with vast community support and have provider for almost each tool which we can consider of in DevOps field.

In this repository [cluster-setup](cluster-setup) directory contain all the Terraform configuration files
Directory structure for **cluster-setup**
```
cluster-setup
├── cluster
│   ├── main.tf
│   ├── provider.tf
│   └── variable.tf
├── dex
├── ingress
│   ├── main.tf
│   ├── provider.tf
│   ├── values.yal
│   └── variable.tf
├── monitoring
│   └── rule.yaml
├── network
│   ├── main.tf
│   ├── output.tf
│   ├── provider.tf
│   └── variable.tf
├── post-init-cluster
│   ├── main.tf
│   ├── provider.tf
│   └── variable.tf
└── velero
```
**Dex, monitoring and velero modules are empty, I have mentioned just for understanding**

## Network
- Network folder contains configuration file related to VPC, subnet, routing and different component of network.
- it consist of 2 availability zone for **high availability** so even if one az goes down we have compute power to schedule out application in another az. 
![Subnets](assets/network/subnet.png)<br>
- Also all the worker nodes are in private subnet so that **they cannot be publicly accessible**, and for internet connection in private subnet I am using NAT Gateway which is managed NAT instance by AWS.
![NAT](assets/network/nat.png)<br>
![Route](assets/network/route.png)<br>
- For creating network, I am using **Terraform AWS provider**


## Cluster
- Cluster consist of EKS cluster along with its component like Node group, storage volume (EBS) autoscaling group, launch template and some security groups and IAM role.
![Cluster](assets/cluster/cluster.png)<br>
- Autoscaling group **fault toleration** to our cluster, it spin up instances immediately if our current instance/s is mark unhealthy in EC2. We have *min, max and desire* configuration for managing those instances.
![Autoscaling](assets/cluster/autoscaling.png)<br>
![Node](assets/cluster/nodegroup.png)<br>
- We can also use spot node along with on demand node to manage cost in out infrastructure as spot node is ~70% cheaper than on demand
- Security group manages in out access to our network and some IAM roles with policies are also get created for nodes to access aws resources like autoscaling.
![Info](assets/cluster/clusterinfo.png)<br>

## post-init-cluster
- Additional component like storage class, cluster autoscaler, vault authentication mechanism installing different operators include in post init.
- All those tool help us to manage workload in our cluster.
![storage](assets/post-init/storage.png)<br>
- In out module we have storageclass to dynamically creates volume for us, cluster-autoscaler to increase resources in cluster if we are exhausing existing one to provide availability and fault-tolerance.
- I also include Hashicorp vault configuration to manage secrets throughout the ci/cd pipeline. It is also useful for providing temporary access to DB and AWS env.
![Vault](assets/post-init/vault.png)<br>

## auth security
- This module consist of dex and login ingress setup.
- If you have Active Directory or any other authenticating service mechanisms you can install dex to provide group bases access control to user.
- Lets say you have group k8s:Dev in AD and you want to provide them only read only access then you can achieve this by dex configuration.
- Dex along with login url gives you ability to provide short term access to Kubernetes
- This is a secure way for providing access to Kubernetes cluster
- Below configuration provide access only for 24h. It uses dex authenticator for authentication.
```
config:
  connectors:
  - config:
      clientID: <client id>
      clientSecret: <client secret>
      redirectURI: <redirect url>
      tenant: <tenant id>
    id: microsoft
    name: Microsoft
    type: microsoft
  expiry:
    idTokens: 24h
    signingKeys: 6h
  frontend:
    issuer: Vignet
    issuerUrl: <issuer URL>
    theme: coreos
  issuer: <issuer url>
```

## Velero
- Velero is used for backup purpose, so even if accidently you delete your env you will have backup to restore it.
- It has different plugins for different clouds provider to backup external resources like RDS and EBS.
- You have to mentioned backup location to keep your backup.
- You also can create backup schedule which help to periodically created backup as per your requirement.
```
configuration:
  backupStorageLocation:
  - bucket: openinnovation-velero-backups
    config:
      region: ap-south-1
    name: aws
    prefix: openinnovation-velero-backups
    provider: aws
```
- We can also specify ttl with backup

## Ingress
- Ingress module is required to configure the URL's of your application.
- We have different other way to expose out app as well like LoadBalancer service but then we have to create load balancer for each url resulting increase cost.
- It create one loadbalancer service in your aws env
```
☁  openinnovationai [master] ⚡  k get svc -n ingress|
Warning: short name "svc" could also match lower priority resource services.tap.linkerd.io
nginx-ingress-ingress-nginx-controller                  LoadBalancer   172.20.192.94    a733965d042b14903bfd651ec71d888d-1619646725.us-east-1.elb.amazonaws.com   80:31364/TCP,443:30619/TCP
```

## Monitoring
- Monitoring module consist of prometheus, grafana, alertmanager, thanos, newrelic setup.
- Prometheus help us to collect metrics within out cluster and even if our app is not supporting prometheus metrics we can use exporter to send prometheus readable data from application.
- Grafana useful for creating dashboard, which make it easy to understand current state of cluster
- Alertmanager is used to notify users through different channels when something goes wrong in the cluster.


- [Main Page](/README.md)
- **Process explanation**
  - [Creating Cluster and its required resources](/ClusterSetup.md)
  - [Explaining CD process for Cluster](/ClusterDeploymentCD.md)
  - [Explaining CD process for Application](/AppDeploymentCD.md)
  - [Explain monitoring and alerting process](/Monitoring.md)
  - [Integration of Vault](/VAULT.md)