#!/bin/bash
# Run this via cron @9am every morning
# crontab -e
# 0 * * * * /bin/bash $HOME/bin/random.sh >> /tmp/random-wallpaper.log 2>&1

declare -a CATEGORIES=(groot spiderman justice-league GotG marvel+comics+collage dc+comics+collage)

randindex=$((RANDOM%(${#CATEGORIES[@]})))
CATEGORY=${CATEGORIES[$randindex]}

echo "Chose category: $CATEGORY"

# This will need changed to wherever the cloned scirpts directory is
$HOME/bin/wallpaper/google.sh $CATEGORY
