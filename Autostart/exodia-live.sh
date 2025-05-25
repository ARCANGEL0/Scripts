#!/bin/bash

# Remove /etc/pacman.conf and replace it with the custom configuration
echo "Removing /etc/pacman.conf..."
sudo rm -f /etc/pacman.conf

# Creating a new /etc/pacman.conf with the provided configuration
echo "Creating new /etc/pacman.conf..."
cat <<EOF | sudo tee /etc/pacman.conf
#####################################
#                                   #
#  @author      : 00xWolf           #
#    GitHub    : @mmsaeed509       #
#    Developer : Mahmoud Mohamed   #
#  﫥  Copyright : Exodia OS         #
#                                   #
#####################################

[options]
HoldPkg     = pacman glibc
Architecture = auto
CheckSpace
Color
ILoveCandy
ParallelDownloads = 6
SigLevel    = Never
LocalFileSigLevel = Never

##########################
#      Exodia Repos      #
##########################

## Core packages repo ##
[exodia-repo]
SigLevel = Optional TrustAll
Server = https://exodia-os.github.io/$repo/$arch

## PenTest packages repo ##
[Exodia-PenTest-Repo]
SigLevel = Optional TrustAll
Server = https://exodia-os.github.io/$repo/$arch

## Community Repo ##
# [exodia-community-repo]
# SigLevel = Optional TrustAll
# Server = https://exodia-os.github.io/$repo/$arch

## Testing Repo ##
# [exodia-testing-repo]
# SigLevel = Optional TrustAll
# Server = https://exodia-os.github.io/$repo/$arch

## ---------------------------------------------- ##

#############################
#      ArchLinux Repos      #
#############################

[core]
Include = /etc/pacman.d/mirrorlist

[extra]
Include = /etc/pacman.d/mirrorlist

#[community-testing]
#Include = /etc/pacman.d/mirrorlist

# [community]
#Include = /etc/pacman.d/mirrorlist

# If you want to run 32 bit applications on your x86_64 system,
# enable the multilib repositories as required here.

#[multilib-testing]
#Include = /etc/pacman.d/mirrorlist

[multilib]
Include = /etc/pacman.d/mirrorlist

######################
#      AUR Repo      #
######################

[chaotic-aur]
Include = /etc/pacman.d/chaotic-mirrorlist 


#############################
#      blackarch Repos      #
#############################

[blackarch]
SigLevel = Optional TrustAll
Include = /etc/pacman.d/blackarch-mirrorlist
EOF

# Initialize pacman keyring and populate it
echo "Initializing pacman keyring..."
sudo pacman-key --init
sudo pacman-key --populate archlinux

# Install Firefox and NSS
echo "Installing Firefox and NSS..."
sudo pacman -Sy firefox nss

# Edit XFCE4 Terminal settings
echo "Editing XFCE4 terminal settings..."

# Set background opacity to 0.5 and style based on the system theme
XFCE4_TERMINAL_CONFIG="$HOME/.config/xfce4/terminal/terminalrc"
if [ -f "$XFCE4_TERMINAL_CONFIG" ]; then
  sed -i 's/BackgroundOpacity=.*/BackgroundOpacity=0.5/' $XFCE4_TERMINAL_CONFIG
  sed -i 's/ColorStyle=.*/ColorStyle=1/' $XFCE4_TERMINAL_CONFIG
else
  echo "XFCE4 Terminal config file not found!"
fi

# Install eDEX-UI AppImage and set as runnable bin
echo "Downloading and setting up eDEX-UI AppImage..."
wget https://github.com/GitSquared/edex-ui/releases/download/v2.2.8/eDEX-UI-Linux-arm64.AppImage -O /usr/local/bin/edex
sudo chmod +x /usr/local/bin/edex

# Edit BSPWM keybindings
echo "Editing BSPWM keybindings..."
BSPWM_KEYBINDINGS="$HOME/.config/bspwm/keybinding/sxhkdrc"
if [ -f "$BSPWM_KEYBINDINGS" ]; then
  mv "$BSPWM_KEYBINDINGS" "$BSPWM_KEYBINDINGS.bak"  # Backup the existing keybinding file
fi

cat <<EOF | tee "$HOME/.config/bspwm/keybinding/sxhkdrc"
# Toggle right click context menu. #
~button3
  xqp 0 \$(xdo id -N Bspwm -n root) && jgmenu_run

##---------- Keybindings for bspwm ----------##

# Terminal (alacritty) #
super + Return
	edex

# Terminal (floating) #
super + shift + Return
	bspterm -float

