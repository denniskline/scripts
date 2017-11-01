#!/bin/bash
# Run this via cron @9am every morning
# crontab -e
# 0 9 * * * /bin/bash $HOME/bin/wot.sh >> /tmp/wot-wallpaper.log 2>&1

# Needed for cron to access the gnome-session and set the wallpaper
export DISPLAY=:0
PID=$(pgrep gnome-session)
export DBUS_SESSION_BUS_ADDRESS=$(grep -z DBUS_SESSION_BUS_ADDRESS /proc/$PID/environ|cut -d= -f2-)

# The directory where all tank wallpapers will be downloaded to
PIC_DIRECTORY=$HOME/Pictures/wot

# WoT is not consistent with how they specify their monthly wallpaper dirs.  MONTH array turns into URL appenders for a month
declare -a MONTHS=(1539 2186 1580 1654 1812 1860 1888 November_poster 2070 2165 2237 2343 2424 july-2013-desktop-wallpaper-clear august-2013-wallpaper menu-screen-wallpaper-conqueror menu-screen-wallpaper-t-34-85 september-2013-wallpaper menu-screen-wallpaper-e-100 menu-screen-wallpaper-wz-132 wallpaper-oct-2013 november-2013-wallpaper december-2013-wallpaper january-2014-wallpaper wallpaper-2014feb march-2014-wallpaper april-2014-wallpaper may-2014-wallpaper wallpaper-2014jun wallpaper-2014july wallpaper-2014august wallpaper-2014september wallpaper-2014october november-2014-wallpaper december-2014-wallpaper january-2015-wallpaper february-2015-wallpaper ides-march-2015 march-2015-wallpaper april-2015-wp june-2015-wallpaper july-2015-wallpaper august-2015-wallpaper september-2015-wallpaper october-2015-wallpaper-calendar november-2015-wallpaper-calendar december-2015-calendar-wallpaper)
#declare -a MONTHS=(1860)

# Pick a random wallpaper
randindex=$((RANDOM%(${#MONTHS[@]})))
RAND_URL=${MONTHS[$randindex]}
URL="http://worldoftanks.com/en/media/8/$RAND_URL"
#echo "URL = $URL"

# Look at the source HTML and find an image link for 1280x1024
IMG="$(lynx -source $URL | grep -oP '[^"]*1920[x_]1200[\.\_\-\w+]+jpg\b' | tail -n1)"
#echo "IMG = $IMG"

# Some links from the WoT page are not fully qualified.  If we see one of those, then add the http etc part
if [[ $IMG != http* ]] 
then
    FQ_URL="http://worldoftanks.com$IMG"
    IMG=$FQ_URL
fi

# Just in case: make sure the discovered image is a jpg before trying to set it to the wallpaper
if [ "${IMG##*.}" = "jpg" ] 
then
    cd $PIC_DIRECTORY
    wget $IMG
    IMG_NAME=$(basename $IMG)
    #echo "IMG_NAME = $IMG_NAME"
    gsettings set org.gnome.desktop.background picture-uri "file://$PIC_DIRECTORY/$IMG_NAME"
else
    echo "Unrecognized file extension found for image: $IMG in URL: $URL"
fi

# Delete all pictures that have not been accessed in the last 5 days
find $PIC_DIRECTORY -type f -atime +5 -exec rm {} \;
