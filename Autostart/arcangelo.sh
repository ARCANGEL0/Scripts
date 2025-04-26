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

clear



files() {
    echo -e "OWNER :: PERMISSIONS :: DATE MODIFIED > [TYPE] NAME ∆ SIZE"
    echo "-------------------------------------------------------------"
    for item in .* *; do
        [ -e "$item" ] || continue
        perms=$(stat -c "%A" "$item")
        owner=$(stat -c "%U" "$item")
        date=$(stat -c "%y" "$item" | cut -d'.' -f1)
        if [ -d "$item" ]; then
            icon="[DIR]"
            size=$(du -sh "$item" 2>/dev/null | awk '{print $1}')
        else
            icon="[FILE]"
            size=$(du -h "$item" 2>/dev/null | awk '{print $1}')
        fi
        printf "[%s] :: %s :: %s > %s %s ∆ %s\n" "$owner" "$perms" "$date" "$icon" "$item" "$size"
    done
}
FILES_ALIAS= files
DISK_ALIAS="alias disk='echo -e \"CURRENT FILE SYSTEM FOR [\$(uname -o), \$(hostname)]\\n\" && df -hT | awk '\''NR==1{print \"Filesystem :: Type :: Size :: Used :: Avail :: Mounted on\"; print \"___________________________________________________\"} NR>1{print \$1 \" :: \" \$2 \" :: \" \$3 \" :: \" \$4 \" :: \" \$5 \" :: \" \$7}'\'''"

MEM_ALIAS="alias mem='free -h'"

PORTS_ALIAS="alias ports='ss -tuln'"

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


echo "📦 Cloning robco-termlink repo into ~/.fallout..."
sleep 5
git clone https://github.com/arcangel0/robco-termlink.git "$HOME/.fallout"

if [ $? -ne 0 ]; then
  echo "✅  Termlink Already exists.Skipping."
fi

echo "✅ DONE!"
sleep 5
clear
# Add autostart command if not present
echo "tmux" >> $HOME/.zshrc
echo "python3 $HOME/.fallout/init.py" >> $HOME/.zshrc
  echo "✅ Added auto-launch to zsh"
  sleep 6
  
echo "alias menu='python3 $HOME/.fallout/fallout.py menu'" >> $HOME/.zshrc
  echo "✅ Fallout menu command added to ZSH"
  echo "✅ Type 'menu' anywhere on your terminal to open RobCo menu interface"
  sleep 6
echo ""
echo ""
echo ""
echo "ROBCO INDUSTRIES (TM) UNIFIED OPERATIONAL SYSTEM INSTALLATION" | pv -qL 50
echo "CONFIGURING PACKAGES" | pv -qL 30
echo "TERMINAL COMPONENT NECESSARY" | pv -qL 30
echo "SET APT UPDATE/MASTER" | pv -qL 40
echo "APT INSTALLATION/MODE=ROOT:RWED ACCOUNTS.F" | pv -qL 40
  
sleep 2
clear
echo "🌐 Cloning torall into $HOME/.local/torall/"

git clone https://github.com/bissisoft/torall.git "$HOME/.local/torall/"

if [ $? -ne 0 ]; then
 echo "✅ Tor already exists. Skipping."
  
fi

echo "✅ DONE."
echo "✅ torall downloaded to $HOME/.local/torall/"

echo "🔧 Making build.sh executable..."

chmod +x "$HOME/.local/torall/build.sh"

echo "🚀 Running build.sh..."

cd $HOME/.local/torall

sudo ./build.sh 
echo "✅ Build complete!"

sleep 5
cd $HOME

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


# Installing Cool Retro Term -- Totally required, can't code without those retro screens. 
echo "Installing Cool Retro Term for THAT vibe. . . . "
sudo apt-get install cool-retro-term
grep 'alias crterm="cool-retro-term --fullscreen &"' ~/.zshrc || echo 'alias crterm="cool-retro-term --fullscreen &"' >> ~/.zshrc; grep -qxF 'alias crterm="cool-retro-term --fullscreen &"' ~/.bashrc || echo 'alias crterm="cool-retro-term --fullscreen &"' >> ~/.bashrc

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
figlet -f wideterm "Press any key to continue on the RobCo Terminal (obs: Click with right button to open settings, and set a custom theme: There is a fallout.json file at $HOME where you can import the custom fallout theme) . . ."
read -n 1 -s -r -p ""
cool-retro-term --fullscreen & disown
PPPID=$(awk '{print $4}' "/proc/$PPID/stat")
kill $PPPID

