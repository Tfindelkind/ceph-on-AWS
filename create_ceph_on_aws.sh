#!/bin/bash

# create_AWS_network_environment
# 

# Import functions
source ./scripts/config.sh
source ./scripts/miscellaneous_functions.sh
source ./scripts/AWS_functions.sh 

#Parse input parameters
parse_parameters "$@"

#Global variables
VPCID=0
VPC_CIDR="10.$LAB_SUBNET.0.0/16"
IGWID=0
IGW_EXISTS=0

MAINROUTETABLEID=0
ROUTETABLE_INTID=0
ROUTETABLE_EXTID=0

ROUTETABLE_INT="rt-int-$LAB_SUBNET_USER"
ROUTETABLE_EXT="rt-ext-$LAB_SUBNET_USER"


CEPH_ADMIN="ceph-admin-$LAB_SUBNET_USER"
DEVSTACK="devstack-$LAB_SUBNET_USER"
RADOSGW="radosgw-$LAB_SUBNET_USER"
MON1="mon1-$LAB_SUBNET_USER"
OSD_NODE1="osd-node1-$LAB_SUBNET_USER"
OSD_NODE2="osd-node2-$LAB_SUBNET_USER"
OSD_NODE3="osd-node3-$LAB_SUBNET_USER"


SUB_EXT_AID=0
SUB_EXT_A_CIDR="10.$LAB_SUBNET.$LAB_SUBNET_USER.2/28"
SUB_EXT_BID=0
SUB_EXT_B_CIDR="10.$LAB_SUBNET.$LAB_SUBNET_USER.16/28"
SUB_APP_AID=0
SUB_APP_A_CIDR="10.$LAB_SUBNET.$LAB_SUBNET_USER.32/28"
SUB_APP_BID=0
SUB_APP_B_CIDR="10.$LAB_SUBNET.$LAB_SUBNET_USER.48/28"
SUB_RGW_AID=0
SUB_RGW_A_CIDR="10.$LAB_SUBNET.$LAB_SUBNET_USER.64/28"
SUB_RGW_BID=0
SUB_RGW_B_CIDR="10.$LAB_SUBNET.$LAB_SUBNET_USER.88/28"
SUB_PUB_AID=0
SUB_PUB_A_CIDR="10.$LAB_SUBNET.$LAB_SUBNET_USER.96/28"
SUB_PUB_BID=0
SUB_PUB_B_CIDR="10.$LAB_SUBNET.$LAB_SUBNET_USER.112/28"
SUB_CLU_AID=0
SUB_CLU_A_CIDR="10.$LAB_SUBNET.$LAB_SUBNET_USER.128/28"
SUB_CLU_BID=0
SUB_CLU_B_CIDR="10.$LAB_SUBNET.$LAB_SUBNET_USER.144/28"

SG_EXTID=0
SG_APPID=0
SG_RGWID=0
SG_PUBID=0
SG_CLUID=0

CEPH_ADMINID=0
DEVSTACKID=0
RADOSGWID=0
MON1ID=0
OSD_NODE1ID=0
OSD_NODE2ID=0
OSD_NODE3ID=0

CEPH_ADMIN_ENIID=0
CEPH_ADMIN_PUBLICIP=0

OSD_NODE1_XVDBID=0
OSD_NODE1_XVDCID=0
OSD_NODE1_XVDDID=0
OSD_NODE2_XVDBID=0
OSD_NODE2_XVDCID=0
OSD_NODE2_XVDDID=0
OSD_NODE3_XVDBID=0
OSD_NODE3_XVDCID=0
OSD_NODE3_XVDDID=0



########################################################
# Main


# no return values for functions
result=0
	
#result=$(yes_no_input "Do you wish to create lab VPC: $VPC_NAME with CIDR block: $VPC_CIDR y/n:");
#if [ $result -eq 1 ];then exit 0; fi
		
get_vpcid

get_igw

create_vpc 

create_igw


if [ "$IGW_EXISTS" = false ]; then attach_igw; fi

get_main_route_table 

create_subnet SUB_EXT_AID $SUB_EXT_A_CIDR $AZ_A $SUB_EXT_A
create_subnet SUB_EXT_BID $SUB_EXT_B_CIDR $AZ_B $SUB_EXT_B
create_subnet SUB_APP_AID $SUB_APP_A_CIDR $AZ_A $SUB_APP_A
create_subnet SUB_APP_BID $SUB_APP_B_CIDR $AZ_B $SUB_APP_B
create_subnet SUB_RGW_AID $SUB_RGW_A_CIDR $AZ_A $SUB_RGW_A
create_subnet SUB_RGW_BID $SUB_RGW_B_CIDR $AZ_B $SUB_RGW_B
create_subnet SUB_PUB_AID $SUB_PUB_A_CIDR $AZ_A $SUB_PUB_A
create_subnet SUB_PUB_BID $SUB_PUB_B_CIDR $AZ_B $SUB_PUB_B
create_subnet SUB_CLU_AID $SUB_CLU_A_CIDR $AZ_A $SUB_CLU_A
create_subnet SUB_CLU_BID $SUB_CLU_B_CIDR $AZ_B $SUB_CLU_B

