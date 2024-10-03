terraform {
  backend "s3" {
    bucket = "example-terraform-state"
    key    = "sample/terraform.tfstate"
    region = "us-east-1"
  }
}