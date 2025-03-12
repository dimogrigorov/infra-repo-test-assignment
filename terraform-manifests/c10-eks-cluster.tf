module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.14.0"

  cluster_name                    = "${var.cluster_name}"
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
    instance_types = var.instance_types

    attach_cluster_primary_security_group = true
    key_name       = "terraform-key"
   
    vpc_security_group_ids = [module.vpc.default_security_group_id, aws_security_group.eks_worker_sg.id]
  }

  eks_managed_node_groups = {
    green = {
      min_size     = 1
      max_size     = 1
      desired_size = 1

      instance_types = var.instance_types
      capacity_type  = var.capacity_type
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

    blue = {
      min_size     = 1
      max_size     = 3
      desired_size = 1

      instance_types = var.instance_types
      capacity_type  = var.capacity_type
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

# Create security group for EKS Worker nodes
resource "aws_security_group" "eks_worker_sg" {
  name        = "eks-worker-sg"
  description = "EKS Worker nodes security group"
  vpc_id      = module.vpc.vpc_id

  # Ingress Rules
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow traffic from anywhere
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow SSH access from anywhere (adjust if needed)
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow HTTP traffic on port 8080 from anywhere
  }

  # Egress Rules
  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow all outbound traffic
  }

  tags = {
    Name = "eks-worker-sg"
  }
}

resource "kubernetes_config_map" "aws_auth" {
  depends_on = [ module.eks.name ]
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = <<YAML
    - rolearn: arn:aws:iam::${var.aws_account_id}:role/eks-worker-role
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
    - rolearn: arn:aws:iam::${var.aws_account_id}:role/EKSAdminRole
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