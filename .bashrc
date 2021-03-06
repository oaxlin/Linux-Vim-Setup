# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# Look for my custom scripts
PATH=$PATH:$HOME/bin
export PATH
PS1='[\j \u@\h:\w] '
export PS1

# Make sure our ssh-agent is running (useful for windows linux subsystem)
if [ -z "$SSH_AUTH_SOCK" ]; then
    if [ -f ".ssh/id_rsa" ]; then
        echo -n 'SSH ';
        eval $(ssh-agent -s)
        echo 'Remember to ssh-add your keys';
    fi
fi

WINDOW_TITLE_PREFIX='';
if [ -e ~/.window_title_prefix ]
then
        WINDOW_TITLE_PREFIX=`cat ~/.window_title_prefix`;
fi

# Stuff for git
#
function git-branch-prompt {
    local branch=`git symbolic-ref HEAD 2>/dev/null | cut -d"/" -f 3,4`
    if [ $branch ]; then
        local untracked=`git status -s`
        if [ "$untracked" != "" ]; then
            local gitdiff=`git diff --name-only`
            if [ "$gitdiff" != "" ]; then
                printf "\[\e[1;31m\]%s\[\e[0m\] " $branch;
            else
                local gitnew=`git diff --cached --name-only --diff-filter=A`
                if [ "$gitnew" != "" ]; then
                    printf "\[\e[1;31m\]%s\[\e[0m\] " $branch;
                else
                    printf "\[\e[1;33m\]%s\[\e[0m\] " $branch;
                fi
            fi
        else
            printf "\[\e[1;32m\]%s\[\e[0m\] " $branch;
        fi
    elif [ -e 'CVS/Root' ]; then
        printf "\[\e[1;32m\]%s\[\e[0m\] " 'CVS';
    fi
}
function get_prompt {
    PS1="$(printf "%$((COLUMNS-1))s\r")\j $(git-branch-prompt)\u@\h:\w] "
}

#PS1='$(printf "%$((COLUMNS-1))s\r")\j$(git-branch-prompt 2>/dev/null) \u@\h:\w] '
PROMPT_COMMAND='~/bin/bash_newline;echo -ne "\033]0;${WINDOW_TITLE_PREFIX}${USER}@${HOSTNAME}: ${PWD/#$HOME/~}\007";get_prompt'
shopt -s promptvars

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=10000
HISTFILESIZE=20000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi
