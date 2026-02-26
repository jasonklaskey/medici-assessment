#!/bin/bash
set -e

cd terraform/environments/dev

for dir in ecr rds ec2 security-groups vpc; do
  echo "Destroying $dir..."
  cd $dir
  echo "yes" | terragrunt destroy
  cd ..
done

echo "All infrastructure destroyed!"
