#Need no stinking version check for tools
export BELLE2_NO_TOOLS_CHECK=true
#... unless we want to of course
if [ "$1" == "check" ]; then
    unset BELLE2_NO_TOOLS_CHECK
fi

export BELLE2_BACKGROUND_DIR=~/belle2/bkg/
export GIT_AUTHOR_EMAIL=martin.ritter@desy.de

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

# if [ -n $BELLE2_DISTCC ] && [ -f /usr/bin/distcc ]; then
    # mkdir -p $BELLE2_LOCAL_DIR/bin/distcc
    # for shadow in gcc g++ gfortran rootcling ld; do
        # ln -sfT /usr/bin/distcc $BELLE2_LOCAL_DIR/bin/distcc/$shadow;
    # done
    # # make sure path comes before externals
    # prepend_path PATH $BELLE2_LOCAL_DIR/bin/distcc/

    # export DISTCC_DIR=/var/run/user/$UID/distcc
    # export DISTCC_COMMON="--localslots=8 --localslots_cpp=40"
    # mkdir -p $DISTCC_DIR

    # distcc_remote() {
        # export DISTCC_HOSTS="$DISTCC_COMMON kuhrios/40,lzo"
    # }
    # distcc_local() {
        # export DISTCC_HOSTS="$DISTCC_COMMON localhost/8"
    # }
    # distcc_local
# fi

if hash ccache 2>/dev/null; then
    mkdir -p $BELLE2_LOCAL_DIR/bin/ccache
    for shadow in gcc g++ cc c++; do
        ln -sfT `which ccache` $BELLE2_LOCAL_DIR/bin/ccache/$shadow
    done
    prepend_path PATH $BELLE2_LOCAL_DIR/bin/ccache
fi

#Now let's remove the useless file catalog things and database caches
find -name Belle2FileCatalog.xml -delete
find -name centraldb -exec rm -fr {} +

#Done here, go back home
popd > /dev/null

alias scons="scons -DQ"
alias bcd="cd $BELLE2_LOCAL_DIR"

#Make prompt more colorfulc and add b2 option
export PS1='\[\e]0;[B2:${BELLE2_OPTION}] \h: \w\a\]\t [\[\033[0;32m\]\h\[\033[0m\]:\w]\$ '
