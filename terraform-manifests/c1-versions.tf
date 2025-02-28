# Terraform Block
terraform {
  required_version = ">= 1.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    null = {
      source = "hashicorp/null"
      version = "~> 3.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.25.0"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }               
  }
  # Adding Backend as S3 for Remote State Storage
  backend "s3" {}      
}
provider "aws" {
  region  = var.aws_region
  #profile = "default"
}

# Get the EKS Cluster Details
data "aws_eks_cluster" "cluster" {
  name = "my-cluster"
  depends_on = [module.eks.cluster_name]
}

# Get the EKS Cluster Authentication Token
data "aws_eks_cluster_auth" "cluster" {
  name = "my-cluster"
  depends_on = [module.eks.cluster_name]
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  token                  = data.aws_eks_cluster_auth.cluster.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
}

provider "kubectl" {
}
