## Installing ekcctl when the EKS cluster is up and running!!
4. Follow the instructions https://eksctl.io/installation/ or simply run:
./install-ecsctl.sh

aws eks describe-cluster --name my-cluster --query "cluster.identity.oidc.issuer" --output text
#Example output:
https://oidc.eks.us-east-1.amazonaws.com/id/EXAMPLE123456
Extract the OIDC ID from the last part of the URL (EXAMPLE123456)
Edit alb-trust-policy.json accordingly

aws iam create-role --role-name alb-ingress-controller-role \
  --assume-role-policy-document file://alb-trust-policy.json
  
aws iam attach-role-policy --role-name alb-ingress-controller-role \
  --policy-arn arn:aws:iam::<AWS_ACCOUNT_ID>:policy/AWSLoadBalancerControllerPolicy
  
kubectl create serviceaccount alb-ingress-controller -n kube-system

kubectl annotate serviceaccount alb-ingress-controller -n kube-system \
  eks.amazonaws.com/role-arn=arn:aws:iam::<AWS_ACCOUNT_ID>:role/alb-ingress-controller-role
  
helm install my-nginx helm-charts/ingress-nginx/ingress-nginx-*.tgz -f helm-charts/ingress-nginx/values.yaml --set clusterName=my-cluster --set serviceAccount.create=false --set serviceAccount.name=alb-ingress-controller --set region=us-east-1 -n kube-system



## Creating Service account needed for nginx-ingress
eksctl create iamserviceaccount \
  --name alb-ingress-controller \
  --namespace kube-system \
  --cluster my-cluster \
  --attach-policy-arn arn:aws:iam::aws:policy/AWSLoadBalancerControllerPolicy \
  --approve \
  --override-existing-serviceaccounts

## Add and Update the Nginx Ingress controller Helm Repository (Optional)
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm fetch ingress-nginx/ingress-nginx --version <version>  # Optional: specify version
tar -xzf ingress-nginx-*.tgz
## Store value file separately:
helm show values ingress-nginx/ingress-nginx > values.yaml

## Install from the Local Nginx Ingress Chart
5. helm install my-nginx helm-charts/ingress-nginx/ingress-nginx-*.tgz -f helm-charts/ingress-nginx/values.yaml -n ingress-nginx --set clusterName=my-cluster --set serviceAccount.create=false --set serviceAccount.name=alb-ingress-controller
