#!/bin/bash
OPTS=`getopt -o oc --long open,close -- "$@"`

if [ $? != 0 ] ; then echo "Failed parsing options." >&2 ; exit 1 ; fi

#echo "$OPTS"
eval set -- "$OPTS"

# Helper functions
open_terminal() {
  xfce4-terminal -T $1 --color-bg $2 &
}

get_window_id() {
  echo $(xdotool search --sync --name $1)
}

resize_window() {
  xdotool windowsize $1 $2 $3
}

move_window() {
  xdotool windowmove $1 $2 $3
}

# Color codes
purple='#610B5E'
blue='#0B0B61'
red='#610B0B'
green='#173B0B'

# Terminal titles
titles=("top-left" "top-right" "bot-left" "bot-right")
colors=($purple $blue $red $green)

# Retrieve window status
windows=()
for title in ${titles[@]}; do
  window=$(xdotool search --name ${title})
  if [ -z $window ]; then
    window="closed"
  fi
  windows+=($window)
done

# Loop over arguments
while true; do
  case "$1" in
    -o | --open )
      # Open terminals
      for i in {0..3}
      do
        if [ "${windows[$i]}" = "closed" ]; then
          open_terminal ${titles[i]} ${colors[i]}
        fi
      done

      # Get screen resolution
      xyres=$(xrandr --current | grep '*' | uniq | awk '{print $1}')
      xfull=$(echo $xyres | cut -d 'x' -f1)
      yfull=$(echo $xyres | cut -d 'x' -f2)
      xhalf=$((xfull/2))
      yhalf=$((yfull/2))
      ymenu=25

      # Update window ids
      for i in {0..3}
      do
        if [ "${windows[$i]}" = "closed" ]; then
          windows[$i]=$(get_window_id ${titles[i]})
        fi
        # Resize windows
        resize_window ${windows[$i]} $xhalf $((yhalf-ymenu))
      done

      # Move windows
      move_window ${windows[0]} 0 0
      move_window ${windows[1]} $xhalf 0
      move_window ${windows[2]} 0 $((yhalf+ymenu))
      move_window ${windows[3]} $xhalf $((yhalf+ymenu))

      shift ;;
    -c | --close )
      for window in ${windows[@]}; do
        if [ "$window" != "closed" ]; then
          #xdotool windowclose $window
          wmctrl -ic $window
        fi
      done
      shift ;;
    -- ) shift; break ;;
    * ) break ;;
  esac
done

#echo 'exit'
exit;