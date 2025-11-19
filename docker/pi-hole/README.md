# Pi-hole Docker Setup with Nginx & Tailscale

Network-wide ad blocking using Pi-hole, reverse proxied through Nginx, accessible via Tailscale.

## Architecture Overview

```
Tailscale Network (100.x.x.x)
         ↓
    Nginx (443) → Pi-hole Web (8080)
         ↓
    Pi-hole DNS (53)
         ↓
  Blocked Ads & Tracking
```

## Prerequisites

- Docker and Docker Compose installed
- Nginx running on host (not in Docker)
- Tailscale installed and configured
- SSL certificates (via Certbot with Cloudflare DNS-01 challenge recommended)

## Key Design Decisions

### Why `network_mode: host`?

Pi-hole needs to listen on port 53 (DNS) across all network interfaces, including the Tailscale interface. Using `host` network mode:

- Allows Pi-hole to bind directly to the host's network stack
- Enables DNS queries from Tailscale devices
- Simplifies networking without macvlan complexity

**Trade-off:** Port 80 conflict with Nginx, so Pi-hole web interface runs on port 8080.

### Why Port 8080 for Web Interface?

Nginx already uses port 80 for reverse proxying. Pi-hole's web interface is moved to port 8080 to avoid conflicts. Users access it via:

- `https://pihole.yourdomain.com` (through Nginx reverse proxy)
- Direct access: `http://SERVER_IP:8080/admin` (if needed)

### Why Not Standard Bridge Network?

Docker's default bridge network isolates containers from the host's network interfaces. Tailscale operates at the host level, so Pi-hole in a bridge network cannot see Tailscale DNS queries.

**Alternatives considered:**

- **Macvlan:** Complex, requires dedicated IP, overkill for this use case
- **Bridge + port mapping:** Doesn't expose Tailscale interface

## Setup Instructions

## Quick Install

```bash
# One-line install
curl -fsSL https://raw.githubusercontent.com/hbabb/homelab/main/docker/pi-hole/install.sh | bash

# Or specify custom directory
curl -fsSL https://raw.githubusercontent.com/hbabb/homelab/main/docker/pi-hole/install.sh | bash -s /opt/pihole
```

**Required variables:**

- `TZ`: Your timezone (e.g., `America/New_York`)
- `PIHOLE_PASSWORD`: Secure password for web interface
- `PIHOLE_WEB_PORT`: Port for web interface (default: 8080)

### 1. Start Pi-hole

```bash
docker-compose up -d
```

### 2. Verify Pi-hole is Running

```bash
# Check container status
docker ps | grep pihole

# Check logs
docker logs pihole

# Test DNS blocking
dig @localhost doubleclick.net
# Should return 0.0.0.0 (blocked)
```

### 3. Configure Nginx Reverse Proxy

Copy the provided `nginx-pihole.conf` to your Nginx sites-available:

```bash
# Copy config (anonymized version in repo)
sudo cp nginx/pihole.conf /etc/nginx/sites-available/pihole.yourdomain.com.conf

# Edit with your domain
sudo nano /etc/nginx/sites-available/pihole.yourdomain.com.conf

# Enable site
sudo ln -s /etc/nginx/sites-available/pihole.yourdomain.com.conf \
           /etc/nginx/sites-enabled/

# Test and reload
sudo nginx -t
sudo systemctl reload nginx
```

**Key Nginx configuration:**

```nginx
location / {
    proxy_pass http://localhost:8080/admin/;
    # ... proxy headers ...
}
```

### 4. Configure Tailscale DNS

**Option A: Tailscale Admin Console** (Recommended)

