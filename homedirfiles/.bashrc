#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Stuff for exa
export EXA_ICON_SPACING=2
# files, dirs, links, executables, links with not target
clr="reset:ex=32;01:di=32:ln=04;34:or=32:lp=34:fi=00"

# user permission bits
clr=$clr":ur=00:uw=00:ux=32;01:ue=00"

# group
clr=$clr":gr=00:gw=00:gx=00"

# others
clr=$clr":tr=00:tw=00:tx=00"

# filesize number and color < 1KB
clr=$clr":nb=00:ub:00"

#  1KB < size < 1MB
clr=$clr":nk=00;01:uk=00;01"

# 1 MB < size < 1 GB
clr=$clr":nm=32:um=32"

# 1 GB < size < 1 TB
clr=$clr":ng=32:ug=34"

# git
clr=$clr":ga=32;01:gm=36;01:gd=31;01:gv=38;5;226"

# date, user 
clr=$clr":da=0:uu=32"


# markdow
clr=$clr":*.md=00:README.md=38;5;226;04"

export EXA_COLORS=$clr

alias ls='exa --icons --git --group-directories-first'
alias lsa='exa --icons --git -lah'
alias lst='exa --icons --tree'
alias lsta='exa --icons --tree --long --git'
alias n='nvim'
alias pacsyu='sudo pacman -Syu' # update only standard pkgs
alias pacs='sudo pacman -S'
alias pacrs='sudo pacman -Rs'
alias pacown='pacman -Qo'

alias neofetch='neofetch --colors 4 2 1 2 8 4 --ascii_colors 2 4'

force_color_prompt=yes
# PS1='[\u@\h \W]\$ '
PS1='\[\033[1;32m\]シンジくん\[\033[1;30m\]@\[\033[1;34m\]初号機:\[\033[1;36m\]\w\[\033[1;30m\]∮\[\033[0m\] '
