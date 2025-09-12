# backend.tf - Налаштування S3 backend для Terraform state

terraform {
  backend "s3" {
    bucket         = "final-devops-terraform-state-70452f55"
    key            = "final-project/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}