#!/bin/bash
if ! command -v dialog &>/dev/null; then
    echo "'dialog' not found. Installing..."
    if ! grep -q "universe" /etc/apt/sources.list; then
        echo "Adding 'universe' repository..."
        sudo add-apt-repository universe
        sudo apt update
    fi

    sudo apt install -y dialog toilet figlet toilet-fonts nmap ffmpeg curl wget git curl python3 pv
fi
LAYOUT_SELECTION_SCRIPT="
dialog --menu \"Select Keyboard Layout\" 0 0 0 \\
\"us\" \"US English\" \\
\"gb\" \"UK English\" \\
\"de\" \"German\" \\
\"fr\" \"French\" \\
\"it\" \"Italian\" \\
\"es\" \"Spanish\" \\
\"pt\" \"Portuguese\" \\
\"ru\" \"Russian\" \\
\"jp\" \"Japanese\" \\
\"kr\" \"Korean\" \\
\"pl\" \"Polish\" \\
\"nl\" \"Dutch\" \\
\"se\" \"Swedish\" \\
\"dk\" \"Danish\" \\
\"fi\" \"Finnish\" \\
\"cz\" \"Czech\" \\
\"sk\" \"Slovak\" \\
\"ro\" \"Romanian\" \\
\"tr\" \"Turkish\" \\
\"hu\" \"Hungarian\" \\
\"gr\" \"Greek\" \\
\"ar\" \"Arabic\" \\
\"he\" \"Hebrew\" \\
\"bg\" \"Bulgarian\" \\
\"hr\" \"Croatian\" \\
\"th\" \"Thai\" \\
\"zh\" \"Chinese\" \\
\"ko\" \"Korean\" \\
\"vn\" \"Vietnamese\" \\
2>/tmp/kbd_layout && setxkbmap \$(cat /tmp/kbd_layout)
"
eval "$LAYOUT_SELECTION_SCRIPT"
echo "Keyboard layout has been changed."
echo "Updating package list and installing required packages..."
sudo apt update && sudo apt install -y zsh fonts-powerline git curl
clear

# Set zsh as the default shell
echo "Setting zsh as the default shell..."
chsh -s $(which zsh)

# Install Oh My Zsh
# Install Zsh if not present
if ! command -v zsh &> /dev/null; then
  echo "Zsh not found. Installing..."
  if [[ "$OSTYPE" == "darwin"* ]]; then
    brew install zsh
  elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    sudo apt update && sudo apt install -y zsh
  fi
else
  echo "Zsh already installed."
fi

echo "🎨 Installing Oh My Zsh without launching Zsh..."
RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
echo "🔄 Setting Zsh as the default shell..."
if [[ "$SHELL" != "$(which zsh)" ]]; then
  chsh -s "$(which zsh)"
  echo "✅ Zsh is now your default shell. It will take effect next time you open a terminal."
else
  echo "Zsh is already your default shell."
fi
echo "Oh My Zsh installed "

sleep 5
clear

echo "Installing some useful scripts for me"
git clone https://github.com/nil0x42/phpsploit
cd phpsploit/
pip3 install -r requirements.txt --break-system-packages
sudo mv ./phpsploit /usr/bin/ && \
grep -q "/usr/bin" <<< "$PATH" || echo 'export PATH=$PATH:/usr/bin' >> ${HOME}/.bashrc
cd $HOME

echo "PHPSploit installed. ✅"
sleep 5
clear
git clone https://github.com/commixproject/commix.git commix
cd commix
python3 setup.py install
echo "Commix installed. ✅"
clear

echo "Configuring Oh My Zsh to use my theme..."
git clone https://github.com/egorlem/ultima.zsh-theme ~/.ultima-shell
echo 'source ~/.ultima-shell/ultima.zsh-theme' >> ~/.zshrc
echo "Adding repository sources to ensure xfce4-terminal is available..."
sudo apt update
if ! grep -q "^deb .*universe" /etc/apt/sources.list; then
    echo "Enabling the universe repository..."
    sudo add-apt-repository universe
    sudo apt update
