# Get Parameters 
Param(
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)][String]$Gain = 10,
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)][String]$Filetype = "WAV"
)
# -t waveaudio -c 1 -r 44100 -d "%NFCfilename%.%filetype%" trim 0 05:00:00
$soxParam = @('t waveaudio',
          '-c 1',
          '-r 44100',
          '-d'
          )

# py -m birdvoxdetect -t 22 -c -d 3 -v "NFC 2019-04-26 0000.wav"
$birdvoxParam = @('-t 30',
            '-c',
            '-d 3',
            '-v'
          )

Write-Host "Starting PM Recording."
Write-Host (Get-Date -Format "yyyy-MM-dd HH:mm:ss")

$PMFilename = "NFC " + (get-date -Format yyyy-MM-dd) + " " +  (Get-Date -Format HHmm) + ".wav"

& "c:\Program Files (x86)\sox-14-4-2\sox"

$AMFilename = "NFC " + (get-date -Format yyyy-MM-dd) + " " +  (Get-Date -Format HHmm) + ".wav"

$ToMidnight.Hours + ":" + $ToMidnight.Minutes