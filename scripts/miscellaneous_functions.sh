 #!/bin/bash 
  
 # repository for all miscelleanous funtions
 
function print_help() {
echo "create_ceph_on_aws -sh -s <subnet>"
echo ""
echo "-h --help				: Print this help"
echo "-s <subnet>				: subnet inside CIDR used for this lab"
echo ""
echo "CIDR is 10.<subnet>.0.0 and default subnet=100 results in VPC with 10.100.0.0/16"
echo 0
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


