# .bashrc

# Source global definitions

if [ -f /etc/bashrc ]; then
    source /etc/bashrc
fi

# Colors

COLOR_RESET='\[\033[0m\]'
COLOR_RED='\[\033[38;5;196m\]'
COLOR_BLUE='\[\033[38;5;39m\]'
COLOR_GREEN='\[\033[38;5;118m\]'
COLOR_YELLOW='\[\033[38;5;226m\]'
COLOR_ORANGE='\[\033[38;5;214m\]'
COLOR_CYAN='\[\033[38;5;51m\]'
COLOR_MAGENTA='\[\033[38;5;201m\]'

# Prompt

if [ -f /etc/os-release ]; then
    DISTRO_ID=$(bash --norc -c 'source /etc/os-release && echo ${PRETTY_NAME}')
    DISTRO_COLOR="\[\033[$(bash --norc -c 'source /etc/os-release && echo ${ANSI_COLOR}')m\]"
else
    DISTRO_ID="Unknown"
fi

if [ -z "$DISTRO_COLOR" ]; then
    DISTRO_COLOR=$COLOR_RESET
    if echo $DISTRO_ID | grep -q "Red Hat Enterprise Linux"; then
        DISTRO_COLOR=$COLOR_RED
    elif echo $DISTRO_ID | grep -q "Fedora"; then
        DISTRO_COLOR=$COLOR_MAGENTA
    elif echo $DISTRO_ID | grep -q "Ubuntu"; then
        DISTRO_COLOR=$COLOR_ORANGE
    elif echo $DISTRO_ID | grep -q "Raspbian"; then
        DISTRO_COLOR=$COLOR_GREEN
    fi
fi

PS1="\${debian_chroot:+(\$debian_chroot)}$COLOR_BLUE\u$COLOR_RESET@$DISTRO_COLOR\h$COLOR_RESET(\j):$COLOR_BLUE\w$COLOR_RESET\n\$ "

# Variables

export GPG_TTY=$(tty)
HISTCONTROL=ignoreboth

# Aliases

alias ls='ls --color=auto'
alias ll='ls -lha'
alias l='ls -lh'
alias grep='grep --color=auto'
alias lower='tr "[:upper:]" "[:lower:]"'
alias upper='tr "[:lower:]" "[:upper:]"'

# Functions

function amap {
    # Aggressive nmap port scan
    TARGET=$1
    shift
    PORTS=$1
    shift
    nmap -n -T4 -Pn --max-rtt-timeout 50ms --initial-rtt-timeout 50ms --min-hostgroup 512 -oG - -open -p $PORTS $TARGET "$@"
}

function color {
    # Colorize stderr
    (set -o pipefail;"$@" 2>&1>&3|sed $'s,.*,\e[31m&\e[m,'>&2)3>&1
}

function hostrev {
    if [[ $# -ne 1 ]]; then
        echo Usage: ${FUNCNAME[0]} hostname
        return 1
    fi

    if [[ $1 =~ \. ]]; then
        host=$1
    else
        host=$1.`hostname -d`
    fi

    for ip in $(dig +noall +answer $host | awk '{print $NF}'); do dig +noall +answer -x $ip; done | awk '{print $NF}' | sort
}

function s_client {
    if [ -z "$1" ]; then
        echo USAGE: s_client HOST [PORT]
        return 1
    fi
    local HOST="${1}"
    local PORT=${2:-443}
    openssl s_client -connect "$HOST":"$PORT" < /dev/null 2> /dev/null | openssl x509 -noout -dates -subject -issuer -ext subjectAltName
}

# If this is an xterm set the title to user@host:dir
case "$TERM" in
    xterm*|rxvt*)
        PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD/$HOME/~}\007"'
        ;;
esac

