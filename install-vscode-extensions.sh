#!/bin/bash

echo "Installing VS Code Extensions for AWS DevOps Project..."

# Git
echo "Installing Git Extension..."
code --install-extension eamodio.gitlens

# Terraform
echo "Installing HashiCorp Terraform..."
code --install-extension hashicorp.terraform

# Terraform Snippets
echo "Installing Terraform Doc Snippets..."
code --install-extension mikael.terraform-doc-snippets

# AWS Toolkit
echo "Installing AWS Toolkit..."
code --install-extension AmazonWebServices.aws-toolkit-vscode

# YAML
echo "Installing YAML Support..."
code --install-extension redhat.vscode-yaml

# Git Graph
echo "Installing Git Graph..."
code --install-extension mhutchie.git-graph

# GitLens (already included above, but keeping for reference)
echo "Installing GitLens..."
code --install-extension eamodio.gitlens

# Markdown Preview
echo "Installing Markdown Preview Enhanced..."
code --install-extension shd101wyy.markdown-preview-enhanced

# Thunder Client
echo "Installing Thunder Client..."
code --install-extension rangav.vscode-thunder-client

# JSON Tools
echo "Installing JSON Tools..."
code --install-extension eriklynd.json-tools

# Prettier
echo "Installing Prettier..."
code --install-extension esbenp.prettier-vscode

echo "✅ All extensions installed successfully!"
echo "Please restart VS Code to activate all extensions."
