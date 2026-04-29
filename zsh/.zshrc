PROMPT='%B%F{white}%n@%m %1~ ~> %f%b'
ZDOTDIR=~/.config/zsh

HISTSIZE=100000
SAVEHIST=100000
HISTFILE="$ZDOTDIR/.zsh_history"

. $ZDOTDIR/.worktrees

[ $(uname) = 'Darwin' ] && eval "$($(which brew) shellenv)"

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

bindkey -M vicmd '/' history-incremental-pattern-search-backward
bindkey -M vicmd '?' history-incremental-pattern-search-forward
bindkey -M viins '^R' history-incremental-pattern-search-backward
bindkey -M viins '^F' history-incremental-pattern-search-forward

ssh_setup

[ -f $ZDOTDIR/.plugins ] && . $ZDOTDIR/.plugins

# disable sort when completing `git checkout`
zstyle ':completion:*:git-checkout:*' sort false
# set descriptions format to enable group support
# NOTE: don't use escape sequences (like '%F{red}%d%f') here, fzf-tab will ignore them
zstyle ':completion:*:descriptions' format '[%d]'
# set list-colors to enable filename colorizing
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
zstyle ':completion:*' menu no
# preview directory's content with eza when completing cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
# custom fzf flags
# NOTE: fzf-tab does not follow FZF_DEFAULT_OPTS by default
zstyle ':fzf-tab:*' fzf-flags --color=fg:1,fg+:2 --bind=tab:accept
# To make fzf-tab follow FZF_DEFAULT_OPTS.
# NOTE: This may lead to unexpected behavior since some flags break this plugin. See Aloxaf/fzf-tab#455.
zstyle ':fzf-tab:*' use-fzf-default-opts yes
# switch group using `<` and `>`
zstyle ':fzf-tab:*' switch-group '<' '>'
autoload -U compinit; compinit


source_python() {
    [ -z "$1" ] && exit 1
    source "$1/bin/activate"
}
