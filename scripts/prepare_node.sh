source lab.conf

scp -i $STUDENT.pem ./config-files/dhclient.conf ubuntu@$1:/home/ubuntu
ssh -i $STUDENT.pem ubuntu@$1 sudo cp dhclient.conf /etc/dhcp/
scp -i $STUDENT.pem ./config-files/sshd_config ubuntu@$1:/home/ubuntu
ssh -i $STUDENT.pem ubuntu@$1 sudo cp sshd_config /etc/ssh/sshd_config
ssh -i $STUDENT.pem ubuntu@$1 "echo ubuntu:ceph | sudo chpasswd"
ssh -i $STUDENT.pem ubuntu@$1 "echo $1 > hostname"
ssh -i $STUDENT.pem ubuntu@$1 sudo cp hostname /etc/hostname
ssh -i $STUDENT.pem ubuntu@$1 sudo reboot
