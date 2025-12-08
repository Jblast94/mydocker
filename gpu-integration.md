# GPU Node Integration Guide

This guide details how to integrate cloud GPU providers into your Docker Swarm.

## Option A: Runpod Integration

Runpod allows you to rent GPU pods. Since standard Runpod instances are containerized themselves, running Docker-in-Docker (DinD) or connecting them to the Swarm requires specific configuration.

### Strategy: Secure Tunneling
Since Runpod instances are behind NAT, they cannot easily expose the Swarm ports (2377, etc.) directly to the internet securely. We will use **Tailscale** or **WireGuard** to create a mesh network.

1. **Prepare Runpod Template**:
   - Base Image: `ubuntu:22.04` (or similar)
   - Start Script:
     - Install Docker (using `scripts/setup_node.sh`)
     - Install Tailscale/WireGuard
     - Join the VPN
     - Join the Swarm using the VPN IP of the Manager.

2. **Manager Configuration**:
   - Install Tailscale/WireGuard on the Manager (`linux-home`).
   - Advertise the VPN IP for Swarm communication if needed, or ensure the overlay network works over the VPN.

3. **Automation**:
   - Use Runpod API to launch pods.
   - Pass the Swarm Join Token and Manager VPN IP as environment variables.

## Option B: Vast AI Integration

Vast AI offers bare-metal-like instances or containerized environments.

1. **Instance Selection**:
   - Filter for instances with open ports or high reliability.
   - Prefer instances that allow SSH access.

2. **Setup**:
   - SSH into the Vast AI instance.
   - Run `scripts/gpu_setup.sh` to ensure NVIDIA drivers are ready (usually pre-installed on Vast).
   - Run `scripts/setup_node.sh` to install Docker and join Swarm.
   - **Important**: You may need to use a VPN (like Tailscale) as Vast AI instances are often behind NAT or have dynamic IPs.

## VPN Recommendation: Tailscale
Tailscale is the easiest way to mesh these disparate nodes.

### Setup on Manager:
```bash
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up
ip addr show tailscale0 # Note this IP
```

### Setup on Cloud Node:
```bash
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up --authkey <YOUR_AUTH_KEY>
# Then join swarm using Manager's Tailscale IP
docker swarm join --token <TOKEN> <MANAGER_TAILSCALE_IP>:2377
```
