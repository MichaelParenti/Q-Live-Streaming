# Make sure the directories are created
mkdir -p log
mkdir -p qrcd
# define functions
func_append() {
    str=$1
    while [ ${#str} -lt $2 ]; do
        str="${str} "
        #	echo "$str ${#str} "
    done
    output="$str"
}

# Declare an associative array to hold previous sizes to determine streams that may be failing to terminate
declare -A PREVIOUS_SIZE

# Do this forever
i="0"
while [ $i -gt -1 ]; do

    #Do date/time work
    RED=0
    TOMORROW=($(date +%Y%m%d --date="tomorrow"))
    NOW=$(date +%s)
    FUTURE=$(date +%s --date "$TOMORROW 02:00:00")
    let DATETIMEDIFF=($FUTURE - $NOW)

    # erase all files containing a "~" in the conf directory
    rm conf/*~ 2>/dev/null

    # For each file in the conf directory as s
    for f in $(ls conf); do

        # load parameters (#ROOM,#CAMTYPE, and #IP)
        SRVR=""
        source conf/$f

        # only work on the cameras for this server
        CURRENTSRVR=$(uname -n)
        if [[ $SRVR != $CURRENTSRVR ]]; then
            continue
        fi

        # let's go to work
        BASE=$(echo $f | cut --delimiter='/' -f3 | cut --delimiter='.' -f1)
        PSCOUNT=$(ps ax | fgrep $IP | fgrep qrcd | fgrep $BASE | wc -l)
        STREAMPSCOUNT=$(ps ax | fgrep $IP | fgrep video.q2025 | fgrep $BASE | wc -l)
        FLVPSCOUNT=$(ps ax | fgrep $IP | fgrep qrcd | fgrep $BASE | wc -l)
        CAMTYPE=$(echo $CAMTYPE | tr [:upper:] [:lower:])

        # Report what we are doing
        #echo "Checking " $f $IP $BASE $CAMTYPE

        # Now run the checks
        if [ $STREAMPSCOUNT -ne 1 ]; then
            # kill off any already running ffmpeg sending to nginx
            echo "Killing Stream" $IP $BASE
            # Start up the new ones
            if [ $CAMTYPE = "cisco" ]; then
                ## The following line is how we did it at Q2022 with NGINX
                exec ffmpeg -t $DATETIMEDIFF -re -i http://$IP/img/video.asf -vf "scale=2*iw:-1, crop=iw/2:ih/2" -vcodec libx264 -vprofile baseline -acodec aac -strict -2 -f flv rtmp://video.q2025.org/show/$BASE 2>>log/$BASE-$(date +%y%m%d).slog 1</dev/null &
            elif [ $CAMTYPE = 'wyse' ]; then
                #   exec ffmpeg -t $DATETIMEDIFF -i rtsp://$UN:$PWD@$IP/live -vcodec libx264 -vprofile baseline -acodec aac -strict -2 -f flv rtmp://video.q2025.org/show/$BASE 2>>log/$BASE-$(date +%y%m%d).slog &
                exec ffmpeg -t $DATETIMEDIFF -i rtsp://$UN:$PWD@$IP/live -vcodec libx264 -s 768x432 -acodec aac -f flv rtmp://video.q2025.org/show/$BASE 2>>log/$BASE-$(date +%y%m%d).slog 1</dev/null &
            fi
            sleep 2
            RED=1
            echo -e "\n\e[41m$(date) Restarting $BASE -> NGINX Streamer\e[49m" | tee -a log/$BASE-$(date +%y%m%d).io.log
        fi
        # now go check the flv file creator
        if [ $FLVPSCOUNT -ne 0 ]; then
            # kill off any already running ffmpeg saving to a file
            echo "Killing FLV" $IP $BASE
            # Start up the new ones
            if [ $CAMTYPE = "ciscoz" ]; then
                exec ffmpeg -t $DATETIMEDIFF -re -i http://$IP/img/video.asf -b 1024k -s 640x480 -acodec libmp3lame -ar 11025 -ab 32k -async 3200 -r 15 -f flv qrcd/$BASE'_'$(date +%y%m%d%H%M).flv 2>>log/$BASE-$(date +%y%m%d).log 1</dev/null &
            elif [ $CAMTYPE = "wysez" ]; then
                #   exec ffmpeg -t $DATETIMEDIFF -i rtsp://$UN:$PWD:qtest@$IP/live -f mp4 qrcd/$BASE'_'$(date +%y%m%d%H%M).mp4 2>>log/$BASE-$(date +%y%m%d).log &
                exec ffmpeg -t $DATETIMEDIFF -i rtsp://$UN:$PWD@$IP/live -b 1024k -acodec libmp3lame -ar 11025 -ab 32k -async 3200 -f flv qrcd/$BASE'_'$(date +%y%m%d%H%M).flv 2>>log/$BASE-$(date +%y%m%d).log 1</dev/null &
            fi
            sleep 2
            RED=1
            echo -e "\n\e[41m$(date) Restarting $BASE -> FLV/MP4 file creator\e[49m" | tee -a log/$BASE-$(date +%y%m%d).io.log
        fi
        # Tell the user we're doing ok
        # make sure they have the right amount of whitespace
        func_append $IP 15
        PIP=$output
        func_append $BASE 15
        PBASE=$output
        func_append $CAMTYPE 5
        PCAMTYPE=$output
        echo "$(date) Ok $PBASE $PIP $PCAMTYPE pscount=$FLVPSCOUNT streampscount=$STREAMPSCOUNT" | tee -a log/$BASE-$(date +%y%m%d).io.log

        # check log file sizes to determine those that may be failing and terminate those

        # Get the log file of $BASE
        LOG_FILE="log/$BASE-$(date +%y%m%d).slog"

        # Set the current size
        CURRENT_SIZE=$(stat -c '%s' "$LOG_FILE")

        # echo "Current and previous log file sizes for $BASE are:"
        # echo $CURRENT_SIZE
        # echo "${PREVIOUS_SIZE["$LOG_FILE"]}"

        # if [ -z $PREVIOUS_SIZE["$LOG_FILE"] ]; then
        #     echo "No log file $LOG_FILE exists. Please check configuration and script."
        # else
        echo "Checking log '$LOG_FILE' size delta for $BASE"
        # If the current size is not equal to the previous size...
        if [[ "$CURRENT_SIZE" -eq "${PREVIOUS_SIZE["$LOG_FILE"]}" ]]; then
            # Find the Process ID (PID) of the $BASE process
            PIDS=$(ps aux | grep "$BASE" | grep -v grep | awk '{print $2}')

            # Check if any PIDs were not found
            if [ -z "$PIDS" ]; then
                echo "$(date +"%Y-%m-%d %H:%M:%S.%3N") No process named $BASE found to kill." | tee -a log/$BASE-$(date +%y%m%d).io.log
            else
                # Kill the process
                for PID in $PIDS; do
                    kill $PID
                    if [ $? -eq 0 ]; then
                        echo "$(date +"%Y-%m-%d %H:%M:%S.%3N") Process $PID killed (likely hung)." | tee -a log/$BASE-$(date +%y%m%d).io.log
                    else
                        echo "$(date +"%Y-%m-%d %H:%M:%S.%3N") Failed to kill likely hung process $PID." | tee -a log/$BASE-$(date +%y%m%d).io.log
                    fi
                done
            fi

        fi
        # Set previous size to the current size
        PREVIOUS_SIZE["$LOG_FILE"]=$CURRENT_SIZE
        # echo "Current and previous sizes are BOTTOM:"
        # echo $CURRENT_SIZE
        # # PREVIOUS_SIZE["$LOG_FILE"]=$CURRENT_SIZE
        # echo "${PREVIOUS_SIZE["$LOG_FILE"]}"
        # fi

        # go back to the top
    done
    # now go to sleep to make sure we don't use up all the cpu
    RED=0
    echo ""
    sleep 10
done
