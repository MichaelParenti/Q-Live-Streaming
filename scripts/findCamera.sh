#
# findCamera.sh
#
echo "Finding Wyse Cameras"
HOSTADDRESS=`ifconfig|fgrep inet|fgrep netmask|fgrep -v 127.0.0`
NETMASK=`echo $HOSTADDRESS | cut --delimiter=' ' -f4`
HOSTADDRESS=`echo $HOSTADDRESS | cut --delimiter=' ' -f2`
HOSTNETWORK=`echo $HOSTADDRESS | cut --delimiter='.' -f4 --complement`
echo "Host Address $HOSTADDRESS"
echo "Host Network $HOSTNETWORK"
echo "Host Netmask $NETMASK"
echo "Scanning network : $HOSTNETWORK.0"
MEMBER="1"
while [ $MEMBER -lt 256 ]
do
    CAMERAADDRESS=$HOSTNETWORK+$MEMBER
    echo -n "."
    RSLT=`nmap -n -A -T4 -T5 -Pn -p554 $HOSTNETWORK.$MEMBER | fgrep -i "Doorbird"`
    LENGTH=$(expr length "$RSLT")
    if [ $LENGTH -gt 0 ]
    then
       echo ""
       echo "Found Wyse Camera at $HOSTNETWORK.$MEMBER $RSLT"
    fi
    MEMBER=$((MEMBER+1))
done
echo ""
exit 0
