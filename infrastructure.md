# Infrastructure Assessment

## 1. Physical Home Servers
### Node 1: `linux-home` (Current Machine)
- **Role**: Swarm Manager (Proposed)
- **OS**: Linux (Ubuntu 24.04 LTS likely, based on plan)
- **CPU**: 4 Processors
- **RAM**: 16 GB (15 Gi Total, 10 Gi Available)
- **IP Address**: 192.168.86.51
- **Docker Version**: 29.1.2
- **Network**: Gigabit Ethernet (enp3s0)
- **Swarm Status**: Leader / Manager
- **Join Token**: `SWMTKN-1-3x39w0d3f9y3cjk6y1m3fzpyvelc4u6btp4qh11bmv34mybnn0-bckdjlrfre7zoqxicg0cbgyl9`

### Node 2: [Second Home Server Name]
- **Role**: Worker Node
- **Specs**: [To be filled]

## 2. Cloud Infrastructure
### Linode VM
- **Role**: Worker Node / External Gateway
- **Specs**: Ubuntu 24.04 LTS
- **Instance Type**: [To be filled]

## 3. Network Configuration
- **Overlay Network**: `gpu-net` (Created)
- **Subnet**: Automatic
- **Encryption**: Disabled (default) - Consider enabling for cross-node traffic if VPN not used.

## 4. GPU Nodes (On-Demand)
### Runpod / Vast AI
- **Role**: GPU Worker Nodes
- **Status**: Potential integration
- **Pricing**: [To be determined]
