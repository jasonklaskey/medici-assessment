include "root" {
  path = find_in_parent_folders("terragrunt.hcl")
}

terraform {
  source = "."
}

inputs = {
  aws_region              = "eu-west-1"
  environment             = "dev"
  project_name            = "medici-assessment"
  private_subnet_1_id     = "subnet-05dcc03c6b467f053"
  private_subnet_2_id     = "subnet-0671f5a632516198f"
  rds_security_group_id   = "sg-033e3635c6bc45788"
  db_instance_class       = "db.t3.micro"
  db_allocated_storage    = 20
  db_name                 = "devopsdb"
  db_username             = "admin"
}
