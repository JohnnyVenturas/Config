#!/bin/sh

target_dir="$HOME/.config/nvim"
if [ -e "$target_dir" ] ; then
    echo "$target_dir already exist."
    echo "Remove old config before continuing (e.g ~/.config/nvim)"
else 
    ln -s "$PWD" "$target_dir"
fi

#symbolic link to the nvim folder

#symbolic link to .tmux.conf

if [ -e "$HOME/.tmux.conf" ] ; then
    echo "$HOME/.tmux.conf already exist."
    echo "Remove old config before continuing (e.g. ~/.tmux.conf)"
else
    ln -s "$PWD"/.tmux.conf ~/.tmux.conf
fi

