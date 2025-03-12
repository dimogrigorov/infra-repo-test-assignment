# Environment
environment = "dev"
# VPC Variables
vpc_name = "myvpc"
vpc_cidr_block = "10.0.0.0/16"
vpc_availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
vpc_public_subnets = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
vpc_private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
#vpc_database_subnets= ["10.0.151.0/24", "10.0.152.0/24", "10.0.153.0/24"]
vpc_enable_nat_gateway = true  
vpc_single_nat_gateway = true

# EC2 Instance Variables
instance_type = "t3.micro"
instance_keypair = "terraform-key"
aws_account_id = "479701439711"
#eks_oidc_provider = "oidc.eks.us-east-1.amazonaws.com/id/3019CF13FBBFF050463353654F3FD056"

locks_table = "terraform-locks"
backend_bucket_name = "my-terraform-state-bucket-dimogrig"
remote_state_key = "dev/terraform.tfstate"

instance_types = ["t3.medium"]
capacity_type = "SPOT"

ecr_repositories = ["my-spring-boot-repo"]
