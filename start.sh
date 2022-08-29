#!/usr/bin/env bash
# Script to jumpstart a macbook with ansible 

function uninstall() {
    echo "${RED}WARNING : This will remove homebrew and all applications installed through it"
    echo -n "are you sure you want to do that? [y/n] : ${NORMAL}"
    read confirmation

    if [ "$confirmation" == "y" ]; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"
        return 0
    else
        echo "Cancelling Uninstall. No changes were made"
        return 0
    fi
}

function install() {
    
    echo "${GREEN}${BOLD}========================"
    echo "Setting up the macbook"
    echo "========================${NORMAL}"
    
    echo "${BLUE}Installing xcode command line tools...${NORMAL}"
    xcode-select --install

    # check if user is member of wheel group
    if [ $(id -Gn | grep -c 'wheel') -eq 0 ]; then
      echo "${BLUE}${BOLD}Enter password for sudo access to add user to 'wheel' group${NORMAL}"
      if [ "$(sudo dseditgroup -o read wheel 2>/dev/null)" ]
      then
          printf "%s\n" "Adding user to wheel group..."
          sudo dseditgroup -o edit -a $(whoami) -t user wheel
          sudo -k
      else
          printf "%s\n" "ERROR: No wheel group found. Exiting." >&2
          exit 1
      fi
    fi

    if ! command -v brew &>/dev/null; then
      echo "${BLUE}Installing Homwebrew, follow the instructions...${NORMAL}"

      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    else
        echo "${YELLOW}${BOLD}You already have Homebrew installed...${NORMAL}"
    fi

    if [ "$(uname -m)" == "arm64" ]; then
      if [[ :$PATH: != *:"/opt/homebrew/bin":* ]] ; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
      fi
    else
      if [[ :$PATH: != *:"/opt/homebrew/bin":* ]] ; then
        echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/usr/local/bin/brew shellenv)"
      fi
    fi

    brew update --force --quiet
    chmod -R go-w "$(brew --prefix)/share/zsh"

    if ! command -v ansible $>/dev/null; then
        echo "${BLUE}Installing Ansible...${NORMAL}"

        brew install ansible

    else
        echo "${YELLOW}${BOLD}You already have Ansible installed...${NORMAL}"
    fi

    echo "${BLUE}Running ansible-pull on remote playbook in verbose mode.${NORMAL}"
    ansible-pull --ask-become-pass --verbose --url https://github.com/raganw/macbook-setup.git

    echo "${BLUE}Setup repo has been cloned to ~/Developer/macbook-setup${NORMAL}"
    echo "${BLUE}run "zsh -l" to restart zsh with new config${NORMAL}"
}

function initialize() {
    BLACK=$(tput setaf 0)
    RED=$(tput setaf 1)
    GREEN=$(tput setaf 2)
    LIME_YELLOW=$(tput setaf 190)
    YELLOW=$(tput setaf 3)
    POWDER_BLUE=$(tput setaf 153)
    BLUE=$(tput setaf 4)
    MAGENTA=$(tput setaf 5)
    CYAN=$(tput setaf 6)
    WHITE=$(tput setaf 7)
    BOLD=$(tput bold)
    NORMAL=$(tput sgr0)
    BLINK=$(tput blink)
    REVERSE=$(tput smso)
    UNDERLINE=$(tput smul)
}

function main() {
    local EXIT_VAL=0
    # initialization
    initialize
    echo "${BLUE}Initialization complete.${NORMAL}"

    if [ "$1" == "uninstall" ]
    then
        uninstall
    fi

    if install
    then
        echo "${GREEN}Installed successfully${NORMAL}"
    else
        echo "${RED}Install Failed${NORMAL}"
        EXIT_VAL=1
    fi
    exit ${EXIT_VAL}
}


# call the main executable function
main "$@"

