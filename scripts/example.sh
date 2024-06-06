# loop forever on camera6
ROOM="mediaroom"
IP="172.20.134.75"
LOOPCOUNT="360"
i="0"
while [ $i -gt -1 ]
do
# let's go to work
BASE=`echo $0|cut --delimiter='/' -f3|cut --delimiter='.' -f1`
PSCOUNT=`ps ax|fgrep $IP|wc -l`
RED5PSCOUNT=`ps ax|fgrep $IP|fgrep SOSample|wc -l`
FLVPSCOUNT=`ps ax|fgrep $IP|fgrep q2014rcd|wc -l`
if [ $RED5PSCOUNT -ne 1 ]
then
# kill off any already running avconv sending to red5
ps ax|fgrep $IP|fgrep SOSample|cut -c1-6 2>/dev/null|xargs kill -9 2>/dev/null
# Start up the new ones
exec avconv -i http://$IP/img/video.asf -b 1024k -s 320x240 -re -acodec libmp3lame -ar 11025 -ab 32k -async 3200 -r 15 -f flv rtmp://video.q2014.org/SOSample/$ROOM 2>>~/log/$BASE.log &
echo -e "\n\e[41m`date` Restarting $BASE -> Red5 Streamer\e[49m" |tee -a ~/log/$BASE.io.log
fi
# now go check the flv file creator
if [ $FLVPSCOUNT -ne 1 ]
then
# kill off any already running avconv saving to a file
ps ax|fgrep $IP|fgrep q2014rcd|cut -c1-6 2>/dev/null|xargs kill -9 2>/dev/null
# Start up the new ones
exec avconv -i http://$IP/img/video.asf -b 1024k -s 320x240 -re -acodec libmp3lame -ar 11025 -ab 32k -async 3200 -r 15 -f flv q2014rcd/$BASE`date +%y%m%d%H%M`.flv 2>>log/$BASE.slog &
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

