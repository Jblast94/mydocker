# DNS Configuration for jcn.digital

To enable public access to your services, create the following A records with your DNS provider.

**Public IP**: `69.116.133.106`

## Required A Records

| Subdomain | Target IP | Service |
|-----------|-----------|---------|
| `traefik.jcn.digital` | `69.116.133.106` | Traefik Dashboard |
| `portainer.jcn.digital` | `69.116.133.106` | Portainer Management |
| `visualizer.jcn.digital` | `69.116.133.106` | Swarm Visualizer |
| `whoami.jcn.digital` | `69.116.133.106` | Connectivity Test |
| `grafana.jcn.digital` | `69.116.133.106` | Grafana Monitoring |
| `prometheus.jcn.digital` | `69.116.133.106` | Prometheus Metrics |

*Alternatively, you can create a wildcard A record:*
| Subdomain | Target IP |
|-----------|-----------|
| `*.jcn.digital` | `69.116.133.106` |

## Router Configuration (Port Forwarding)

You must configure your router to forward traffic to your Swarm Manager (this machine).

- **Local IP**: `192.168.86.51`
- **Port 80 (TCP)** -> `192.168.86.51:80`
- **Port 443 (TCP)** -> `192.168.86.51:443`

## DHCP / Static IP
Since you mentioned the host uses DHCP:
1.  **DHCP Reservation**: Log in to your router and set a **DHCP Reservation** for MAC address `d8:9e:f3:3d:d4:62` (enp3s0) to IP `192.168.86.51`. This ensures the server IP doesn't change on reboot, which would break the port forwarding.
