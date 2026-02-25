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
}
