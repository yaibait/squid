#!/bin/bash

socks_user=binh
socks_password=Quacam123

yum -y install epel-release
yum -y install dante-server

useradd -M -s /sbin/nologin $socks_user
echo "$socks_user:$socks_password" | chpasswd

mv /etc/sockd.conf /etc/sockd.conf.bak 2>/dev/null

IFACE=$(ip route get 1 | awk '{print $5;exit}')

cat > /etc/sockd.conf <<EOF
logoutput: syslog

internal: 0.0.0.0 port = 4977
external: $IFACE

method: username
user.privileged: root
user.notprivileged: nobody

client pass {
    from: 0.0.0.0/0 to: 0.0.0.0/0
    log: connect disconnect
}

socks pass {
    from: 0.0.0.0/0 to: 0.0.0.0/0
    command: connect
    method: username
    log: connect disconnect
}
EOF

iptables -I INPUT -p tcp --dport 4977 -j ACCEPT
/sbin/service iptables save

systemctl restart sockd
systemctl enable sockd
systemctl status sockd