fi
sudo apt update -qq > /dev/null 2>&1
sudo apt-get install curl wget zip git nmap figlet toilet tor python pip3 ffmpeg pv tmux -y curl > /dev/null 2>&1
sudo apt update && sudo apt install -y tmux curl zsh > /dev/null 2>&1 && echo "set -g @plugin 'tmux-plugins/tpm'\nset -g @plugin 'o0th/tmux-nova'\nset -g @plugin 'yumiriam/tmux-disk'\nset -g @plugin 'xamut/tmux-weather'\nset -g @plugin 'tmux-plugins/tmux-cpu'\nset -g mouse on\nset -g @plugin 'AngryMorrocoy/tmux-neolazygit'\nset -g @plugin 'xamut/tmux-network-bandwidth'\n\nWEATHER='#(curl -s wttr.in/London:Stockholm:Moscow?format=%25l:+%25c%20%25t%60%25w&period=60)'\nset -g @nova-segment-time \"󱇏 #H | #(date +'%H:%M') 󰄾\"\nset -g @nova-segment-time-colors \"#000000 #ff0000\"\nset -g status-interval 60\n\nset-option -g @tmux-weather-interval 5\nset-option -g @tmux-weather-format \"  %t+%w\"\nset -g @nova-segment-weather \"     #{weather}/ \"\nset -g @nova-segment-weather-colors \"#000000 #ff0000\"\n\nset -g @disk_mount_point \"/\"\nset -g @nova-segment-disk \" #{disk_available}b/ \"\nset -g @nova-segment-disk-colors \"#000000 #ff0000\"\n\nset -g @nova-segment-cpu \" CPU: #{cpu_percentage}/ \"\nset -g @nova-segment-cpu-colors \"#000000 #ff0000\"\n\nset -g @nova-segment-ram \" RAM: #{ram_percentage}/ \"\nset -g @nova-segment-ram-colors \"#000000 #ff0000\"\n\nset -g @nova-segment-net \" #{network_bandwidth}/ \"\nset -g @nova-segment-net-colors \"#000000 #ff0000\"\n\nset -g @nova-nerdfonts true\n\nset -g @nova-pane-active-border-style \"#44475a\"\nset -g @nova-pane-border-style \"#282a36\"\nset -g @nova-status-style-bg 'default'\nset -g @nova-status-style-fg '#000000'\nset -g @nova-status-style-active-bg \"#000000\"\nset -g @nova-status-style-active-fg \"#ff0000\"\nset -g @nova-status-style-double-bg \"#ff6666\"\nset -g window-style 'fg=colour247,bg=#00ff00'\nset -g window-active-style 'fg=colour250,bg=black'\n\nset -g @nova-pane-active-border-style \"#ffa500\"\nset -g @nova-pane-border-style        \"#282a36\"\n\nset -g window-status-style         \"bg=default,fg=default\"\nset -g window-status-current-style \"bg=default,fg=default\"\nset -g @nova-pane-border-style \"#ffa500\"\n\nset -g @nova-pane \"#I#{?pane_in_mode,  #{pane_mode},}  #W\"\n\nset -g @nova-segment-mode \"#{?client_prefix,󰋘,󰋙} |\"\nset -g @nova-segment-mode-colors \"#000000 #ff0000\"\nset -g @nova-segment-whoami \"󰛡 NETRUNNER_V3\"\nset -g @nova-segment-whoami-colors \"#000000 #ff0000\"\nset -g status-right-length 300\nset -g @nova-rows 0\nset -g @nova-segments-0-left \"mode time\"\nset -g @nova-segments-0-right \"weather disk cpu ram net whoami\"\n\nrun '~/.tmux/plugins/tpm/tpm'" > ~/.tmux.conf && echo "if command -v tmux >/dev/null 2>&1; then\n  [ -z \"\$TMUX\" ] && exec tmux\nfi" >> ~/.bashrc && echo "if command -v tmux >/dev/null 2>&1; then\n  [ -z \"\$TMUX\" ] && exec tmux\nfi" >> ~/.zshrc
clear

