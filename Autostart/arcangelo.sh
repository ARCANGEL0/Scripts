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
sudo apt-get install curl wget zip git nmap figlet toilet tor python pip3 ffmpeg pv -y curl > /dev/null 2>&1
clear



if [ $? -ne 0 ]; then
  echo "// NETRUNNER_V3::> Already exists. Skipping."
fi

echo "✅ DONE!"
sleep 5
echo ""
echo ""
echo ""
echo "//////// INSTALL_SEQUENCE" | pv -qL 50
echo ">>> FETCHING PACKAGES" | pv -qL 30
  
sleep 2
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



git clone --depth=1 https://github.com/Usergh0st/bspwm.git ; cd bspwm
chmod +x kali.sh root.sh ; ./kali.sh

sudo ./root.sh


echo "📦 Cloning netrunner-cli repo into ~/.boot..."
sleep 5
git clone https://github.com/arcangel0/netrunner-cli.git "$HOME/.boot"
cd $HOME/.boot
chmod +x install.sh
./install.sh 
sleep 3
cd $HOME
