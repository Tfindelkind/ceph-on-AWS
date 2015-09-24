#!/bin/bash

# create_AWS_network_environment
# 


# Import functions
source ./scripts/miscellaneous_functions.sh
source ./scripts/AWS_functions.sh 

# global variables
CIDR_BLOCK=10.$1.0.0/16  # for later use
LAB_SUBNET=100
LAB_NAME="ceph-lab"
VPCID=0
IGWID=0
IGW_EXISTS=0
MAINROUTETABLEID=0

# no return values for functions
result=0

# parse input parameters
while getopts "hs:" OPTION; do 
	case $OPTION in 
	h) 
		print_help 
		exit 0
		;; 
	s) 
		if [[ "$OPTARG" =~ ^[0-9]*$  && "$OPTARG" -ge 0 && "$OPTARG" -le 254 ]];
			then
				LABSUBNET=$OPTARG		
			else
				echo "subnet value is not valid or not between 0 and 254"
				exit 1;
		fi
		;; 
	*) 
		echo "Incorrect options provided" 
		exit 1 
		;; 
	esac
done

	
#result=$(yes_no_input "Do you wish to create VPC with CIDR block: 10.$LAB_SUBNET.0.0/16 y/n:");
#if [ $result -eq 1 ];then exit 0; fi
		

create_vpc 

create_igw


if [ "$IGW_EXISTS" = false ]; then attach_igw; fi

get_main_route_table 

#echo $igw


#sub_ext_euc1a=`aws ec2 create-subnet --vpc-id=$vpc --cidr-block 10.$1.0.0/24 --availability-zone eu-central-1a --query 'Subnet.SubnetId' --output text`
#echo "Subnet External EUC-1a: $subnet_ext_euc1a created"

#sub_ext_euc1b=`aws ec2 create-subnet --vpc-id=$vpc --cidr-block 10.$1.1.0/24 --availability-zone eu-central-1b --query 'Subnet.SubnetId' --output text`
#echo "Subnet External EUC-1b: $subnet_ext_euc1b created"

#sub_app_euc1a=`aws ec2 create-subnet --vpc-id=$vpc --cidr-block 10.$1.2.0/24 --availability-zone eu-central-1a --query 'Subnet.SubnetId' --output text`
#echo "Subnet Application EUC-1a: $subnet_app_euc1a created"

#sub_app_euc1b=`aws ec2 create-subnet --vpc-id=$vpc --cidr-block 10.$1.3.0/24 --availability-zone eu-central-1b --query 'Subnet.SubnetId' --output text`
#echo "Subnet Application EUC-1b: $subnet_app_euc1b created"

#sub_rgw_euc1a=`aws ec2 create-subnet --vpc-id=$vpc --cidr-block 10.$1.4.0/24 --availability-zone eu-central-1a --query 'Subnet.SubnetId' --output text`
#echo "Subnet RADOS Gateway EUC-1a: $subnet_rgw_euc1a created"

#sub_rgw_euc1b=`aws ec2 create-subnet --vpc-id=$vpc --cidr-block 10.$1.5.0/24 --availability-zone eu-central-1b --query 'Subnet.SubnetId' --output text`
#echo "Subnet RADOS Gateway EUC-1b: $subnet_rgw_euc1b created"

#sub_pub_euc1a=`aws ec2 create-subnet --vpc-id=$vpc --cidr-block 10.$1.6.0/24 --availability-zone eu-central-1a --query 'Subnet.SubnetId' --output text`
#echo "Subnet Public Network EUC-1a: $subnet_pub_euc1a created"

#sub_pub_euc1b=`aws ec2 create-subnet --vpc-id=$vpc --cidr-block 10.$1.7.0/24 --availability-zone eu-central-1b --query 'Subnet.SubnetId' --output text`
#echo "Subnet Public Network EUC-1b: $subnet_pub_euc1b created"

#sub_clu_euc1a=`aws ec2 create-subnet --vpc-id=$vpc --cidr-block 10.$1.8.0/24 --availability-zone eu-central-1a --query 'Subnet.SubnetId' --output text`
#echo "Subnet Cluster Network EUC-1a: $subnet_clu_euc1a created"

