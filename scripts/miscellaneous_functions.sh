 #!/bin/bash 
  
 # repository for all miscelleanous funtions
 
function print_help() {
echo "create_ceph_on_aws -abhsuv -a <AZ> -b <AZ> -s <subnet_number> -u <user_subnet_number> -v <VPC_name>"
echo ""
echo "-a <AZ>                   : Availabilty Zone A"
echo "-b <AZ>                   : Availabilty Zone B"
echo "-h                        : Print this help"
echo "-s <subnet_number>        : subnet inside CIDR used for this lab"
echo "-u <user_subnet_number>   : Subnet for User inside -s Subnet"
echo "-v <VPC_name>             : VPC name"
echo ""
echo "defaults:"
echo "-a = $AZ_A"
echo "-b = $AZ_B"
echo "-s = $LAB_SUBNET"
echo "-u = $LAB_SUBNET_USER"
echo "-v = VPC_NAME"
echo ""
echo "VPC $VPC_NAME with CIDR 10.$LAB_SUBNET.0.0/16 for user-subnet 10.$LAB_SUBNET.$LAB_SUBNET_USER.0 in AZ-A $AZ_A and AZ-B $AZ_B"
exit 0
}


function yes_no_input () {
#$1 = message to display	

	while true; do
		read -p "$1" yn
		case $yn in
			[Yy]* ) echo 0; exit;;
			[Nn]* ) echo 1; exit;;
			* ) echo "Please answer (y)es or (n)o.";;
		esac
	done	
}

function parse_parameters () {
# parse input parameters

	local OPTIND o a 

	while getopts "a:b:hs:au:v" o; do 
		case "${o}" in 
		a) 
			AZ_A=${OPTARG}				
			;; 
		b) 
			AZ_B=${OPTARG}
			;; 
		h) 
			print_help 
			exit 0
			;; 
		s) 
			if [[ "${OPTARG}" =~ ^[0-9]*$  && "${OPTARG}" -ge 0 && "${OPTARG}" -le 254 ]];
				then
					LAB_SUBNET=${OPTARG}		
				else
					echo "subnet value is not valid or not between 0 and 254"
					exit 1;
			fi
			;; 
		u) 
			if [[ "${OPTARG}" =~ ^[0-9]*$  && "${OPTARG}" -ge 0 && "${OPTARG}" -le 254 ]];
				then
					LAB_SUBNET_USER=${OPTARG}		
				else
					echo "subnet for user is not valid or not between 0 and 254"
					exit 1;
			fi
			;; 
		v) 
			VPC_NAME=${OPTARG}
			;; 
		*) 
			echo "Incorrect options provided" 
			print_help
			exit 1 
			;; 
		esac
	done

}


