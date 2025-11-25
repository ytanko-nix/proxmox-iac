#!/bin/bash
set -euo pipefail

# Configuration
TEMPLATE_ID=9000
TEMPLATE_NAME="rocky9-cloudinit-template"
STORAGE="local"
IMAGE_URL="https://download.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-GenericCloud.latest.x86_64.qcow2"
IMAGE_NAME="Rocky-9-GenericCloud.latest.x86_64.qcow2"

echo "Downloading Rocky Linux 9 Cloud Image..."
wget -q --show-progress "$IMAGE_URL" -O "$IMAGE_NAME"

echo "Creating Virtual Machine $TEMPLATE_ID ($TEMPLATE_NAME)..."
qm create $TEMPLATE_ID --memory 2048 --core 2 --name "$TEMPLATE_NAME" --net0 virtio,bridge=vmbr0

echo "Importing disk to $STORAGE..."
qm importdisk $TEMPLATE_ID "$IMAGE_NAME" "$STORAGE"

echo "Configuring VM hardware..."
qm set $TEMPLATE_ID --scsihw virtio-scsi-pci --scsi0 "$STORAGE:vm-$TEMPLATE_ID-disk-0"
qm set $TEMPLATE_ID --ide2 "$STORAGE:cloudinit"
qm set $TEMPLATE_ID --boot c --bootdisk scsi0
qm set $TEMPLATE_ID --serial0 socket --vga serial0

echo "Converting to template..."
qm template $TEMPLATE_ID

echo "Cleaning up..."
rm "$IMAGE_NAME"

echo "✅ Template $TEMPLATE_NAME ($TEMPLATE_ID) created successfully!"
