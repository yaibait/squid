#!/usr/bin/env bash
set -euo pipefail

# Usage: sudo ./add-mirror.sh [MIRROR_BASE_URL]
# Example: sudo ./add-mirror.sh https://ftp.osuosl.org/pub/centos-stream

MIRROR="${1:-https://mirror.stream.centos.org}"
REPO_FILE="/etc/yum.repos.d/centos-stream-custom.repo"
BACKUP_DIR="/root/repo-backup-$(date +%Y%m%d-%H%M%S)"

# check root
if [[ $EUID -ne 0 ]]; then
  echo "Vui lòng chạy script này với sudo hoặc root."
  exit 1
fi

echo "=== Backup các file .repo hiện tại vào $BACKUP_DIR ==="
mkdir -p "$BACKUP_DIR"
cp -av /etc/yum.repos.d/*.repo "$BACKUP_DIR/" || true

echo "=== Tạo file repo mới: $REPO_FILE (mirror: $MIRROR) ==="

cat > "$REPO_FILE" <<EOF
[baseos]
name=CentOS Stream \$releasever - BaseOS - custom mirror
baseurl=$MIRROR/\$releasever-stream/BaseOS/\$basearch/os/
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial

[appstream]
name=CentOS Stream \$releasever - AppStream - custom mirror
baseurl=$MIRROR/\$releasever-stream/AppStream/\$basearch/os/
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial

[extras]
name=CentOS Stream \$releasever - Extras - custom mirror
baseurl=$MIRROR/\$releasever-stream/extras/\$basearch/os/
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial
EOF

# Ensure existing centos-release-stream package is present (best-effort update)
echo "=== Cập nhật gói centos-release-stream (nếu có) ==="
if dnf list installed centos-release-stream &>/dev/null; then
  dnf -y update centos-release-stream || true
fi

echo "=== Làm sạch cache DNF và tải lại metadata ==="
dnf clean all
rm -rf /var/cache/dnf || true

echo "=== Tạo cache mới ==="
if ! dnf makecache; then
  echo "WARN: dnf makecache thất bại — kiểm tra kết nối tới mirror ($MIRROR) và DNS."
  echo "Bạn có thể thử các mirror khác (ví dụ https://ftp.osuosl.org/pub/centos-stream)."
  exit 2
fi

echo "=== Hiện repo list ==="
dnf repolist

echo "=== Thử cài squid và httpd-tools ==="
if dnf -y install squid httpd-tools; then
  echo "Cài đặt thành công squid và httpd-tools."
else
  echo "Cài đặt thất bại. Kiểm tra lỗi bên trên. Có thể repo chưa đúng hoặc mirror unreachable."
  exit 3
fi

echo "=== Hoàn tất ==="
echo "Backup repo cũ ở: $BACKUP_DIR"
echo "File repo mới: $REPO_FILE"
