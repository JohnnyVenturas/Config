autoload -z edit-command-line
zle -N edit-command-line
alias pip='python3 -m pip'

export EDITOR=nvim

bindkey -v

bindkey -M vicmd 'v' edit-command-line


