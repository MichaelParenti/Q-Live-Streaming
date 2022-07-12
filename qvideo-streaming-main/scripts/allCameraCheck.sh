# define functions
func_append ()
{
    str=$1
    while [ ${#str} -lt $2 ]
    do
	str="${str} "
#	echo "$str ${#str} "
    done
    output="$str"
}

# Do this forever
i="0"
while [ $i -gt -1 ]
do

#Do date/time work
RED=0
TOMORROW=(`date +%Y%m%d --date="tomorrow"`)
NOW=`date +%s`
FUTURE=`date +%s --date "$TOMORROW 02:00:00"`
let DATETIMEDIFF=($FUTURE-$NOW)

# erase all files containing a "~" in the conf directory
rm conf/*~ 2>/dev/null

# For each file in the conf directory as s
for f in `ls conf` ; do

# load parameters (#ROOM,#CAMTYPE, and #IP)
SRVR=""
source conf/$f

# only work on the cameras for this server
CURRENTSRVR=`uname -n`
if [[ $SRVR  != $CURRENTSRVR ]]; then
    continue
fi

# let's go to work
BASE=`echo $f|cut --delimiter='/' -f3|cut --delimiter='.' -f1`
PSCOUNT=`ps ax|fgrep $IP|fgrep qrcd|fgrep $BASE|wc -l`
STREAMPSCOUNT=`ps ax|fgrep $IP|fgrep video.quizstuff|fgrep $BASE|wc -l`
FLVPSCOUNT=`ps ax|fgrep $IP|fgrep qrcd|fgrep $BASE|wc -l`
CAMTYPE=`echo $CAMTYPE | tr [:upper:] [:lower:]`

# Report what we are doing
#echo "Checking " $f $IP $BASE $CAMTYPE

# Now run the checks
#if [ $STREAMPSCOUNT -ne 1 ]
#then
# Start up the new ones
DT=`date +%y%m%d`
LASTLINE=`tail -n 1 log/$ROOM-$DT.slog`
JUSTDROP=`echo $LASTLINE |cut -d ' ' -f1-250|fmt -w 1 -s | fgrep drop | cut -c6-99`

echo $ROOM
echo $LASTLINE 
#fi

# go back to the top
done
# now go to sleep to make sure we don't use up all the cpu
RED=0
echo ""
sleep 30
done
