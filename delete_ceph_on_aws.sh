#!/bin/bash

# delete ceph_AWS_network_environment
# 

# Import functions
source ./scripts/config.sh
source ./scripts/miscellaneous_functions.sh
source ./scripts/AWS_functions.sh 


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

detach_read_policy

delete_login_profile

delete_user

delete_key_pair 

detach_igw

delete_igw

delete_vpc








