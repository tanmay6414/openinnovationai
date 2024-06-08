# Open Innovation Assignment

### Problem Statement
You are tasked to implement a platform to support a microservices architecture composed of a backend service, frontend service and PostgreSQL database with the
following requirements
• Automated Deployment
• Fault Tolerant / Highly Available
• Secure
• Autoscaling

### Proposed Solution

- I am using Docker package and manage above application as it consistent and isolated environment deployment across different application.
- For orchestring docker container I am using Kubernetes. We have option like docker-sworm and other but kubenrtes have lots of advantages over such platform such as scalability, scheduling ease, easy administration, self healing, fault tolerent and kubenrtes is highly available along with good community support.
- I am using AWS public cloud for hosting all those component.
- For this solution, i am deploying Kubernetes cluster using EKS with managed node group. 
>EKS is managed Kubernetes service provided by AWS which provide high availability (3 master), Enhance security, easy upgrade statergy.
So that we can focus on system reliability rather than spending lots of time on administration.

### Creating Cluster and its required resources

For creating kubenrtes cluster along with its network and other component, I am using Terraform.
We have different tool as well like Ansible, Cloud formation but each one have its own limitation.
Ansible can not store the state of infrastructure and cloud formation is paid tool by AWS which having limitation to AWS resources.
On other hand Terraform is free tool which supporting storing statefile at different location along with vast community support and have provider for almost each tool which we can consider of in DevOps field.

In this repository [cluster-setuo](cluster-setup) directory contain all the Terraform configuration files
Directory structure for **cluster-setup**
```
cluster-setup
├── cluster
│   ├── main.tf
│   ├── provider.tf
│   └── variable.tf
├── dex
├── ingress
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
