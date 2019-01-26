#!/bin/bash

# Config locations
folders="$HOME/.dotfiles/shortcut-sync/folders"
configs="$HOME/.dotfiles/shortcut-sync/configs"

# Output locations
shell_shortcuts="$HOME/.shortcuts"
ranger_shortcuts="$HOME/.config/ranger/shortcuts.conf"
qute_shortcuts="$HOME/.config/qutebrowser/shortcuts.py"

# Shell rc file (i.e. bash vs. zsh, etc.)
shellrc="$HOME/.zshrc"

# Download the shorcut files if not present.
[[ ! -f $folders ]] && curl https://raw.githubusercontent.com/zzzdeb/shortcut-sync/master/folders > "$folders"
[[ ! -f $configs ]] && curl https://raw.githubusercontent.com/zzzdeb/shortcut-sync/master/configs > "$configs"

# Remove
rm -f $shell_shortcuts $ranger_shortcuts $qute_shortcuts

# Ensuring that output locations are properly sourced
(grep "source ~/.shortcuts"  $shellrc)>/dev/null || echo "source ~/.shortcuts" >> $shellrc
(grep "source $HOME/.config/ranger/shortcuts.conf" $HOME/.config/ranger/rc.conf)>/dev/null || echo "source $HOME/.config/ranger/shortcuts.conf" >> $HOME/.config/ranger/rc.conf
(grep "config.source('shortcuts.py')" $HOME/.config/qutebrowser/config.py)>/dev/null || echo "config.source('shortcuts.py')" >> $HOME/.config/qutebrowser/config.py

# directory shortcuts
sed "/^#/d" $folders | awk '{tmp=$1; $1 = ""; print "alias ,"tmp"=\"cd \\\""$0"\\\" && ls -a\""}' | sed 's/ ~/$HOME/'>> $shell_shortcuts
sed "/^#/d" $folders | awk '{tmp=$1; $1=""; print "map ,"tmp" cd "$0"\nmap t"tmp" tab_new "$0"\nmap m"tmp" shell mv -v %s "$0"\nmap Y"tmp" shell cp -rv %s "$0}' >> $ranger_shortcuts
sed "/^#/d" $folders | awk '{tmp=$1; $1 = ""; print "config.bind(\","tmp"\", \"set downloads.location.directory \\\""$0"\\\" ;; hint links download\")"}'| sed 's/ ~\//~\//' >> $qute_shortcuts

# dotfile shortcuts
sed "/^#/d" $configs | awk '{print "alias "$1"=\"$EDITOR "$2"\""}' >> $shell_shortcuts
sed "/^#/d" $configs | awk '{print "map "$1" shell $EDITOR "$2}' >> $ranger_shortcuts
