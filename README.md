<img src="https://github.com/avanc/photOS/blob/master/logo/photos_logo.svg?raw=true" alt="photOS" width="300"/>


# What's photOS?

**photOS** is a lightweight Linux-based operating system for a DIY photoframe. The software syncs photos with a dav server so new images can be easily added. In my current setup I use [Nextcloud](https://nextcloud.com) as server, but any dav server should work. With Nextcloud I can use the Android app to directly upload images from my mobile phone. In addition, I can share the photo folder with other family members, so they can add photos as well. Even from a distance during pandemies...

Main focus are the Raspberry Pi boards (especially Raspberry Pi Zero W, as the performance is sufficient). But as photoOS is based on the great work of [thingOS](https://github.com/ccrisan/thingos) by ccrisan, which builds on top of [BuildRoot](https://buildroot.uclibc.org), other boards can be easily supported. Just create a ticket for not supported boards.

# Features
* **Sync**: Photos can be synced from a [WebDAV](https://en.wikipedia.org/wiki/WebDAV) server.
* **Offline**: Works also if no internet connection is available.
* **Power Saving**: By turning the HDMI output off (e.g. by default at night) most monitors go into power savings mode.
* **Small Footprint**: Images are directly drawn on the framebuffer without the need for any X dependencies.
* **Highly Customizable**: As true for all Open Source solutions :-)

# Hardware
The hardware requirements are minimal and the system is easy to setup, as only a Raspberry Pi and an old monitor is needed. But you can spend a lot of time in the woodwork :-)

# Installation
The installation process is documented in the [wiki](https://github.com/avanc/photOS/wiki/Installation).

# Update
An update to a newer version can be easily triggered using the webui.

# WebDAV
photOS snychronizes images from a WebDAV server. Although any standard compliant server should work, this section explains a setup using [Nextcloud](https://docs.nextcloud.com/server/19/user_manual/files/access_webdav.html).
With Nextcloud and the corresponding smartphone app it is possible to send photos directly from your smartphone to your photo frame. In addition, it is very simple to give other Nextcloud users permissions to also add images to your photo frame.

It is advised to create a separate Nextcloud user (e.g. _photoframe_), as the password needs to be stored in cleartext on that device and gives access to all data on that account. As user _photoframe_ create a folder "photos" and share the folder with your main Nextcloud account and additional accounts or gropus (family, friends, flatmates, ...). All those accounts can now share images with your photo frame.

The WebDAV URL needed for configuring photOS is typically something like htt<span>ps</span>://your.nextcloud<b>/remote.php/dav/files/</b>photoframe/photos.

# Additional information
For additional information have a look at the [FAQ](https://github.com/avanc/photOS/wiki/FAQ) and the growing wiki pages.

Don't hesitate to add questions as issues labled _question_ if soemthing is unclear.
