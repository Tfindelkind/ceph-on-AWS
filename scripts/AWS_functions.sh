#!/bin/bash 
  
# repository for all AWS related resources 


function get_vpcid () {
		
	VPCID=`aws ec2 describe-vpcs --output text --filter Name=tag:Name,Values=$VPC_NAME --query 'Vpcs[].VpcId'`
	
}

function get_igw () {
	
	IGWID=`aws ec2 describe-internet-gateways --output text --filter Name=attachment.vpc-id,Values=$VPCID --query 'InternetGateways[*].InternetGatewayId'`
		
}


function get_account_id () {

	
	user_arn=`aws iam get-user --output text --query "User.Arn"`
	IFS=': ' read -a array <<< "$user_arn"
	ACCOUNTID="${array[4]}"
	
	
}
 
function create_vpc () {  
		
	if [[ -z $VPCID ]]; 
		then 
			VPCID=`aws ec2 create-vpc --cidr-block $VPC_CIDR --query 'Vpc.VpcId' --output text`
	
			aws ec2 create-tags --resources $VPCID --tags "Key=Name,Value=$VPC_NAME"

			echo "VPC: $VPCID created" | tee -a $LOG_FILE
		else
			result=$(yes_no_input "Do you really wish to use the existing VPC: $VPCID (y/n):");
			if [ $result -eq 1 ];then exit 0; fi
	fi
	
}

function create_name_tag () {
#$1 = Resource ID	
#$2 = Name
	
	aws ec2 create-tags --resources $1 --tags "Key=Name,Value=$2"
	
	exit_on_error "Name tag $2 created for $1" "Name tag $2 couldn't created for $1"
	
}



function create_igw () {

	
	if [[ -z "$IGWID" ]]; 
		then
			IGWID=`aws ec2 create-internet-gateway --query 'InternetGateway.InternetGatewayId' --output text` 
			create_name_tag $IGWID "igw-$VPC_NAME"
			IGW_EXISTS=false
			echo "Internet Gateway: $IGWID created" | tee -a $LOG_FILE
		else 
			echo "Internet Gateway: $IGWID exist and is attached" | tee -a $LOG_FILE
			IGW_EXISTS=true
	fi			
}

function attach_igw () {

	aws ec2 attach-internet-gateway --internet-gateway-id=$IGWID --vpc-id=$VPCID

	exit_on_error "Internet Gateway: $IGWID attached to VPC: $VPCID" "Internet Gateway: $IGWID couldn't attached to VPC: $VPCID"
}

function get_main_route_table () {
	
	MAINROUTETABLEID=`aws ec2 describe-route-tables --output=text --filters Name=vpc-id,Values=$VPCID Name=association.main,Values=true --query 'RouteTables[*].Associations[*].RouteTableId'`
	
	exit_on_error "Main route table: $MAINROUTETABLEID added to: $VPCID" "Main route table: $MAINROUTETABLEID couldn't added to: $VPCID"
	
	create_name_tag $MAINROUTETABLEID "mrt-$VPC_NAME" 
	
}

function create_subnet () {
#$1 = Returns SubnetID variable
#$2 = Subnet CIDR Block
#$3 = Availability Zone
#$4 = Subnet Name
	local __subnetId=$1
	local subnetId

	subnetId=`aws ec2 create-subnet --vpc-id=$VPCID --cidr-block $2 --availability-zone $3 --query 'Subnet.SubnetId' --output text`
	
	exit_on_error "Subnet $4  with SubnetID: $subnetId in AZ: $3 created" "Subnet $4  with SubnetID: $subnetId in AZ: $3 couldn't created"
	
	create_name_tag $subnetId $4
	
	eval $__subnetId="'$subnetId'"
}

function create_security_group () {
#$1 = Return Security Group ID
#$2 = Security Group Name
#$3 = Securtiy Group description
	
	local __SGId=$1
	local SGId
	
	SGId=`aws ec2 create-security-group --group-name $2 --description $3 --vpc-id $VPCID --query 'GroupId' --output text`
	exit_on_error "Security Group $2 : $SGId created" "Security Group $2 : $SGId couldn't created"
	
	create_name_tag $SGId $2
	
	eval $__SGId="'$SGId'"
}

