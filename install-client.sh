#!/bin/bash

yum install -y archivematica-mcp-client

sudo ln -sf /usr/bin/7za /usr/bin/7z

sed -i 's/^#TCPSocket/TCPSocket/g' /etc/clamd.d/scan.conf

sed -i 's/^Example//g' /etc/clamd.d/scan.conf

systemctl enable archivematica-mcp-client && systemctl start archivematica-mcp-client
systemctl enable fits-nailgun  && systemctl start fits-nailgun
systemctl enable clamd@scan  && systemctl start clamd@scan
systemctl restart archivematica-dashboard
systemctl restart archivematica-mcp-server

