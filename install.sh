#!/bin/sh

colors () {
    GREEN='\033[0;32m'
    RED='\033[0;31m'
    NC='\033[0m' # No Color
}

newline() {
    printf '=%.0s' $(seq 1 50)
    printf '\n%.0s' $(seq 1 2)
}

zshenv() {

    if [ -e "$HOME/.zshenv" ]; then
        printf "Please remmove zshenv before proceding"
    else
        ln -s "$PWD/.zshenv" "$HOME/.zshenv"
    fi
}

set_base_paths () {
    base_directory="$HOME/.config"
}

build_parents() {

    set -- "tmux" "zsh" "wezterm"

    for parent_directory in "$@"; do
        if [ ! -e "$base_directory/$parent_directory" ]; then
            mkdir "$base_directory/$parent_directory"
            printf "%bCreating%b parent_directory %b%s%b" "$RED" "$NC"  "$GREEN" "$base_directory/$parent_directory" "$NC"
        fi
    done

}

config_files() {
    set -- "nvim" "tmux/tmux.conf" ".zprofile" ".profile" "zsh/.zshrc" ".bashrc" "wezterm/wezterm.lua"
    success=0
    failure=0
    total=$#

    for configuration_file in "$@"; do
        if [ -e "$base_directory/$configuration_file" ]; then
            printf "%s already exists\n"  "$base_directory/$configuration_file"
            printf "%bFailiure%b . Remove old config before continuing (e.g $configuration_file)\n" "${RED}" "${NC}"
            failure=$((failure + 1))
            newline
        else
            printf "%bSuccess%b . Linked $base_directory/$configuration_file to %s.\n" "${GREEN}" "${NC}" "$PWD/$configuration_file"
            success=$((success + 1))
            ln -s "$PWD/$configuration_file" "$base_directory/$configuration_file"
        fi
    done
    printf "succeded %s .  failed %s\n" "$success/$total" "$failure/$total"
}


colors
zshenv

set_base_paths
build_parents
config_files


