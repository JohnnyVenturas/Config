target_dir=~/.config/nvim
if [ -e "$target_dir" ] ; then
    echo "$target_dir already exist."
    echo "Remove old config before continuing (e.g ~/.config/nvim)"
else 
    ln -s $PWD $target_dir
fi

#symbolic link to the nvim folder

#symbolic link to .tmux.conf

if [ -e "~/.tmux.conf" ] ; then
    echo "~/.tmux.conf already exist."
    echo "Remove old config before continuing (e.g. ~/.tmux.conf)"
else
    ln -s .tmux.conf ~/.tmux.conf
fi

