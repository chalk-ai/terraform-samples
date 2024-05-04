terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.7"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.10.1"
    }
  }
}