terraform {
  required_version = ">= 0.12, < 0.15"
  backend "s3" {
    bucket = "terraform-state-jonico"
    key = "global/s3/actions-runner-controller.tfstate"
    region = "us-east-2"
    dynamodb_table = "terraform-locks-jonico"
    encrypt = true
  }
}
