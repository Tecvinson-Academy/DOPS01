terraform {
  backend "s3" {
    bucket                  = "dops01-terraform"
    key                     = "dops01-tfstate"
    region                  = "us-east-1"
    
  }
}

provider "aws" {
  region                  = "us-east-1"

}