# Now you can evaluate the function
eval "$FILESFUNC"



FILES_ALIAS="alias files='files'"
DISK_ALIAS="alias disk='echo -e \"CURRENT FILE SYSTEM FOR [\$(uname -o), \$(hostname)]\\n\" && df -hT | awk '\''NR==1{print \"Filesystem :: Type :: Size :: Used :: Avail :: Mounted on\"; print \"___________________________________________________\"} NR>1{print \$1 \" :: \" \$2 \" :: \" \$3 \" :: \" \$4 \" :: \" \$5 \" :: \" \$7}'\'''"

MEM_ALIAS="alias mem='free -h'"

PORTS_ALIAS="alias ports='ss -tuln'"
WEATT="alias weather='curl wttr.in/?d'"
UPDATES_ALIAS="alias updates='sudo apt update && sudo apt list --upgradable'"

IPINFO_ALIAS="alias ipinfo='echo Local IP: \$(hostname -I) && echo Public IP: \$(curl -s ifconfig.me)'"

UPTIME_ALIAS="alias uptimeinfo='uptime -p && uptime'"

PSG_ALIAS="alias psg='ps aux | grep -v grep | grep -i'"

EXTRACT_FUNC="
extract () {
    if [ -f \"\$1\" ]; then
        case \"\$1\" in
            *.tar.bz2)   tar xvjf \"\$1\"    ;;
            *.tar.gz)    tar xvzf \"\$1\"    ;;
            *.tar.xz)    tar xvJf \"\$1\"    ;;
            *.bz2)       bunzip2 \"\$1\"     ;;
            *.rar)       unrar x \"\$1\"     ;;
            *.gz)        gunzip \"\$1\"      ;;
            *.tar)       tar xvf \"\$1\"     ;;
            *.tbz2)      tar xvjf \"\$1\"    ;;
            *.tgz)       tar xvzf \"\$1\"    ;;
            *.zip)       unzip \"\$1\"       ;;
            *.Z)         uncompress \"\$1\"  ;;
            *.7z)        7z x \"\$1\"        ;;
            *)           echo \"Don't know how to extract '\$1'...\" ;;
        esac
    else
        echo \"'\$1' is not a valid file!\"
    fi
}
"

TARGET_FILES=(~/.bashrc ~/.zshrc)
add_aliases() {
    for target in "${TARGET_FILES[@]}"; do
        if [ -f "$target" ]; then
            {
                echo ""
                echo "# === Custom Aliases Installation ==="

                echo "$FILES_ALIAS"
                echo "$WEATT"            
                echo "$DISK_ALIAS"
                echo "$MEM_ALIAS"
                echo "$PORTS_ALIAS"
                echo "$UPDATES_ALIAS"
                echo "$IPINFO_ALIAS"
                echo "$UPTIME_ALIAS"
                echo "$PSG_ALIAS"
                echo "$EXTRACT_FUNC"
            } >> "$target"
            echo "Added aliases to $target"
        fi
    done
}

add_aliases
echo "Installation complete! "


echo "📦 Cloning netrunner-cli repo into ~/.boot..."
sleep 5
git clone https://github.com/arcangel0/netrunner-cli.git "$HOME/.boot"
cd $HOME/.boot
chmod +x install.sh
./install.sh 
sleep 3
cd $HOME

if [ $? -ne 0 ]; then
  echo "// NETRUNNER_V3::> Already exists. Skipping."
fi

echo "✅ DONE!"
sleep 5
clear
# Add autostart command if not present
  echo "✅ Added auto-launch to zsh"
  sleep 6
  
echo "alias menu='python3 $HOME/.boot/boot.py firstMenu'" >> $HOME/.zshrc
  echo "// NETRUNNER_V3::TERMINAL_INSTALLED. ✅ "
  echo "✅ Type 'menu' anywhere on your terminal to open Netrunner menu"
  sleep 6
echo ""
echo ""
echo ""
echo "//////// INSTALL_SEQUENCE" | pv -qL 50
echo ">>> FETCHING PACKAGES" | pv -qL 30
  
sleep 2
clear

