#!/bin/bash

# export TERM=xterm-kitty
nohup obsidian &
nvim -c "WorkspacesOpen wiki"