create_security_group SG_EXTID $SG_EXT $SG_EXT_DESC
create_security_group SG_APPID $SG_APP $SG_APP_DESC
create_security_group SG_RGWID $SG_RGW $SG_RGW_DESC
create_security_group SG_PUBID $SG_PUB $SG_PUB_DESC
create_security_group SG_CLUID $SG_CLU $SG_CLU_DESC


auth_sg_ingress $SG_EXTID tcp 22 0.0.0.0/0
auth_sg_ingress $SG_EXTID tcp 80 0.0.0.0/0
auth_sg_ingress $SG_EXTID tcp 443 0.0.0.0/0
auth_sg_ingress $SG_EXTID tcp 10000 0.0.0.0/0
auth_sg_ingress $SG_EXTID all all $VPC_CIDR
auth_sg_ingress $SG_APPID all all $VPC_CIDR
auth_sg_ingress $SG_RGWID all all $VPC_CIDR
auth_sg_ingress $SG_PUBID all all $VPC_CIDR
auth_sg_ingress $SG_CLUID all all $VPC_CIDR

run_instance CEPH_ADMINID $AMI t2.small ceph-lab $SG_EXTID $SUB_EXT_AID 10.$LAB_SUBNET.$LAB_SUBNET_USER.4 $CEPH_ADMIN 1 
run_instance DEVSTACKID $AMI t2.micro ceph-lab $SG_APPID $SUB_APP_AID 10.$LAB_SUBNET.$LAB_SUBNET_USER.36 $DEVSTACK 0
run_instance RADOSGWID $AMI t2.micro ceph-lab $SG_RGWID $SUB_RGW_AID 10.$LAB_SUBNET.$LAB_SUBNET_USER.68 $RADOSGW 0
run_instance MON1ID $AMI t2.micro ceph-lab $SG_PUBID $SUB_PUB_AID 10.$LAB_SUBNET.$LAB_SUBNET_USER.100 $MON1 0
run_instance OSD_NODE1ID $AMI t2.micro ceph-lab $SG_CLUID $SUB_CLU_AID 10.$LAB_SUBNET.$LAB_SUBNET_USER.132 $OSD_NODE1 0
run_instance OSD_NODE2ID $AMI t2.micro ceph-lab $SG_CLUID $SUB_CLU_BID 10.$LAB_SUBNET.$LAB_SUBNET_USER.148 $OSD_NODE2 0
run_instance OSD_NODE3ID $AMI t2.micro ceph-lab $SG_CLUID $SUB_CLU_AID 10.$LAB_SUBNET.$LAB_SUBNET_USER.133 $OSD_NODE3 0

disable_source_dest_check $CEPH_ADMINID

create_volume OSD_NODE1_XVDBID $DEVICE_SIZE $AZ_A gp2 $OSD_NODE1-xvdb
create_volume OSD_NODE1_XVDCID $DEVICE_SIZE $AZ_A gp2 $OSD_NODE1-xvdc
create_volume OSD_NODE1_XVDDID $DEVICE_SIZE $AZ_A gp2 $OSD_NODE1-xvdd
create_volume OSD_NODE2_XVDBID $DEVICE_SIZE $AZ_B gp2 $OSD_NODE2-xvdb
create_volume OSD_NODE2_XVDCID $DEVICE_SIZE $AZ_B gp2 $OSD_NODE2-xvdc
create_volume OSD_NODE2_XVDDID $DEVICE_SIZE $AZ_B gp2 $OSD_NODE2-xvdd
create_volume OSD_NODE3_XVDBID $DEVICE_SIZE $AZ_A gp2 $OSD_NODE3-xvdb
create_volume OSD_NODE3_XVDCID $DEVICE_SIZE $AZ_A gp2 $OSD_NODE3-xvdc
create_volume OSD_NODE3_XVDDID $DEVICE_SIZE $AZ_A gp2 $OSD_NODE3-xvdd

# Create route tables
create_route_table ROUTETABLE_EXTID $ROUTETABLE_EXT
aws ec2 create-route --route-table-id $ROUTETABLE_EXTID --destination-cidr-block 0.0.0.0/0 --gateway-id $IGWID
associate_route_table $ROUTETABLE_EXTID $SUB_EXT_AID
associate_route_table $ROUTETABLE_EXTID $SUB_EXT_BID


