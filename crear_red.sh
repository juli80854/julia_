#!/bin/bash

# Variables
VPC_NAME="MiVPC"
VPC_CIDR="10.0.0.0/16"
SUBNET_CIDR="10.0.1.0/24"
REGION="us-east-1"
TAG="Project=InfraTest"

echo "Creando VPC..."
VPC_ID=$(aws ec2 create-vpc --cidr-block $VPC_CIDR --region $REGION --output text --query 'Vpc.VpcId')
aws ec2 create-tags --resources $VPC_ID --tags Key=Name,Value=$VPC_NAME $TAG

echo "Creando Subnet..."
SUBNET_ID=$(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block $SUBNET_CIDR --region $REGION --output text --query 'Subnet.SubnetId')

echo "Creando Internet Gateway..."
IGW_ID=$(aws ec2 create-internet-gateway --region $REGION --output text --query 'InternetGateway.InternetGatewayId')
aws ec2 attach-internet-gateway --internet-gateway-id $IGW_ID --vpc-id $VPC_ID

echo "Creando tabla de rutas..."
ROUTE_TABLE_ID=$(aws ec2 create-route-table --vpc-id $VPC_ID --region $REGION --output text --query 'RouteTable.RouteTableId')
aws ec2 create-route --route-table-id $ROUTE_TABLE_ID --destination-cidr-block 0.0.0.0/0 --gateway-id $IGW_ID

echo "Asociando Subnet con la tabla de rutas..."
aws ec2 associate-route-table --subnet-id $SUBNET_ID --route-table-id $ROUTE_TABLE_ID

echo "Haciendo subnet pública..."
aws ec2 modify-subnet-attribute --subnet-id $SUBNET_ID --map-public-ip-on-launch

# Guardar IDs
echo $VPC_ID > vpc_id.txt
echo $SUBNET_ID > subnet_id.txt

echo "✅ Infraestructura de red creada correctamente."
