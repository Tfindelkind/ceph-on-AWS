# download all needed config files
wget -O ceph-lab.pem http://tfindelkind.com/wp-content/uploads/2015/09/ceph-lab.zip
wget -O dhclient.conf http://tfindelkind.com/wp-content/uploads/2015/09/dhclient.zip
wget -O sshc http://tfindelkind.com/wp-content/uploads/2015/09/sshc.zip
wget -O sshd_config http://tfindelkind.com/wp-content/uploads/2015/09/sshd_config.zip
wget -O sysctl.conf http://tfindelkind.com/wp-content/uploads/2015/09/sysctl.zip
wget -O named.conf.options http://tfindelkind.com/wp-content/uploads/2015/09/named.conf_.options.zip
wget -O named.conf.local http://tfindelkind.com/wp-content/uploads/2015/09/named.conf_.local_.zip
wget -O lab.hosts http://tfindelkind.com/wp-content/uploads/2015/09/lab.hosts_.zip
wget -O 10.100.rev http://tfindelkind.com/wp-content/uploads/2015/09/10.100.rev_.zip
wget http://tfindelkind.com/wp-content/uploads/2015/09/sndk-ifos-1.0.0.09.build2c.tar.gz 
wget -O install.conf http://tfindelkind.com/wp-content/uploads/2015/09/install.conf_1.zip
wget -O prepare_node http://tfindelkind.com/wp-content/uploads/2015/09/prepare_node2.zip
wget -O install_calamari http://tfindelkind.com/wp-content/uploads/2015/09/install_calamari1.zip


#change file permissions
sudo chmod 600 ceph-lab.pem
sudo chmod 770 sshc
sudo chmod 770 prepare_node
sudo chmod 770 install_calamari

# change hostname
sudo /bin/su -c "echo ceph-admin > /etc/hostname"
sudo hostname ceph-admin


# enable password ssh access
sudo cp sshd_config /etc/ssh/sshd_config
sudo reload ssh
echo ubuntu:ceph | sudo /usr/sbin/chpasswd

# config for NAT
sudo cp sysctl.conf /etc/sysctl.conf 
sudo apt-get update
sudo apt-get install -y iptables-persistent
sudo iptables -t nat -A POSTROUTING -s 10.$1.0.0/16 -j MASQUERADE
sudo /bin/su -c "iptables-save > /etc/iptables/rules.v4"

# install BIND server and use lab config 
sudo apt-get install -y bind9
sudo cp named.conf.local /etc/bind/named.conf.local
sudo cp named.conf.options /etc/bind/named.conf.options
# prepare bind files
sed -i.bak s/100./$1./g 10.100.rev
sed -i.bak s/100./$1./g lab.hosts
sudo cp 10.100.rev /var/lib/bind/10.100.rev
sudo cp lab.hosts /var/lib/bind/lab.hosts 
sudo service bind9 restart

# install webmin for easy changes
sudo apt-get install -y libnet-ssleay-perl libauthen-pam-perl libio-pty-perl apt-show-versions
wget http://prdownloads.sourceforge.net/webadmin/webmin_1.660_all.deb
sudo dpkg --install webmin_1.660_all.deb
sudo /usr/share/webmin/changepass.pl /etc/webmin root ceph

#config DHCP for local DNS
sudo cp dhclient.conf /etc/dhcp/
sudo dhclient -r; sudo dhclient

#prepare IFOS
tar -xvzf sndk-ifos-1.0.0.09.build2c.tar.gz
cp install.conf sndk-ifos-1.0.0.09.build2c

#prepare other hosts

ssh-keyscan -H ceph-admin >> ~/.ssh/known_hosts
ssh-keyscan -H 10.$1.0.10 >> ~/.ssh/known_hosts
ssh-keyscan -H devstack >> ~/.ssh/known_hosts
ssh-keyscan -H 10.$1.2.10 >> ~/.ssh/known_hosts
ssh-keyscan -H radosgw >> ~/.ssh/known_hosts
ssh-keyscan -H 10.$1.4.10 >> ~/.ssh/known_hosts
ssh-keyscan -H mon1 >> ~/.ssh/known_hosts
ssh-keyscan -H 10.$1.6.10 >> ~/.ssh/known_hosts
ssh-keyscan -H osd-node1 >> ~/.ssh/known_hosts
ssh-keyscan -H 10.$1.8.10 >> ~/.ssh/known_hosts
ssh-keyscan -H osd-node2 >> ~/.ssh/known_hosts
ssh-keyscan -H 10.$1.9.10 >> ~/.ssh/known_hosts
ssh-keyscan -H osd-node3 >> ~/.ssh/known_hosts
ssh-keyscan -H 10.$1.8.11 >> ~/.ssh/known_hosts

./prepare_node devstack
./prepare_node radosgw
./prepare_node mon1
./prepare_node osd-node1
./prepare_node osd-node2
./prepare_node osd-node3
./prepare_node ceph-admin
