# If not running interactively, don't do anything
[ -z "$PS1" ] && return

export LC_CTYPE="en_US.UTF-8"
export LC_NUMERIC="en_US.UTF-8"
export LC_TIME="en_DK.UTF-8"
export LC_COLLATE="en_US.UTF-8"
export LC_MONETARY="en_IE.UTF-8"
export LC_MESSAGES="en_US.UTF-8"
export LC_PAPER="en_GB.UTF-8"
export LC_NAME="en_US.UTF-8"
export LC_ADDRESS="en_US.UTF-8"
export LC_TELEPHONE="en_US.UTF-8"
export LC_MEASUREMENT="en_DK.UTF-8"
export LC_IDENTIFICATION="en_US.UTF-8"

export SOFTWARE_WORK=~/work
export SOFTWARE_LOCAL=~/local
export PATH=$SOFTWARE_WORK/bin:$SOFTWARE_LOCAL/bin:$PATH
export LD_LIBRARY_PATH=$SOFTWARE_WORK/lib:$SOFTWARE_LOCAL/lib:$LD_LIBRARY_PATH
export PYTHONPATH=$SOFTWARE_WORK/python
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
    echo -ne "\033]0;${HOSTNAME}: ${PWD/$HOME/~}\007"
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

export MPI=ritter@pcbelle03.mpp.mpg.de
export KEK=ritter@login.cc.kek.jp
export AFS=/afs/ipp/home/m/mritter
export BH=/afs/ipp/mpp/belle

alias afslogin='klog.afs -principal mritter -cell ipp-garching.mpg.de'
alias rzg='ssh -Y mritter@mpiui1.t2.rzg.mpg.de'
alias vnc='xtightvncviewer -encodings "copyrect tight hextile  zlib  corre  rre raw"'

function alert(){
    ssh -Y pcbelle03 "DISPLAY=:0 notify-send -u critical -t 1000 -i $([ $? = 0 ] && echo terminal || echo error)\
                      \"$(history|tail -n1| sed -e 's/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//')\""
}