# Terminal (fullscreen) #
super + t
	xfce4-terminal
#Firefox
super + b 
   firefox
##---------- Rofi Launcher & Menus ----------##

# Rofi App Launcher #
alt + F1
	sh ~/.config/bspwm/rofi/bin/launcher

# Rofi Network Menu #
super + n
	nmd

# Rofi Themes Menu #
ctrl + alt + t
	sh ~/.config/bspwm/rofi/bin/themes

# Rofi Menus/Applets #
super + {w,m,x,r,s,i}
	sh ~/.config/bspwm/rofi/bin/{windows,mpd,powermenu,asroot,screenshot,network}

##---------- Applications ----------##

# Open/close dashboard #
super + d
	sh ~/.config/eww/dashboard/launch_dashboard

# Launch Apps #
super + shift + {b,e}
	{brave,geany}

# Terminal Apps #
ctrl + alt + {r,h,b,n,v}
	alacritty --config-file ~/.config/bspwm/alacritty/alacritty.toml -e {ranger,htop,bashtop,nvim,vim}

# Color Picker #
super + p
	colorPicker

# Lockscreen #
ctrl + alt + l
    betterlockscreen --lock

# music art #
super + shift + m
	music --albumArtCover

# Open Tmux #
super + shift + t
	bsptmux

##---------- System Keys ----------##

# Take a screenshot #
Print
	takeshot --now
	
# Take screenshot in 5 second #
alt + Print	
	takeshot --in5

# Take screenshot in 10 second #
shift + Print	
	takeshot --in10

# Take screenshot of active window #
ctrl + Print
	takeshot --win

# Take screenshot of area #
ctrl + alt + Print
	takeshot --area

# Brighness control #
XF86MonBrightness{Up,Down}
	bspbrightness{ --inc, --dec}
	
# Volume control #
XF86Audio{RaiseVolume,LowerVolume}
	bspvolume{ --inc, --dec}

# Volume Mute #
XF86AudioMute
	bspvolume --toggle

# Music control #
XF86Audio{Next,Prev,Play,Stop}
	mpc {next,prev,toggle,stop}

# Mic Volume control
XF86Audio{Mute,MicMute}
	bspvolume{ --toggle, --toggle-mic}
	
##---------- Bspwm ----------##

# Close App #
super + {_,shift + }c
	bspc node -{c,k}ss

# Reload Keybindings #
super + k
	pkill -USR1 -x sxhkd

# kill window #
super + Escape
    xkill

# Quit/Restart bspwm #
ctrl + shift + {q,r}
	bspc {quit,wm -r}
	
# Split horizontal, vertical or cancel #
super + {h,v,q}
	bspc node -p {east,south,cancel}

# Preselect the ratio #
super + ctrl + {1-9}
	bspc node -o 0.{1-9}

# Monocle #
super + l
	bspc desktop -l next
	
# Fullscreen #
super + f
    bspc node -t "~"fullscreen

# Toggle beetwen floating & tiled #
super + space
    bspc node -t "~"{floating,tiled}

# Pseudo Tiled & tiled mode #
super + shift + space
#  super + {p,t}
    bspc node -t "~"{pseudo_tiled,tiled}

# Set the node flags #
super + ctrl + {m,x,y,z}
	bspc node -g {marked,locked,sticky,private}

# Send the window to another edge of the screen #
super + {_,shift + }{Left,Down,Up,Right}
	bspc node -{f,s} {west,south,north,east}

# Change focus to next window, including floating window #
alt + {_,shift + }Tab
	bspc node -f {next.local,prev.local}

# Switch workspace #
ctrl + alt + {Left,Right}
	bspc desktop -f {prev.local,next.local}

# Switch to last opened workspace #
super + {Tab,grave}
	bspc {node,desktop} -f last

# Send focused window to another workspace #
super + {_,shift + }{1-8}
	bspc {desktop -f,node -d} '^{1-8}'

# Expanding windows #
ctrl + super + alt + Up
	bspc node -z right 20 0; \
	bspc node -z top 0 20

# Shrinking windows #
ctrl + super + alt + Down
	bspc node -z right -20 0; \
	bspc node -z top 0 -20
EOF

# Reload bspwm to apply changes
echo "Reloading BSPWM..."
bspc wm -r

# Install Zsh and set as default shell
echo "Installing Zsh and setting as default shell..."
sudo pacman -S zsh zsh-completions

# Change the default shell to Zsh
chsh -s $(which zsh)

