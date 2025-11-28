set shell := ["bash", "-eu", "-o", "pipefail", "-c"]

default: help

help:
	@echo "Proxmox IaC Justfile - Available recipes:"
	@echo ""
	@echo "Terraform:"
	@echo "  tf-init              Initialize Terraform"
	@echo "  tf-fmt               Format Terraform files"
	@echo "  tf-validate          Validate Terraform configuration"
	@echo "  tf-plan              Show Terraform plan"
	@echo "  tf-apply             Apply Terraform configuration (auto-approve)"
	@echo "  tf-destroy           Destroy infrastructure (auto-approve)"
	@echo "  tf-clean             Clean local Terraform state files"
	@echo ""
	@echo "Ansible:"
	@echo "  ansible-post         Run post-install playbook"
	@echo "  ansible-java         Install Java 17 + Tomcat 10.1"
	@echo "  generate-inventory   Generate inventory from Terraform outputs"
	@echo ""
	@echo "Workflows:"
	@echo "  deploy               Full deployment: tf-apply → inventory → ansible-java"
	@echo "  deploy-post          Full deployment: tf-apply → inventory → ansible-post"
	@echo ""
	@echo "Utilities:"
	@echo "  upload-ci-snippet    Upload cloud-init to Proxmox snippets"
	@echo "  git-commit MSG       Commit changes with message"

tf-init:
	cd terraform && terraform init

tf-fmt:
	cd terraform && terraform fmt -recursive

tf-validate:
	cd terraform && terraform validate

tf-plan:
	cd terraform && terraform plan

tf-apply:
	cd terraform && terraform apply -auto-approve

tf-destroy:
	cd terraform && terraform destroy -auto-approve

tf-clean:
	rm -rf terraform/.terraform terraform/*.tfstate terraform/*.tfstate.backup terraform/crash.log

upload-ci-snippet:
	#!/bin/bash
	: "${PM_HOST:?Set PM_HOST (e.g., node1 or FQDN)}"
	: "${PM_SSH_USER:=root}"
	: "${VM_NAME:?Set VM_NAME (e.g., my-vm)}"
	scp cloud-init/cloud-init.yml "${PM_SSH_USER}@${PM_HOST}:/var/lib/vz/snippets/${VM_NAME}-cloud-init.yml"

ansible-post:
	cd ansible && ansible-playbook -i inventory.ini post_install.yml

ansible-java:
	cd ansible && ansible-playbook -i inventory.ini java_tomcat.yml

generate-inventory:
	./scripts/generate_inventory.sh

# Full deployment workflow: create VM and install Java/Tomcat
deploy: tf-apply
	#!/bin/bash
	set -euo pipefail
	echo "Waiting for VM to get IP address..."
	sleep 30
	./scripts/generate_inventory.sh
	cd ansible && ansible-playbook -i inventory.ini java_tomcat.yml
	echo ""
	echo "Deployment complete! Check Tomcat at http://<vm_ip>:8080"

# Full deployment workflow: create VM and run post-install
deploy-post: tf-apply
	#!/bin/bash
	set -euo pipefail
	echo "Waiting for VM to get IP address..."
	sleep 30
	./scripts/generate_inventory.sh
	cd ansible && ansible-playbook -i inventory.ini post_install.yml

git-commit MSG="chore: update":
	git add .
	git commit -m "{{MSG}}"
