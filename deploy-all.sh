#!/bin/bash
set -e

cd terraform/environments/dev

echo "=========================================="
echo "PHASE 1: Planning all modules"
echo "=========================================="

for dir in vpc security-groups ec2 rds ecr; do
  echo ""
  echo "Planning $dir..."
  cd $dir
  terragrunt plan
  if [ $? -ne 0 ]; then
    echo "❌ Plan failed for $dir"
    exit 1
  fi
  cd ..
done

echo ""
echo "=========================================="
echo "✅ All plans completed successfully!"
echo "=========================================="
echo ""
read -p "Do you want to proceed with apply? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
  echo "Deployment cancelled"
  exit 0
fi

echo ""
echo "=========================================="
echo "PHASE 2: Applying all modules"
echo "=========================================="

for dir in vpc security-groups ec2 rds ecr; do
  echo ""
  echo "Applying $dir..."
  cd $dir
  echo "yes" | terragrunt apply
  if [ $? -ne 0 ]; then
    echo "❌ Apply failed for $dir"
    exit 1
  fi
  cd ..
done

echo ""
echo "=========================================="
echo "✅ All infrastructure deployed successfully!"
echo "=========================================="
