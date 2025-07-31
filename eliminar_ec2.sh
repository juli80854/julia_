#!/bin/bash

REGION="us-east-1"
INSTANCE_ID=$(cat instance_id.txt)
SG_ID=$(cat sg_id.txt)

echo "Terminando instancia..."
aws ec2 terminate-instances --instance-ids $INSTANCE_ID --region $REGION
aws ec2 wait instance-terminated --instance-ids $INSTANCE_ID --region $REGION

echo "Eliminando grupo de seguridad..."
aws ec2 delete-security-group --group-id $SG_ID --region $REGION

rm -f instance_id.txt sg_id.txt

echo "✅ Instancia y grupo de seguridad eliminados."
