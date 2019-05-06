# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

#Make sure that there are no duplicates in path variables
#Optionally, the arguments 2 and 3 are prepended and appended respectively for
#use with append_path and prepend_path
function clean_path (){
    eval OLD_PATH=\$$1
    #This line is kind of long and awkward ...
    NEW_PATH=`echo "$2$OLD_PATH$3" | awk -F: '{for (i=1;i<=NF;i++) { if ( !x[$i]++ ) { if(i>1) printf(":"); printf("%s",$i); }}}'`
    export $1=$NEW_PATH
}
#Append value to path variable and remove duplicates
function append_path (){
    clean_path $1 "" :$2
}
#Prepend value to path variable and remove duplicates
function prepend_path (){
    clean_path $1 $2: ""
}

export SOFTWARE_WORK=~/work
export SOFTWARE_LOCAL=~/local
prepend_path PATH ~/.local/bin:$SOFTWARE_WORK/config/bin:$SOFTWARE_LOCAL/bin
prepend_path LD_LIBRARY_PATH $SOFTWARE_LOCAL/lib
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
PROMPT_END='$'
PROMPT_INFO='\w'
if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ] || [ -n "$SSH_CONNECTION" ]; then
  PROMPT_INFO="\h:\w"
  if [ $(whoami) != 'ritter' ]; then
    PROMPT_INFO="\u@\h:\w"
  fi
fi
PS1="\[\e[1;90m\][$PROMPT_INFO]\$PROMPT_END\[\e[0m\] "

case "$TERM" in
xterm*|rxvt*)
    PROMPT_COMMAND="prompt_command"
    PS1="\[\e]0;$PROMPT_INFO\$PROMPT_END\a\]$PS1"
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
for TEXLIVE in ~/local/texlive /usr/local/texlive/2017 /usr/local/texlive/2016 /usr/local/texlive/2015; do
    if [ -d $TEXLIVE ]; then
        prepend_path PATH $TEXLIVE/bin/x86_64-linux
        export TEXLIVE
        break;
    fi
done

alias vnc='xtightvncviewer -encodings "copyrect tight hextile zlib corre rre raw"'
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
