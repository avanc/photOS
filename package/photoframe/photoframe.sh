#! /bin/sh

DAVFS_CONF=/etc/photoframe/davfs2.conf
MOUNTPOINT_DAV=/data/photoframe/images_webdav
FOLDER_IMAGES=/data/photoframe/images_local

PARAMS_FBV="--fullscreen;--delay;1"

DELAY=3

function read_conf {
  read -r firstline</data/photoframe/photoframe.conf
  array=($firstline)
  echo ${array[0]}
}

function sync {
  mkdir -p $FOLDER_IMAGES                                         
  mkdir -p $MOUNTPOINT_DAV                                        
                                                                
  REMOTE_DAV=$(read_conf)

  mount.davfs -o ro,conf=$DAVFS_CONF $REMOTE_DAV $MOUNTPOINT_DAV

  rsync -vtd --delete $MOUNTPOINT_DAV/ $FOLDER_IMAGES

  umount $MOUNTPOINT_DAV
}


function get_images {
  local IMAGES
  IMAGES=""
  for f in $FOLDER_IMAGES/*; do
    [[ -e $f ]] || continue
    if [[ $f =~ .*\.(jpg|png) ]]
    then
      if [ ! -z "$IMAGES" ]      
      then
        IMAGES="$IMAGES;"     
      fi                      
      IMAGES="$IMAGES${f}"
    fi
  done

  echo $IMAGES
}



function start {

  while true; do
    IMAGES=$(get_images)
    echo $IMAGES

    OFS="$IFS"
    IFS=";"
    for i in $IMAGES
    do
      fbv -c $PARAMS_FBV $i
      sleep $DELAY
    done
  
  IFS="$OFS"
  done
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
            
    *)
        echo "Usage: $0 {start|stop|restart|sync}"
        exit 1
esac


