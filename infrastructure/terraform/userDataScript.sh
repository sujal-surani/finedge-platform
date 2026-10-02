#!/bin/bash
# Update packages
apt-get update -y
# Install k3s with explicit flags to disable default networking
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--flannel-backend=none --disable-network-policy" sh -
