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


set_base_paths () {
    config_directory="$HOME/.config"
    current_directory=$(dirname $(realpath "$0"))

}

build_parents() {

    set -- "tmux" "zsh" "wezterm"

    for parent_directory in "$@"; do
        if [ ! -e "$config_directory/$parent_directory" ]; then
            mkdir "$config_directory/$parent_directory"
            printf "%bCreating%b parent_directory %b%s%b" "$RED" "$NC"  "$GREEN" "$config_directory/$parent_directory" "$NC"
        fi
    done

}

install_configs() {
    set -- "nvim" "tmux/tmux.conf" "zsh/.zprofile"  "zsh/.zshrc" "zsh/.zshenv" ".profile" ".bashrc" "wezterm/wezterm.lua"
    success=0
    failure=0
    total=$#

    for configuration_file in "$@"; do
        source_path="$current_directory/$configuration_file"

        case $configuration_file in
            "zsh/.zshenv")
                destination_path="$HOME/.zshenv"
                ;;
            *)
                destination_path="$config_directory/$configuration_file"
                ;;
        esac


        if [ -e $destination_path ]; then
            printf "%s already exists\n"  "$destination_path"
            printf "%bFailiure%b . Remove old config before continuing (e.g $configuration_file)\n" "${RED}" "${NC}"
            failure=$((failure + 1))
            newline
        else
            printf "%bSuccess%b . Linked %s  to %s.\n" "${GREEN}" "${NC}" "$destination_path" "$source_path"
            success=$((success + 1))
            ln -s "$source_path" "$destination_path"
        fi
    done

    printf "%bsucceded%b %s " "${GREEN}" "${NC}" "$success/$total"  
    printf "%bfailed%b %s\n" "${RED}" "${NC}" "$failure/$total"
}

uninstall_configs() {
    set -- "nvim" "tmux/tmux.conf" "zsh/.zprofile"  "zsh/.zshrc" "zsh/.zshenv" ".profile" ".bashrc" "wezterm/wezterm.lua"

    for configuration_file in "$@"; do

        case $configuration_file in
            "zsh/.zshenv")
                destination_path="$HOME/.zshenv"
                ;;
            *)
                destination_path="$config_directory/$configuration_file"
                ;;
        esac

        unlink "$destination_path"
    done
}

colors
set_base_paths
build_parents

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



