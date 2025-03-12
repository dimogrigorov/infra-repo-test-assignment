variable "locks_table" {
  type = string
  default = "terraform-locks"  
}

variable "backend_bucket_name" {
  type = string
  default = "my-terraform-state-bucket-dimogrig"  
}

variable "remote_state_key" {
  type = string
  default = "dev/terraform.tfstate"  
}