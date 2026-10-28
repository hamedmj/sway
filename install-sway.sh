#!/usr/bin/env bash
set -Eeuo pipefail

if [[ $EUID -eq 0 ]]; then
    echo "Run as your normal user, not root."
    exit 1
fi

sudo -v

echo "==> Updating Ubuntu..."
sudo apt update
sudo apt full-upgrade -y

echo "==> Installing Sway desktop..."
sudo apt install -y \
    sway swaybg swayidle swaylock \
    waybar wofi foot mako-notifier \
    grim slurp wl-clipboard xwayland \
    sddm dbus-user-session \
    xdg-desktop-portal \
    xdg-desktop-portal-wlr \
    xdg-desktop-portal-gtk \
    pipewire-audio wireplumber \
    pavucontrol playerctl \
    network-manager network-manager-gnome \
    blueman \
    brightnessctl power-profiles-daemon \
    thunar thunar-archive-plugin file-roller \
    firefox-esr \
    loupe \
    lxpolkit \
    fonts-dejavu-core fonts-noto-core \
    fonts-noto-color-emoji \
    papirus-icon-theme \
    git curl wget unzip zip \
    build-essential \
    zsh tmux \
    xdg-utils \
    polkitd

echo "==> Creating user configuration directories..."
mkdir -p \
    "$HOME/.config/sway" \
    "$HOME/.config/waybar" \
    "$HOME/.config/foot" \
    "$HOME/.config/wofi" \
    "$HOME/.config/mako" \
    "$HOME/Pictures"

echo "==> Creating Sway configuration..."
if [[ ! -f "$HOME/.config/sway/config" ]]; then
cat > "$HOME/.config/sway/config" <<'SWAY'
set $mod Mod4
font pango:DejaVu Sans Mono 10

# Applications
bindsym $mod+Return exec foot
bindsym $mod+d exec wofi --show drun
bindsym $mod+e exec thunar
bindsym $mod+Shift+q kill
bindsym $mod+Shift+c reload
bindsym $mod+Shift+e exec swaynag -t warning -m 'Exit Sway?' -B 'Exit' 'swaymsg exit'

# Window focus
bindsym $mod+h focus left
bindsym $mod+j focus down
bindsym $mod+k focus up
bindsym $mod+l focus right

# Move windows
bindsym $mod+Shift+h move left
bindsym $mod+Shift+j move down
bindsym $mod+Shift+k move up
bindsym $mod+Shift+l move right

# Layout
bindsym $mod+f fullscreen
bindsym $mod+space floating toggle
bindsym $mod+b splith
bindsym $mod+v splitv

# Workspaces
bindsym $mod+1 workspace number 1
bindsym $mod+2 workspace number 2
bindsym $mod+3 workspace number 3
bindsym $mod+4 workspace number 4

bindsym $mod+Shift+1 move container to workspace number 1
bindsym $mod+Shift+2 move container to workspace number 2
bindsym $mod+Shift+3 move container to workspace number 3
bindsym $mod+Shift+4 move container to workspace number 4

# Screenshots
bindsym Print exec sh -c 'grim -g "$(slurp)" "$HOME/Pictures/screenshot-$(date +%Y%m%d-%H%M%S).png"'

# Audio
bindsym XF86AudioRaiseVolume exec wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+
bindsym XF86AudioLowerVolume exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
bindsym XF86AudioMute exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle

# Brightness and lock screen
bindsym XF86MonBrightnessUp exec brightnessctl set 5%+
bindsym XF86MonBrightnessDown exec brightnessctl set 5%-
bindsym $mod+Shift+x exec swaylock -f -c 000000

# Desktop services
exec waybar
exec mako
exec lxpolkit
exec nm-applet --indicator
exec blueman-applet
SWAY
fi

echo "==> Creating Waybar configuration..."
if [[ ! -f "$HOME/.config/waybar/config" ]]; then
cat > "$HOME/.config/waybar/config" <<'WAYBAR'
{
    "layer": "top",
    "position": "top",
    "height": 30,
    "modules-left": ["sway/workspaces", "sway/window"],
    "modules-center": ["clock"],
    "modules-right": [
        "pulseaudio", "network", "cpu",
        "memory", "battery", "tray"
    ],
    "clock": {
        "format": "{:%a %d %b  %H:%M}"
    },
    "pulseaudio": {
        "format": "VOL {volume}%",
        "format-muted": "MUTED"
    },
    "network": {
        "format-wifi": "Wi-Fi {essid}",
        "format-ethernet": "LAN {ipaddr}",
        "format-disconnected": "Offline"
    },
    "cpu": {
        "format": "CPU {usage}%"
    },
    "memory": {
        "format": "RAM {percentage}%"
    },
    "battery": {
        "format": "BAT {capacity}%"
    }
}
WAYBAR
fi

echo "==> Enabling desktop services..."
sudo systemctl enable sddm
sudo systemctl enable --now power-profiles-daemon

# Do not change Netplan or force a network renderer here.
# Check networking before enabling NetworkManager on an existing system.

echo
echo "Installation complete."
echo "Review networking, then reboot into SDDM."
echo "Use Super+Enter for the terminal, Super+D for applications,"
echo "and Super+E for the file manager."
