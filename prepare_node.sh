scp -i ceph-lab.pem ./scripts/dhclient.conf ubuntu@$1:/home/ubuntu
ssh -v -i ceph-lab.pem ubuntu@$1 sudo cp dhclient.conf /etc/dhcp/
scp -i ceph-lab.pem ./scripts/sshd_config ubuntu@$1:/home/ubuntu
ssh -v -i ceph-lab.pem ubuntu@$1 sudo cp sshd_config /etc/ssh/sshd_config
ssh -v -i ceph-lab.pem ubuntu@$1 "echo ubuntu:ceph | sudo chpasswd"
ssh -v -i ceph-lab.pem ubuntu@$1 "echo $1 > hostname"
ssh -v -i ceph-lab.pem ubuntu@$1 sudo cp hostname /etc/hostname
ssh -v -i ceph-lab.pem ubuntu@$1 sudo reboot
