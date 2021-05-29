#! /bin/sh
CONF_DIR=/data/photoframe
DAVFS_CONF=/etc/photoframe/davfs2.conf
MOUNTPOINT_DAV=/data/photoframe/images_webdav
FOLDER_IMAGES=/data/photoframe/images_local
WEBDAV_CONF=${CONF_DIR}/conf/webdav.conf

#File that lists all available photos. Will be overwritten on sync
PHOTO_FILE_LIST=/data/photoframe/filenames.txt

PARAMS_FBV="--noclear --smartfit 30 --delay 1"

NO_IMAGES="/usr/share/photoframe/noimages.png"

ERROR_DIR="/tmp/photoframe"
mkdir -p $ERROR_DIR

SLIDESHOW_DELAY=3
SHUFFLE=true

if [ -e ${CONF_DIR}/conf/photoframe.conf ]
then
  source ${CONF_DIR}/conf/photoframe.conf
fi


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

  ERROR=$(mount.davfs -o ro,conf=$DAVFS_CONF "$REMOTE_DAV" $MOUNTPOINT_DAV 2>&1 > /dev/null)
  if [ $? -ne 0 ]
  then
    error_write "Mounting $REMOTE_DAV failed: $ERROR"
  fi

  # Check if dav is mounted before starting rsync
  mount | grep $MOUNTPOINT_DAV > /dev/null
  if [ $? -eq 0 ]
  then
    ERROR=$(rsync -vtr --include '*.png' --include '*.jpg' --include '*.JPG' --exclude '*.mp4' --exclude '*.MOV' --delete $MOUNTPOINT_DAV/ $FOLDER_IMAGES 2>&1 > /dev/null)
    [ $? -eq 0 ] || error_write "Syncing images failed: $ERROR"

    umount $MOUNTPOINT_DAV

    find $FOLDER_IMAGES -type f -iname '*\.jpg' -o -iname '*\.png' > $PHOTO_FILE_LIST
    chmod a+r $PHOTO_FILE_LIST
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
      rnd_num=$(( $RANDOM % $num_files ))
    else
      rnd_num=$file_num
      file_num=$((file_num+1));
      file_num=$((file_num % $num_files));
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



IMAGE=$NO_IMAGES

function start {
  counter=0
  error_settopic 01_Startup
  error_write "Go to http://$(hostname) to configure photOS"

  while true; do
    get_image
    echo $IMAGE

    IMAGE2=/tmp/photoframe.image
    cp "$IMAGE" "$IMAGE2"
#    convert -auto-orient "$IMAGE" "$IMAGE2"
    jhead -autorot $IMAGE2 &> /dev/null
    fbv $PARAMS_FBV "$IMAGE2"

    # abuse error reporting to show the path of the current picture
    error_settopic 02_Current
    error_write "$IMAGE"

    error_display
    sleep $SLIDESHOW_DELAY

    counter=$((counter+1))
    if [ $counter -eq 10 ]
    then
      error_settopic 01_Startup
    fi

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


