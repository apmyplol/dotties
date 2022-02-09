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

# Set stuff for Wacom driver
# TODO: Run wacom script and change middle mouse clicc behavior

xrandr --output DVI-I-0 --off --output DVI-I-1 --off --output HDMI-0 --primary --mode 1920x1080 --pos 0x623 --rotate normal --output DP-0 --mode 1920x1200 --pos 1920x0 --rotate left --output DP-1 --off --output DVI-D-0 --off &
#fcitx5 &
redshift &
anki &
exec awesome
