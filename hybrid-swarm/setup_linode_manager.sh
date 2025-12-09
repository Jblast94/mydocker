#!/bin/bash
set -e

# ==============================================================================
# Linode Manager Setup Script for Hybrid Swarm
# ==============================================================================
# This script turns a fresh Linode instance into the "Brain" of your Swarm.
# It installs Docker, WireGuard, and initializes the Swarm.
# Compatible with ProtonVPN Split Routing (Split Tunneling).
#
# USAGE:
#   chmod +x setup_linode_manager.sh
#   ./setup_linode_manager.sh
# ==============================================================================

echo ">>> Updating System..."
apt-get update && apt-get upgrade -y

echo ">>> Installing Docker..."
curl -fsSL https://get.docker.com | sh

echo ">>> Installing WireGuard..."
apt-get install -y wireguard wireguard-tools qrencode

# --- WireGuard Configuration ---
echo ">>> Configuring WireGuard Hub..."
umask 077
wg genkey | tee server_private.key | wg pubkey > server_public.key

SERVER_PRIV_KEY=$(cat server_private.key)
SERVER_PUB_KEY=$(cat server_public.key)
SERVER_IP="10.10.0.1/24"

cat > /etc/wireguard/wg0.conf <<EOF
[Interface]
Address = $SERVER_IP
ListenPort = 51820
PrivateKey = $SERVER_PRIV_KEY
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
SaveConfig = true

# Peers will be added here automatically by 'wg set' commands
EOF

echo ">>> Enabling IP Forwarding..."
echo "net.ipv4.ip_forward=1" > /etc/sysctl.d/99-wireguard.conf
sysctl -p /etc/sysctl.d/99-wireguard.conf

echo ">>> Starting WireGuard..."
systemctl enable wg-quick@wg0
systemctl start wg-quick@wg0

# --- Docker Swarm Initialization ---
echo ">>> Initializing Docker Swarm..."
# We advertise the WireGuard IP so workers connect securely over the tunnel
docker swarm init --advertise-addr 10.10.0.1

# --- Output Info ---
PUBLIC_IP=$(curl -s ifconfig.me)
SWARM_TOKEN=$(docker swarm join-token worker -q)

echo ""
echo "========================================================================"
echo "   HYBRID SWARM MANAGER SETUP COMPLETE"
echo "========================================================================"
echo "1. WireGuard Server is running on: $PUBLIC_IP:51820"
echo "2. WireGuard Internal IP: 10.10.0.1"
echo "3. Server Public Key: $SERVER_PUB_KEY"
echo "4. Swarm Join Token: $SWARM_TOKEN"
echo "========================================================================"
echo ""
echo "Copy the 'Server Public Key' and 'Public IP' for your Worker scripts."
