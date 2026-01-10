PROMPT='%B%F{white}%n@%m %1~ ~> %f%b'
ZDOTDIR=~/.config/zsh


plugins=( 'zsh-users/zsh-autosuggestions')

autoload -z edit-command-line
zle -N edit-command-line
alias pip='python3 -m pip'

export EDITOR=nvim

bindkey -v

bindkey -M vicmd 'v' edit-command-line


alias ls='ls --color=auto'
alias grep='grep --color=auto'


function ssh_setup() {
    # generate the ssh_agent session
    if [ ! -e '/tmp/ssh_agent' ] ;then
        ssh-agent > /tmp/ssh_agent
    fi


    #ensure the ssh-agent is in a valid state

    ssh-add -l > /dev/null 2>&1

    if [ $? -eq 2 ];then
        ssh-agent > /tmp/ssh_agent
    fi

    eval "$(cat /tmp/ssh_agent)" > /dev/null

    ssh-add ~/.ssh/bbudura > /dev/null 2>&1
}



function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}

function fan_on() {
    pinctrl FAN_PWM op dl
}
function fan_off() {
    pinctrl FAN_PWM op dh
}

# function load_plugins {
#     cd "plugins"
#     for plugin in *; do
#         cd $plugin || exit 1
#     done
# }
#
# function install_plugins {
#     local prefix="https://github.com"
#     cd "plugins" || exit 1
#     for plugin in "${plugins[@]}";do
#         local plugin_name=${plugin/*\//}
#
#         if [ -e "$plugin_name" ] && [ -d "$plugin_name" ]; then
#             cd "$plugin_name" || exit 1
#             git pull
#             cd ..
#             continue
#         fi
#
#         git clone "$prefix/$plugin"
#     done
#
#     cd ..
#
# }



ssh_setup