function auth_sg_ingress () {
#$1 = Security Group ID
#$2 = Protocol
#$3 = Port
#$4 = CIDR
	
		
	SGId=`aws ec2 authorize-security-group-ingress --group-id $1 --protocol $2 --port $3 --cidr $4`
	
	exit_on_error "Security Group: $1 authorized protocol $2 on port $3 for $4" "Security Group: $1 couldn't authorized protocol $2 on port $3 for $4" 
	
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
	exit_on_error "Instance $8 with Id: $InstanceId created" "Instance $8 with Id: $InstanceId couldn't created"
	create_name_tag $InstanceId $8
	
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
	exit_on_error "Volume $5 created"  "Volume $5 couldn't created"
	
	create_name_tag $VolumeId $5
	
	eval $__VolumeId="'$VolumeId'"
	
}

function attach_volume () {
#$1 = Instance ID
#$2 = Volume ID
#$3 = Device name
	
	aws ec2 attach-volume --volume-id $2 --instance-id $1 --device $3
	exit_on_error "Volume $2 attached to $1"  "Volume $5 couldn't attached to $1"

}

function create_route_table () {
#$1 = Return Route Table ID
#$2 = Route Table Name

	local __RouteTableId=$1
	local RouteTableId
	
	RouteTableId=`aws ec2 create-route-table --vpc-id=$VPCID --query 'RouteTable.RouteTableId' --output text`
	exit_on_error "Route table $2 with ID: $RouteTableId created" "Route table $2 with ID: $RouteTableId couldn't created"
	create_name_tag $RouteTableId $2
	
	eval $__RouteTableId="'$RouteTableId'"
}

function associate_route_table () {
#$1 = Route Table ID
#$2 = Subnet ID
	
	aws ec2 associate-route-table --route-table-id $1 --subnet-id $2
	exit_on_error "Route table $1 associted to Subnet $2" "Route table $1 couldn't associted to Subnet $2"
	
}


#function get_instance_arn_byname () 
#$1 = Return ARN for instance
#$2 = instance name 
#{
#	local __ARN=$1
#	local ARN
#	
#	user_arn=`aws iam get-user --output text --query "User.Arn"`
#	IFS=': ' read -a array <<< "$user_arn"
#	aws_account_id="${array[4]}"
#	
#	region=`aws configure get region`
#	
#	InstanceId=`aws ec2 describe-instances --filters $filter --output text --filters Name=tag:Name,Values=$CEPH_ADMIN Name=instance-state-name,Values=pending,running,shutting-down,stopping,stopped --query "Reservations[].Instances[].InstanceId"`	
#		
#	ARN="arn:aws:ec2:$region:$aws_account_id:instance/$InstanceId"
#	echo $ARN
#	
#	#PublicIp=`aws ec2 describe-network-interfaces --network-interface-ids $2 --output text --query "NetworkInterfaces[].PrivateIpAddresses[].Association.PublicIp"`
#	#arn:aws:ec2:us-east-1:123456789012:instance/i-123abc12
#	
#	
#	#eval $__PublicIp="'$PublicIp'"
#
#}

function attach_read_policy () {
	
	aws iam attach-user-policy --user-name $STUDENT --policy-arn arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess
	
	exit_on_error "AmazonEC2ReadOnlyAccess attached to $STUDENT" "AmazonEC2ReadOnlyAccess couldn't attached to $STUDENT"
}

function detach_read_policy () {
	
	aws iam detach-user-policy --user-name $STUDENT --policy-arn arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess
	
	echo_log "AmazonEC2ReadOnlyAccess detached from $STUDENT"
}

function create_key_pair () {
	
	aws ec2 create-key-pair --key-name $STUDENT --output text --query 'KeyMaterial' > $STUDENT.pem
	
	exit_on_error "Keypair created and downloaded to $STUDENT.pem" "Keypair couldn't created for $STUDENT"
}

function delete_key_pair () {
	
	aws ec2 delete-key-pair --key-name $STUDENT
	
	echo_log "Keypair $STUDENT.pem deleted"
}


function create_login_profile () {
	
	aws iam create-login-profile --user-name $STUDENT --password ceph
	
	exit_on_error "Default password set for $STUDENT" "Default password couldn't set for $STUDENT"
	
}

function delete_login_profile () {
	
	aws iam delete-login-profile --user-name $STUDENT 
	
	echo_log "Login Profile deleted for User $STUDENT" 
	
}

