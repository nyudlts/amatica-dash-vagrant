#!/bin/bash

yum update -y

semanage port -a -t http_port_t -p tcp 80
semanage port -a -t http_port_t -p tcp 3306
semanage port -a -t http_port_t -p tcp 4730
semanage port -a -t http_port_t -p tcp 9200

setsebool -P httpd_can_network_connect_db=1
setsebool -P httpd_can_network_connect=1
setsebool -P httpd_setrlimit 1

yum install -y epel-release

rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch

bash -c 'cat << EOF > /etc/yum.repos.d/archivematica.repo
[archivematica]
name=archivematica
baseurl=https://packages.archivematica.org/1.10.x/centos
gpgcheck=1
gpgkey=https://packages.archivematica.org/1.10.x/key.asc
enabled=1
EOF'

bash -c 'cat << EOF > /etc/yum.repos.d/archivematica-extras.repo
[archivematica-extras]
name=archivematica-extras
baseurl=https://packages.archivematica.org/1.10.x/centos-extras
gpgcheck=1
gpgkey=https://packages.archivematica.org/1.10.x/key.asc
enabled=1
EOF'

bash -c 'cat << EOF > /etc/yum.repos.d/elasticsearch.repo
[elasticsearch-6.x]
name=Elasticsearch repository for 6.x packages
baseurl=https://artifacts.elastic.co/packages/6.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
EOF'

yum install -y java-1.8.0-openjdk-headless elasticsearch mariadb-server gearmand python-pip

echo "network.host: 0.0.0.0" >> /etc/elasticsearch/elasticsearch.yml

systemctl enable elasticsearch && systemctl start elasticsearch

systemctl enable mariadb && systemctl start mariadb

systemctl enable gearmand && systemctl start gearmand

mysql -hlocalhost -uroot -e "DROP DATABASE IF EXISTS MCP; CREATE DATABASE MCP CHARACTER SET utf8 COLLATE utf8_unicode_ci;"

mysql -hlocalhost -uroot -e "CREATE USER 'archivematica'@'localhost' IDENTIFIED BY 'demo';"

mysql -hlocalhost -uroot -e "GRANT ALL ON MCP.* TO 'archivematica'@'localhost';"

yum install -y archivematica-common archivematica-mcp-server archivematica-dashboard

sudo -u archivematica bash -c " \
set -a -e -x
source /etc/sysconfig/archivematica-dashboard
cd /usr/share/archivematica/dashboard
/usr/share/archivematica/virtualenvs/archivematica-dashboard/bin/python manage.py migrate
";

systemctl enable archivematica-mcp-server && systemctl start archivematica-mcp-server

systemctl enable archivematica-dashboard && systemctl start archivematica-dashboard

sed -i -e 's/listen 81 default_server/listen 80 default_server/' /etc/nginx/conf.d/archivematica-dashboard.conf

mv /tmp/nginx.conf /etc/nginx/nginx.conf

systemctl enable nginx && systemctl start nginx