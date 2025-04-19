# Installing Cool Retro Term -- Totally required, can't code without those retro screens. 
wget https://github.com/Swordfish90/cool-retro-term/releases/download/continuous/Cool_Retro_Term-dac2b4f-x86_64.AppImage 
mv Cool_Retro_Term-dac2b4f-x86_64.AppImage retro-terminal 
mv retro-terminal /usr/bin/retro-terminal
grep 'alias crterm="retro-terminal --fullscreen &"' ~/.zshrc || echo 'alias crterm="retro-terminal --fullscreen &"' >> ~/.zshrc; grep -qxF 'alias crterm="retro-terminal --fullscreen &"' ~/.bashrc || echo 'alias crterm="retro-terminal --fullscreen &"' >> ~/.bashrc
