# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

export SOFTWARE_WORK=~/work
export SOFTWARE_LOCAL=~/local
export PATH=~/.local/bin:$SOFTWARE_WORK/bin:$SOFTWARE_LOCAL/bin:$PATH
export LD_LIBRARY_PATH=$SOFTWARE_WORK/lib:$SOFTWARE_LOCAL/lib:$LD_LIBRARY_PATH
export PYTHONPATH=$SOFTWARE_WORK/python:$SOFTWARE_LOCAL/lib/python2.7/site-packages
export TEXMFHOME=$SOFTWARE_WORK/texmf
export EDITOR=vim

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=5000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

function prompt_command () {
    RETURN=$?
    if [ $RETURN -ne 0 ]; then
        echo -e "\nreturncode: \033[0;31m$RETURN\033[00m";
    fi
    return $RETURN
}

PROMPT_DIRTRIM=3
PS1='\t [\h:\w]\$ '
case "$TERM" in
xterm*|rxvt*)
    PROMPT_COMMAND="prompt_command"
    PS1="\[\e]0;${SETUP}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'
# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# enable texlive distribution and check more than one directory
for TEXLIVE in ~/local/texlive /usr/local/texlive/2015; do
    if [ -d $TEXLIVE ]; then
        export PATH=$TEXLIVE/bin/x86_64-linux:$PATH
        export TEXLIVE
        break;
    fi
done

export AFS=/afs/ipp/home/m/mritter
export BH=/afs/ipp/mpp/belle

alias afslogin='klog.afs -principal mritter -cell ipp-garching.mpg.de'
alias rzg='ssh -Y mritter@mpiui1.t2.rzg.mpg.de'
alias vnc='xtightvncviewer -encodings "copyrect tight hextile zlib corre rre raw"'
alias vim='gvim -v'
alias belle2=". ~/belle2/software/setup.sh"

function my_alert(){
python <<EOT
import re
from gi.repository import Notify

ret = $?
#get last command name, replacing ' with \'
cmd = '$(history 1 | sed "s/'/\\\\'/g")'
#replace the entry number at the beginning and the alert command at the end
cmd = re.sub("^\\s*\\d+\\s*|(;|&&|\\|\\|)\\s*alert\\s*$","", cmd)
#set title and icon according to return value
title = (ret==0) and "finished" or ("failed (%d)" % ret)
icon = (ret==0) and "dialog-information" or "dialog-error"
#send notification
Notify.init("alert")
n = Notify.Notification.new("Command "+ title, cmd, icon)
n.show()
EOT
}
