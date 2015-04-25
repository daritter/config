# If not running interactively, don't do anything
[ -z "$PS1" ] && return

export SOFTWARE_WORK=~/work
export SOFTWARE_LOCAL=~/local
export PATH=~/.local/bin:$SOFTWARE_WORK/bin:$SOFTWARE_LOCAL/bin:$PATH
export LD_LIBRARY_PATH=$SOFTWARE_WORK/lib:$SOFTWARE_LOCAL/lib:$LD_LIBRARY_PATH
export PYTHONPATH=$SOFTWARE_WORK/python:$SOFTWARE_LOCAL/lib/python2.7/site-packages
export TEXMFHOME=$SOFTWARE_WORK/texmf
export EDITOR=vim

# don't put duplicate lines in the history. See bash(1) for more options
export HISTCONTROL=ignoredups
# append to the history file, don't overwrite it
shopt -s histappend
export HISTSIZE=1000
export HISTFILESIZE=5000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(lesspipe)"
export LESS="FRSXQ"

function prompt_command () {
    RETURN=$?
    if [ $RETURN -ne 0 ]; then
        echo -e "\nreturncode: \033[0;31m$RETURN\033[00m";
    fi
    echo -ne "\033]0;${SETUP}${HOSTNAME}: ${PWD/#$HOME/\~}\007"
    return $RETURN
}
case "$TERM" in
xterm*|rxvt*)
    PROMPT_COMMAND="prompt_command"
    ;;
*)
    ;;
esac
PROMPT_DIRTRIM=3
PS1='\t [\h:\w]\$ '

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

# enable texlive distribution and check more than one directory
for TEXLIVE in ~/local/texlive /usr/local/texlive/2014; do
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

function alert(){
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
