# raddiola 

![screenshot.png](/data/screenshot.png)

Simple radio with a clear and concise interface. You can listen to your favorite stations, add new ones, edit existing ones and delete unnecessary ones. There are already 10 stations built into the radio.

## Get it from the elementary OS AppCenter!

[![Get it on AppCenter](https://appcenter.elementary.io/badge.svg)](https://appcenter.elementary.io/raddiola)

This app is available on the elementary OS AppCenter.

# Install it from source

You can of course download and install this app from source.

## Dependencies

Ensure you have these dependencies installed

* granite
* gtk+-3.0
* switchboard-2.0

## Install, build and run

```bash
# install elementary-sdk, meson and ninja 
sudo apt install elementary-sdk meson ninja
# clone repository
git clone {{repository_url}} raddiola
# cd to dir
cd raddiola
# run meson
meson build --prefix=/usr
# cd to build, build and test
cd build
sudo ninja install && raddiola
```

## Generating pot file

```bash
# after setting up meson build
cd build

# generates pot file
sudo ninja raddiola-pot

# to regenerate and propagate changes to every po file
sudo ninja raddiola-update-po
```
