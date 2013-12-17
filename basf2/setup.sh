if [ -z ${BELLE2_CLEAN_PATH+set} ]; then
    export BELLE2_CLEAN_PATH=$PATH
    export BELLE2_CLEAN_PYTHONPATH=$PYTHONPATH
    export BELLE2_CLEAN_LDPATH=$LD_LIBRARY_PATH
fi

function clean_env () {(
    # set paths to pre-belle2 values
    export PATH=$BELLE2_CLEAN_PATH
    export PYTHONPATH=$BELLE2_CLEAN_PYTHONPATH
    export LD_LIBRARY_PATH=BELLE2_CLEAN_LDPATH
    # decativate python virtual_env
    deactivate
    #run command
    $@
)}

export BELLE2_NO_TOOLS_CHECK=true
if [ "$1" == "check" ]; then
    unset BELLE2_NO_TOOLS_CHECK
fi
DIR=`dirname $BASH_SOURCE`
pushd $DIR > /dev/null
. ../tools/setup_belle2.sh

#setextoption opt
setoption opt
setuprel
popd > /dev/null
export EDITOR=vim

alias vim="clean_env vim"
alias gvim="clean_env gvim"
alias ipython="clean_env python"
