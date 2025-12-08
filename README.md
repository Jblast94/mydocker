# Docker Swarm GPU Cluster

This repository contains the configuration and scripts to manage a Docker Swarm cluster with GPU capabilities, spanning local home servers and cloud instances (Runpod/Vast AI).

## 1. Quick Start

### Manager Setup (Already Done)
The current node (`linux-home`) is the Swarm Manager.
- **Join Token**: `SWMTKN-1-3x39w0d3f9y3cjk6y1m3fzpyvelc4u6btp4qh11bmv34mybnn0-bckdjlrfre7zoqxicg0cbgyl9`
- **Manager IP**: `192.168.86.51`

### Adding a New Node
Run the setup script on the new worker node:
```bash
# On the worker node:
curl -fsSL https://raw.githubusercontent.com/jim/mydocker/main/scripts/setup_node.sh | bash -s -- 192.168.86.51 <JOIN_TOKEN>
# Note: Ensure you copy the scripts folder or use scp if not using git.
```

### Enabling GPU Support
On GPU nodes, run the GPU setup script:
```bash
./scripts/gpu_setup.sh
```
Then label the node in the manager:
```bash
docker node update --label-add gpu=true <hostname>
```

## 2. Infrastructure
See [infrastructure.md](infrastructure.md) for detailed node specs and network layout.
See [gpu-integration.md](gpu-integration.md) for Runpod/Vast AI integration steps.

## 3. Services

### Main Stack (`swarm-gpu`)
Deployed via `docker-compose.yml`. Includes:
- **Visualizer**: http://localhost:8080
- **Whoami**: http://localhost:8000
- **GPU Worker**: Placeholder service (currently scaled to 0).

To deploy/update:
```bash
docker stack deploy -c docker-compose.yml swarm-gpu
```

### Monitoring Stack (`monitoring`)
Deployed via `monitoring/docker-compose.yml`. Includes:
- **Grafana**: http://localhost:3000 (Default admin/admin)
- **Prometheus**: http://localhost:9090
- **Cadvisor** & **Node Exporter**: Running globally on all nodes.

To deploy/update:
```bash
docker stack deploy -c monitoring/docker-compose.yml monitoring
```

## 4. Networks
- `gpu-net`: Overlay network for GPU services.
- `monitoring-net`: Overlay network for monitoring tools.

## 5. Security & Maintenance
- **Backups**: Periodically backup `/var/lib/docker/swarm` on the manager.
- **Updates**: Run `sudo apt update && sudo apt upgrade` on nodes regularly.
- **Secrets**: Use `docker secret create` for sensitive data (API keys, etc.).

## 6. Cost Management
- Monitor cloud instance usage via the provider dashboard.
- Scale down GPU services when not in use: `docker service scale swarm-gpu_gpu-worker=0`.
