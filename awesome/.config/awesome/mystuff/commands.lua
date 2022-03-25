return{
  GET_VOLUME = "pamixer --get-volume && pamixer --get-mute",
  INC_VOLUME = "pamixer -i 2",
  DEC_VOLUME = "pamixer -d 2",
  TOG_VOLUME = "pamixer -t",
  TOG_PLAY = "playerctl play-pause",
  MEDIA_NEXT = "playerctl next",
  MEDIA_PREV = "playerctl previous",
  IDLE_MPV = "mpv --player-operation-mode=pseudo-gui",
  YT_MUSIC = "brave --profile-directory=Default --app-id=cinhimbnkkaeohfgghhklpknlkffjgod",
}
