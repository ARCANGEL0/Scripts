#!/bin/bash

mv boot $HOME/
# Update package list and install necessary packages
echo "Updating package list and installing required packages..."
sudo apt update && sudo apt install -y zsh fonts-powerline git curl

# Set zsh as the default shell
echo "Setting zsh as the default shell..."
chsh -s $(which zsh)

# Install Oh My Zsh
echo "Installing Oh My Zsh..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" 

# Install powerlevel10k theme for Oh My Zsh
echo "Installing powerlevel10k theme..."
git clone --depth 1 https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k

# Configure Oh My Zsh to use the powerlevel10k theme
echo "Configuring Oh My Zsh to use powerlevel10k theme..."
sed -i 's/ZSH_THEME=".*"/ZSH_THEME="powerlevel10k/powerlevel10k"/' ~/.zshrc

# Reload zsh configuration to apply changes
echo "Reloading zsh configuration..."
[ -f ~/.bashrc ] && ! grep -Fxq "~/boot" ~/.bashrc && echo '~/boot' >> ~/.bashrc; [ -f ~/.zshrc ] && ! grep -Fxq "~/boot" ~/.zshrc && echo '~/boot' >> ~/.zshrc
source ~/.zshrc


# Installing Cool Retro Term -- Totally required, can't code without those retro screens. 
echo "Installing Cool Retro Term for THAT vibe. . . . "
wget https://github.com/Swordfish90/cool-retro-term/releases/download/continuous/Cool_Retro_Term-dac2b4f-x86_64.AppImage 
mv Cool_Retro_Term-dac2b4f-x86_64.AppImage retro-terminal 
mv retro-terminal /usr/bin/retro-terminal
grep 'alias crterm="retro-terminal --fullscreen &"' ~/.zshrc || echo 'alias crterm="retro-terminal --fullscreen &"' >> ~/.zshrc; grep -qxF 'alias crterm="retro-terminal --fullscreen &"' ~/.bashrc || echo 'alias crterm="retro-terminal --fullscreen &"' >> ~/.bashrc
$SHELL -c 'echo $0' && exec $SHELL 
echo " Done !"
clear
# Done

# Install nnn filemanager
echo " Installing NNN and setting file manager"
git clone https://github.com/jarun/nnn 
cd nnn
sudo apt-get install pkg-config libncursesw5-dev libreadline-dev -y
sudo make strip install
( [ -f ~/.zshrc ] && echo 'alias ls="nnn -H -de"' >> ~/.zshrc ) || ( [ -f ~/.bashrc ] && echo 'alias ls="nnn -H -de"' >> ~/.bashrc )
$SHELL -c 'echo $0' && exec $SHELL 
echo " Done !"

# Done

# Install micro if not installed
if ! command -v micro &> /dev/null; then
  echo "Installing micro..."
  curl https://getmic.ro | bash
  sudo mv micro /usr/local/bin
else
  echo "Micro is already installed."
fi

# Install plugins
echo "Installing plugins..."
micro -plugin install detectindent filemanager manipulator quickfix snippets wakatime autoclose comment diff ftoptions linter literate status

echo "Micro and plugins installed successfully!"

# Done


# Run the terminal 

crterm


