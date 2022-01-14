#!/bin/sh

userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap

# merge in defaults and keymaps

if [ -f $sysresources ]; then
    xrdb -merge $sysresources
fi

if [ -f $sysmodmap ]; then
    xmodmap $sysmodmap
fi

if [ -f "$userresources" ]; then
    xrdb -merge "$userresources"
fi

if [ -f "$usermodmap" ]; then
    xmodmap "$usermodmap"
fi

# start some nice programs

if [ -d /etc/X11/xinit/xinitrc.d ] ; then
 for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
  [ -x "$f" ] && . "$f"
 done
 unset f
fi

export PATH=$PATH:$HOME/.config/my_scripts
export PATH=$PATH:$HOME/.local/bin
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx

picom --experimental-backends --config $HOME/.config/picom.conf &
nm-applet &
# Set stuff for Wacom driver
# TODO: add keyboard shortcuts and change mouse middle button behaviour
xsetwacom set "Wacom Graphire3 Pen eraser" Mode "Relative"
xsetwacom set "Wacom Graphire3 Pen eraser" Area 0 0 20416 14848
xsetwacom set "Wacom Graphire3 Pen stylus" Mode "Relative"
xsetwacom set "Wacom Graphire3 Pen stylus" Area 0 0 20416 14848

fcitx &
redshift &
exec awesome
