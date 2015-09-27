#!/bin/bash

# delete ceph_AWS_network_environment
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
STUDENT="student-$LAB_SUBNET-$LAB_SUBNET_USER"
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


get_vpcid

get_igw

terminate_instance_byname OSD_NODE3ID osd-node3-$LAB_SUBNET_USER
terminate_instance_byname OSD_NODE2ID osd-node2-$LAB_SUBNET_USER
terminate_instance_byname OSD_NODE1ID osd-node1-$LAB_SUBNET_USER
terminate_instance_byname MON1ID mon1-$LAB_SUBNET_USER
terminate_instance_byname RADOSGWID radosgw-$LAB_SUBNET_USER
terminate_instance_byname DEVSTACKID devstack-$LAB_SUBNET_USER
terminate_instance_byname CEPH_ADMINID ceph-admin-$LAB_SUBNET_USER

# make sure all instances are terminated before continue
while [ `aws ec2 describe-instances --output=text --instance-ids $OSD_NODE3ID --query Reservations[*].Instances[*].State.Name` != "terminated" ]; do echo "Wait for terminating OSD_NODE3ID"; done
while [ `aws ec2 describe-instances --output=text --instance-ids $OSD_NODE2ID --query Reservations[*].Instances[*].State.Name` != "terminated" ]; do echo "Wait for terminating OSD_NODE3ID"; done
while [ `aws ec2 describe-instances --output=text --instance-ids $OSD_NODE1ID --query Reservations[*].Instances[*].State.Name` != "terminated" ]; do echo "Wait for terminating OSD_NODE3ID"; done
while [ `aws ec2 describe-instances --output=text --instance-ids $MON1ID --query Reservations[*].Instances[*].State.Name` != "terminated" ]; do echo "Wait for terminating OSD_NODE3ID"; done
while [ `aws ec2 describe-instances --output=text --instance-ids $RADOSGWID --query Reservations[*].Instances[*].State.Name` != "terminated" ]; do echo "Wait for terminating OSD_NODE3ID"; done
while [ `aws ec2 describe-instances --output=text --instance-ids $DEVSTACKID --query Reservations[*].Instances[*].State.Name` != "terminated" ]; do echo "Wait for terminating OSD_NODE3ID"; done
while [ `aws ec2 describe-instances --output=text --instance-ids $CEPH_ADMINID --query Reservations[*].Instances[*].State.Name` != "terminated" ]; do echo "Wait for terminating OSD_NODE3ID"; done


delete_volume_byname $AZ_A $OSD_NODE1-xvdb
delete_volume_byname $AZ_A $OSD_NODE1-xvdc
delete_volume_byname $AZ_A $OSD_NODE1-xvdd
delete_volume_byname $AZ_B $OSD_NODE2-xvdb
delete_volume_byname $AZ_B $OSD_NODE2-xvdc
delete_volume_byname $AZ_B $OSD_NODE2-xvdd
delete_volume_byname $AZ_A $OSD_NODE3-xvdb
delete_volume_byname $AZ_A $OSD_NODE3-xvdc
delete_volume_byname $AZ_A $OSD_NODE3-xvdd

delete_security_group_byname $SG_EXT
delete_security_group_byname $SG_APP
delete_security_group_byname $SG_RGW
delete_security_group_byname $SG_PUB
delete_security_group_byname $SG_CLU

delete_subnet_byname  $SUB_EXT_A
delete_subnet_byname  $SUB_EXT_B
delete_subnet_byname  $SUB_APP_A
delete_subnet_byname  $SUB_APP_B
delete_subnet_byname  $SUB_RGW_A
delete_subnet_byname  $SUB_RGW_B
delete_subnet_byname  $SUB_PUB_A
delete_subnet_byname  $SUB_PUB_B
delete_subnet_byname  $SUB_CLU_A
delete_subnet_byname  $SUB_CLU_B

delete_route_table_byname $ROUTETABLE_INT
delete_route_table_byname $ROUTETABLE_EXT

delete_key_pair $STUDENT

detach_igw

delete_igw

delete_vpc