function create_user () {
	
	aws iam create-user --user-name $STUDENT
	
	exit_on_error "Student: $STUDENT created" "Student: $STUDENT couldn't created"
	
}

function delete_user () {
	
	aws iam delete-user --user-name $STUDENT
	
	echo_log "Student: $STUDENT deleted"

}

function disable_source_dest_check () {
#$1 = Instance ID
	
	aws ec2 modify-instance-attribute --instance-id $1 --source-dest-check "{\"Value\": false}"
	
	exit_on_error "Set disable Source-Destination-check for $1" "Set disable Source-Destination-check for $1 failed"

}

function disable_api_termination () {
#$1= Instance ID
	
	aws ec2 modify-instance-attribute --instance-id $1 --no-disable-api-termination
	
	echo_log "Set disable API termination for $1"

}

function delete_security_group_byname () {
#$1 = Security Group Name
	
	SecurityGroupId=`aws ec2 describe-security-groups --output text --filter Name=vpc-id,Values=$VPCID Name=group-name,Values=$1 --query SecurityGroups[*].GroupId`
	aws ec2 delete-security-group --group-id $SecurityGroupId
	echo_log "Security Group $1 deleted" 
	
}

function delete_subnet_byname () {
#$1 = Subnet Name
		
	SubnetId=`aws ec2 describe-subnets --output text --filter Name=vpc-id,Values=$VPCID Name=tag:Name,Values=$1 --query Subnets[*].SubnetId`
	aws ec2 delete-subnet --subnet-id $SubnetId
	echo_log "Subnet $1 deleted" 
}


function stop_instance_byname () {
#$1 = Instance Name
		
	InstanceId=`aws ec2 describe-instances --filters $filter --output text --filter Name=tag:Name,Values=$1 --query "Reservations[].Instances[].InstanceId"`	
	aws ec2 stop-instances --instance-ids $InstanceId 
	echo_log "Stopping Instanc:e $1" 
}

function terminate_instance_byname () {
#$1 = Return Instance ID
#$2 = Instance Name
	
	local __InstanceId=$1
	local InstanceId
		 	
	InstanceId=`aws ec2 describe-instances --filters $filter --output text --filters Name=tag:Name,Values=$2 Name=instance-state-name,Values=pending,running,shutting-down,stopping,stopped --query "Reservations[].Instances[].InstanceId"`	
	disable_api_termination $InstanceId
		aws ec2 terminate-instances --instance-ids $InstanceId 
	echo_log "Instance $2 with ID: $1 terminating" 
	
	eval $__InstanceId="'$InstanceId'"
}

function delete_volume_byname () {
#$1 = Availability Zone
#$2 = Volume Name
	
	VolumeId=`aws ec2 describe-volumes --output text --filters Name=availability-zone,Values=$1 Name=tag:Name,Values=$2 --query "Volumes[].VolumeId"`
	aws ec2 delete-volume --volume-id $VolumeId
	echo_log "Volume $2 with ID: $VolumeId deleted" 
	
}

function delete_route_table_byname () {
#$1 = Route Table Name	
	
	RouteTableId=`aws ec2 describe-route-tables --output text --filters Name=tag:Name,Values=$1 --query "RouteTables[].RouteTableId"`
	aws ec2 delete-route-table --route-table-id $RouteTableId
	echo_log "Route Table $1 with ID: $RouteTableId deleted" 
}	

function detach_igw () {

	aws ec2 detach-internet-gateway --internet-gateway-id $IGWID --vpc-id $VPCID
	echo_log "IGW $IGWID detached" 
	
}

function delete_igw () {

	aws ec2 delete-internet-gateway --internet-gateway-id $IGWID 
	echo_log "IGW $IGWID deleted" 

}

function delete_vpc () {

	aws ec2 delete-vpc --vpc-id $VPCID
	echo_log "VPC $VPCID deleted" 

}

function get_public_ip_eni () 
#$1 = Return public IP address of ENI
#$2 = ENI ID 
{
	local __PublicIp=$1
	local PublicIp
	
	PublicIp=`aws ec2 describe-network-interfaces --network-interface-ids $2 --output text --query "NetworkInterfaces[].PrivateIpAddresses[].Association.PublicIp"`
	
	eval $__PublicIp="'$PublicIp'" 

}
