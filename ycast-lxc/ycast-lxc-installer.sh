#!/bin/bash

# Menu-Driven YCast Installer for Proxmox VE

if [ "$(id -u)" != "0" ]; then
  echo "⚠️  Run as root on the Proxmox node."
  exit 1
fi

has_whiptail=1
command -v whiptail >/dev/null 2>&1 || has_whiptail=0

prompt() {
  if [ $has_whiptail -eq 1 ]; then
    whiptail --title "$1" --inputbox "$2" 10 60 "$3" 3>&1 1>&2 2>&3
  else
    read -p "$2 [$3]: " val
    echo "${val:-$3}"
  fi
}

msgbox() {
  if [ $has_whiptail -eq 1 ]; then
    whiptail --title "$1" --msgbox "$2" 10 60
  else
    echo -e "\n$1: $2"
  fi
}

CTID=$(prompt "Container ID" "Enter LXC Container ID" "150")
HOSTNAME=$(prompt "Hostname" "Enter hostname" "ycast")
DISK_SIZE=$(prompt "Disk Size" "Enter disk size (e.g., 4G)" "4G")
MEMORY=$(prompt "Memory (MB)" "Enter RAM in MB" "512")
CORES=$(prompt "CPU Cores" "Enter number of vCPUs" "1")
BRIDGE=$(prompt "Bridge" "Enter network bridge name" "vmbr0")
STORAGE=$(prompt "Storage" "Enter storage pool for rootfs" "local-lvm")
TEMPLATE_STORAGE=$(prompt "Template Storage" "Enter template storage pool" "local")
PORT=$(prompt "Port" "Enter YCast HTTP port" "8000")

msgbox "Info" "Creating LXC with ID $CTID and hostname $HOSTNAME..."

TEMPLATE="debian-12-standard_*.tar.zst"
if ! ls /var/lib/vz/template/cache/$TEMPLATE &> /dev/null; then
  pveam update
  pveam download "$TEMPLATE_STORAGE" debian-12-standard
fi

pct create $CTID $TEMPLATE_STORAGE:vztmpl/$TEMPLATE   --hostname $HOSTNAME   --cores $CORES   --memory $MEMORY   --rootfs $STORAGE:$DISK_SIZE   --net0 name=eth0,bridge=$BRIDGE,ip=dhcp   --unprivileged 1   --features nesting=1   --start 1

echo "🚀 Container $CTID started."

echo "📥 Installing dependencies and YCast..."
pct exec $CTID -- bash -c "
  apt update && apt install -y git python3 python3-pip curl
  git clone https://github.com/milaq/YCast.git /opt/ycast
  cd /opt/ycast && pip3 install -r requirements.txt
"

echo "📝 Creating YCast config file..."
pct exec $CTID -- bash -c "
cat <<EOF > /opt/ycast/config
name: MyYCast
stations:
  - title: Chillhop Radio
    url: http://streams.ilovemusic.de/iloveradio1.mp3
    image: https://i1.sndcdn.com/artworks-000190430190-7s6qjv-t500x500.jpg
  - title: SomaFM - Groove Salad
    url: http://ice1.somafm.com/groovesalad-128-mp3
    image: https://somafm.com/img3/groovesalad-400.jpg
EOF
"

echo "🔧 Creating systemd service..."
pct exec $CTID -- bash -c "
cat <<EOF > /etc/systemd/system/ycast.service
[Unit]
Description=YCast DLNA Internet Radio Emulator
After=network.target

[Service]
ExecStart=/usr/bin/python3 /opt/ycast/ycast.py --config /opt/ycast/config --port $PORT
WorkingDirectory=/opt/ycast
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reexec
systemctl daemon-reload
systemctl enable --now ycast
"

IP=$(pct exec $CTID -- hostname -I | awk '{print $1}')
msgbox "✅ Done" "YCast is installed and running on http://$IP:$PORT/"
