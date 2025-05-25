# YCast LXC Installer for Proxmox VE

This script installs [YCast](https://github.com/milaq/YCast) in a lightweight LXC container on your Proxmox VE node.

## Features

- Menu-driven installer (via `whiptail` or plain shell)
- Deploys a Debian-based LXC container
- Installs Python, YCast, and sample internet radio stations
- Sets up YCast as a systemd service

## Usage

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/kriziw/proxmox-scripts/edit//main/ycast-lxc/ycast-lxc-installer.sh)"
```

## Optional

- Set a static IP, add custom stations, or reverse proxy (e.g., with Caddy or Nginx)

