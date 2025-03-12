# README: AWS EKS Cluster with Terraform and FluxCD

## 1. Build the Terraform Infrastructure - AWS EKS Cluster

### 1.1 Initialize Terraform with Backend Configuration
To initialize Terraform and configure the backend, run:
```sh
terraform init -backend-config="dev.conf"
```

### 1.2 Validate Terraform Configuration
Before applying the changes, validate your Terraform configuration:
```sh
terraform validate
```

### 1.3 Apply Terraform Code to Create AWS EKS Cluster
To provision the managed EKS cluster, execute:
```sh
terraform apply -var-file=dev.tfvars -auto-approve
```

## 2. Setting Up FluxCD for GitOps

### 2.1 Generate and Retrieve an SSH Key for Flux
To generate an SSH key for Flux to authenticate with GitHub, run:
```sh
ssh-keygen -t ed25519 -C "flux-eks"
```
By default, the key will be stored in `~/.ssh/id_ed25519`.

You will get two files:
- `id_ed25519` (private key)
- `id_ed25519.pub` (public key)

### 2.2 Add SSH Key to GitHub as a Deploy Key
Retrieve the public key:
```sh
cat ~/.ssh/id_ed25519.pub
```
Copy the output and add it to your GitHub repository under:
**GitHub Settings → Deploy Keys → Add Key** (Ensure "Allow write access" is enabled).

### 2.3 Bootstrap Flux with GitHub
Use the following command to bootstrap Flux:
```sh
flux bootstrap github \
  --owner=<github-username> \
  --repository=<repo-name> \
  --branch=main \
  --path=my-cluster \
  --private-key-file ~/.ssh/id_ed25519
```

---

## 3. Verifying FluxCD Deployment

### 3.1 Check If Flux Is Detecting Changes
Run the following commands to check the status of Flux sources and Helm releases:
```sh
flux get sources git -n flux-system
flux get helmrelease -n staging
```

### 3.2 Force a Reconciliation (If Needed)
If Flux does not automatically detect changes, manually trigger reconciliation:
```sh
flux reconcile source git flux-system -n flux-system
flux reconcile kustomization flux-system -n flux-system
flux reconcile kustomization staging -n flux-system
flux reconcile kustomization production -n flux-system
```

### 3.3 Check Logs for Issues
If errors occur, inspect the logs for debugging:
```sh
kubectl logs -n flux-system -l app.kubernetes.io/name=source-controller
kubectl logs -n flux-system -l app.kubernetes.io/name=helm-controller
```

## 4. Install argocd
Run the following::
```sh
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```
