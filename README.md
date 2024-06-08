# qvideo-streaming
Code and setup to stream from Wyse v3s &amp; Cisco WVR210s to Nginx

This is the code that we used to stream video from Wyse v3 Cameras and 
Cisco WVR210 cameras.

Basically the ./scripts/allCameraEncoder.sh script is run.   That script 
reads configuration from the files in conf directory.   The script writes 
the video streams to video.q2022.org nginx server.

Directories:

conf -> Configuration files.  Each file is one camera.
log -> Log files are kept here.
qrcd -> The script writes video files to this directory.
html -> These are the HTML files loaded by the browsers.  Divs in these 
        files source from the nginx server

