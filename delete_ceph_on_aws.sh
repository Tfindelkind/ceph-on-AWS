#!/bin/bash

# delete ceph_AWS_network_environment
# 

# Import functions
source ./scripts/miscellaneous_functions.sh
source ./scripts/AWS_functions.sh 

#global defaults
VPC_NAME="vpc-ceph-lab"
AZ_A="eu-central-1a"
AZ_B="eu-central-1b"
LAB_SUBNET=100
LAB_SUBNET_USER=0

SUB_EXT_A="sub_ext_a"
SUB_EXT_B="sub_ext_b"
SUB_APP_A="sub_app_a"
SUB_APP_B="sub_app_b"
SUB_RGW_A="sub_rgw_a"
SUB_RGW_B="sub_rgw_b"
SUB_PUB_A="sub_pub_a"
SUB_PUB_B="sub_pub_b"
SUB_CLU_A="sub_clu_a"
SUB_CLU_B="sub_clu_b"

SG_EXT="sg_ext"
SG_EXT_DESC=$SG_EXT"_desc"
SG_APP="sg_app"
SG_APP_DESC=$SG_APP"_desc"
SG_RGW="sg_rgw"
SG_RGW_DESC=$SG_RGW"_desc"
SG_PUB="sg_pub"
SG_PUB_DESC=$SG_PUB"_desc"
SG_CLU="sg_clu"
SG_CLU_DESC=$SG_CLU"_desc"


parse_parameters "$@"


#Global variables
VPCID=0
VPC_CIDR="10.$LAB_SUBNET.0.0/16"
IGWID=0
IGW_EXISTS=0

MAINROUTETABLEID=0

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

########################################################
# Main


get_vpcid

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








