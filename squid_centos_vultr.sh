#!/bin/bash
# <UDF name="squid_user" Label="Proxy Username" />
# <UDF name="squid_password" Label="Proxy Password" />
# Squid Proxy Server
# Author: admin@hostonnet.com
# Blog: https://blog.hostonnet.com
# Edits: Khaled AlHashem
# Site: https://knaved.com
# Version 0.1

squid_user=binh
squid_password=Quacam123

yum -y install squid httpd-tools

htpasswd -b -c /etc/squid/passwd $squid_user $squid_password

mv /etc/squid/squid.conf /etc/squid/squid.conf.bak
touch /etc/squid/blacklist.acl
curl -o /etc/squid/squid.conf  https://raw.githubusercontent.com/yaibait/squid/master/squid_centos.conf
iptables -I INPUT -p tcp --dport 7749 -j ACCEPT
#/sbin/iptables-save
/sbin/service iptables save
firewall-cmd --permanent --add-port=7749/tcp
firewall-cmd --permanent --add-port=7749/udp
firewall-cmd --reload
systemctl restart squid
systemctl enable squid
systemctl status squid
#update-rc.d squid defaults
