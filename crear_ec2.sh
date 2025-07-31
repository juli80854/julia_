#!/bin/bash

AMI_ID="ami-0c55b159cbfafe1f0" # Amazon Linux 2 (reemplázalo si usas otra región)
INSTANCE_TYPE="t2.micro"
KEY_NAME="mi-clave-ec2" # Debes tenerla creada
REGION="us-east-1"

VPC_ID=$(cat vpc_id.txt)
SUBNET_ID=$(cat subnet_id.txt)

echo "Creando grupo de seguridad..."
SG_ID=$(aws ec2 create-security-group \
  --group-name mi-sg \
  --description "Security Group para EC2" \
  --vpc-id $VPC_ID \
  --region $REGION \
  --output text --query 'GroupId')

# Abrir puerto SSH
aws ec2 authorize-security-group-ingress \
  --group-id $SG_ID \
  --protocol tcp \
  --port 22 \
  --cidr 0.0.0.0/0 \
  --region $REGION

echo "Lanzando instancia EC2..."
INSTANCE_ID=$(aws ec2 run-instances \
  --image-id $AMI_ID \
  --instance-type $INSTANCE_TYPE \
  --key-name $KEY_NAME \
  --security-group-ids $SG_ID \
  --subnet-id $SUBNET_ID \
  --associate-public-ip-address \
  --region $REGION \
  --output text --query 'Instances[0].InstanceId')

echo $INSTANCE_ID > instance_id.txt
echo $SG_ID > sg_id.txt

echo "Esperando a que la instancia esté en estado 'running'..."
aws ec2 wait instance-running --instance-ids $INSTANCE_ID --region $REGION

IP_PUBLICA=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --region $REGION --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)

echo "✅ Instancia creada: $INSTANCE_ID"
echo "🌐 IP pública: $IP_PUBLICA"
