terraform {
  required_providers {
    aws = {
      version = "= 5.39.1"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}
