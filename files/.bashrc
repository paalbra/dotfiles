# .bashrc

# Source global definitions

if [ -f /etc/bashrc ]; then
    source /etc/bashrc
fi

# Prompt

PS1='${debian_chroot:+($debian_chroot)}\[\033[01;31m\]\u@\h\[\033[00m\](\j):\[\033[01;34m\]\w\[\033[00m\]\n\$ '

# Aliases

alias ls='ls --color=auto'
alias ll='ls -lha'
alias l='ls -lh'
alias grep='grep --color=auto'
alias lower='tr "[:upper:]" "[:lower:]"'
alias upper='tr "[:lower:]" "[:upper:]"'

# Functions

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


# If this is an xterm set the title to user@host:dir
case "$TERM" in
    xterm*|rxvt*)
        PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD/$HOME/~}\007"'
        ;;
esac

