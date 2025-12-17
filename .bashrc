#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

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

ssh_setup