#sub_clu_euc1b=`aws ec2 create-subnet --vpc-id=$vpc --cidr-block 10.$1.9.0/24 --availability-zone eu-central-1b --query 'Subnet.SubnetId' --output text`
#echo "Subnet Cluster Network EUC-1b: $subnet_clu_euc1b created"

#SG_ext=`aws ec2 create-security-group --group-name SG_ext_$1 --description SG_ext_$1 --vpc-id $vpc --query 'GroupId' --output text`
#aws ec2 authorize-security-group-ingress --group-id $SG_ext --protocol tcp --port 22 --cidr 0.0.0.0/0
#aws ec2 authorize-security-group-ingress --group-id $SG_ext --protocol tcp --port 80 --cidr 0.0.0.0/0
#aws ec2 authorize-security-group-ingress --group-id $SG_ext --protocol tcp --port 443 --cidr 0.0.0.0/0
#aws ec2 authorize-security-group-ingress --group-id $SG_ext --protocol tcp --port 10000 --cidr 0.0.0.0/0
#aws ec2 authorize-security-group-ingress --group-id $SG_ext --protocol all --port all --cidr 10.$1.0.0/16
#echo "Security Group SG_ext: $SG_ext created"
#SG_app=`aws ec2 create-security-group --group-name SG_app_$1 --description SG_app_$1 --vpc-id $vpc --query 'GroupId' --output text`
#aws ec2 authorize-security-group-ingress --group-id $SG_app --protocol all --port all --cidr 10.$1.0.0/16
#echo "Security Group SG_app: $SG_app created"
#SG_rgw=`aws ec2 create-security-group --group-name SG_rgw_$1 --description SG_rgw_$1 --vpc-id $vpc --query 'GroupId' --output text`
#aws ec2 authorize-security-group-ingress --group-id $SG_rgw --protocol all --port all --cidr 10.$1.0.0/16
#echo "Security Group SG_rgw: $SG_rgw created"
#SG_pub=`aws ec2 create-security-group --group-name SG_pub_$1 --description SG_pub_$1 --vpc-id $vpc --query 'GroupId' --output text`
#aws ec2 authorize-security-group-ingress --group-id $SG_pub --protocol all --port all --cidr 10.$1.0.0/16
#echo "Security Group SG_pub: $SG_pub created"
#SG_clu=`aws ec2 create-security-group --group-name SG_clu_$1 --description SG_clu_$1 --vpc-id $vpc --query 'GroupId' --output text`
#aws ec2 authorize-security-group-ingress --group-id $SG_clu --protocol all --port all --cidr 10.$1.0.0/16
#echo "Security Group SG_clu: $SG_clu created"

#ceph_admin=`aws ec2 run-instances --image-id ami-accff2b1 --count 1 --instance-type t2.small --key-name ceph-lab --security-group-ids $SG_ext --subnet-id $sub_ext_euc1a --private-ip-address 10.$1.0.10 --associate-public-ip-address --query 'Instances[0].InstanceId' --output text` 
#aws ec2 modify-instance-attribute --instance-id $ceph_admin --source-dest-check "{\"Value\": false}"
#aws ec2 create-tags --resources $ceph_admin --tags "Key=Name,Value=ceph-admin-$1"
#echo "Instance ceph-admin: $ceph_admin created"

#devstack=`aws ec2 run-instances --image-id ami-accff2b1 --count 1 --instance-type t2.micro --key-name ceph-lab --security-group-ids $SG_app --subnet-id $sub_app_euc1a --private-ip-address 10.$1.2.10 --no-associate-public-ip-address --query 'Instances[0].InstanceId' --output text`
#aws ec2 create-tags --resources $devstack --tags "Key=Name,Value=devstack-$1"
#echo "Instance devstack: $devstack created"

#radosgw=`aws ec2 run-instances --image-id ami-accff2b1 --count 1 --instance-type t2.micro --key-name ceph-lab --security-group-ids $SG_rgw --subnet-id $sub_rgw_euc1a --private-ip-address 10.$1.4.10 --no-associate-public-ip-address --query 'Instances[0].InstanceId' --output text`
#aws ec2 create-tags --resources $radosgw --tags "Key=Name,Value=radosgw-$1"
#echo "Instance radosgw: $radosgw created"

