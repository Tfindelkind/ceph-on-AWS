#!/bin/bash 
  
# repository for all AWS related resources 
 
function create_vpc () {  
	
	VPCID=`aws ec2 describe-vpcs --output text --filter Name=tag:Name,Values=vpc-$LAB_NAME --query 'Vpcs[].VpcId'`
	
	if [[ -z $VPCID ]]; 
		then 
			VPCID=`aws ec2 create-vpc --cidr-block 10.$LAB_SUBNET.0.0/16 --query 'Vpc.VpcId' --output text`
	
			aws ec2 create-tags --resources $VPCID --tags "Key=Name,Value=vpc-$LAB_NAME"

			echo "VPC: $VPCID created"
		else
			result=$(yes_no_input "Do you really wish to use the existing VPC: $VPCID (y/n):");
			if [ $result -eq 1 ];then exit 0; fi
	fi
	
}

function create_igw () {

	
	IGWID=`aws ec2 describe-internet-gateways --output text --filter Name=attachment.vpc-id,Values=$VPCID --query 'InternetGateways[*].InternetGatewayId'`
	
	if [[ -z "$IGWID" ]]; 
		then
			IGWID=`aws ec2 create-internet-gateway --query 'InternetGateway.InternetGatewayId' --output text` 
			aws ec2 create-tags --resources $IGWID --tags "Key=Name,Value=igw-$LAB_NAME"
			IGW_EXISTS=false
			echo "Internet Gateway: $IGWID created"
		else 
			echo "Internet Gateway: $IGWID exist and is attached"
			IGW_EXISTS=true
	fi			
}

function attach_igw () {

	aws ec2 attach-internet-gateway --internet-gateway-id=$IGWID --vpc-id=$VPCID

	echo "Internet Gateway: $IGWID attached to VPC: $VPCID"
}

function get_main_route_table () {
	
	MAINROUTETABLEID=`aws ec2 describe-route-tables --output=text --filters Name=vpc-id,Values=$VPCID Name=association.main,Values=true --query 'RouteTables[*].Associations[*].RouteTableId'`
	aws ec2 create-tags --resources $MAINROUTETABLEID --tags "Key=Name,Value=mrt-$LAB_NAME"
	echo "Main route table: $MAINROUTETABLEID added to: $VPCID"
	
	
}
