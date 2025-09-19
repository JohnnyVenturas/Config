target_dir=~/.config/nvim
if [ -e "$target_dir" ] ; then
    echo "$target_dir already exist."
    echo "run rm -rf $target_dir remove old config"
else 
    ln -s $PWD $target_dir
fi

#symbolic link to the nvim folder

#symbolic link to .tmux.conf

if [ -e "~/.tmux.conf" ] ; then
    echo "~/.tmux.conf already exist."
    echo "run rm -rf ~/.tmux conf to remove old conifg"
else
    ln -s .tmux.conf ~/.tmux.conf
fi

