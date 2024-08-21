
# Created: 21 August, 2024
# Author: ChefYeshpal
# Purpose: To beep after specified time
######################################################################

seconds=3
start="$(($(date +%s) + $seconds))"
while [ "$start" -ge `date +%s` ]; do
    time="$(( $start - `date +%s` ))"
    printf '%s\r' "$(date -u -d "@$time" +%H:%M:%S)"
done
