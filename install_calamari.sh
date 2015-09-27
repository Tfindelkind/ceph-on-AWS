#install calamari

sudo apt-get install -y apache2 libapache2-mod-wsgi libcairo2 supervisor python-cairo libpq5 postgresql python-pip
sudo pip install ceph-deploy --upgrade
echo deb http://ppa.launchpad.net/saltstack/salt/ubuntu lsb_release -sc main | sudo tee /etc/apt/sources.list.d/saltstack.list
wget -q -O- "http://keyserver.ubuntu.com:11371/pks/lookup?op=get&search=0x4759FA960E27C0A6" | sudo apt-key add -
sudo apt-get update
sudo apt-get install -y gdebi-core
sudo gdebi -n ./AMI/ami-accff2b1/calamari-server*
sudo gdebi -n ./AMI/ami-accff2b1/diamond*
sudo calamari-ctl initialize --admin-username ubuntu --admin-password ceph --admin-email admin@ceph-admin 


#install clients
tar -xvzf ./AMI/ami-accff2b1/calamari-clients_1.2.2.tar.gz
sudo cp -avr ./calamari-clients-1.2.2/dashboard/dist /opt/calamari/webapp/content/dashboard
sudo cp -avr ./calamari-clients-1.2.2/login/dist /opt/calamari/webapp/content/login
sudo cp -avr ./calamari-clients-1.2.2/manage/dist /opt/calamari/webapp/content/manage
sudo cp -avr ./calamari-clients-1.2.2/admin/dist /opt/calamari/webapp/content/admin
