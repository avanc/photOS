#! /bin/sh

DAVFS_CONF=/etc/photoframe/davfs2.conf
MOUNTPOINT_DAV=/data/photoframe/images_webdav
FOLDER_IMAGES=/data/photoframe/images_local
WEBDAV_CONF=/data/photoframe/photoframe.conf

PARAMS_FBV="--noclear --smartfit 30 --delay 1"

NO_IMAGES="/usr/share/photoframe/noimages.png"

ERROR_DIR="/tmp/photoframe"
mkdir -p $ERROR_DIR

DELAY=3

function read_conf {
  read -r firstline< $WEBDAV_CONF
  array=($firstline)
  echo ${array[0]}
}

function sync {
error_settopic 10_Sync

if [ -f "$WEBDAV_CONF" ]; then
  chmod 0600 ${WEBDAV_CONF}
  

  mkdir -p $FOLDER_IMAGES                                         
  mkdir -p $MOUNTPOINT_DAV                                        
                                                                
  REMOTE_DAV=$(read_conf)

  ERROR=$(mount.davfs -o ro,conf=$DAVFS_CONF $REMOTE_DAV $MOUNTPOINT_DAV 2>&1 > /dev/null)
  if [ $? -ne 0 ]
  then
    error_write "Mounting $REMOTE_DAV failed: $ERROR"
  fi

  # Check if dav is mounted before starting rsync
  mount | grep $MOUNTPOINT_DAV > /dev/null
  if [ $? -eq 0 ]
  then
    ERROR=$(rsync -vtd --delete $MOUNTPOINT_DAV/ $FOLDER_IMAGES 2>&1 > /dev/null)
    [ $? -eq 0 ] || error_write "Syncing images failed: $ERROR"

    umount $MOUNTPOINT_DAV
  fi
else

  error_write "No WebDAV server configured. Go to http://$(hostname)"

fi
}

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

function get_image {
  local rnd_num
  rnd_num=-1
  local counter
  counter=0

  if [ $num_files -gt 0 ]
  then
    rnd_num=$(( $RANDOM % $num_files ))
  fi

  local IMAGE
  IMAGE=""
  for f in $FOLDER_IMAGES/*; do
    [[ -f $f ]] || continue
    if [[ $f =~ .*\.(jpg|JPG|png) ]]
    then
      if [ $counter -eq $rnd_num ]
      then
        IMAGE=$f;
      fi
      counter=$((counter+1)); 
    fi
  done

  num_files=$counter;

  if [ -z "$IMAGE" ]                                     
  then 
    if [ $num_files -eq 0 ]
    then
      IMAGE=$NO_IMAGES
    else
      IMAGE=$(get_image)
    fi
  fi                                                        

  echo $IMAGE
}



function start {

  while true; do
    IMAGE=$(get_image)
    echo $IMAGE

    fbv $PARAMS_FBV "$IMAGE"
    error_display
    sleep $DELAY
  done
}


function display {
  case "$1" in                                                    
    on)                                                      
        vcgencmd display_power 1                                                   
        ;;                                                      
                                                                
    off)                                                       
        vcgencmd display_power 0                                                    
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

    sync)         
        sync
        ;;             
            
    display)                                                       
        display $2                                                   
        ;;                                           
             
    test)
        get_image
        ;;

    *)
        echo "Usage: $0 {start|stop|restart|sync|display on/off}"
        exit 1
esac


