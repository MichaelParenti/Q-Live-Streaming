# load parameters (#ROOM and #IP)
source `dirname $0`/conf/$1.room

# loop forever on camera
LOOPCOUNT="360"
i="0"
while [ $i -gt -1 ]
do
# let's go to work
BASE=`echo $1|cut --delimiter='/' -f3|cut --delimiter='.' -f1`
PSCOUNT=`ps ax|fgrep ffmpeg|fgrep $IP|wc -l`
if [ $PSCOUNT -ne 1 ]
then
# kill off any already running ffmpeg for this ip
ps ax|fgrep ffmpeg|fgrep $IP|cut -c1-6 2>/dev/null|xargs kill -9 2>/dev/null

# Start up the new ones

#new combined command
exec /media/sdb/q2014/ffmpeg -i http://$IP/img/video.asf -vcodec flv -b:v 1024k -s 640x480 -acodec libmp3lame -ar 11025 -b:a 32k -async 3200 -r 15 -f tee -map 0 -flags +global_header  "[f=flv]rtmp://video.q2014.org/SOSample/$ROOM|[f=flv]q2014rcd/$ROOM'_'`date +%y%m%d%H%M`.flv" 2>>~/log/$BASE'_'`date +%y%m%d%H%M`.log &

#old RED5 command
#exec avconv -i http://$IP/img/video.asf -b 1024k -s 640x480 -re -acodec libmp3lame -ar 11025 -ab 32k -async 3200 -r 15 -f flv rtmp://video.q2014.org/SOSample/$ROOM 2>>~/log/$BASE.log &
echo -e "\n\e[41m`date` Restarting $BASE \e[49m" |tee -a ~/log/$BASE.io.log
fi

#old local file command
#exec avconv -i http://$IP/img/video.asf -b 1024k -s 640x480 -re -acodec libmp3lame -ar 11025 -ab 32k -async 3200 -r 15 -f flv q2014rcd/$BASE'_'`date +%y%m%d%H%M`.flv 2>>log/$BASE.slog &

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

