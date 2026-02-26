remote_state {
  backend = "s3"
  config = {
    bucket         = "medici-assessment-tfstate-205883165886"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "eu-west-1"
    encrypt        = true
    # REMOVED: dynamodb_table - causes lock issues in dev
  }
}

terraform {
  extra_arguments "common_vars" {
    commands = ["plan", "apply", "destroy", "refresh", "import", "push", "refresh"]
  }
}
