#!/bin/bash
set -e

# ==============================================================================
# Simple Worker Setup Script
# ==============================================================================
# This script joins a machine to the Swarm using the Public IP.
# ==============================================================================

MANAGER_IP="172.237.151.90"
SWARM_TOKEN="SWMTKN-1-3gnerikj74qi7tzcxqvd5wtuimi95g7xahxigty9l95g69y9yb-a1kq8wwjs64o2i1wiyydhq6g8"

echo ">>> Updating System..."
if command -v apt-get &> /dev/null; then
    sudo apt-get update
fi

echo ">>> Installing Docker (if missing)..."
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com | sh
else
    echo "Docker already installed."
fi

echo ">>> Cleaning up previous Swarm state..."
if docker info | grep -q "Swarm: active"; then
    echo "Leaving previous swarm..."
    docker swarm leave --force
fi

echo ">>> Joining Swarm at $MANAGER_IP..."
docker swarm join --token "$SWARM_TOKEN" "$MANAGER_IP:2377"

echo ""
echo "========================================================================"
echo "   SUCCESS! WORKER JOINED"
echo "========================================================================"
