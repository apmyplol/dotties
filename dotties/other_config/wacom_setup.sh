#!/bin/bash

# TODO: add keyboard shortcuts 
# copy 99-wacom.rules to /etc/udev/rules.d/99-wacom.rules
# and wacom.service to ~/.config/systemd/user/wacom.service
# maybe need to change ExecStart in wacom.service 

# Wait for wacom to be ready
sleep 5

xsetwacom set "Wacom Graphire3 Pen stylus" Mode "Relative"
xsetwacom set "Wacom Graphire3 Pen stylus" Area 0 0 40832 29692
xsetwacom set "Wacom Graphire3 Pen eraser" Mode "Relative"
xsetwacom set "Wacom Graphire3 Pen eraser" Area 0 0 40832 29692

# Set button mappings
xsetwacom set "Wacom Graphire3 Pen stylus" Button 3 "key ctrl z"
xsetwacom set "Wacom Graphire3 Pen stylus" Button 2 "key e"
xsetwacom set "Wacom Graphire3 Pen eraser" Button 1 "key v button +3"

# set smoothness
xsetwacom set "Wacom Graphire3 Pen stylus" RawSample 3
# xsetwacom set "Wacom Graphire3 Pen stylus" Threshold 10
# xsetwacom set "Wacom Graphire3 Pen stylus" PressureCurve 0 10 100 10
