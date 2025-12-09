#!/bin/bash
set -e

# ==============================================================================
# Worker Node Setup Script for Hybrid Swarm
# ==============================================================================
# This script joins a local machine (or Cloud GPU instance) to your Hybrid Swarm.
# It installs Docker, WireGuard, connects to the Hub, and joins the Swarm.
#
# USAGE:
#   chmod +x setup_worker.sh
#   ./setup_worker.sh
# ==============================================================================

# --- Configuration (PROMPT USER) ---
read -p "Enter Linode Public IP: " HUB_PUBLIC_IP
read -p "Enter Linode WireGuard Public Key: " HUB_PUB_KEY
read -p "Enter Swarm Join Token: " SWARM_TOKEN
read -p "Enter Desired Internal IP (e.g., 10.10.0.2): " WORKER_IP

echo ">>> Updating System..."
apt-get update && apt-get upgrade -y

echo ">>> Installing Docker..."
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com | sh
else
    echo "Docker already installed."
fi

echo ">>> Installing WireGuard..."
apt-get install -y wireguard wireguard-tools

# --- WireGuard Configuration ---
echo ">>> Configuring WireGuard Client..."
umask 077
wg genkey | tee client_private.key | wg pubkey > client_public.key

CLIENT_PRIV_KEY=$(cat client_private.key)
CLIENT_PUB_KEY=$(cat client_public.key)

cat > /etc/wireguard/wg0.conf <<EOF
[Interface]
Address = $WORKER_IP/32
PrivateKey = $CLIENT_PRIV_KEY
# Only route Swarm traffic (10.10.0.x) through VPN to avoid ProtonVPN conflicts
DNS = 1.1.1.1

[Peer]
PublicKey = $HUB_PUB_KEY
Endpoint = $HUB_PUBLIC_IP:51820
AllowedIPs = 10.10.0.0/24
PersistentKeepalive = 25
EOF

echo ">>> Starting WireGuard..."
systemctl enable wg-quick@wg0
systemctl start wg-quick@wg0

echo ""
echo "========================================================================"
echo "   STEP 1 COMPLETE: WIREGUARD CLIENT STARTED"
echo "========================================================================"
echo "Please go to your Linode Manager and run this command to authorize this peer:"
echo ""
echo "   wg set wg0 peer $CLIENT_PUB_KEY allowed-ips $WORKER_IP/32"
echo ""
echo "After you run that command on Linode, press ENTER to join the Swarm..."
read -r

# --- Docker Swarm Join ---
echo ">>> Joining Docker Swarm..."
docker swarm join --token "$SWARM_TOKEN" 10.10.0.1:2377

echo ""
echo "========================================================================"
echo "   SUCCESS! WORKER JOINED HYBRID SWARM"
echo "========================================================================"
