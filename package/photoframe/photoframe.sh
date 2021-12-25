#! /bin/bash
CONF_DIR=/data/photoframe
MOUNTPOINT_DAV=/data/photoframe/images_webdav
FOLDER_IMAGES=/data/photoframe/images_local

#File that lists all available photos. Will be overwritten when new files are downloaded
PHOTO_FILE_LIST_FILE=${CONF_DIR}/conf/filelist.txt
PHOTO_FILE_LIST=${PHOTO_FILE_LIST_FILE}
COMPLETE_PHOTO_FILE_LIST=${CONF_DIR}/conf/complete_filelist.txt

NO_IMAGES="/usr/share/photoframe/noimages.png"

ERROR_DIR="/tmp/photoframe"
mkdir -p $ERROR_DIR

SLIDESHOW_DELAY=60
SHUFFLE=false
SHOW_FILENAME=false
SHOW_VIDEOS=false
SMARTFIT=30
CEC_DEVICE_ID=-1

RESUME_DEFAULT_FILELIST_DELAY=60 # delay to resume play only PHOTO_FILE_LIST

GPIO_PIN_NEXT=5 # show next file
GPIO_PIN_PREVIOUS=-1 # show previous file
GPIO_PIN_PLAY=-1 # start/pause rotating images automatically
GPIO_PIN_ALL=6 # switch to COMPLETE_PHOTO_FILE_LIST to show all pictures ()
GPIO_PIN_SHUTDOWN=13
GPIO_ACTION_VALUE=0 # value to identify action, for an pullup the value should be 0, for pulldown 1
SWITCH_TO_ALL_DATETIME=0


if [ -e ${CONF_DIR}/conf/photoframe.conf ]
then
  source ${CONF_DIR}/conf/photoframe.conf
fi

PARAMS_FBV="--noclear --smartfit ${SMARTFIT} --delay 1"

# configure control buttons
function init_gpio_input_pin() {
  if [ "${1}" != "-1" ]
    then
    echo 'configure gpio pin'
    if [ ! -d /sys/class/gpio/gpio${1} ]
    then
      echo ${1} > /sys/class/gpio/export
      echo "in" > /sys/class/gpio/gpio${1}/direction
    fi
  else 
    echo not configuring gpio
  fi
}

init_gpio_input_pin ${GPIO_PIN_NEXT} 
init_gpio_input_pin ${GPIO_PIN_PLAY}
init_gpio_input_pin ${GPIO_PIN_PREVIOUS}
init_gpio_input_pin ${GPIO_PIN_ALL}
init_gpio_input_pin ${GPIO_PIN_SHUTDOWN}


ERROR_TOPIC="";

