#!/bin/bash

[ -z "$REPO_URL" ] && echo "Error: REPO_URL is not set." && exit 1
[ -z "$TF_PATH" ] && echo "Error: TF_PATH is not set." && exit 1
[ -z "$BUCKET_NAME" ] && echo "Error: BUCKET_NAME is not set." && exit 1
[ -z "$BUCKET_STATE" ] && echo "Error: BUCKET_STATE is not set." && exit 1


VAR_ARGS=()
for env_var in $(env | grep '^VAR_' | cut -d= -f1); do
  var_name=$(echo "$env_var" | sed 's/^VAR_//')
  var_value=$(printenv "$env_var")
  VAR_ARGS+=("-var" "${var_name}=${var_value}")
done


REPO_DIR="/tmp/terraform_repo"

echo "Cloning repo..."
git clone "$REPO_URL" "$REPO_DIR" || { echo "Failed to clone repository."; exit 1; }

cd "$REPO_DIR/$TF_PATH" || { echo "Path not found: $REPO_DIR/$TF_PATH"; exit 1; }

echo "Creating backend.tf..."
cat <<EOF > backend.tf
terraform {
  backend "s3" {
    bucket  = "$BUCKET_NAME"
    key     = "$BUCKET_STATE"
    region  = "us-east-1"
  }
}
EOF

echo "Running terraform init..."
terraform init -reconfigure

echo "Running terraform apply with "${VAR_ARGS[@]}" ...."
terraform apply "${VAR_ARGS[@]}" -auto-approve