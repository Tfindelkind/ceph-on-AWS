#!/bin/bash

source ./scripts/miscellaneous_functions.sh


#global defaults
AZ_A="eu-central-1a"
AZ_B="eu-central-1b"
LAB_SUBNET=100
LAB_SUBNET_USER=0
VPC_NAME="vpc-$LAB_SUBNET"
VPC_NAME_FULL="vpc-$LAB_SUBNET-$LAB_SUBNET_USER"
AMI="ami-accff2b1"
DEVICE_SIZE=8
LOG_FILE=ceph_on_AWS.log
echo "ceph-on-AWS log file: " > ceph_on_AWS.log

#Parse input parameters
parse_parameters "$@"

SUB_EXT_A="sub_ext_a-$VPC_NAME_FULL"
SUB_EXT_B="sub_ext_b-$VPC_NAME_FULL"
SUB_APP_A="sub_app_a-$VPC_NAME_FULL"
SUB_APP_B="sub_app_b-$VPC_NAME_FULL"
SUB_RGW_A="sub_rgw_a-$VPC_NAME_FULL"
SUB_RGW_B="sub_rgw_b-$VPC_NAME_FULL"
SUB_PUB_A="sub_pub_a-$VPC_NAME_FULL"
SUB_PUB_B="sub_pub_b-$VPC_NAME_FULL"
SUB_CLU_A="sub_clu_a-$VPC_NAME_FULL"
SUB_CLU_B="sub_clu_b-$VPC_NAME_FULL"

SG_EXT="sg_ext-$VPC_NAME_FULL"
SG_EXT_DESC="$SG_EXT-$VPC_NAME_FULL-desc"
SG_APP="sg_app-$VPC_NAME_FULL"
SG_APP_DESC="$SG_APP-$VPC_NAME_FULL-desc"
SG_RGW="sg_rgw-$VPC_NAME_FULL"
SG_RGW_DESC="$SG_RGW-$VPC_NAME_FULL-desc"
SG_PUB="sg_pub-$VPC_NAME_FULL"
SG_PUB_DESC="$SG_PUB-$VPC_NAME_FULL-desc"
SG_CLU="sg_clu-$VPC_NAME_FULL"
SG_CLU_DESC="$SG_CLU-$VPC_NAME_FULL-desc"

#Global variables
VPCID=0
VPC_CIDR="10.$LAB_SUBNET.0.0/16"
STUDENT="student-$VPC_NAME_FULL"
IGWID=0
IGW_EXISTS=0
ACCOUNTID=0

MAINROUTETABLEID=0
ROUTETABLE_INTID=0
ROUTETABLE_EXTID=0

ROUTETABLE_INT="rt-int-$VPC_NAME_FULL"
ROUTETABLE_EXT="rt-ext-$VPC_NAME_FULL"


CEPH_ADMIN="ceph-admin-$VPC_NAME_FULL"
DEVSTACK="devstack-$VPC_NAME_FULL"
RADOSGW="radosgw-$VPC_NAME_FULL"
MON1="mon1-$VPC_NAME_FULL"
OSD_NODE1="osd-node1-$VPC_NAME_FULL"
OSD_NODE2="osd-node2-$VPC_NAME_FULL"
OSD_NODE3="osd-node3-$VPC_NAME_FULL"


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

