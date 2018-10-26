#!/bin/bash
# Run this via cron @9am every morning
# crontab -e
# 0 9 * * * /bin/bash $HOME/bin/google_wallpaper.sh >> /tmp/google-wallpaper.log 2>&1

# Needed for cron to access the gnome-session and set the wallpaper
#export DISPLAY=:0
#PID=$(pgrep gnome-session)
#export DBUS_SESSION_BUS_ADDRESS=$(grep -z DBUS_SESSION_BUS_ADDRESS /proc/$PID/environ|cut -d= -f2-)

# The directory where all google wallpapers will be downloaded to
PIC_DIRECTORY=$HOME/Pictures/google
if [ ! -d "$PIC_DIRECTORY" ]; then
	mkdir -p $PIC_DIRECTORY
fi

# Define a destination file
IMAGE_FILE_NAME="GOOGLE_Wallpaper_Image"

# Define the google image url and query string
SUPER_HERO=$1
if [ -z "$SUPER_HERO" ] ; then
	SUPER_HERO="groot"
fi
GOOGLE_IMAGE_URL="https://www.google.com/search?q=$SUPER_HERO+wallpaper&tbm=isch&tbs=isz:ex,iszw:1920,iszh:1080,itp:photo"

# Define the agent to make it look legit
USER_AGENT="Mozilla/5.0 (Windows NT 6.1; WOW64; rv:31.0) Gecko/20100101 Firefox/31.0"

image_file="/some/file/seed/meant/to/not/exist"

# ----------------------------------------------------------------------
# Clean up all old images so we don't get full on space
clean() {
	rm -f $PIC_DIRECTORY/*
}

# ----------------------------------------------------------------------
# Define a function to pick a random image, download it, and set it to the desktop
download() {
	# Pick a random search index
	randindex=$(( ( RANDOM % 50 )  + 1 ))
	echo "Picking a random google image: $randindex for $SUPER_HERO"

	image_url=$(wget -e robots=off --user-agent "$USER_AGENT" -qO - "$GOOGLE_IMAGE_URL" | sed 's/<\/\?[^>]\+>/\n/g' | grep "\"oh\":1080,\"ou\":" | awk -F\"ou\":\" '{print $2}'| awk -F\" '{print $1}' | head -n $randindex | tail -n1)
	image_url="${image_url%\%*}"
	file_extension=$(echo $image_url | sed "s/.*\(\.[^\.]*\)$/\1/")
	echo "Google search returned a link to: $image_url which looks like a $file_extension file"

	image_file="$PIC_DIRECTORY/$IMAGE_FILE_NAME$randindex$file_extension"
	echo "Fetching new google image"
	wget --max-redirect 0 -qO "$image_file" "${image_url}"
	echo "Retrieved new google image and stored in: $image_file"
}

# ----------------------------------------------------------------------
# Assign the newly downloaded image to the desktop
set_desktop() {
	echo "Setting desktop background to: $image_file"
	echo "gsettings set org.gnome.desktop.background picture-uri \"file://$image_file\""
	gsettings set org.gnome.desktop.background picture-uri "file://$image_file"
}

# Clean up old images
clean

# ----------------------------------------------------------------------
# Try 5 times to set the desktop to a random google image
retries=0
until [ $retries -ge 5 ] || [ -s $image_file ] 
do
	download
	if [ -s $image_file ]; then
		echo "Setting desktop to $image_file"
		set_desktop
	else
		# TODO: Retries for when an image is of 0 size
		echo "ERROR $retries: $image_file is of 0 size.  This probably means that the download url is blocked."
	fi
	retries=$[$retries+1]
done
