autoload -z edit-command-line
zle -N edit-command-line
alias pip='python3 -m pip'

export EDITOR=nvim

bindkey -v

bindkey -M vicmd 'v' edit-command-line


alias ls='ls --color=auto'
alias grep='grep --color=auto'

PROMPT='%B%F{white}%n@%m %1~> %f%b'
ZDOTDIR=~/.config/zsh

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


ssh_setup

