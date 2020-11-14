#! /bin/sh

DAVFS_CONF=/etc/photoframe/davfs2.conf
MOUNTPOINT_DAV=/data/photoframe/images_webdav
FOLDER_IMAGES=/data/photoframe/images_local

PARAMS_FBV="--enlarge --shrink --delay 20"

RUNNING=true

trap ctrl_c INT

function ctrl_c() {
        echo "** Trapped CTRL-C"
        RUNNING=false
}

function read_conf {
  read -r firstline</data/photoframe/photoframe.conf
  array=($firstline)
  echo ${array[0]}
}

function mount_dav {
  mount.davfs -o ro,conf=$DAVFS_CONF $REMOTE_DAV $MOUNTPOINT_DAV
}

function sync_images {
  rsync -td --delete $MOUNTPOINT_DAV $FOLDER_IMAGES
}

function get_images {
  local IMAGES
  IMAGES=""
  for f in $FOLDER_IMAGES/*; do
    [[ -e $f ]] || continue
    if [[ $f =~ .*\.(jpg|png) ]]
    then
	IMAGES="$IMAGES $f"
    fi
  done

  echo $IMAGES
}


mkdir -p $FOLDER_IMAGES
mkdir -p $MOUNTPOINT_DAV

REMOTE_DAV=$(read_conf)


while $RUNNING; do
  mount_dav
  sync_images
  IMAGES=$(get_images)
  echo $IMAGES
  fbv $PARAMS_FBV $IMAGES
done
