@echo off
REM This tiny script is a hacky solution to the fact that I can't get Powershell to call sox correctly from within 
"c:\Program Files (x86)\sox-14-4-2\sox" -t waveaudio -c 1 -r 44100 "In 1-2" %1 trim 0 %2