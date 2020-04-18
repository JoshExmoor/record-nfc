@Echo off
C:
cd "\NFC RECORDINGS\"

set gain=10
set filetype=WAV

REM Record for three hours. This assumes that the script starts at 9pm, so it would end at exactly midnight. Adjust total recording time as needed. 
echo Hour 1 - %time%
set NFCfilename=NFC %date:~10,4%-%date:~4,2%-%date:~7,2% %time:~0,2%%time:~3,2%
set file1=%NFCfilename%
"c:\Program Files (x86)\sox-14-4-2\sox" -t waveaudio -c 1 -r 44100 -d "%NFCfilename%.%filetype%" trim 0 03:00:00


REM Start recording at midnight (assuming the above line recorded until exactly midnight) and record for the length of time at the end of the last line (Currently 5 hours). 
Echo Hour 2 - %time%
set NFCfilename=NFC %date:~10,4%-%date:~4,2%-%date:~7,2% 0%time:~1,1%%time:~3,2%
set file2=%NFCfilename%
"c:\Program Files (x86)\sox-14-4-2\sox" -t waveaudio -c 1 -r 44100 -d "%NFCfilename%.%filetype%" trim 0 04:30:00

Echo Recording Complete - %time%

Echo Running BirdVoxDetect - %time%

py -m birdvoxdetect -t 22 -c -d 2 -v  "%file1%.wav" "%file2%.wav"

Echo BirdvoxDetect Complete - %time%


Echo Converting WAV to FLAC

"c:\Program Files (x86)\sox-14-4-2\sox" "%file1%.wav" "%file1%.flac"
"c:\Program Files (x86)\sox-14-4-2\sox" "%file2%.wav" "%file2%.flac"

Echo Deleting WAV Files - %time%

del "%file1%.wav"
del "%file2%.wav"

Echo Transcoding Complete - %time%


Pause
