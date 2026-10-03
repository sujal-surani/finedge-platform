terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1" # Deploying to Mumbai for lowest latency

  default_tags {
    tags = {
      Project     = "FinEdge"
      Environment = "Dev"
      ManagedBy   = "Terraform"
    }
  }
}