terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  #access_key =
  #secret_key =  
}

#Call s3 module
module "s3" {
  source = "./modules/"
}

#Call DynamoDB module
module "dynamodb" {
  source = "./modules/"
}

#Call API module
#Call AWS Lambda module