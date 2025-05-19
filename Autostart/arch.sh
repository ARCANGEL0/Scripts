#!/bin/bash
set -euo pipefail

echo "[*] Starting Exodia OS automation setup..."

# ─────────────────────────────────────────────
# 1. Backup and Patch pacman.conf
# ─────────────────────────────────────────────
echo "[*] Backing up and editing /etc/pacman.conf..."
sudo cp /etc/pacman.conf /etc/pacman.conf.bak

# Disable community repo by commenting it out
sudo sed -i 's/^\[community\]/#[community]/' /etc/pacman.conf
sudo sed -i '/^\[community\]/,/^Include/ s/^/#/' /etc/pacman.conf

echo "[✓] [community] repo disabled."

# ─────────────────────────────────────────────
# 2. Update System and Install Packages
# ─────────────────────────────────────────────
echo "[*] Checking for Erlang package conflicts..."
if pacman -Q erlang-nox &>/dev/null; then
    echo "[!] Conflict detected: removing 'erlang-nox'..."
    sudo pacman -Rdd --noconfirm erlang-nox
    echo "[✓] Removed 'erlang-nox'"
fi

echo "[*] Checking for Java-related package conflicts..."
if pacman -Q jre11-openjdk &>/dev/null; then
    echo "[!] Conflict detected: removing 'jre11-openjdk'..."
    sudo pacman -Rdd --noconfirm jre11-openjdk
fi

if pacman -Q jre11-openjdk-headless &>/dev/null; then
    echo "[!] Removing 'jre11-openjdk-headless'..."
    sudo pacman -Rdd --noconfirm jre11-openjdk-headless
fi

echo "[*] Removing chaotic-kf5-dummy if present..."

if pacman -Qi chaotic-kf5-dummy &> /dev/null; then
    sudo pacman -Rdd --noconfirm chaotic-kf5-dummy
    echo "[✓] Removed chaotic-kf5-dummy."
else
    echo "[i] chaotic-kf5-dummy not installed."
fi
echo "[*] Updating system..."

sudo pacman -Syyu --noconfirm

echo "[*] Installing required packages..."
sudo pacman -S --noconfirm --needed \
  xfce4-terminal thunar nnn micro tmux \
  toilet figlet firefox cool-retro-term \
  xdotool xorg-xprop dconf jq

# ─────────────────────────────────────────────
# 3. Clean Alacritty from system
# ─────────────────────────────────────────────
echo "[*] Removing Alacritty if present..."
sudo pacman -Rns --noconfirm alacritty || echo "[i] Alacritty already removed."
rm -rf ~/.config/alacritty

# ─────────────────────────────────────────────
# 4. Replace Alacritty Keybindings in sxhkdrc
# ─────────────────────────────────────────────
SXHKDRC="$HOME/.config/bspwm/keybinding/sxhkdrc"

if [[ -f "$SXHKDRC" ]]; then
  echo "[*] Backing up sxhkdrc..."
  cp "$SXHKDRC" "$SXHKDRC.bak"

  echo "[*] Replacing Alacritty commands with xfce4-terminal..."
  sed -i \
    -e 's|alacritty[^ ]* .*|xfce4-terminal|g' \
    -e 's|alacritty|xfce4-terminal|g' \
    -e 's|bspterm[^ ]*|xfce4-terminal|g' \
    -e 's|bspterm|xfce4-terminal|g' \
    "$SXHKDRC"

  # Add Thunar shortcut if missing
  if ! grep -q "super + e" "$SXHKDRC"; then
    echo -e "\n# Open Thunar\nsuper + e\n\tthunar" >> "$SXHKDRC"
    echo "[+] Added Super+E for Thunar."
  fi
else
  echo "[!] sxhkdrc not found at $SXHKDRC. Skipping keybindings."
fi

# ─────────────────────────────────────────────
# 5. Set xfce4-terminal Opacity to 0.60
# ─────────────────────────────────────────────
echo "[*] Setting xfce4-terminal transparency to 60%..."
TERMINAL_CONF="$HOME/.config/xfce4/terminal/terminalrc"
mkdir -p "$(dirname "$TERMINAL_CONF")"

cat > "$TERMINAL_CONF" <<EOF
[Configuration]
BackgroundMode=TRANSPARENT
BackgroundDarkness=0.60
ColorForeground=#FFFFFF
ColorBackground=#000000
FontName=Monospace 11
MiscAlwaysShowTabs=FALSE
MiscConfirmClose=TRUE
EOF

# ─────────────────────────────────────────────
# 6. Done
# ─────────────────────────────────────────────
echo ""
echo "[✓] Exodia customization complete."
echo "[🡺] You may need to reload sxhkd or reboot for all changes to apply."