# Install Oh My Zsh for better configuration
echo "Installing Oh My Zsh..."
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Configure Zsh prompt and theme
echo "Configuring Zsh prompt..."
cat <<EOF >> ~/.zshrc

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]];
    
    then
        
        source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"

fi

# default editor #
export EDITOR=nvim

# Path to your oh-my-zsh installation. #
export ZSH=$HOME/.oh-my-zsh

# zsh theme #
ZSH_THEME="powerlevel10k/powerlevel10k"

# disable bi-weekly auto-update checks. #
DISABLE_AUTO_UPDATE="true"

# plugins #
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  web-search
  )

source $ZSH/oh-my-zsh.sh

## ------------ User configuration ------------ ##

# On-demand rehash #
zshcache_time="$(date +%s%N)"

autoload -Uz add-zsh-hook

rehash_precmd() {
  if [[ -a /var/cache/zsh/pacman ]];
      
      then
          
          local paccache_time="$(date -r /var/cache/zsh/pacman +%s%N)"
          
          if (( zshcache_time < paccache_time ));
              
              then
                  
                  rehash
                  zshcache_time="$paccache_time"

          fi

  fi

}

add-zsh-hook -Uz precmd rehash_precmd

## ------------ Alias ------------ ##

alias zshconfig="geany ~/.zshrc"
alias ohmyzsh="thunar ~/.oh-my-zsh"

# ls #
alias ls='lsd'
alias l='lsd -lh'
alias ll='lsd -lah'
alias la='lsd -A'
alias lm='lsd -m'
alias lr='lsd -R'
alias lg='lsd -l --group-directories-first'

# git #
alias gcl='git clone --depth 1'
alias gi='git init'
alias ga='git add'
alias gc='git commit -m'
alias gp='git push origin master'
alias cb='git checkout -f'

# Pacman #
alias sync="sudo pacman -Syyy"
alias install="sudo pacman -S"
alias ipkg="sudo pacman -U"
alias update="sudo pacman -Syyu"
alias search="sudo pacman -Ss"
alias search-local="sudo pacman -Qs"
alias pkg-info="sudo pacman -Qi"
alias clr-cache="sudo pacman -Scc"
alias unlock="sudo rm /var/lib/pacman/db.lck"
alias remove="sudo pacman -R"
alias autoremove="sudo pacman -Rns"

# yay - AUR Helper #
alias Ysync="yay -Syyy"
alias Yinstall="yay -S"
alias Yipkg="yay -U"
alias Yupdate="yay -Syyu"
alias Ysearch="yay -Ss"
alias Ysearch-local="yay -Qs"
alias Ypkg-info="yay -Qi"
alias Ylocal-install="yay -U"
alias Yclr-cache="yay -Scc"
alias Yremove="yay -R"
alias Yautoremove="yay -Rns"

# Other #
alias M="ncmpcpp"
alias MA="cd ~/.ncmpcpp/scripts/ && ./ncmpcpp-art"

## ------------ COLORS ------------ ##

# Reset #
RESET_COLOR='\033[0m' # Text Reset

# Regular Colors #
Black='\033[0;30m'  Red='\033[0;31m'     Green='\033[0;32m'  Yellow='\033[0;33m'
Blue='\033[0;34m'   Purple='\033[0;35m'  Cyan='\033[0;36m'   White='\033[0;37m'

# Bold #
BBlack='\033[1;30m' BRed='\033[1;31m'    BGreen='\033[1;32m' BYellow='\033[1;33m'
BBlue='\033[1;34m'  BPurple='\033[1;35m' BCyan='\033[1;36m'  BWhite='\033[1;37m'

# Underline #
UBlack='\033[4;30m' URed='\033[4;31m'    UGreen='\033[4;32m' UYellow='\033[4;33m'
UBlue='\033[4;34m'  UPurple='\033[4;35m' UCyan='\033[4;36m'  UWhite='\033[4;37m'

# Background #
On_Black='\033[40m' On_Red='\033[41m'    On_Green='\033[42m' On_Yellow='\033[43m'
On_Blue='\033[44m'  On_Purple='\033[45m' On_Cyan='\033[46m'  On_White='\033[47m'

# High Intensity #
IBlack='\033[0;90m' IRed='\033[0;91m' IGreen='\033[0;92m' IYellow='\033[0;93m'      
IBlue='\033[0;94m' IPurple='\033[0;95m' ICyan='\033[0;96m' IWhite='\033[0;97m'      

# Bold High Intensity #
BIBlack='\033[1;90m' BIRed='\033[1;91m' BIGreen='\033[1;92m' BIYellow='\033[1;93m'
BIBlue='\033[1;94m' BIPurple='\033[1;95m' BICyan='\033[1;96m' BIWhite='\033[1;97m'