#mon1=`aws ec2 run-instances --image-id ami-accff2b1 --count 1 --instance-type t2.micro --key-name ceph-lab --security-group-ids $SG_pub --subnet-id $sub_pub_euc1a --private-ip-address 10.$1.6.10 --no-associate-public-ip-address --query 'Instances[0].InstanceId' --output text`
#aws ec2 create-tags --resources $mon1 --tags "Key=Name,Value=mon1-$1"
#echo "Instance mon1: $mon1 created"

# Create all OSD-nodes
#osdnode1=`aws ec2 run-instances --image-id ami-accff2b1 --count 1 --instance-type t2.micro --key-name ceph-lab --security-group-ids $SG_clu --subnet-id $sub_clu_euc1a --private-ip-address 10.$1.8.10 --no-associate-public-ip-address --query 'Instances[0].InstanceId' --output text`
#aws ec2 create-tags --resources $osdnode1 --tags "Key=Name,Value=osd-node1-$1"
#osdnode2=`aws ec2 run-instances --image-id ami-accff2b1 --count 1 --instance-type t2.micro --key-name ceph-lab --security-group-ids $SG_clu --subnet-id $sub_clu_euc1b --private-ip-address 10.$1.9.10 --no-associate-public-ip-address --query 'Instances[0].InstanceId' --output text`
#aws ec2 create-tags --resources $osdnode2 --tags "Key=Name,Value=osd-node2-$1"
#osdnode3=`aws ec2 run-instances --image-id ami-accff2b1 --count 1 --instance-type t2.micro --key-name ceph-lab --security-group-ids $SG_clu --subnet-id $sub_clu_euc1a --private-ip-address 10.$1.8.11 --no-associate-public-ip-address --query 'Instances[0].InstanceId' --output text`
#aws ec2 create-tags --resources $osdnode3 --tags "Key=Name,Value=osd-node3-$1"
#echo "osd-node1: $osdnode1 osd-node2: $osdnode2 osd-node3: $osdnode3 created"


# Create all volumes
#osdnode1_xvdb=`aws ec2 create-volume --size=8 --availability-zone eu-central-1a --volume-type gp2 --output text --query VolumeId`
#osdnode1_xvdc=`aws ec2 create-volume --size=8 --availability-zone eu-central-1a --volume-type gp2 --output text --query VolumeId`
#osdnode1_xvdd=`aws ec2 create-volume --size=8 --availability-zone eu-central-1a --volume-type gp2 --output text --query VolumeId`
#osdnode2_xvdb=`aws ec2 create-volume --size=8 --availability-zone eu-central-1b --volume-type gp2 --output text --query VolumeId`
#osdnode2_xvdc=`aws ec2 create-volume --size=8 --availability-zone eu-central-1b --volume-type gp2 --output text --query VolumeId`
#osdnode2_xvdd=`aws ec2 create-volume --size=8 --availability-zone eu-central-1b --volume-type gp2 --output text --query VolumeId`
#osdnode3_xvdb=`aws ec2 create-volume --size=8 --availability-zone eu-central-1a --volume-type gp2 --output text --query VolumeId`
#osdnode3_xvdc=`aws ec2 create-volume --size=8 --availability-zone eu-central-1a --volume-type gp2 --output text --query VolumeId`
#osdnode3_xvdd=`aws ec2 create-volume --size=8 --availability-zone eu-central-1a --volume-type gp2 --output text --query VolumeId`
#echo "OSD Volumes: $osdnode1_xvdb $osdnode1_xvdc $osdnode1_xvdd $osdnode2_xvdb osdnode2_xvdc osdnode2_xvdd osdnode3_xvdb osdnode3_xvdc osdnode3_xvdd" 

# Create route tables
#route_table_ext=`aws ec2 create-route-table --vpc-id=$vpc --query 'RouteTable.RouteTableId' --output text`
#aws ec2 create-route --route-table-id $route_table_ext --destination-cidr-block 0.0.0.0/0 --gateway-id $igw

#aws ec2 associate-route-table --route-table-id $route_table_ext --subnet-id $sub_ext_euc1a
#aws ec2 associate-route-table --route-table-id $route_table_ext --subnet-id $sub_ext_euc1b


#route_table_int=`aws ec2 create-route-table --vpc-id=$vpc --query 'RouteTable.RouteTableId' --output text`
#ceph_admin_eni=`aws ec2 describe-instances --instance-id $ceph_admin --output text --query Reservations[*].Instances[*].NetworkInterfaces[*].NetworkInterfaceId`
#aws ec2 create-route --route-table-id $route_table_int --destination-cidr-block 0.0.0.0/0 --network-interface-id $ceph_admin_eni

