# Integration of Vault
- Hashicorp-Vault is an application to store and manage secretes, providing temporary access securely.
- It is opensource software and enterprise version is also available with increase feature.
- I am deploying Vault in a Kubernetes cluster using helm package manager.
- **We can use vault in each step of our CI/CD process.**
- For jenkins Vault plugin is available and for Terraform we have a vault provider.
- For Kubernetes we need to configure our cluster with vault initially so that the deployment requesting secret from vault can authenticate.
- We also need a **vault-agent/Banzaicloud webhook** running in our cluster to mutate our pod with vault binary.
- Kubernetes configuration to vault can be found [here](/cluster-setup/post-init-cluster/main.tf).

# Flow
![VFlow](/assets/vault/Vault.jpg)<br><br>

# Configure Vault.
- I have created one ACL policy and one Kubernetes auth backend role for our cluster by providing access to all namespaces, serviceaccount and read access to whole kv path.
- You can create a role and policy with specific access only inside Vault.
- **ACL Policy**
![Policy](/assets/vault/policy.png) <br><br>
- **Kubernetes Role**
![Role](/assets/vault/role.png)<br><br>

# Configure Deployment to mutate vault secret
- After creating ACL policy and K8s role, I have setup my Kubernetes deployment to mutate vault secrets.
- For this, I have added annotation to the deployment in out helm chart.
- In our case, added annotation to both backend and database pod from [values.yaml](https://github.com/tanmay6414/openinnovationai-backend/blob/01e2d23eb30214b44c4239e1eb05ca405d90a78f/charts/backend/values.yaml#L24-L29) file.
![Annotation](/assets/vault/annotation.png)<br>
- After deploying helm chart with above changes, if we exec into pod and try to print all env variable then we get a vault path instead of actual secret value.
![path](/assets/vault/path.png)<br>
- To check actual secret. we need to run **vault-env** binary in **/vault** path
![secret](/assets/vault/secret.png)


- **Process explanation**
  - [Creating Cluster and its required resources](/ClusterSetup.md)
  - [Explaining CD process for Cluster](/ClusterDeploymentCD.md)
  - [Explaining CD process for Application](/AppDeploymentCD.md)
  - [Explain monitoring and alerting process](/Monitoring.md)
  - [Integration of Vault](/VAULT.md)