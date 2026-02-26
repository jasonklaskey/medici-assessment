#!/bin/bash
set -e

cd terraform/environments/dev

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

START_TIME=$(date +%s)

declare -a SUCCESSFUL_MODULES
declare -a FAILED_MODULES

format_time() {
  local seconds=$1
  local hours=$((seconds / 3600))
  local minutes=$(((seconds % 3600) / 60))
  local secs=$((seconds % 60))
  
  if [ $hours -gt 0 ]; then
    printf "%dh %dm %ds" $hours $minutes $secs
  elif [ $minutes -gt 0 ]; then
    printf "%dm %ds" $minutes $secs
  else
    printf "%ds" $secs
  fi
}

extract_plan_summary() {
  local module=$1
  local plan_output=$2
  
  local to_add=$(echo "$plan_output" | grep -oP 'Plan: \K\d+(?= to add)' || echo "0")
  local to_change=$(echo "$plan_output" | grep -oP '\d+(?= to change)' | head -1 || echo "0")
  local to_destroy=$(echo "$plan_output" | grep -oP '\d+(?= to destroy)' | head -1 || echo "0")
  
  echo -e "${CYAN}📋 $module Summary:${NC}"
  if [ "$to_add" != "0" ] || [ "$to_change" != "0" ] || [ "$to_destroy" != "0" ]; then
    [ "$to_add" != "0" ] && echo -e "  ${GREEN}➕ Create: $to_add${NC}"
    [ "$to_change" != "0" ] && echo -e "  ${YELLOW}🔄 Change: $to_change${NC}"
    [ "$to_destroy" != "0" ] && echo -e "  ${RED}🗑️  Destroy: $to_destroy${NC}"
  else
    echo -e "  ${BLUE}✓ No changes${NC}"
  fi
  echo ""
}

