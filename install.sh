#!/bin/bash
set -e

pushd `dirname $0` > /dev/null
SCRIPTPATH=`pwd`

# make vim tmp dir
mkdir -p vim/tmp

cat > ~/.config/autostart/evincesync.desktop <<EOT
[Desktop Entry]
Type=Application
Exec=$SCRIPTPATH/bin/evincesync
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=evince sync
Comment=allows to navigate between evince and vim using synctex and dbus
EOT

function install_link () {
    src=$1
    dest=$2
    if [[ -e $dest && ! -L $dest ]]; then
        echo mkdir -p bak
        echo mv $dest bak/$src
    fi
    echo ln -sf `pwd`/$src $dest
}

for file in bashrc ctags.conf gitconfig vim vimrc; do
    install_link $file ~/.$file
done

install_link ssh_config ~/.ssh/config

if [[ -e ~/belle2/software ]]; then
    install_link basf2/setup.sh ~/belle2/software/setup.sh
    install_link basf2/gitignore ~/belle2/software/.gitignore
    install_link basf2/githooks ~/belle2/software/.git/hooks
    install_link basf2/ycm_extra_conf.py ~/belle2/software/.ycm_extra_conf.py
fi

popd > /dev/null
