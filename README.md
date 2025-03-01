# Build the terraform infrastructure - AWS EKS cluster

## How to initiate terraform with it's backend config
1. terraform init -backend-config="dev.conf"

## How to validate terraform 
2. terraform validate

## How to apply your terraform code and create managed EKS cluster on AWS
3. terraform apply  -var-file dev.tfvars  -auto-approve 

## Installing nginx-ingress controller(OPTIONAL and not done in our case) 
4. Follow the instructions in helm-charts/ingress-nginx/ and helm-charts/ingress-nginx/ingress-controller-prerequisites/

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
