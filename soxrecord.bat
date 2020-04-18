@echo off
"c:\Program Files (x86)\sox-14-4-2\sox" -t waveaudio -c 1 -r 44100 "In 1-2" %1 trim 0 %2