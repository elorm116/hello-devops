terraform {
  backend "s3" {
    bucket         = "hello-devops-terraform-state-mali"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}