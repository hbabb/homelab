#!/bin/bash
# Quick installer for Pi-hole Docker setup

set -e

REPO_BASE="https://raw.githubusercontent.com/hbabb/homelab/main"
INSTALL_DIR="${1:-$HOME/pihole-docker}"

echo "Installing Pi-hole Docker setup to: $INSTALL_DIR"

# Create directories
mkdir -p "$INSTALL_DIR/nginx"

# Download files
echo "Downloading configuration files..."
curl -fsSL "$REPO_BASE/docker/pi-hole/docker-compose.yml" -o "$INSTALL_DIR/docker-compose.yml"
curl -fsSL "$REPO_BASE/docker/nginx/pi-hole.conf" -o "$INSTALL_DIR/nginx/pi-hole.conf"
curl -fsSL "$REPO_BASE/docker/pi-hole/.env.example" -o "$INSTALL_DIR/.env.example"

# Create .env from example
cp "$INSTALL_DIR/.env.example" "$INSTALL_DIR/.env"

echo ""
echo "✅ Installation complete!"
echo ""
echo "Next steps:"
echo "1. cd $INSTALL_DIR"
echo "2. Edit .env with your configuration"
echo "3. docker-compose up -d"
echo ""
