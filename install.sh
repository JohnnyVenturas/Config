#!/bin/sh

newline() {
    printf '=%.0s' $(seq 1 50)
    printf '\n%.0s' $(seq 1 2)
}

nvim_config_directory="$HOME/.config/nvim"
if [ -e "$nvim_config_directory" ] ; then
    echo "$nvim_config_directory already exist."
    echo "Remove old config before continuing (e.g ~/.config/nvim)"
    newline
else 
    #symbolic link to the nvim folder
    ln -s "$PWD" "$nvim_config_directory"
fi



if [ -e "$HOME/.tmux.conf" ] ; then
    echo "$HOME/.tmux.conf already exist."
    echo "Remove old config before continuing (e.g. ~/.tmux.conf)"
    newline
else
    #symbolic link to .tmux.conf
    ln -s "$PWD/.tmux.conf" ~/.tmux.conf
fi

if [ -e "$HOME/.profile" ]; then
    echo "~/.profile is already found on path"
    echo "Manually remove it before proceding"
    newline
else
    ln -s "$PWD/.profile" "$HOME/.profile"
fi

if [ -e "$HOME/.zshrc" ]; then
    echo "~/.zshrc is already found on path"
    echo "Manually remove it before proceding"
    newline
else
    ln -s "$PWD/.zshrc" "$HOME/.zshrc"
fi

if [ -e "$HOME/.wezterm.lua" ]; then
    echo "~/.wezterm is already found on path"
    echo "Manually remove it before proceding"
    newline
else
    ln -s "$PWD/.wezterm.lua" "$HOME/.wezterm.lua"
fi

