# What's photoOS?

**photoOS** is a lightweight operating system for a DIY photoframe. The software syncs photos with a dav server so new images can be easily added. In my current setup I use [Nextcloud](https://nextcloud.com) as server, but any dav server should work. With Nextcloud I can use the Android app to directly upload images from my mobile phone. In addition, I can share the photo folder with other family members, so they can add photos as well. Even from a distance during pandemies...

Main focus are the Raspberry Pi boards (especially Raspberry Pi Zero W, as the performance is sufficient). But as photoOS is based on the great work of [thingOS](https://github.com/ccrisan/thingos) by ccrisan, which builds on top of [BuildRoot](https://buildroot.uclibc.org), other boards can be easily supported. Just create a ticket for not supported boards.


that serves as a base for IoT dedicated operating systems. If you want to turn your Raspberry PI board into something that controls your lights, doors, sprinklers or other devices, by designing your own "firmware", thingOS may be a good choice.

# Features
* **Sync**: Photos can be synced from a dav server.
* **Offline**: Works also if no internet connection is available.
* **Power Saving**: By turning the HDMI output off (e.g. by default at night) most monitors go into power savings mode.
* **Small Footprint**: Images are directly drawn on the framebuffer without the need for any X dependencies.
* **Highly Customizable**: As true for all Open Source solutions :-)

# Hardware
The hardware requirements are minimal and the system is easy to setup, as only a Raspberry Pi and an old monitor is needed. But you can spend a lot of time in the woodwork :-)

# Installation

## The quick way
This section describes the setup using a prebuild image. However, there is no prebuild image available yet...

1. Download the latest stable release (not availabe yet)
2. Extract the image file from the archive
3. Write the image file to your SD card:

    **If you use Windows**, just follow [these instructions](http://www.raspberrypi.org/documentation/installation/installing-images/windows.md).

    **If you use Linux or OSX**, there's a [writeimage.sh](https://raw.githubusercontent.com/avanc/photos/master/writeimage.sh) script that will do everything for you, including the setup of a wireless network connection and configuration of the dav server credentials. Just run the script as follows (replacing the arguments with appropriate values):

        ./writeimage.sh -d /dev/mmcblk0 -i "/path/to/photos.img" -n 'yournet:yourkey' -p 'https://davserver/yourphotos:username:password' 

    **note**: specify the device path to the disk and not to some partition (e.g. `/dev/mmcblk0` instead of `/dev/mmcblk0p1`)


## The other way
Although the image can be easily created thanks to thingOS and BuildRoot, the compilation of the whole software can take a few hours.

1. Clone the repository:

    git clone https://github.com/avanc/photOS.git
    
2. Compile the whole stuff and take a rest:

    cd photOS
    ./build.sh <board_name>
    
3. Build the compressed image:

    ./build.sh <board_name> mkrelease

4. Write the image to SD-card as written above in The quick way