# High Intensity backgrounds #
On_IBlack='\033[0;100m' On_IRed='\033[0;101m' On_IGreen='\033[0;102m' On_IYellow='\033[0;103m'
On_IBlue='\033[0;104m' On_IPurple='\033[0;105m' On_ICyan='\033[0;106m' On_IWhite='\033[0;107m'

# load on startup #
echo -e "\033[1;31m
		⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣴⣾⣷⣤⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀   ▖ 
		⠀⠀⠀⠀⠀⠀⠀⠀⢀⣠⣴⡿⠟⠋⠀⠈⠙⠻⣷⣦⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀   ▌ ▛▌▛▌▛▌  
		⠀⠀⠀⠀⠀⢀⣤⡀⠹⠛⠉⠀⣠⣴⣿⣷⣦⣀⠀⠉⠻⠏⢠⣄⡀⠀⠀⠀⠀⠀   ▙▖▙▌▌▌▙▌
		⠀⠀⣀⣴⣾⠿⠋⠁⠀⠀⠀⠛⠉⢹⣿⣿⡇⠉⠓⠀⠀⠀⠈⠛⢿⣷⣤⣀⠀⠀         ▄▌
		⣴⡿⠟⠋⠀⣀⣤⠶⠀⠀⠀⠀⠀⢸⣿⣿⠃⠀⠀⠀⠀⠀⠶⣄⡀⠈⠙⠻⣷⣦   ▖ ▘   
		⣿⡇⠀⣴⣾⣿⣤⡀⠀⠀⠀⠀⠀⠈⣿⣿⠀⠀⠀⠀⠀⠀⢀⣼⣿⣷⡆⠀⢸⣿   ▌ ▌▌▌█▌
		⣿⡇⠀⣿⢿⣿⣿⣿⣶⣄⠀⠀⢀⣤⣿⣿⣤⡀⠀⢀⣠⣾⣿⣿⣿⣿⡇⠀⢸⣿   ▙▖▌▚▘▙▖
		⣿⡇⠀⣿⠀⠈⠉⠛⠿⣿⣿⣾⣿⣿⣿⣿⣿⣿⣷⣿⣿⠿⠛⠉⠀⠘⡇⠀⢸⣿
		⠿⠇⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠸⠟   ▗ ▌    ▄▖     ▘  
		⣶⡆⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⢰⣶   ▜▘▛▌█▌ ▙▖▛▛▌▛▌▌▛▘█▌
		⣿⡇⠀⣿⠀⢀⣀⣤⣶⣿⣿⢿⣿⣿⣿⣿⣿⣿⡿⣿⣿⣶⣤⣀⠀⢸⡇⠀⢸⣿   ▐▖▌▌▙▖ ▙▖▌▌▌▙▌▌▌ ▙▖
		⣿⡇⠀⣿⣾⣿⣿⣿⠿⠋⠀⠀⠈⠛⣿⣿⠋⠁⠀⠈⠙⢿⣿⣿⣿⣿⡇⠀⢸⣿	            ▌    
		⣿⡇⠀⠻⢿⣿⠛⠁⠀⠀⠀⠀⠀⢠⣿⣿⠀⠀⠀⠀⠀⠀⠈⢻⣿⡿⠇⠀⢸⣿
		⠻⣿⣦⣄⡀⠉⠛⠶⠀⠀⠀⠀⠀⢸⣿⣿⡄⠀⠀⠀⠀⠀⠶⠋⠁⢀⣠⣶⡿⠟
		⠀⠀⠉⠛⢿⣶⣤⡀⠀⠀⠀⣤⣀⣸⣿⣿⡇⣀⡤⠀⠀⠀⢀⣤⣾⡿⠛⠁⠀⠀
		⠀⠀⠀⠀⠀⠈⠙⠁⣰⣦⣀⠀⠙⠻⣿⡿⠟⠉⠀⣀⣴⣆⠘⠋⠁⠀⠀⠀⠀⠀
		⠀⠀⠀⠀⠀⠀⠀⠀⠈⠙⠻⣿⣦⣄⠀⢀⣠⣴⡿⠟⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀
	        ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠻⢿⡿⠛⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
\033[0m"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh. #
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# load custom profile #
if [[ -f ~/.custom-profile ]];
    
    then
        
        . ~/.custom-profile

fi



# change sudo prompt #
export sudo_PROMPT="[] Enter sudo Password"

EOF

# Reload the shell configuration
source ~/.zshrc

echo "Setup complete!"
