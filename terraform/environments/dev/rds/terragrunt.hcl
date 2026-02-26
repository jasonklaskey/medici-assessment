include "root" {
  path = find_in_parent_folders("terragrunt.hcl")
}

terraform {
  source = "."
}

dependency "vpc" {
  config_path = "../vpc"
  
  mock_outputs = {
    private_subnet_1_id = "subnet-12345678"
    private_subnet_2_id = "subnet-87654321"
  }
}

dependency "security_groups" {
  config_path = "../security-groups"
  
  mock_outputs = {
    rds_security_group_id = "sg-12345678"
  }
}

inputs = {
  aws_region              = "eu-west-1"
  environment             = "dev"
  project_name            = "medici-assessment"
  private_subnet_1_id     = dependency.vpc.outputs.private_subnet_1_id
  private_subnet_2_id     = dependency.vpc.outputs.private_subnet_2_id
  rds_security_group_id   = dependency.security_groups.outputs.rds_security_group_id
  db_instance_class       = "db.t3.micro"
  db_allocated_storage    = 20
  db_name                 = "devopsdb"
  db_username             = "admin"
}
