
config_dir="$HOME"

case  "$SHELL"  in
    *bash*)
    . "$config_dir/.bash_profile";;
    *zsh*)
    . "$config_dir/.zprofile"
        ;;
esac

export NVIM="$HOME/.config/nvim"

if [ "$(uname -s)" = "Darwin" ];then
    alias snapshot='top -l 1'
elif [ "$(uname -s)" = "Linux" ];then
    alias snapshot='top -b -n 1'
fi


if ! snapshot | grep -q ssh-agent ; then
    eval "$(ssh-agent)" &> /dev/null
fi

ssh-add ~/.ssh/bbudura &> /dev/null




