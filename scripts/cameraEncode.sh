# load parameters (#ROOM and #IP)
source `dirname $0`/conf/$1.room

# loop forever on camera
LOOPCOUNT="360"
i="0"
while [ $i -gt -1 ]
do

# let's go to work
BASE=`echo $1|cut --delimiter='/' -f3|cut --delimiter='.' -f1`
PSCOUNT=`ps ax|fgrep $IP|wc -l`
RED5PSCOUNT=`ps ax|fgrep $IP|fgrep video.q2016.org|wc -l`
FLVPSCOUNT=`ps ax|fgrep $IP|fgrep q2016rcd|wc -l`
if [ $RED5PSCOUNT -ne 1 ]
then
# kill off any already running avconv sending to red5
ps ax|fgrep $IP|fgrep video.q2016.org|cut -c1-6 2>/dev/null|xargs kill -9 2>/dev/null
# Start up the new ones
# old
exec avconv -re -i http://$IP/img/video.asf -b 1024k -s 640x480 -acodec libmp3lame -ar 11025 -ab 32k -async 3200 -r 15 -f flv rtmp://video.q2016.org/live/$ROOM 2>>~/log/$BASE.slog &
########avconv -re -i http://10.101.14.202/img/video.asf -b:v 1024k -s 640x480 -acodec libmp3lame -ar 11025 -ab 32k -async 3200 -r 15 -f flv rtmp://162.243.201.90/live/heritage
### mp4 with faststart
#exec avconv -re -i http://$IP/img/video.asf -s 640x480 -acodec libmp3lame -g 1800  -vcodec libx264 -an -f mp4 -movflags faststart+frag_keyframe+empty_moov rtmp://video.q2016.org/live/$ROOM 2>>~/log/$BASE.slog&
#######ffmpeg -re -i http://10.101.14.202/img/video.asf -s 640x480 -acodec libmp3lame -g 1800  -vcodec libx264 -an -f mp4 -movflags faststart+frag_keyframe+empty_moov rtmp://162.243.201.90/live/heritage

echo -e "\n\e[41m`date` Restarting $BASE -> Red5 Streamer\e[49m" |tee -a ~/log/$BASE.io.log
fi

# now go check the flv file creator
if [ $FLVPSCOUNT -ne 1 ]
then
# kill off any already running avconv saving to a file
ps ax|fgrep $IP|fgrep q2016rcd|cut -c1-6 2>/dev/null|xargs kill -9 2>/dev/null
# Start up the new ones
exec avconv -re -i http://$IP/img/video.asf -b 1024k -s 640x480 -acodec libmp3lame -ar 11025 -ab 32k -async 3200 -r 15 -f flv q2016rcd/$BASE'_'`date +%y%m%d%H%M`.flv 2>>log/$BASE.log &
echo -e "\n\e[41m`date` Restarting $BASE -> FLV file creator\e[49m"|tee -a ~/log/$BASE.io.log
fi
# now go to sleep to make sure we don't use up all the cpu
sleep 10
# Tell the user we're doing ok
if [ $LOOPCOUNT -lt 360 ]
then
echo -e -n "\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b"
echo -e -n "\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b"
echo -e -n "$BASE `date +%c`"
echo -e -n "`date` doing ok $BASE pscount=$PSCOUNT\n" >>~/log/$BASE.io.log
else
echo -e "`date` doing ok $BASE pscount=$PSCOUNT"|tee -a ~/log/$BASE.io.log
LOOPCOUNT="0"
fi
((LOOPCOUNT++))
# go back to the top
done

