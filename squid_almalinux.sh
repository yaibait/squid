#!/bin/bash
# Squid Proxy Server - AlmaLinux version

squid_user=binh
squid_password=Quacam123
PORT=7749

echo "===== INSTALL SQUID ====="
dnf install -y squid httpd-tools

echo "===== CREATE USER ====="
htpasswd -b -c /etc/squid/passwd $squid_user $squid_password

echo "===== BACKUP CONFIG ====="
mv /etc/squid/squid.conf /etc/squid/squid.conf.bak

echo "===== CREATE BLACKLIST ====="
touch /etc/squid/blacklist.acl

echo "===== DOWNLOAD CONFIG ====="
curl -o /etc/squid/squid.conf https://raw.githubusercontent.com/yaibait/squid/master/squid_centos.conf

echo "===== CONFIG FIREWALL ====="
systemctl enable firewalld
systemctl start firewalld

firewall-cmd --permanent --add-port=${PORT}/tcp
firewall-cmd --permanent --add-port=${PORT}/udp
firewall-cmd --reload

echo "===== START SQUID ====="
systemctl restart squid
systemctl enable squid

echo "===== STATUS ====="
systemctl status squid --no-pager

echo "===== DONE ====="
echo "Proxy: $(curl -s ifconfig.me):${PORT}"
echo "User: $squid_user"
echo "Pass: $squid_password"
