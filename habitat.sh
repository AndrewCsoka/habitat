#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

correct_usage () {
  echo "Correct usage:"
  echo "habitat (-c|--config) <configfile> [--no-web]"
}

while [[ $# -gt 1 ]]
do
  key="$1"

  case $key in
      -c|--config)
      CONFIG_FILE="$2"
      shift
      ;;

      *)
      # unknown option
      ;;

  esac
  shift
done

if [ ! -n "$CONFIG_FILE" ]; then
  echo "ERROR: no config file specified"
  correct_usage
  exit 1;

elif [ ! -f "$CONFIG_FILE" ]; then
  echo "ERROR: $CONFIG_FILE does not exist"
  echo "This should be a habitat config file"
  correct_usage
  exit 1;

else
  # Source config file
  echo "Sourcing config file: $CONFIG_FILE"
  . $CONFIG_FILE

fi


main () {

  if [ -n "$MUTE_SPEAKERS" ]; then
    mute_speakers
  fi

  if [ -n "$PRIMARY_MONITOR" ]; then
    select_primary_monitor
  fi

  if [ -n "$SECONDARY_MONITOR" ] && [ -n "$SECONDARY_MONITOR_RESOLUTION" ]; then
    select_resolution $SECONDARY_MONITOR $SECONDARY_MONITOR_RESOLUTION
  fi

  if [ -n "$PROGRAMS" ]; then
    start_programs
  fi

  if [ -n "$WEBPAGES" ]; then
    start_chrome
  fi

  if [ "$BLUETOOTH" == "true" ]; then
    start_bluetooth
  fi

  if [ -n "$TODO_LIST" ]; then
    cat_todo_list
  fi

  # Show desktop / minimise all
  wmctrl -k on

}

mute_speakers () {

    MUTE_RESULT=$(amixer set Master mute | grep off)
    if [[ $MUTE_RESULT == *"off"* ]]
    then
      tick "Audio muted"
    else
      fail "Audio muted"
    fi
}


select_resolution () {

    monitor=$1
    resolution=$2
    xrandr --output $monitor --mode $resolution

    if [ $? -eq 0 ]
    then
      tick "$monitor set to $resolution"
    else
      fail "$monitor set to $resolution"
    fi

}

select_primary_monitor () {

  # Select Primary Monitor
  MONITORS=$(xrandr --prop | grep "[^dis]connected" | cut --delimiter=" " -f1)
  if [[ $MONITORS == *"$PRIMARY_MONITOR"* ]]
  then
    echo $PRIMARY_MONITOR | monitor-switcher.sh > /dev/null 2>&1;
    MON_RESULT=$(xrandr --prop | grep "$PRIMARY_MONITOR")
    if [[ $MON_RESULT == *"primary"* ]]
    then
      tick "$PRIMARY_MONITOR is now primary monitor"
    else
      fail "$PRIMARY_MONITOR is now primary monitor"
    fi

    if [ -n "$PRIMARY_MONITOR_RESOLUTION" ]; then
      select_resolution $PRIMARY_MONITOR  $PRIMARY_MONITOR_RESOLUTION
    fi

  else
    echo -e "${RED}*** $PRIMARY_MONITOR is not connected ***${NC}"
  fi
}

start_programs () {

  # Start Programs
  for i in "${PROGRAMS[@]}"
  do
    startme $i
  done
}

start_chrome () {

  # Start Chrome with profile & pages
  google-chrome \
      $WEBPAGES \
      --profile-directory="Profile 1" \
      > /dev/null 2>&1 &

  if [ $? -eq 0 ]
  then
    tick "chrome"
  else
    fail "chrome"
  fi
}

start_bluetooth () {

  rfkill unblock bluetooth

  if [ $? -eq 0 ]
  then
    tick $1
  else
    fail $1
  fi

}

cat_todo_list () {

  # cat todo list to screen
  echo "------------------------------"
  echo "*** Here is your todo list ***"
  echo "$TODO_LIST"
  echo "------------------------------"
  eval cat $TODO_LIST
}


startme () {

  pgrep $1 > /dev/null 2>&1
  if [ $? -ne 0 ]
  then
    nohup $1 > /dev/null 2>&1 &

    pgrep $1 > /dev/null 2>&1

    if [ $? -eq 0 ]
    then
      tick $1
    else
      fail $1
    fi

  else
    tick $1
  fi

}

tick () {
  echo -e "${GREEN}\xE2\x9c\x94${NC} $1"
}

fail () {
  echo -e "${RED}\xE2\x9c\x98${NC} $1"
}

main "$@"