1. Go to https://login.tailscale.com/admin/dns
2. Add nameserver: `100.x.x.x` (your server's Tailscale IP)
3. Enable "Override local DNS"

**Option B: Per-Device** (if you can't access admin console)

```bash
tailscale set --accept-dns=true
```

### 5. Verify DNS is Working

```bash
# Check Tailscale DNS status
tailscale status --json | grep DNS

# Test from any Tailscale device
nslookup doubleclick.net
# Should resolve to 0.0.0.0
```

## Accessing Pi-hole

- **Web Interface (via Nginx):** `https://pihole.yourdomain.com`
- **Direct Access:** `http://SERVER_TAILSCALE_IP:8080/admin`
- **DNS:** Point devices to your server's Tailscale IP on port 53

## Troubleshooting

### Pi-hole Not Blocking Ads

**Check if DNS queries are reaching Pi-hole:**

```bash
docker logs pihole | grep "query"
```

**Verify device is using Pi-hole:**

```bash
# From device
nslookup doubleclick.net SERVER_TAILSCALE_IP
# Should return 0.0.0.0
```

**Update blocklists:**

```bash
docker exec pihole pihole -g
```

### Can't Access Web Interface

**Check Nginx is proxying correctly:**

```bash
sudo tail -f /var/log/nginx/pihole_error.log
```

**Verify Pi-hole web port:**

```bash
curl http://localhost:8080/admin/
```

### Port 53 Conflict

**Check what's using port 53:**

```bash
sudo lsof -i :53
```

**If systemd-resolved is running:**

```bash
sudo systemctl disable systemd-resolved
sudo systemctl stop systemd-resolved
```

### Browser Bypassing Pi-hole

**Disable DNS-over-HTTPS in browsers:**

- **Firefox:** Settings → Privacy & Security → DNS over HTTPS (disable)
- **Chrome/Brave:** Settings → Privacy → Security → Use secure DNS (disable)
- **Edge:** Settings → Privacy → Use secure DNS (disable)

## Limitations

### What Pi-hole CAN Block

- ✅ Third-party ad networks
- ✅ Tracking domains
- ✅ Malware/phishing sites
- ✅ Telemetry from apps/services

### What Pi-hole CANNOT Block

- ❌ YouTube ads (first-party, same domain as content)
- ❌ Facebook/Instagram ads (first-party)
- ❌ Twitter/X ads (first-party)
- ❌ Ads served from same domain as content

**For these, use browser extensions like uBlock Origin.**

## Maintenance

### Update Pi-hole

```bash
docker-compose pull
docker-compose up -d
```

### Update Blocklists

```bash
docker exec pihole pihole -g
```

### Backup Configuration

```bash
# Backup volumes
tar -czf pihole-backup-$(date +%Y%m%d).tar.gz etc-pihole/ etc-dnsmasq.d/
```

### View Logs

```bash
# Container logs
docker logs -f pihole

# Pi-hole specific logs
docker exec pihole tail -f /var/log/pihole/pihole.log
```

## File Structure

```
pihole-docker/
├── docker-compose.yml       # Main Docker Compose config
├── .env.example            # Example environment variables
├── .env                    # Your actual environment (gitignored)
├── nginx/
│   └── pihole.conf         # Anonymized Nginx config example
├── etc-pihole/             # Pi-hole configuration (created on first run)
└── README.md              # This file
```

## Security Notes

- ⚠️ Never commit `.env` file to git (contains passwords)
- ⚠️ Use strong passwords for `PIHOLE_PASSWORD`
- ⚠️ Keep Pi-hole and Docker updated
- ⚠️ Consider firewall rules if exposing beyond Tailscale

## References

- [Pi-hole Documentation](https://docs.pi-hole.net/)
- [Pi-hole Docker Hub](https://hub.docker.com/r/pihole/pihole)
- [Tailscale Documentation](https://tailscale.com/kb/)
- [Nginx Reverse Proxy Guide](https://docs.nginx.com/nginx/admin-guide/web-server/reverse-proxy/)

## License

[MIT](/docker/pi-hole/LICENSE)

## Contributing

Pull requests welcome! Please ensure:

- Anonymized configurations (no personal IPs/domains)
- Clear commit messages
- Updated documentation
