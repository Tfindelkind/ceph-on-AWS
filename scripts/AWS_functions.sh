#!/bin/bash 
  
# repository for all AWS related resources 


function get_vpcid () {
		
	VPCID=`aws ec2 describe-vpcs --output text --filter Name=tag:Name,Values=$VPC_NAME --query 'Vpcs[].VpcId'`
	
}

function get_igw () {
	IGWID=`aws ec2 describe-internet-gateways --output text --filter Name=attachment.vpc-id,Values=$VPCID --query 'InternetGateways[*].InternetGatewayId'`
		
}
 
function create_vpc () {  
		
	if [[ -z $VPCID ]]; 
		then 
			VPCID=`aws ec2 create-vpc --cidr-block $VPC_CIDR --query 'Vpc.VpcId' --output text`
	
			aws ec2 create-tags --resources $VPCID --tags "Key=Name,Value=$VPC_NAME"

			echo "VPC: $VPCID created"
		else
			result=$(yes_no_input "Do you really wish to use the existing VPC: $VPCID (y/n):");
			if [ $result -eq 1 ];then exit 0; fi
	fi
	
}

function create_igw () {

	
	if [[ -z "$IGWID" ]]; 
		then
			IGWID=`aws ec2 create-internet-gateway --query 'InternetGateway.InternetGatewayId' --output text` 
			aws ec2 create-tags --resources $IGWID --tags "Key=Name,Value=igw-$VPC_NAME"
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
	aws ec2 create-tags --resources $MAINROUTETABLEID --tags "Key=Name,Value=mrt-$VPC_NAME" 
	echo "Main route table: $MAINROUTETABLEID added to: $VPCID"
	
	
}

function create_subnet () {
#$1 = Returns SubnetID variable
#$2 = Subnet CIDR Block
#$3 = Availability Zone
#$4 = Subnet Name
	local __subnetId=$1
	local subnetId

	subnetId=`aws ec2 create-subnet --vpc-id=$VPCID --cidr-block $2 --availability-zone $3 --query 'Subnet.SubnetId' --output text`
	aws ec2 create-tags --resources $subnetId --tags "Key=Name,Value=$4"
	echo "Subnet $4  with SubnetID: $subnetId in AZ: $3 created"
	
	eval $__subnetId="'$subnetId'"
}

function create_security_group () {
#$1 = Return Security Group ID
#$2 = Security Group Name
#$3 = Securtiy Group description
	
	local __SGId=$1
	local SGId
	
	SGId=`aws ec2 create-security-group --group-name $2 --description $3 --vpc-id $VPCID --query 'GroupId' --output text`
	aws ec2 create-tags --resources $SGId --tags "Key=Name,Value=$2"
	echo "Security Group $2 : $SGId created"
	
	eval $__SGId="'$SGId'"
}

function auth_sg_ingress () {
#$1 = Security Group ID
#$2 = Protocol
#$3 = Port
#$4 = CIDR
	
		
	SGId=`aws ec2 authorize-security-group-ingress --group-id $1 --protocol $2 --port $3 --cidr $4`
	
	echo "Security Group $1 : authorized protocol $2 on port $3 for $4"
	
}

function run_instance () {
#$1 = Return Instance ID
#$2 = ami-ID
#$3 = instance type
#$4 = key-name
#$5 = Security Group ID
#$6 = Subnet ID
#$7 = private IP Address
#$8 = Instance Name
#$9 = Public IP

	
	local __InstanceId=$1
	local InstanceId
	
	if [ $9 == 1 ];
	then
	 InstanceId=`aws ec2 run-instances --image-id $2 --count 1 --instance-type $3 --key-name $4 --security-group-ids $5 --subnet-id $6 --private-ip-address $7 --associate-public-ip-address --query 'Instances[0].InstanceId' --output text` 
	else
	 InstanceId=`aws ec2 run-instances --image-id $2 --count 1 --instance-type $3 --key-name $4 --security-group-ids $5 --subnet-id $6 --private-ip-address $7 --no-associate-public-ip-address --query 'Instances[0].InstanceId' --output text` 	
	fi 
	aws ec2 create-tags --resources $InstanceId --tags "Key=Name,Value=$8"
	echo "Instance $8 with Id: $InstanceId created"
	
	eval $__InstanceId="'$InstanceId'"
}

function create_volume () {
#$1 = Return Volume ID
#$2 = Volume size
#$3 = Availabilty Zone
#$4 = Volume Type
#$5 = Volume Name

	local __VolumeId=$1
	local VolumeId
	
	VolumeId=`aws ec2 create-volume --size=$2 --availability-zone $3 --volume-type $4 --output text --query VolumeId`
	aws ec2 create-tags --resources $VolumeId --tags "Key=Name,Value=$5"
	eval $__VolumeId="'$VolumeId'"
	
}

