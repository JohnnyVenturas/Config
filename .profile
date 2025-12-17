

config_dir="$HOME"

export NVIM="$HOME/.config/nvim"


if [ "$(uname -s)" = "Darwin" ];then
    alias snapshot='top -l 1'
elif [ "$(uname -s)" = "Linux" ];then
    alias snapshot='top -b -n 1'
fi


# if ! snapshot | grep -q ssh-agent ; then
#     eval "$(ssh-agent)" &> /dev/null
# fi
#




