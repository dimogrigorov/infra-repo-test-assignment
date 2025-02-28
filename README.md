# Build the terraform infrastructure - AWS EKS cluster

## How to initiate terraform with it's backend config
1. terraform init -backend-config="dev.conf"

## How to validate terraform 
2. terraform validate

## How to apply your terraform code and create managed EKS cluster on AWS
3. terraform apply  -var-file dev.tfvars  -auto-approve 

## Add and Update the Nginx Ingress controller Helm Repository (Optional)
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm fetch ingress-nginx/ingress-nginx --version <version>  # Optional: specify version
tar -xzf ingress-nginx-*.tgz
## Store value file separately:
helm show values ingress-nginx/ingress-nginx > values.yaml

## Install from the Local Nginx Ingress Chart
4. helm install my-nginx helm-charts/ingress-nginx/ingress-nginx-*.tgz -f helm-charts/ingress-nginx/values.yaml

# Steps to Install Flux in EKS Using Helm

## Prerequisites
✅ EKS Cluster up and running.
✅ kubectl configured to communicate with the cluster.
✅ Helm installed (helm version should return a valid version).
✅ GitHub Personal Access Token (PAT) with repo permissions (for GitOps).

## Add and Update the Flux Helm Repository (Optional)
helm repo add fluxcd https://charts.fluxcd.io
helm repo update
helm fetch fluxcd/flux --version <version>  # Optional: specify version
tar -xzf flux-*.tgz

## Store value file separately:
helm show values flux/ > values.yaml

## Install from the Local Flux Chart
helm install flux helm-charts/flux/flux-*.tgz -f helm-charts/flux/values.yaml --namespace flux-system --create-namespace   --set git.url=git.url=git@github.com:<your-github-username>/<your-repo>.git --set git.branch=main

📌 Replace:
<your-github-username> → Your GitHub username.
<your-repo> → The repo where your Kubernetes manifests live.
