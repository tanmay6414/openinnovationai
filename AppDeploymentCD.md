# Automated Deployment for Application
- Uses ArgoCD for CD process. Flux dont have any UI and not possible to give access to dev and QA. Tekton need lots of configuration and showing intermidiate issue.

# Installation of ArgoCD
- ArgoCD is installed as Helm chart on kubenrtes cluster.
- have different component like controller, server, notification controller,workflow and repo server.
- Helm values file for confuring argo with EKS
```
crds:
  keep: false
server:
  rbacConfig:
    policy.default: role:readonly
  extraArgs:
   - --insecure
  env:
  - name: AWS_ACCESS_KEY_ID
    value: <access key>
  - name: AWS_SECRET_ACCESS_KEY
    value: <secret-key>
  ingress:
    enabled: true
    hosts:
      - argocd.mycluster.com
    ingressClassName: nginx
  config:
    url: https://argocd.mycluster.com
dex:
  enabled: false

applicationSet:
  extraEnv:
  - name: AWS_ACCESS_KEY_ID
    value: <access key>
  - name: AWS_SECRET_ACCESS_KEY
    value: <secret-key>

controller:
  env:
  - name: AWS_ACCESS_KEY_ID
    value: <access key>
  - name: AWS_SECRET_ACCESS_KEY
    value: <secret-key>
```
- Once Deployed create one ArgoCD [application](argo/cd/app-of-app.yaml) and mentioned the githubrepository folder and apply this manually 
- You also need to configure cluster, helm repo, harbor repo with it, you can find configuration [here](argo/) in this repository.
- Because you created app of app you dont need to apply those file manually, just push changes on master.

# Configuring CD of application
- Write [ArgoCD application](argo/cd/qa/frontend/frontend.yaml) yaml file.
```
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: frontend-app-qa
  namespace: argo-cd
spec:
  syncPolicy:
    automated:
      prune: true
  destination:
    name: TestCluster
    namespace: qa
  project: testcluster
  sources:
  -  chart: frontend
     helm:
      releaseName: frontend
      valueFiles:
      - $values/argo/cd/qa/frontend/values.yaml
     repoURL: demo.goharbor.io/openinnovationai
     targetRevision: 0.1.0
  -  repoURL: 'https://github.com/tanmay6414/openinnovationai.git'
     targetRevision: master
     ref: values
```
- **sync** policy define auto sync behaviour
- **destination** define the cluster on which we want to deploy application.
- **sources** define the helm repo and github repo for helm chart and values file.
- We can provide access for dev and qa as per there requirnment, they can take ownership of there app.
![App](assets/argo/apps.png)
![Sync](assets/argo/sync.png)
