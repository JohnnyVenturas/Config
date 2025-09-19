target_dir=~/.config/nvim
if [ -e "$target_dir" ] ; then
    echo "$target_dir already exist."
    echo "run rm -rf $target_dir"
fi

#symbolic link to the nvim folder
ln -s $PWD $target_dir

#symbolic link to .tmux.conf
ln -s .tmux.conf ~/.tmux.conf