sleep 5
echo "[::]> INSTALLING TOR PROXY. . . . . . . .   " | pv -qL 60
echo ""
echo ""

cd $HOME
wget https://github.com/JohnMcLaren/torctl-bridged/releases/download/torctl-bridged/torctl-bridged_0.5.7-1_amd64.deb 
sudo apt install $HOME/torctl-bridged_0.5.7-1_amd64.deb
clear
echo "🌐 Installing EzyMap "

git clone https://github.com/ARCANGEL0/EzyMap.git "$HOME/.ezymap"
if [ $? -ne 0 ]; then
  echo "❌ Failed to clone ezymap. Exiting."
fi
sleep 5

echo "✅ DONE"

echo "🚀 Running install.sh..."

sleep 3
echo ". . . . . . . . . ." | pv -qL 25
mkdir -p ~/.local/share/fonts
[ ! -f ~/.local/share/fonts/starwars.flf ] && curl -o ~/.local/share/fonts/starwars.flf https://raw.githubusercontent.com/xero/figlet-fonts/master/starwars.flf
[ ! -f ~/.local/share/fonts/Doom.flf ] && curl -o ~/.local/share/fonts/Doom.flf https://raw.githubusercontent.com/xero/figlet-fonts/master/Doom.flf

for i in {1..5}; do
  echo -n "Loading"
  for j in {1..3}; do
    echo -n "."
    sleep 0.5
  done
  echo ""
done

echo ""

figlet -f ~/.local/share/fonts/starwars.flf "EzyMap"


SHELL_NAME=$(basename "$SHELL")
if [ "$SHELL_NAME" == "bash" ]; then
  echo "export PATH=\$PATH:$(pwd)" >> ~/.bashrc
elif [ "$SHELL_NAME" == "zsh" ]; then
  echo "export PATH=\$PATH:$(pwd)" >> ~/.zshrc
 else
  sudo cp $HOME/.ezymap/ezymap /usr/bin/
fi

echo "Installing Cool Retro Term for THAT vibe. . . . "
sudo apt-get install cool-retro-term
grep 'alias crterm="cool-retro-term --fullscreen --profile 'Futuristic' &"' ~/.zshrc || echo 'alias crterm="cool-retro-term --fullscreen --profile 'Futuristic' &"' >> ~/.zshrc; grep -qxF 'alias crterm="cool-retro-term --fullscreen --profile 'Futuristic' &"' ~/.bashrc || echo 'alias crterm="cool-retro-term --fullscreen --profile 'Futuristic' &"' >> ~/.bashrc

echo " Done ! Just open crterm on anyterminal or open CRT as application on menu"


clear
# Done

# Install nnn filemanager
echo " Installing NNN and setting file manager"
git clone https://github.com/jarun/nnn 
cd nnn
sudo apt-get install pkg-config libncursesw5-dev libreadline-dev -y
sudo make strip install
( [ -f ~/.zshrc ] && echo 'alias ls="nnn -H -de"' >> ~/.zshrc ) || ( [ -f ~/.bashrc ] && echo 'alias ls="nnn -H -de"' >> ~/.bashrc )
echo " Done ! Use ls anywhere to navigate with nnn"

# Done
clear
# Install micro if not installed
if ! command -v micro &> /dev/null; then
  echo "Installing micro..."
  curl https://getmic.ro | bash
  sudo mv micro /usr/local/bin
else
  echo "Micro is already installed."
fi

clear
# Install plugins
echo "Installing plugins..."
micro -plugin install detectindent filemanager manipulator quickfix snippets wakatime autoclose comment diff ftoptions linter literate status

echo "Micro and plugins installed successfully! Use 'micro' anywhere now"

# Done
clear
cp $HOME/.fallout/fallout.json $HOME/fallout.json
figlet -f smmono9 "Scripts installed!"
figlet -f wideterm "// NETRUNNER_INSTALLED++"
read -n 1 -s -r -p ""
cool-retro-term --fullscreen --profile 'Futuristic'
PPPID=$(awk '{print $4}' "/proc/$PPID/stat")
kill $PPPID

