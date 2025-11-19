# My Homelab Infrastructure

Personal homelab setup including Docker services, Proxmox VMs, Raspberry Pi projects, and IoT integrations.

## Projects

### Docker Services

- [**Pi-hole**](docker/pi-hole/) - Network-wide ad blocking with Nginx reverse proxy
- [**Nextcloud**](docker/nextcloud/) - Self-hosted cloud storage
- [**Portainer**](docker/portainer/) - Docker management UI

### Proxmox

- [**VM Templates**](proxmox/vm-templates/) - Automated VM provisioning
- [**LXC Containers**](proxmox/lxc/) - Lightweight container setups

### Raspberry Pi

- [**Home Automation**](raspberry-pi/home-assistant/) - Home Assistant setup
- [**Network Monitor**](raspberry-pi/monitoring/) - Network traffic analysis

### IoT

- [**Zigbee Network**](iot/zigbee/) - Smart home device integration

## Quick Start

Each project has its own README with setup instructions. Most Docker projects include an `install.sh` for quick deployment.

## Infrastructure Overview

- **Network:** Tailscale mesh VPN
- **Reverse Proxy:** Nginx with Let's Encrypt SSL
- **Container Runtime:** Docker & Docker Compose
- **Virtualization:** Proxmox VE

## Documentation

- [Tailscale Setup Guide](docs/tailscale-setup.md)
- [Nginx Reverse Proxy Configuration](docs/nginx-reverse-proxy.md)
- [SSL Certificates with Cloudflare](docs/certbot-cloudflare.md)

## Planned Repository structure

```bash
homelab-github/
├── README.md                    # Main overview of all projects
├── docs/                        # Shared documentation
│   ├── tailscale-setup.md
│   ├── nginx-reverse-proxy.md
│   └── certbot-cloudflare.md
├── docker/
│   ├── nginx/                   # Shared nginx configs
│   │   ├── pi-hole.conf
│   │   ├── nextcloud.conf
│   │   └── portainer.conf
│   ├── pi-hole/
│   │   ├── README.md           # Project-specific docs
│   │   ├── docker-compose.yml
│   │   ├── .env.example
│   │   └── install.sh
│   ├── nextcloud/
│   │   ├── README.md
│   │   ├── docker-compose.yml
│   │   └── install.sh
│   └── portainer/
│       └── ...
├── proxmox/
│   ├── vm-templates/
│   └── scripts/
├── raspberry-pi/
│   ├── projects/
│   └── configs/
└── iot/
    ├── home-assistant/
    └── zigbee/
```
