resource "aws_ecr_repository" "my_repo" {
  #for_each = toset(var.ecr_repositories)
  name = "testname"

  count = var.create_ecr_repo ? 1 : 0  
  #name                 = "testassignment/${each.value}"
  image_tag_mutability = "MUTABLE"

  encryption_configuration {
    encryption_type = "KMS"
  }

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Environment = "Production"
  }

  lifecycle {
    prevent_destroy = true
  }
}

variable "create_ecr_repo" {
  description = "Boolean flag to determine whether to create the ECR repository"
  type        = bool
  default     = false  # Set to false if you want to skip creation
}

variable "ecr_repositories" {
  description = "List of ECR repository names"
  type        = list(string)
  default     = []
}