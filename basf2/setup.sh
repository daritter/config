export BELLE2_SYSTEM_PYTHON=1
#Need no stinking version check for tools
export BELLE2_NO_TOOLS_CHECK=true
#... unless we want to of course
if [ "$1" == "check" ]; then
    unset BELLE2_NO_TOOLS_CHECK
fi

export BELLE2_BACKGROUND_DIR=~/belle2/bkg/

# Find out where we want to be
BELLE2_LOCAL_DIR=`dirname $BASH_SOURCE`
# and go there
pushd $BELLE2_LOCAL_DIR > /dev/null
#Let's open the tool box
source ../tools/setup_belle2.sh
#Debug mode is for loosers and people with to much cpu power
setoption opt
#It's a TRAP ... I mean setup ... never mind
setuprel
#Done here, go back home
popd > /dev/null

alias scons="scons -DQ"
alias bcd="cd $BELLE2_LOCAL_DIR"

#Make prompt more colorfulc and add b2 option
export PS1='\[\e]0;[B2:${BELLE2_OPTION}] \h: \w\a\]\t [\[\033[0;32m\]\h\[\033[0m\]:\w]\$ '
