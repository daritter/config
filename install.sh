#!/bin/bash
set -e

pushd `dirname $0` > /dev/null
SCRIPTPATH=`pwd`

# make vim tmp dir
mkdir -p vim/tmp

mkdir -p ~/.config/autostart
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
        mkdir -p bak
        mv $dest bak/$src
    fi
    ln -sfT `pwd`/$src $dest
}

for file in bashrc ctags.conf gitconfig vim vimrc gdbinit; do
    install_link $file ~/.$file
done

install_link ssh_config ~/.ssh/config

if [[ -e ~/belle2/software ]]; then
    install_link basf2/setup.sh ~/belle2/software/setup.sh
fi

popd > /dev/null
