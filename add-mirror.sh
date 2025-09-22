#!/usr/bin/env bash
set -euo pipefail

REPO_FILE="/etc/yum.repos.d/CentOS-Stream-Extra.repo"

echo "=== Tạo repo mới: $REPO_FILE ==="

cat > "$REPO_FILE" <<'EOF'
[baseos]
name=CentOS Stream $releasever - BaseOS - OSUOSL
baseurl=https://ftp.osuosl.org/pub/centos-stream/$releasever-stream/BaseOS/$basearch/os/
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial

[appstream]
name=CentOS Stream $releasever - AppStream - OSUOSL
baseurl=https://ftp.osuosl.org/pub/centos-stream/$releasever-stream/AppStream/$basearch/os/
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial
EOF

echo "=== Repo đã được tạo tại $REPO_FILE ==="

echo "=== Làm sạch cache DNF ==="
dnf clean all

echo "=== Tạo lại metadata từ mirror OSUOSL ==="
dnf makecache

echo "=== Hoàn tất! ==="
