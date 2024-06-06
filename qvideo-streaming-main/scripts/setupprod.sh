#
# !bin/sh
#
# Time to put this in production
#
mkdir -p ~/conf
mkdir -p ~/firmware
mkdir -p ~/html
mkdir -p ~/scripts
cp ~/qvideo-streaming/LICENSE ~
cp ~/qvideo-streaming/README.md ~
cp ~/qvideo-streaming/conf/wyzeexample.room conf/wyseexample.room
cp ~/qvideo-streaming/conf/ciscoexample.room conf/ciscoexample.room
#sed -i 's/old-text/new-text/g' input.txt
cp ~/qvideo-streaming/firmware/* ~/firmware
cp ~/qvideo-streaming/html/ciscoexample.html ~/html/ciscoexample.html
cp ~/qvideo-streaming/html/wyzeexample.html ~/html/wyzeexample.html
mkdir -p ~/html/js
cp ~/qvideo-streaming/html/js/* ~/html/js
cp ~/qvideo-streaming/html/videojs.html ~/html
cp ~/qvideo-streaming/html/*.css ~/html
cp ~/qvideo-streaming/html/*.js ~/html
mkdir -p ~/scripts
cp ~/qvideo-streaming/scripts/all*.sh ~/scripts
cp ~/qvideo-streaming/scripts/find*.sh ~/scripts
cp ~/qvideo-streaming/scripts/cameraEncodeSingle.sh ~/scripts

