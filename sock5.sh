#!/bin/bash

socks_user=binh
socks_password=Quacam123
PORT=4977

dnf install -y epel-release
dnf install -y dante-server

useradd -M -s /sbin/nologin $socks_user
echo "$socks_user:$socks_password" | chpasswd

IFACE=$(ip route get 1 | awk '{print $5;exit}')

cat > /etc/sockd.conf <<EOF
logoutput: syslog

internal: 0.0.0.0 port = $PORT
external: $IFACE

method: username

user.privileged: root
user.notprivileged: nobody

client pass {
    from: 0.0.0.0/0 to: 0.0.0.0/0
}

socks pass {
    from: 0.0.0.0/0 to: 0.0.0.0/0
    command: connect
    method: username
}
EOF

# mở firewall
firewall-cmd --permanent --add-port=$PORT/tcp
firewall-cmd --reload

systemctl enable sockd
systemctl restart sockd
systemctl status sockd
