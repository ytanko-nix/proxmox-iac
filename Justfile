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

git-commit MSG="chore: update":
	git add .
	git commit -m "{{MSG}}"