print_summary() {
  local operation=$1
  local total_time=$2
  
  echo ""
  echo -e "${BLUE}=========================================="
  echo "📊 OPERATION SUMMARY"
  echo "==========================================${NC}"
  echo ""
  
  if [ ${#SUCCESSFUL_MODULES[@]} -gt 0 ]; then
    echo -e "${GREEN}✅ SUCCESSFUL MODULES (${#SUCCESSFUL_MODULES[@]}):${NC}"
    for module in "${SUCCESSFUL_MODULES[@]}"; do
      echo -e "  ${GREEN}✓${NC} $module"
    done
    echo ""
  fi
  
  if [ ${#FAILED_MODULES[@]} -gt 0 ]; then
    echo -e "${RED}❌ FAILED MODULES (${#FAILED_MODULES[@]}):${NC}"
    for module in "${FAILED_MODULES[@]}"; do
      echo -e "  ${RED}✗${NC} $module"
    done
    echo ""
  fi
  
  echo -e "${BLUE}⏱️  Total $operation time: $(format_time $total_time)${NC}"
  echo -e "${BLUE}=========================================${NC}"
  echo ""
}

cleanup_state() {
  echo -e "${YELLOW}Cleaning up caches and state files...${NC}"
  
  find . -type d -name ".terragrunt-cache" -exec rm -rf {} + 2>/dev/null || true
  find . -type d -name ".terraform" -exec rm -rf {} + 2>/dev/null || true
  find . -type f -name ".terraform.lock.hcl" -delete 2>/dev/null || true
  find . -type f -name "terraform.tfstate*" -delete 2>/dev/null || true
  
  echo -e "${GREEN}✅ Local caches cleaned${NC}"
}

clear_remote_state() {
  echo -e "${YELLOW}Clearing remote Terraform state...${NC}"
  
  # Clear S3 state files
  aws s3 rm s3://medici-assessment-tfstate-205883165886/ --recursive --region eu-west-1 2>/dev/null || true
  
  sleep 2
  
  echo -e "${GREEN}✅ Remote state cleared${NC}"
}

deploy() {
  local deploy_start=$(date +%s)
  cleanup_state
  
  echo ""
  echo -e "${GREEN}=========================================="
  echo "PHASE 1: Planning all modules (FRESH)"
  echo "==========================================${NC}"
  
  for dir in vpc security-groups ec2 rds ecr; do
    echo ""
    echo -e "${YELLOW}Planning $dir...${NC}"
    cd $dir
    plan_output=$(terragrunt plan 2>&1)
    echo "$plan_output"
    extract_plan_summary "$dir" "$plan_output"
    cd ..
  done
  
  echo ""
  echo -e "${GREEN}=========================================="
  echo "✅ All plans completed successfully!"
  echo "==========================================${NC}"
  echo ""
  read -p "Do you want to proceed with apply? (yes/no): " confirm
  
  if [ "$confirm" != "yes" ]; then
    echo "Deployment cancelled"
    exit 0
  fi
  
  echo ""
  echo -e "${GREEN}=========================================="
  echo "PHASE 2: Applying all modules"
  echo "==========================================${NC}"
  
  for dir in vpc security-groups ec2 rds ecr; do
    echo ""
    echo -e "${YELLOW}Applying $dir...${NC}"
    cd $dir
    if echo "yes" | terragrunt apply; then
      SUCCESSFUL_MODULES+=("$dir")
      echo -e "${GREEN}✅ $dir applied successfully${NC}"
    else
      FAILED_MODULES+=("$dir")
      echo -e "${RED}❌ $dir apply failed${NC}"
    fi
    cd ..
  done
  
  local deploy_end=$(date +%s)
  local deploy_elapsed=$((deploy_end - deploy_start))
  
  print_summary "deployment" $deploy_elapsed
}

destroy() {
  local destroy_start=$(date +%s)
  cleanup_state
  clear_remote_state  # NEW: Clear remote state before destroy
  
  echo ""
  echo -e "${RED}=========================================="
  echo "PHASE 1: Planning destruction (reverse order)"
  echo "==========================================${NC}"
  
  for dir in ecr rds ec2 security-groups vpc; do
    echo ""
    echo -e "${YELLOW}Planning destruction of $dir...${NC}"
    cd $dir
    plan_output=$(terragrunt plan 2>&1)
    echo "$plan_output"
    extract_plan_summary "$dir" "$plan_output"
    cd ..
  done
  
  echo ""
  echo -e "${RED}=========================================="
  echo "✅ Destruction plan completed!"
  echo "==========================================${NC}"
  echo ""
  echo -e "${RED}⚠️  WARNING: This will DELETE all resources shown above!${NC}"
  echo ""
  read -p "Are you SURE you want to destroy? (type 'yes' to confirm): " confirm
  
  if [ "$confirm" != "yes" ]; then
    echo "Destroy cancelled"
    exit 0
  fi
  
  echo ""
  echo -e "${RED}=========================================="
  echo "PHASE 2: Destroying all modules"
  echo "==========================================${NC}"
  
  for dir in ecr rds ec2 security-groups vpc; do
    echo ""
    echo -e "${YELLOW}Destroying $dir...${NC}"
    cd $dir
    if echo "yes" | terragrunt destroy; then
      SUCCESSFUL_MODULES+=("$dir")
      echo -e "${GREEN}✅ $dir destroyed successfully${NC}"
    else
      FAILED_MODULES+=("$dir")
      echo -e "${RED}❌ $dir destroy failed${NC}"
    fi
    cd ..
  done
  
  local destroy_end=$(date +%s)
  local destroy_elapsed=$((destroy_end - destroy_start))
  
  print_summary "destruction" $destroy_elapsed
}

echo ""
echo "=========================================="
echo "AWS DevOps Infrastructure Manager"
echo "=========================================="
echo ""
echo "1) Deploy (Fresh Plan + Apply)"
echo "2) Destroy (Plan + Confirm + Apply)"
echo "3) Exit"
echo ""
read -p "Choose an option (1-3): " choice

case $choice in
  1)
    deploy
    ;;
  2)
    destroy
    ;;
  3)
    echo "Exiting..."
    exit 0
    ;;
  *)
    echo "Invalid option"
    exit 1
    ;;
esac

END_TIME=$(date +%s)
TOTAL_ELAPSED=$((END_TIME - START_TIME))

echo -e "${BLUE}=========================================="
echo "📊 Total execution time: $(format_time $TOTAL_ELAPSED)"
echo "==========================================${NC}"