#aws ec2 associate-route-table --route-table-id $route_table_int --subnet-id $sub_app_euc1a
#aws ec2 associate-route-table --route-table-id $route_table_int --subnet-id $sub_app_euc1b
#aws ec2 associate-route-table --route-table-id $route_table_int --subnet-id $sub_rgw_euc1a
#aws ec2 associate-route-table --route-table-id $route_table_int --subnet-id $sub_rgw_euc1b
#aws ec2 associate-route-table --route-table-id $route_table_int --subnet-id $sub_pub_euc1a
#aws ec2 associate-route-table --route-table-id $route_table_int --subnet-id $sub_pub_euc1b
#aws ec2 associate-route-table --route-table-id $route_table_int --subnet-id $sub_clu_euc1a
#aws ec2 associate-route-table --route-table-id $route_table_int --subnet-id $sub_clu_euc1b



#while [ `aws ec2 describe-instances --output=text --instance-ids $osdnode1 --query Reservations[*].Instances[*].State.Name` != "running" ]; do echo "Wait for startup osd-node1"; done
#while [ `aws ec2 describe-instances --output=text --instance-ids $osdnode2 --query Reservations[*].Instances[*].State.Name` != "running" ]; do echo "Wait for startup osd-node2"; done
#while [ `aws ec2 describe-instances --output=text --instance-ids $osdnode3 --query Reservations[*].Instances[*].State.Name` != "running" ]; do echo "Wait for startup osd-node3"; done


#while [ `aws ec2 describe-volumes --volume-id $osdnode1_xvdb --output text --query Volumes[*].State` != "available" ] ; do  echo "wait" ; done
#aws ec2 attach-volume --volume-id $osdnode1_xvdb --instance-id $osdnode1 --device /dev/xvdb
#while [ `aws ec2 describe-volumes --volume-id $osdnode1_xvdc --output text --query Volumes[*].State` != "available" ] ; do  echo "wait" ; done
#aws ec2 attach-volume --volume-id $osdnode1_xvdc --instance-id $osdnode1 --device /dev/xvdc
#while [ `aws ec2 describe-volumes --volume-id $osdnode1_xvdd --output text --query Volumes[*].State` != "available" ] ; do  echo "wait" ; done
#aws ec2 attach-volume --volume-id $osdnode1_xvdd --instance-id $osdnode1 --device /dev/xvdd


#while [ `aws ec2 describe-volumes --volume-id $osdnode2_xvdb --output text --query Volumes[*].State` != "available" ] ; do  echo "wait" ; done
#aws ec2 attach-volume --volume-id $osdnode2_xvdb --instance-id $osdnode2 --device /dev/xvdb
#while [ `aws ec2 describe-volumes --volume-id $osdnode2_xvdc --output text --query Volumes[*].State` != "available" ] ; do  echo "wait" ; done
#aws ec2 attach-volume --volume-id $osdnode2_xvdc --instance-id $osdnode2 --device /dev/xvdc
#while [ `aws ec2 describe-volumes --volume-id $osdnode2_xvdd --output text --query Volumes[*].State` != "available" ] ; do  echo "wait" ; done
#aws ec2 attach-volume --volume-id $osdnode2_xvdd --instance-id $osdnode2 --device /dev/xvdd


#while [ `aws ec2 describe-volumes --volume-id $osdnode3_xvdb --output text --query Volumes[*].State` != "available" ] ; do  echo "wait" ; done
#aws ec2 attach-volume --volume-id $osdnode3_xvdb --instance-id $osdnode3 --device /dev/xvdb
#while [ `aws ec2 describe-volumes --volume-id $osdnode3_xvdc --output text --query Volumes[*].State` != "available" ] ; do  echo "wait" ; done
#aws ec2 attach-volume --volume-id $osdnode3_xvdc --instance-id $osdnode3 --device /dev/xvdc
#while [ `aws ec2 describe-volumes --volume-id $osdnode3_xvdd --output text --query Volumes[*].State` != "available" ] ; do  echo "wait" ; done
#aws ec2 attach-volume --volume-id $osdnode3_xvdd --instance-id $osdnode3 --device /dev/xvdd