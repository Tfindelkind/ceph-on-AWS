#!/bin/bash

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