# Make Sure Ceph Admin is the default gateway for all subnets (NAT)
create_route_table ROUTETABLE_INTID $ROUTETABLE_INT
CEPH_ADMIN_ENIID=`aws ec2 describe-instances --instance-id $CEPH_ADMINID --output text --query Reservations[*].Instances[*].NetworkInterfaces[*].NetworkInterfaceId`
aws ec2 create-route --route-table-id $ROUTETABLE_INTID --destination-cidr-block 0.0.0.0/0 --network-interface-id $CEPH_ADMIN_ENIID
associate_route_table $ROUTETABLE_INTID $SUB_APP_AID
associate_route_table $ROUTETABLE_INTID $SUB_APP_BID
associate_route_table $ROUTETABLE_INTID $SUB_RGW_AID
associate_route_table $ROUTETABLE_INTID $SUB_RGW_BID
associate_route_table $ROUTETABLE_INTID $SUB_PUB_AID
associate_route_table $ROUTETABLE_INTID $SUB_PUB_BID
associate_route_table $ROUTETABLE_INTID $SUB_CLU_AID
associate_route_table $ROUTETABLE_INTID $SUB_CLU_BID

while [ `aws ec2 describe-instances --output=text --instance-ids $OSD_NODE1ID --query Reservations[*].Instances[*].State.Name` != "running" ]; do echo "Wait for startup osd-node1-$LAB_SUBNET_USER"; done
while [ `aws ec2 describe-instances --output=text --instance-ids $OSD_NODE2ID --query Reservations[*].Instances[*].State.Name` != "running" ]; do echo "Wait for startup osd-node2-$LAB_SUBNET_USER"; done
while [ `aws ec2 describe-instances --output=text --instance-ids $OSD_NODE3ID --query Reservations[*].Instances[*].State.Name` != "running" ]; do echo "Wait for startup osd-node3-$LAB_SUBNET_USER"; done


while [ `aws ec2 describe-volumes --volume-id $OSD_NODE1_XVDBID --output text --query Volumes[*].State` != "available" ] ; do  echo "wait" ; done
attach_volume $OSD_NODE1ID $OSD_NODE1_XVDBID /dev/xvdb 
while [ `aws ec2 describe-volumes --volume-id $OSD_NODE1_XVDCID --output text --query Volumes[*].State` != "available" ] ; do  echo "wait" ; done
attach_volume $OSD_NODE1ID $OSD_NODE1_XVDCID /dev/xvdc
while [ `aws ec2 describe-volumes --volume-id $OSD_NODE1_XVDDID --output text --query Volumes[*].State` != "available" ] ; do  echo "wait" ; done
attach_volume $OSD_NODE1ID $OSD_NODE1_XVDDID /dev/xvdd
while [ `aws ec2 describe-volumes --volume-id $OSD_NODE2_XVDBID --output text --query Volumes[*].State` != "available" ] ; do  echo "wait" ; done
attach_volume $OSD_NODE2ID $OSD_NODE2_XVDBID /dev/xvdb
while [ `aws ec2 describe-volumes --volume-id $OSD_NODE2_XVDCID --output text --query Volumes[*].State` != "available" ] ; do  echo "wait" ; done
attach_volume $OSD_NODE2ID $OSD_NODE2_XVDCID /dev/xvdc
while [ `aws ec2 describe-volumes --volume-id $OSD_NODE2_XVDDID --output text --query Volumes[*].State` != "available" ] ; do  echo "wait" ; done
attach_volume $OSD_NODE2ID $OSD_NODE2_XVDDID /dev/xvdd
while [ `aws ec2 describe-volumes --volume-id $OSD_NODE3_XVDBID --output text --query Volumes[*].State` != "available" ] ; do  echo "wait" ; done
attach_volume $OSD_NODE3ID $OSD_NODE3_XVDBID /dev/xvdb
while [ `aws ec2 describe-volumes --volume-id $OSD_NODE3_XVDCID --output text --query Volumes[*].State` != "available" ] ; do  echo "wait" ; done
attach_volume $OSD_NODE3ID $OSD_NODE3_XVDCID /dev/xvdc
while [ `aws ec2 describe-volumes --volume-id $OSD_NODE3_XVDDID --output text --query Volumes[*].State` != "available" ] ; do  echo "wait" ; done
attach_volume $OSD_NODE3ID $OSD_NODE3_XVDDID /dev/xvdd

get_public_ip_eni CEPH_ADMIN_PUBLICIP $CEPH_ADMIN_ENIID

ssh -v -i ceph-lab.pem ubuntu@$CEPH_ADMIN_PUBLICIP sudo apt-get update && sudo apt-get install git && git clone https://github.com/Tfindelkind/ceph-on-AWS 

ssh -v -i ceph-lab.pem ubuntu@$CEPH_ADMIN_PUBLICIP cd ceph-on-AWS && echo "LAB_SUBNET=$LAB_SUBNET" >> lab.conf && echo "LAB_SUBNET_USER=$LAB_SUBNET_USER" >> lab.conf

echo "ceph-admin IP: $CEPH_ADMIN_PUBLICIP"
echo "use: ssh -i ceph-lab.pem ubuntu@$CEPH_ADMIN_PUBLICIP to connect"
echo "Then start ceph install with: ./setup_ceph-admin.sh $AMI"





