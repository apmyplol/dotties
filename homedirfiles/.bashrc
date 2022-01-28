#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
force_color_prompt=yes
#PS1='[\u@\h \W]\$ '
PS1='\[\033[1;32m\]\u\[\033[1;36m\]@\[\033[1;34m\]\h:\[\033[1;34m\]\w\[\033[1;36m\]\$\[\033[0m\] '
