# YCast LXC Installer for Proxmox VE

This script installs [YCast](https://github.com/milaq/YCast) in a lightweight LXC container on your Proxmox VE node.

## Features

- Menu-driven installer (via `whiptail` or plain shell)
- Deploys a Debian-based LXC container
- Installs Python, YCast, and sample internet radio stations
- Sets up YCast as a systemd service

## Usage

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/YOUR_GITHUB_USERNAME/YOUR_REPO/main/ycast-lxc/ycast-lxc-installer.sh)"
```

> Replace `YOUR_GITHUB_USERNAME/YOUR_REPO` with the actual GitHub path once published.

## Optional

- Set a static IP, add custom stations, or reverse proxy (e.g., with Caddy or Nginx)

