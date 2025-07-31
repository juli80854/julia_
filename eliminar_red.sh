#!/bin/bash

REGION="us-east-1"

VPC_ID=$(cat vpc_id.txt)
SUBNET_ID=$(cat subnet_id.txt)

echo "Buscando componentes..."

IGW_ID=$(aws ec2 describe-internet-gateways --region $REGION --filters Name=attachment.vpc-id,Values=$VPC_ID --query 'InternetGateways[0].InternetGatewayId' --output text)
ROUTE_TABLE_ID=$(aws ec2 describe-route-tables --region $REGION --filters Name=vpc-id,Values=$VPC_ID --query 'RouteTables[?Associations[?SubnetId==`'$SUBNET_ID'`]].RouteTableId' --output text)

echo "Desasociando tabla de rutas..."
ASSOCIATION_ID=$(aws ec2 describe-route-tables --route-table-ids $ROUTE_TABLE_ID --region $REGION --query 'RouteTables[0].Associations[0].RouteTableAssociationId' --output text)
aws ec2 disassociate-route-table --association-id $ASSOCIATION_ID

echo "Eliminando ruta..."
aws ec2 delete-route --route-table-id $ROUTE_TABLE_ID --destination-cidr-block 0.0.0.0/0

echo "Eliminando tabla de rutas..."
aws ec2 delete-route-table --route-table-id $ROUTE_TABLE_ID

echo "Desconectando y eliminando Internet Gateway..."
aws ec2 detach-internet-gateway --internet-gateway-id $IGW_ID --vpc-id $VPC_ID
aws ec2 delete-internet-gateway --internet-gateway-id $IGW_ID

echo "Eliminando Subnet..."
aws ec2 delete-subnet --subnet-id $SUBNET_ID

echo "Eliminando VPC..."
aws ec2 delete-vpc --vpc-id $VPC_ID

rm -f vpc_id.txt subnet_id.txt

echo "✅ Infraestructura de red eliminada correctamente."
