include "root" {
  path = find_in_parent_folders("terragrunt.hcl")
}

terraform {
  source = "."
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    vpc_id = "vpc-12345678"
  }
}

inputs = {
  aws_region    = "eu-west-1"
  environment   = "dev"
  project_name  = "medici-assessment"
  vpc_id        = dependency.vpc.outputs.vpc_id
}
