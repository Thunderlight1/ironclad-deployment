#!/bin/bash
# System performance tuning

echo "⚡ Applying performance optimizations..."

# Increase file descriptor limits
echo "fs.file-max = 2097152" >> /etc/sysctl.conf
echo "fs.inotify.max_user_instances = 8192" >> /etc/sysctl.conf
echo "fs.inotify.max_user_watches = 524288" >> /etc/sysctl.conf

# Network optimizations
echo "net.core.rmem_max = 134217728" >> /etc/sysctl.conf
echo "net.core.wmem_max = 134217728" >> /etc/sysctl.conf
echo "net.ipv4.tcp_rmem = 4096 87380 134217728" >> /etc/sysctl.conf
echo "net.ipv4.tcp_wmem = 4096 65536 134217728" >> /etc/sysctl.conf

# Apply settings
sysctl -p

# Docker daemon optimization
echo { > /etc/docker/daemon.json
echo  log-driver: json-file, >> /etc/docker/daemon.json
echo  log-opts: { >> /etc/docker/daemon.json
echo  max-size: 10m, >> /etc/docker/daemon.json
echo  max-file: 3 >> /etc/docker/daemon.json
echo  }, >> /etc/docker/daemon.json
echo  storage-driver: overlay2, >> /etc/docker/daemon.json
echo  exec-opts: [native.cgroupdriver=systemd], >> /etc/docker/daemon.json
echo  max-concurrent-downloads: 10, >> /etc/docker/daemon.json
echo  max-concurrent-uploads: 5 >> /etc/docker/daemon.json
echo } >> /etc/docker/daemon.json

systemctl restart docker

echo "✅ Performance optimizations applied"
