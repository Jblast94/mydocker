#!/bin/bash

# Setup script for Docker Swarm Worker Node (Ubuntu 24.04)
# Usage: ./setup_node.sh [manager_ip] [join_token]

MANAGER_IP=$1
JOIN_TOKEN=$2

if [ -z "$MANAGER_IP" ] || [ -z "$JOIN_TOKEN" ]; then
    echo "Usage: $0 <manager_ip> <join_token>"
    echo "Please provide the manager IP and join token."
    exit 1
fi

echo "Updating system..."
sudo apt-get update && sudo apt-get upgrade -y

echo "Installing Docker..."
# Add Docker's official GPG key:
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "Configuring Firewall..."
# Allow Swarm ports
sudo ufw allow 2377/tcp
sudo ufw allow 7946/tcp
sudo ufw allow 7946/udp
sudo ufw allow 4789/udp
# Allow WireGuard if needed (optional, default 51820)
# sudo ufw allow 51820/udp
sudo ufw reload

echo "Joining Swarm..."
sudo docker swarm join --token $JOIN_TOKEN $MANAGER_IP:2377

echo "Node setup complete!"
