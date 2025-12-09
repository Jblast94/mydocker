# Hybrid Swarm Architecture (Linode Hub + Local Workers)

This configuration enables you to run a Docker Swarm that spans:
1.  **Linode Cloud Instance:** Acts as the **Manager** (Stable IP, Traefik Entrypoint).
2.  **Home Machines:** Act as **Workers** (GPUs, Storage).
3.  **RunPod/Vast.ai:** Act as **Ephemeral Workers** (On-demand GPUs).

All nodes are connected via a private **WireGuard Tunnel (10.10.0.0/24)**.

## Why WireGuard?
- **No Conflicts:** Configured to only route Swarm traffic (`10.10.0.0/24`), so it won't break ProtonVPN or other internet connections.
- **Fast:** Runs in the kernel.
- **Secure:** All Swarm traffic is encrypted.
- **Universal:** Works on Linux, Windows, macOS, and any cloud provider.

---

## Setup Instructions

### 1. Set up the Linode Manager (The Hub)
1.  Create a new Linode instance (Ubuntu 22.04 or 24.04).
2.  SSH into the Linode instance.
3.  Copy and run the `setup_linode_manager.sh` script:
    ```bash
    # (Copy script content to file, then...)
    chmod +x setup_linode_manager.sh
    ./setup_linode_manager.sh
    ```
4.  **Save the Output:** The script will print the `Server Public Key`, `Public IP`, and `Swarm Token`. You need these.

### 2. Connect a Local Machine (Home Worker)
1.  On your home machine (`linux-home`), run:
    ```bash
    sudo ./setup_worker.sh
    ```
2.  Enter the requested info (Linode IP, Key, Token).
3.  **Important:** The script will pause and give you a command to run on the Linode Manager (to authorize the peer).
4.  Run that command on Linode.
5.  Press ENTER on the home machine to finish joining.

### 3. Connect a RunPod/Vast.ai Instance (GPU Worker)
1.  Rent an instance (Ubuntu template).
2.  SSH into it (or use the web terminal).
3.  Copy the `setup_worker.sh` script to the instance.
4.  Run it exactly like the local machine.
    *   *Tip: Use a unique Internal IP for each worker (e.g., 10.10.0.2, 10.10.0.3).*

---

## Adding Services
When deploying stacks in Portainer or Docker Compose, use the `proxy-net` (overlay network). Traefik on Linode will route public traffic (from `jcn.digital`) securely over the WireGuard tunnel to your GPU containers running at home.
