data "aws_eks_cluster" "eks" {
  name = "${var.cluster_name}"
  depends_on = [module.eks.cluster_name]
}

# Get the OIDC provider URL from the cluster's identity section
data "aws_iam_openid_connect_provider" "eks_oidc" {
  url = data.aws_eks_cluster.eks.identity[0].oidc[0].issuer
}

# Output the OIDC provider URL
output "oidc_provider_url" {
  value = data.aws_iam_openid_connect_provider.eks_oidc.url
}

resource "aws_iam_policy" "aws_lb_controller_policy" {
  name        = "AWSLoadBalancerControllerIAMPolicy"
  description = "IAM policy for AWS Load Balancer Controller"
  policy      = file("${path.module}/policies/iam-policy.json") # Download from AWS repo
}

resource "aws_iam_role" "aws_lb_controller_role" {
  name = "eks-lb-controller-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${var.aws_account_id}:oidc-provider/${data.aws_iam_openid_connect_provider.eks_oidc.url}"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${data.aws_iam_openid_connect_provider.eks_oidc.url}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "aws_lb_controller_attachment" {
  policy_arn = aws_iam_policy.aws_lb_controller_policy.arn
  role       = aws_iam_role.aws_lb_controller_role.name
}

resource "kubernetes_service_account" "aws_load_balancer_controller_sa" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.aws_lb_controller_role.arn
    }
  }

  automount_service_account_token = true
}


resource "helm_release" "aws_lb_controller" {
  name       = "aws-load-balancer-controller"
  namespace  = "kube-system"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "1.6.1" # Use latest stable version

  set {
    name  = "clusterName"
    value = var.cluster_name
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }
}