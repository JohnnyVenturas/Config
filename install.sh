#!/bin/sh

configs="nvim;tmux;zsh;ghostty;git"

colors () {
    GREEN='\033[0;32m'
    RED='\033[0;31m'
    NC='\033[0m' # No Color
}

color() {
    local word="$1"
    local color="$2"
    printf "%b%s%b" "$color" "$word" "$NC"
}

newline() {
    printf '=%.0s' $(seq 1 50)
    printf '\n%.0s' $(seq 1 2)
}


set_base_paths () {
    CONFIG_DIR="$HOME/.config"
    CUR_DIR="$(dirname "$(realpath "$0")")"
}


install_configs() {
    IFS=';' 
    for config in $configs; do
        printf "%s\n" "$(color "=== Linking $config ===" "$GREEN")"
        ln -s "$PWD"/"$config" "$CONFIG_DIR"
    done

    printf "%s\n"  "$(color "=== Setting up zshenv ===" "$GREEN")"

    if [ -f ~/.zshenv ]; then 
        printf "%s\n"  "$(color "=== REMOVE ~/.zshenv before continuing ===" "$RED")"
        exit 1
    fi

        cat > ~/.zshenv << 'EOF'
ZDOTDIR=$HOME/.config/zsh

if [ -e "$ZDOTDIR/.zshenv" ]; then
    . "$ZDOTDIR/.zshenv"
fi

EOF
}

uninstall_configs() {
    IFS=';' 
    for config in $configs; do
        printf "%s\n" "$(color "=== Unlinking $config ===" "$RED")"
        unlink $CONFIG_DIR/$config
    done

    if [ -f ~/.zshenv ]; then
        printf "%s\n" "$(color "=== REMOVING ~/.zshenv ===" "$RED")"
        rm ~/.zshenv
    fi
}

colors
set_base_paths

parse_input() {

    if [ -z "$1" ];then
        set -- '-h'
    fi

    while [ ! -z "$1" ]; do
        case $1 in
            "-i"|"--install")
                install_configs
                shift
                ;;
            "-u"|"--uninstall")
                uninstall_configs
                shift
                ;;
            *)
                printf "Find below the docs\n"
                printf "\t-h|--help to see the docs\n"
                printf "\t-i|--install to install all the configuration files\n"
                printf "\t-u|--uninstall to uninstall all the configuration files\n"
                shift
        esac
    done

}

parse_input "$@"



