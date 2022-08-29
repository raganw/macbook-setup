#!/bin/bash
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

    if echo ${PYTHON_VERSION} | grep -q '^Python 3\.'
    then
        echo "${BLUE}Python 3 found. Installing pip and ansible globally${NORMAL}"
        sudo bash -c "curl -s https://bootstrap.pypa.io/get-pip.py | python"
        sudo pip install ansible
    else 
        echo "${BLUE}Python 2 found. Installing pip and virtualenv globally${NORMAL}"
        sudo bash -c "curl -s https://bootstrap.pypa.io/pip/2.7/get-pip.py | python"
        sudo pip install virtualenv
        echo "${BLUE}Activating virtualenv and installing ansible in it.${NORMAL}"
        virtualenv ansible-virtualenv
        source ansible-virtualenv/bin/activate
        pip install ansible
    fi

    INSTALLDIR="/tmp/jumpstart-my-macbook-$RANDOM"
    mkdir ${INSTALLDIR}

    git clone https://github.com/raganw/macbook-setup.git ${INSTALLDIR} 
    if [ ! -d ${INSTALLDIR} ]; then
        echo "${RED}Failed to find ${INSTALLDIR}."
        echo "git clone failed${NORMAL}"
        return 1
    else
        cd ${INSTALLDIR} 
        echo "${BLUE}Running ansible playbook in verbose mode.${NORMAL}"
        ansible-playbook -i ./hosts playbook.yml --verbose
        return 0
    fi
}

function initialise() {
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

    # Find the current default python version 
    PYTHON_VERSION=`python -c 'import sys; version=sys.version_info[:3];print("{0}.{1}.{2}".format(*version))'`
    export PYTHON_VERSION
}

function cleanup() {
    echo "${YELLOW}Cleaning up....${NORMAL}"
    echo "${YELLOW}Deactivating virtualenv if being used${NORMAL}"
    [ -z "${VIRTUAL_ENV}" ] && deactivate
    if [ -d ${INSTALLDIR} ]
    then
        rm -Rfv /tmp/${INSTALLDIR}
    fi
    echo "${YELLOW}${BLINK}Cleanup complete. Please handle any error manually...${NORMAL}"
    return
}


function main() {
    local EXIT_VAL=0
    # initialization
    initialise
    echo "${BLUE}Initialisation complete.${NORMAL}"

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
    cleanup
    exit ${EXIT_VAL}
}


# set a trap for cleanup all before process termination by SIGHUBs
trap "cleanup; exit 1" 1 2 3 13 15

# call the main executable function
main "$@"

