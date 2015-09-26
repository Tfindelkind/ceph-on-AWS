source lab.conf

# download all needed config files
wget http://tfindelkind.com/wp-content/uploads/2015/09/sndk-ifos-1.0.0.09.build2c.tar.gz 

# change hostname
sudo /bin/su -c "echo ceph-admin > /etc/hostname"
sudo hostname ceph-admin

# enable password ssh access
sudo cp ./config-files/sshd_config /etc/ssh/sshd_config
sudo reload ssh
echo ubuntu:ceph | sudo /usr/sbin/chpasswd

# config for NAT
sudo cp ./config-files/sysctl.conf /etc/sysctl.conf 
sudo apt-get update
sudo apt-get install -y iptables-persistent
sudo iptables -t nat -A POSTROUTING -s 10.$LAB_SUBNET.0.0/16 -j MASQUERADE
sudo /bin/su -c "iptables-save > /etc/iptables/rules.v4"

# install BIND server and use lab config 
sudo apt-get install -y bind9

# prepare bind files
sed -i.bak s/LS./$LAB_SUBNET./g ./config-files/named.conf.local
sed -i.bak s/LU./$LAB_SUBNET_USER./g ./config-files/named.conf.local
sed -i.bak s/LS./$LAB_SUBNET./g ./config-files/10.100.rev 
sed -i.bak s/LU./$LAB_SUBNET_USER./g ./config-files/10.100.rev
sed -i.bak s/LS./$LAB_SUBNET./g ./config-files/lab.hosts
sed -i.bak s/LU./$LAB_SUBNET_USER./g ./config-files/lab.hosts

sudo cp ./config-files/named.conf.local /etc/bind/named.conf.local
sudo cp ./config-files/named.conf.options /etc/bind/named.conf.options
sudo cp ./config-files/10.100.rev /var/lib/bind/10.$LAB_SUBNET.rev
sudo cp ./config-files/lab.hosts /var/lib/bind/lab.hosts 
sudo service bind9 restart

# install webmin for easy changes
sudo apt-get install -y libnet-ssleay-perl libauthen-pam-perl libio-pty-perl apt-show-versions
wget http://prdownloads.sourceforge.net/webadmin/webmin_1.660_all.deb
sudo dpkg --install webmin_1.660_all.deb
sudo /usr/share/webmin/changepass.pl /etc/webmin root ceph

#config DHCP for local DNS
sed -i.bak s/LS./$LAB_SUBNET./g ./config-files/dhclient.conf
sed -i.bak s/LU./$LAB_SUBNET_USER./g ./config-files/dhclient.conf
sudo cp ./config-files/dhclient.conf /etc/dhcp/
sudo dhclient -r; sudo dhclient

#prepare IFOS
tar -xvzf sndk-ifos-1.0.0.09.build2c.tar.gz
cp ./config-files/install.conf sndk-ifos-1.0.0.09.build2c

#prepare other hosts

ssh-keyscan -H ceph-admin >> ~/.ssh/known_hosts
ssh-keyscan -H 10.$LAB_SUBNET.$LAB_SUBNET_USER.4 >> ~/.ssh/known_hosts
ssh-keyscan -H devstack >> ~/.ssh/known_hosts
ssh-keyscan -H 10.$LAB_SUBNET.$LAB_SUBNET_USER.36 >> ~/.ssh/known_hosts
ssh-keyscan -H radosgw >> ~/.ssh/known_hosts
ssh-keyscan -H 10.$LAB_SUBNET.$LAB_SUBNET_USER.68 >> ~/.ssh/known_hosts
ssh-keyscan -H mon1 >> ~/.ssh/known_hosts
ssh-keyscan -H 10.$LAB_SUBNET.$LAB_SUBNET_USER.100 >> ~/.ssh/known_hosts
ssh-keyscan -H osd-node1 >> ~/.ssh/known_hosts
ssh-keyscan -H 10.$LAB_SUBNET.$LAB_SUBNET_USER.132 >> ~/.ssh/known_hosts
ssh-keyscan -H osd-node2 >> ~/.ssh/known_hosts
ssh-keyscan -H 10.$LAB_SUBNET.$LAB_SUBNET_USER.148 >> ~/.ssh/known_hosts
ssh-keyscan -H osd-node3 >> ~/.ssh/known_hosts
ssh-keyscan -H 10.$LAB_SUBNET.$LAB_SUBNET_USER.133 >> ~/.ssh/known_hosts

./prepare_node devstack
./prepare_node radosgw
./prepare_node mon1
./prepare_node osd-node1
./prepare_node osd-node2
./prepare_node osd-node3
./prepare_node ceph-admin
