module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.14.0"

  cluster_name                    = "my-cluster"
  cluster_version                 = "1.31"

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  cluster_addons = {
    coredns = {
      resolve_conflicts_on_create = "OVERWRITE"
    }
    kube-proxy = {}
    vpc-cni = {
      resolve_conflicts_on_create = "OVERWRITE"
    }
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets
  
 
  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    ami_type       = "AL2_x86_64"
    instance_types = ["t3.medium"]

    attach_cluster_primary_security_group = true
#    vpc_security_group_ids                = [aws_security_group.additional.id]
    vpc_security_group_ids = [module.vpc.default_security_group_id]
  }

  eks_managed_node_groups = {
    green = {
      min_size     = 1
      max_size     = 1
      desired_size = 1

      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"
      labels = {
        Environment = "test"
      }

      update_config = {
        max_unavailable_percentage = 50 # or set `max_unavailable`
      }

      tags = {
        ExtraTag = "example"
      }
    }
  }

  tags = local.common_tags
}

resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = <<YAML
    - rolearn: arn:aws:iam::479701439711:role/eks-worker-role
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
    - rolearn: arn:aws:iam::479701439711:role/EKSAdminRole
      username: admin
      groups:
        - system:masters
    YAML
  }
}


resource "aws_iam_role" "eks_worker_role" {
  name = "eks-worker-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "eks-worker-role"
  }
}

# Attach Required Policies to the Worker Node Role
resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_worker_role.name
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_worker_role.name
}

resource "aws_iam_role_policy_attachment" "ec2_container_registry_readonly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_worker_role.name
}

# Allow the worker nodes to join the cluster
resource "aws_iam_instance_profile" "eks_worker_profile" {
  name = "eks-worker-profile"
  role = aws_iam_role.eks_worker_role.name
}


#data "aws_caller_identity" "current" {}

#resource "aws_security_group_rule" "eks_ingress_nodes" {
#  type                     = "ingress"
#  from_port                = 1025
#  to_port                  = 65535
#  protocol                 = "tcp"
#  security_group_id        = module.vpc.default_security_group_id
#  source_security_group_id = module.vpc.default_security_group_id
#}

#resource "aws_security_group_rule" "eks_egress_all" {
#  type              = "egress"
#  from_port         = 0
#  to_port           = 0
#  protocol         = "-1"
#  security_group_id = module.vpc.default_security_group_id
#  cidr_blocks      = ["0.0.0.0/0"]
#}
