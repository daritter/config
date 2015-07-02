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

#Need no stinking version check for tools
export BELLE2_NO_TOOLS_CHECK=true
#... unless we want to of course
if [ "$1" == "check" ]; then
    unset BELLE2_NO_TOOLS_CHECK
fi

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

#Not having this makes life meaningless
export EDITOR=vim
if [ "$1" != "gdb" ]; then
    #Makes gdb work
    export PYTHONHOME=$BELLE2_TOOLS/virtualenv
    #Make sure we find the third party packages like numpy, ipython on ubuntu
    prepend_path PYTHONPATH ${BELLE2_TOOLS}/python/lib/python2.7
    append_path PYTHONPATH "/usr/local/lib/python2.7/dist-packages"
    append_path PYTHONPATH "/usr/lib/python2.7/dist-packages"
    append_path PYTHONPATH "/usr/lib/pymodules/python2.7"
    #Remove duplicates from path because reasons
    clean_path PATH
    clean_path LD_LIBRARY_PATH
fi

alias scons="scons -DQ"

#Make prompt more colorful
export PS1='\t [\[\033[0;32m\]\h\[\033[0m\]:\w]\$ '
export SETUP='(B2)'