function attach_volume () {
#$1 = Instance ID
#$2 = Volume ID
#$3 = Device name
	
	aws ec2 attach-volume --volume-id $2 --instance-id $1 --device $3

}

function create_route_table () {
#$1 = Return Route Table ID
#$2 = Route Table Name

	local __RouteTableId=$1
	local RouteTableId
	
	RouteTableId=`aws ec2 create-route-table --vpc-id=$VPCID --query 'RouteTable.RouteTableId' --output text`
	aws ec2 create-tags --resources $RouteTableId --tags "Key=Name,Value=$2"
	
	eval $__RouteTableId="'$RouteTableId'"
}

function associate_route_table () {
#$1 = Route Table ID
#$2 = Subnet ID
	
	aws ec2 associate-route-table --route-table-id $1 --subnet-id $2
	
}



function disable_source_dest_check () {
#$1 = Instance ID
	
	aws ec2 modify-instance-attribute --instance-id $1 --source-dest-check "{\"Value\": false}"

}

function disable_api_termination () {
#$1= Instance ID
	
	aws ec2 modify-instance-attribute --instance-id $1 --no-disable-api-termination

}

function delete_security_group_byname () {
#$1 = Security Group Name
	
	SecurityGroupId=`aws ec2 describe-security-groups --output text --filter Name=vpc-id,Values=$VPCID Name=group-name,Values=$1 --query SecurityGroups[*].GroupId`
	aws ec2 delete-security-group --group-id $SecurityGroupId
	echo "Security Group $1 deleted"
	
}

function delete_subnet_byname () {
#$1 = Subnet Name
		
	SubnetId=`aws ec2 describe-subnets --output text --filter Name=vpc-id,Values=$VPCID Name=tag:Name,Values=$1 --query Subnets[*].SubnetId`
	aws ec2 delete-subnet --subnet-id $SubnetId
	echo "Subnet $1 deleted"
}


function stop_instance_byname () {
#$1 = Instance Name
		
	InstanceId=`aws ec2 describe-instances --filters $filter --output text --filter Name=tag:Name,Values=$1 --query "Reservations[].Instances[].InstanceId"`	
	aws ec2 stop-instances --instance-ids $InstanceId 
	echo "Instance $1 stopped"
}

function terminate_instance_byname () {
#$1 = Return Instance ID
#$2 = Instance Name
	
	local __InstanceId=$1
	local InstanceId
		 	
	InstanceId=`aws ec2 describe-instances --filters $filter --output text --filters Name=tag:Name,Values=$2 Name=instance-state-name,Values=pending,running,shutting-down,stopping,stopped --query "Reservations[].Instances[].InstanceId"`	
	disable_api_termination $InstanceId
		aws ec2 terminate-instances --instance-ids $InstanceId 
	echo "Instance $2 with ID: $1 terminating"
	
	eval $__InstanceId="'$InstanceId'"
}

function delete_volume_byname () {
#$1 = Availability Zone
#$2 = Volume Name
	
	VolumeId=`aws ec2 describe-volumes --output text --filters Name=availability-zone,Values=$1 Name=tag:Name,Values=$2 --query "Volumes[].VolumeId"`
	aws ec2 delete-volume --volume-id $VolumeId
	echo "Volume $2 with ID: $VolumeId deleted"
	
}

function delete_route_table_byname () {
#$1 = Route Table Name	
	
	RouteTableId=`aws ec2 describe-route-tables --output text --filters Name=tag:Name,Values=$1 --query "RouteTables[].RouteTableId"`
	aws ec2 delete-route-table --route-table-id $RouteTableId
	echo "Route Table $1 with ID: $RouteTableId deleted"
}	

function detach_igw () {

	aws ec2 detach-internet-gateway --internet-gateway-id $IGWID --vpc-id $VPCID
	echo "IGW $IGWID detached"
	
}

function delete_igw () {

	aws ec2 delete-internet-gateway --internet-gateway-id $IGWID 
	echo "IGW $IGWID deleted"

}

function delete_vpc () {

	aws ec2 delete-vpc --vpc-id $VPCID
	echo "VPC $VPCID deleted"

}

function get_public_ip_eni () 
#$1 = Return public IP address of ENI
#$2 = ENI ID 
{
	local __PublicIp
	local PublicIp
	
	PublicIp=`aws ec2 describe-network-interfaces --network-interface-ids $2 --output text --query "NetworkInterfaces[].PrivateIpAddresses[].Association.PublicIp"`
	
	eval $__PublicIp="'$PublicIp'"

}
