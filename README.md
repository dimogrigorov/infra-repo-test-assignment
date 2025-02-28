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

# Steps to Install/bootstrap Flux

## Prerequisites
✅ EKS Cluster up and running.
✅ kubectl configured to communicate with the cluster.
✅ GitHub Personal Access Token (PAT) with repo permissions (for GitOps).


## Generating and Retrieving an SSH Key for Flux
ssh-keygen -t ed25519 -C "flux-eks"
The key will be saved in ~/.ssh/id_ed25519 by default.
You’ll get two files:
id_ed25519 (private key)
id_ed25519.pub (public key)
5. cat ~/.ssh/id_ed25519.pub Copy the output and add it to your GitHub repository as a deploy key (Settings → Deploy Keys → Add Key).

## Flux bootstrap
6. using SSH: 
flux bootstrap github \
  --owner=<github-username> \
  --repository=<repo-name> \
  --branch=main \
  --path=clusters/my-cluster \
  --private-key-file ~/.ssh/id_ed25519
