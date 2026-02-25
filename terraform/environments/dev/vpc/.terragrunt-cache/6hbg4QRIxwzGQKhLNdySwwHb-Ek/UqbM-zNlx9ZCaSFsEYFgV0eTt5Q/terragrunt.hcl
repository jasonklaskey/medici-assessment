include "root" {
  path = find_in_parent_folders("terragrunt.hcl")
}

terraform {
  source = "."
}

inputs = {
  aws_region    = "eu-west-1"
  environment   = "dev"
  project_name  = "medici-assessment"
  vpc_cidr      = "10.0.0.0/16"
}
