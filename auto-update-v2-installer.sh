#!/usr/bin/env bash
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "Run: sudo bash auto-update-v2-installer.sh"
  exit 1
fi

cat >/usr/local/bin/auto-update <<'EOF'
#!/usr/bin/env bash
export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a
export GIT_TERMINAL_PROMPT=0

exec 9>/run/auto-update.lock
flock -n 9 || exit 0

USER_NAME=$(logname 2>/dev/null || true)
USER_HOME=$(getent passwd "$USER_NAME" | cut -d: -f6)
[[ -z "$USER_HOME" ]] && USER_HOME=/root

apt-get update || true
apt-get -y full-upgrade || true
apt-get -y autoremove --purge || true
apt-get clean || true

command -v flatpak >/dev/null && { flatpak update -y --noninteractive || true; flatpak uninstall --unused -y || true; }
command -v snap >/dev/null && snap refresh || true
command -v pipx >/dev/null && [[ -n "$USER_NAME" ]] && sudo -u "$USER_NAME" pipx upgrade-all || true
command -v npm >/dev/null && npm update -g || true

find "$USER_HOME" /opt /usr/local/src /srv /root -type d -name .git 2>/dev/null | while read -r g; do
 git -C "${g%/.git}" pull --ff-only >/dev/null 2>&1 || true
done

rm -rf /tmp/* /var/tmp/* || true
find "$USER_HOME/.cache" -mindepth 1 -delete 2>/dev/null || true
find "$USER_HOME/.local/share/Trash" -mindepth 1 -delete 2>/dev/null || true
journalctl --vacuum-time=7d >/dev/null 2>&1 || true
EOF

chmod +x /usr/local/bin/auto-update

cat >/etc/systemd/system/auto-update.service <<'EOF'
[Unit]
Description=Background Auto Update
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/auto-update
Nice=19
IOSchedulingClass=idle
EOF

cat >/etc/systemd/system/auto-update.timer <<'EOF'
[Unit]
Description=Run auto update after boot

[Timer]
OnBootSec=30s
Persistent=true
RandomizedDelaySec=2min
Unit=auto-update.service

[Install]
WantedBy=timers.target
EOF

systemctl daemon-reload
systemctl disable auto-update.service >/dev/null 2>&1 || true
systemctl enable --now auto-update.timer

echo "Installed."
echo "Timer status:"
systemctl --no-pager status auto-update.timer | head -15
