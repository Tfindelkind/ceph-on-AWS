#ceph-on-AWS
Bash scripts and configuration files to install and deploy a ceph training environment based on AWS
Author: Thomas Findelkind, @TFindelkind, Blog: TFindelkind.com, webmaster at thomas-findelkind.de

#Requirements
	
	- bash 
	
	- AWS CLI need to be installed and configured: http://docs.aws.amazon.com/cli/latest/userguide/installing.html
	  Test if commands work like: aws ec2 describe-vpcs --output table 
	  Your user need to have the rights to create objects like: VPC, RouteTable, Route, Instances,...
	  
	- If the region you want to use is not Frankfurt (eu-central-1) set the default region in the "aws configure" 
	  and make use of the -a -b option to set the two Availabilty zones you would like to use
	
	- The AWS VPC and CIDR which is used is forced to be one 10.LAB_SUBNET.X.X net. The lab subnet can only be choosen in the range of 10.XXX.
		
	- git 



#Installing
git clone https://github.com/Tfindelkind/ceph-on-AWS


#How-To run

The setup is seperated in four parts 

	1. User and private keys creation
	
		Because this setup can create up to ~250 student environments in one VPC there need to be possibility to handle the access for the students/users
		There are two supported modes:
			1.1	One user who is admin and student in one person (default)
			
			1.2 One admin user and several student user created in IAM with access to their environments

	
	2. Creation of the AWS environment
		The following script will be run by the admin user to create a lab environment including a VPC called: vpc-ceph-lab ands an IGW
		
		./create_ceph_on_AWS.sh
		(This creates a lab with Subnet 10.100.0.XXX in the region Franfurt eu-central-1)
		
		./create_ceph_on_AWS -a eu-west-1a -b eu-west-1b -s 30 -u 10 -v my-vpc
		(This creates a lab with Subnet 10.30.10.XXX in the region Ireland (eu-west-1) with AZ eu-west-1a and eu-west-1b  in VPC with the name tag my-vpc
		 Make sure to set the default region with "aws configure")
		
	3. Setup ceph-admin hosts
		The following script will be run by the student/user inside the ceph-admin instances to prepare the whole environment for ceph
		
		./setup_ceph-admin.sh 
		
	4. 	The following script will be run by the student/user inside the ceph-admin instances to deploy and create the ceph cluster
		
		./setup_ceph.sh
		
	5. Setup Calamari (optional)	
		The following script will be run by the student/user inside the ceph-admin instances to install calamari for this environment
		
		./install_calamari.sh
		
Have fun!
		



