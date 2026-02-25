include "root" {
  path = find_in_parent_folders("terragrunt.hcl")
}

terraform {
  source = "."
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    public_subnet_1_id = "subnet-12345678"
  }
}

dependency "security_groups" {
  config_path = "../security-groups"

  mock_outputs = {
    ec2_security_group_id = "sg-12345678"
  }
}

inputs = {
  aws_region              = "eu-west-1"
  environment             = "dev"
  project_name            = "medici-assessment"
  public_subnet_1_id      = dependency.vpc.outputs.public_subnet_1_id
  ec2_security_group_id   = dependency.security_groups.outputs.ec2_security_group_id
  instance_type           = "t3.micro"
}