function error_display {
  TTY=/dev/tty0
  echo -en "\e[H" > $TTY # Move tty cursor to beginning (1,1)
  for f in $ERROR_DIR/*.txt; do
    [[ -f $f ]] || continue
    cat $f > $TTY
  done
}


function error_settopic {
  ERROR_TOPIC=$1.txt;
  > $ERROR_DIR/$ERROR_TOPIC
}

function error_write {
  echo $1 >> $ERROR_DIR/$ERROR_TOPIC
}

num_files=0;
file_num=0;

function get_image {
  local rnd_num
  rnd_num=-1
  local counter
  counter=0

  num_files=0
  if [ -f $PHOTO_FILE_LIST ]
  then
    num_files=$(wc -l "$PHOTO_FILE_LIST" | awk '{print $1}')
  fi

  if [ $num_files -gt 0 ]
  then
    if [ "$SHUFFLE" = true ]
    then
      # sed counts from 1 to N (not 0 to N-1)
      rnd_num=$(( ( $RANDOM % $num_files ) + 1 ))
    else
      # sed counts from 1 to N (not 0 to N-1)
      file_num=$((file_num % $num_files));
      file_num=$((file_num+1));
      rnd_num=$file_num
    fi
    IMAGE=$(sed "${rnd_num}q;d" $PHOTO_FILE_LIST)
  fi

  if [ -z "$IMAGE" ]
  then
    if [ $num_files -eq 0 ]
    then
      IMAGE=$NO_IMAGES
    else
      get_image
    fi
  fi
}

function get_previous_image() {
  file_num=$((file_num + $num_files));
  file_num=$((file_num-2));

  get_image
}

declare -A PRESSED
PRESSED["$GPIO_PIN_NEXT"]=false
PRESSED["$GPIO_PIN_PREVIOUS"]=false
PRESSED["$GPIO_PIN_ALL"]=false
PRESSED["$GPIO_PIN_SHUTDOWN"]=false

function is_gpio_pressed() {
  if [ ! -d /sys/class/gpio/gpio${1} ]
  then
    false
    return
  fi
  
  PREV=${PRESSED[$1]}

  if [ "$(cat /sys/class/gpio/gpio${1}/value)" -eq "${GPIO_ACTION_VALUE}" ]
  then
    if [ "$PREV" = false ]
    then
      PRESSED["$1"]=true
      true
      return
    fi
    false
    return
  else
    PRESSED["$1"]=false
    false
    return
  fi
}

function start {
  local IMAGE=$NO_IMAGES
  local AUTO_NEXT_MODE=true # show next file after SLIDESHOW_DELAY
  local IS_IMAGE=false
  local PID=-1 # pid of omxplayer do detect video end
  local LAST_IMAGE_UPDATE=0


  #switch to hdmi
  echo "as" | cec-client -s

  counter=0
  error_settopic 01_Startup

  UPDATE_MEDIA=false 
  while true; do
    if is_gpio_pressed ${GPIO_PIN_NEXT} 
    then
      get_image
      UPDATE_MEDIA=true
      # read -p "Pausing NEXT" -t 1
      continue
    elif is_gpio_pressed ${GPIO_PIN_PREVIOUS}
    then
      get_previous_image
      UPDATE_MEDIA=true
      # read -p "Pausing PREVIOUS" -t 1
      continue
    elif is_gpio_pressed ${GPIO_PIN_ALL}
    then
      SWITCH_TO_ALL_DATETIME=$(date +%s)
      if [ "$PHOTO_FILE_LIST" = "$COMPLETE_PHOTO_FILE_LIST" ] 
      then
        get_image
        UPDATE_MEDIA=true
        continue
      else
        PHOTO_FILE_LIST=$COMPLETE_PHOTO_FILE_LIST
	      file_num=0
        get_image
        UPDATE_MEDIA=true
 	continue        
      fi
    elif is_gpio_pressed ${GPIO_PIN_SHUTDOWN}
    then
	      error_write "Shutdown"
        /sbin/poweroff	      
    elif is_gpio_pressed ${GPIO_PIN_PLAY}
    then
      read -p "Pausing PLAY" -t 5
      if ${AUTO_NEXT_MODE}
      then
        AUTO_NEXT_MODE=false
      else
        AUTO_NEXT_MODE=true
      fi
      continue
    fi

    if ${AUTO_NEXT_MODE}
    then
      NOW=$(date +%s)
      if [ "$IS_IMAGE" = true ]
      then
        # image was shown for slide show delay
        if [ $(( NOW - LAST_IMAGE_UPDATE )) -gt ${SLIDESHOW_DELAY} ]
        then
          UPDATE_MEDIA=true
          get_image
        fi
      else
        # Check if video has ended
        if ! [ -d "/proc/$PID" ]; then
          # Video has ended, new media can be shown
          UPDATE_MEDIA=true
          get_image
        fi
      fi
    fi

    if [ "$PHOTO_FILE_LIST" = "$COMPLETE_PHOTO_FILE_LIST" ]
    then
	NOW=$(date +%s)
	if [ $(( NOW - SWITCH_TO_ALL_DATETIME )) -gt ${RESUME_DEFAULT_FILELIST_DELAY} ]
	then
	  PHOTO_FILE_LIST=$PHOTO_FILE_LIST_FILE
          file_num=0
	  get_image
	  UPDATE_MEDIA=true
	fi
    fi

    if ${UPDATE_MEDIA}
    then
      UPDATE_MEDIA=false
      echo $IMAGE

      IS_IMAGE=false

      if file "$IMAGE" | cut -d':' -f2 |grep -qE 'image|bitmap'
      then
        IS_IMAGE=true
      fi

      if ${IS_IMAGE}
      then
        LAST_IMAGE_UPDATE=$(date +%s)

        IMAGE2=/tmp/photoframe.image
        cp "$IMAGE" "$IMAGE2"
        jhead -autorot $IMAGE2 &> /dev/null
        fbv $PARAMS_FBV "$IMAGE2"
      else
        omxplayer --no-keys "$IMAGE" &
        PID=$!
      fi

      if [ "$SHOW_FILENAME" = true ]
      then
        # abuse error reporting to show the path of the current picture
        error_settopic 02_Current
        #don't show the FOLDER_IMAGES prefix
        error_write "$( echo "$IMAGE" | sed -e "s|^${FOLDER_IMAGES}/||" )"
      fi

      error_display

      counter=$((counter+1))
      if [ $counter -eq 10 ]
      then
        error_settopic 01_Startup
      fi
    fi
  done
}


function display {
  case "$1" in
    on)
        vcgencmd display_power 1
        if [ "${CEC_DEVICE_ID}" != "-1" ]
        then
          echo "on ${CEC_DEVICE_ID}" | cec-client -s -d 1
        fi
        ;;

    off)
        vcgencmd display_power 0
        if [ "${CEC_DEVICE_ID}" != "-1" ]
        then
          echo "standby ${CEC_DEVICE_ID}" | cec-client -s -d 1
        fi
        ;;

    *)
        echo "Usage: $0 display {on|off}"
        exit 1
esac
}


case "$1" in
    start)
        start
        ;;

    stop)
        stop
        ;;

    restart)
        stop
        start
        ;;
    
    display)
        display $2
        ;;

    test)
        get_image
        ;;

    *)
        echo "Usage: $0 {start|stop|restart|display on/off}"
        exit 1
esac