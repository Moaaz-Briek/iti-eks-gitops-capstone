PHONY: infra dinfra helm dhelm k8s dk8s
OUTPUT_FILE := output.txt

s3_state:
	@read -p "bucket name: " bucket; \
	read -p "Region name: " region; \
	echo "terraform {\n  backend \"s3\" {\n    bucket  = \"$$bucket\"\n    key = \"terraform/state/infra-helm\"\n    region = \"$${region:-us-east-1}\"\n  }\n}" > ./terraform/helm/backend.tf; \
	echo "bucket=\"$$bucket\"" > ./terraform/helm/vars.tfvars; \
	echo "terraform {\n  backend \"s3\" {\n    bucket  = \"$$bucket\"\n    key = \"terraform/state/infra\"\n    region = \"$${region:-us-east-1}\"\n  }\n}" > ./terraform/infra/backend.tf; \
	echo "bucket=\"$$bucket\"" > ./terraform/infra/vars.tfvars; \
	echo "terraform {\n  backend \"s3\" {\n    bucket  = \"$$bucket\"\n    key = \"terraform/state/infra-k8s\"\n    region = \"$${region:-us-east-1}\"\n  }\n}" > ./terraform/k8s/backend.tf; \
	echo "bucket=\"$$bucket\"" > ./terraform/k8s/vars.tfvars;

infra:
	@terraform -chdir=terraform/infra init
	@terraform -chdir=terraform/infra apply -var-file="vars.tfvars" --auto-approve

dinfra:
	@terraform -chdir=terraform/infra init
	@terraform -chdir=terraform/infra destroy -var-file="vars.tfvars"  --auto-approve

helm:
	@terraform -chdir=terraform/helm init
	@terraform -chdir=terraform/helm apply -var-file="vars.tfvars" --auto-approve

dhelm:
	@terraform -chdir=terraform/helm init
	@terraform -chdir=terraform/helm destroy -var-file="vars.tfvars"  --auto-approve

k8s:
	@terraform -chdir=terraform/k8s init
	@terraform -chdir=terraform/k8s apply -var-file="vars.tfvars" --auto-approve

dk8s:
	@terraform -chdir=terraform/k8s init
	@terraform -chdir=terraform/k8s destroy -var-file="vars.tfvars"  --auto-approve


apply: infra helm k8s
clean: dk8s dhelm dinfra