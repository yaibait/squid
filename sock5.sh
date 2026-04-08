#!/bin/bash

socks_user=binh
socks_password=Quacam123
PORT=4977
SWAPSIZE=1G

echo "===== FIX DNS ====="
echo -e "nameserver 1.1.1.1\nnameserver 8.8.8.8" > /etc/resolv.conf

echo "===== CHECK SWAP ====="

if [ $(swapon --show | wc -l) -eq 0 ]; then
    echo "No swap found. Creating swap..."

    fallocate -l $SWAPSIZE /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    echo '/swapfile none swap sw 0 0' >> /etc/fstab

    echo "Swap created:"
    free -m
else
    echo "Swap already exists"
fi

echo "===== INSTALL SOCKS5 ====="

dnf install -y epel-release
dnf install -y dante-server --setopt=install_weak_deps=False

echo "===== CREATE USER ====="

id "$socks_user" &>/dev/null || useradd -M -s /sbin/nologin $socks_user
echo "$socks_user:$socks_password" | chpasswd

echo "===== CONFIGURE DANTE ====="

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

echo "===== OPEN FIREWALL ====="

firewall-cmd --permanent --add-port=$PORT/tcp
firewall-cmd --reload

echo "===== START SERVICE ====="

systemctl enable sockd
systemctl restart sockd

systemctl status sockd

echo "===== DONE ====="
echo "SOCKS5 Proxy:"
echo "IP: $(curl -s ifconfig.me):$PORT"
echo "User: $socks_user"
echo "Pass: $socks_password"
