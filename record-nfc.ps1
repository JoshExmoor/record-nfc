# Get Parameters 
Param(
    [Parameter(ValueFromPipeline=$true)][String]$Gain = 10,  #Currently Not In Use
    [Parameter(ValueFromPipeline=$true)][String]$Filetype = "WAV",
    [Parameter(ValueFromPipeline=$true)][String]$BirdVoxThreshold = 10

)

# Select Start Time Based on Month:

# March: 	20:00-06:00
# April:  	20:30-05:15
# May: 	 	21:30-04:15
# June: 	22:00-04:00
# July: 	22:00-04:15
# August:	21:30-04:45
# Sept:		21:00-05:15
# October:	20:30-05:45
# November: 20:00-06:00

$StartEndTimes = @(
    [PSCustomObject]@{Month="March";	MonthNum=03;	StartHour=20;	StartMin=0;		EndHour=06;	EndMin=0}
	)




# py -m birdvoxdetect -t 22 -c -d 3 -v "NFC 2019-04-26 0000.wav"
$birdvoxParam = @('-m', 
            'birdvoxdetect'
            '-t $BirdVoxThreshold',
            '-c',
            '-d 3',
            '-v'
          )

Write-Host "Starting PM Recording."
Write-Host (Get-Date -Format "yyyy-MM-dd HH:mm:ss")

$ToMidnight = (Get-Date -hour 0 -Minute 0 -Second 0).AddDays(1) - (Get-Date)
$PMRecordTime = ($ToMidnight.ToString("hh") + ":" + $ToMidnight.ToString("mm") + ":" + $ToMidnight.ToString("ss"))

# Establish current date and time and create a filename based on those variables for the PM recording. 
$CurrentDate = (get-date -Format yyyy-MM-dd)
$CurrentTime = (Get-Date -Format HHmm)
$PMFilename = "NFC " + $CurrentDate + " " + $CurrentTime + "." + "$Filetype"


& ".\soxrecord.bat" $PMFilename $PMRecordTime


# Establish current date and time and create a filename based on those variables for the AM recording. 
$CurrentDate = (Get-Date -Format yyyy-MM-dd)
$CurrentTime = (Get-Date -Format HHmm)
$AMFilename = "NFC " + $CurrentDate + " " + $CurrentTime + "." + "$Filetype"

Write-Host $AMFilename

# $ToMidnight.Hours + ":" + $ToMidnight.Minutes

# Grab $year string from a substring of $PMFilename
# $year = $PMFilename.Substring(4, 4)
# Convert string to base-10 number:
# [int]$intNum = [convert]::ToInt32($test, 10)