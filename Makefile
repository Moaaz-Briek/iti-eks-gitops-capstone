PHONY: infra dinfra platform dplatform manifests dmanifests
OUTPUT_FILE := output.txt

s3_state:
	@read -p "bucket name: " bucket; \
	read -p "Region name: " region; \
	echo "terraform {\n  backend \"s3\" {\n    bucket  = \"$$bucket\"\n    key = \"terraform/state/infra-platform\"\n    region = \"$${region:-us-east-1}\"\n  }\n}" > ./terraform/platform/backend.tf; \
	echo "bucket=\"$$bucket\"" > ./terraform/platform/vars.tfvars; \
	echo "terraform {\n  backend \"s3\" {\n    bucket  = \"$$bucket\"\n    key = \"terraform/state/infra\"\n    region = \"$${region:-us-east-1}\"\n  }\n}" > ./terraform/infra/backend.tf; \
	echo "bucket=\"$$bucket\"" > ./terraform/infra/vars.tfvars; \
	echo "terraform {\n  backend \"s3\" {\n    bucket  = \"$$bucket\"\n    key = \"terraform/state/infra-manifests\"\n    region = \"$${region:-us-east-1}\"\n  }\n}" > ./terraform/manifests/backend.tf; \
	echo "bucket=\"$$bucket\"" > ./terraform/manifests/vars.tfvars;

infra:
	@terraform -chdir=terraform/infra init
	@terraform -chdir=terraform/infra apply -var-file="vars.tfvars" --auto-approve

infra_plan:
	@terraform -chdir=terraform/infra init
	@terraform -chdir=terraform/infra plan -var-file="vars.tfvars"

dinfra:
	@terraform -chdir=terraform/infra init
	@terraform -chdir=terraform/infra destroy -var-file="vars.tfvars"  --auto-approve

platform:
	@terraform -chdir=terraform/platform init
	@terraform -chdir=terraform/platform apply -var-file="vars.tfvars" --auto-approve

platform_plan:
	@terraform -chdir=terraform/platform init
	@terraform -chdir=terraform/platform plan -var-file="vars.tfvars"

dplatform:
	@terraform -chdir=terraform/platform init
	@terraform -chdir=terraform/platform destroy -var-file="vars.tfvars"  --auto-approve

manifests:
	@terraform -chdir=terraform/manifests init
	@terraform -chdir=terraform/manifests apply -var-file="vars.tfvars" --auto-approve

manifests_plan:
	@terraform -chdir=terraform/platform init
	@terraform -chdir=terraform/platform plan -var-file="vars.tfvars"

dmanifests:
	@terraform -chdir=terraform/manifests init
	@terraform -chdir=terraform/manifests destroy -var-file="vars.tfvars"  --auto-approve

connect:
	@read -p "Instance: " instance; \
	aws ssm start-session --target $$instance

apply: infra platform manifests
clean: dmanifests dplatform dinfra