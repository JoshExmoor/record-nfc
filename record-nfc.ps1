# Get Parameters 
Param(
    [Parameter(ValueFromPipeline=$true)][String]$Gain = 10,  #Currently Not In Use
    [Parameter(ValueFromPipeline=$true)][String]$Filetype = "WAV",
    [Parameter(ValueFromPipeline=$true)][String]$BirdVoxThreshold = 10,
    [Parameter(ValueFromPipeline=$true)][String]$BirdVoxDuration = 3,
    [Parameter(ValueFromPipeline=$true)][String]$SunriseSunsetFilename = '.\SunriseSunset.csv',
    [Parameter(ValueFromPipeline=$true)][Single]$SunsetOffset = 1.0,   # How many hours after sunset do you want recording to start?      
    [Parameter(ValueFromPipeline=$true)][Single]$SunriseOffset = -1.5, # How many hours before Sunrise do you want recording to stop?
    [Parameter(ValueFromPipeline=$true)][switch]$Test = $false,
    [Parameter(ValueFromPipeline=$true)][switch]$PauseForInput = $false
)

. ".\Process-Detections.ps1"

########################################### Auto Start/stop ###########################################

If(Test-Path $SunriseSunsetFilename) {
  $SunriseSunset = Import-Csv $SunriseSunsetFilename
  $Today = $SunriseSunset | Where-Object -Property "Date" -match (Get-Date -Format "^M/d")
  $Sunset = [datetime]::Parse($Today.Sunset)
  $Sunrise = [datetime]::Parse($Today.Sunrise).AddDays(1) 
  $StartRecord = $Sunset.AddHours($SunsetOffset)
  $StopRecord  = $Sunrise.AddHours($SunriseOffset)
}
Else {   #If 
  Write-Host -ForegroundColor Yellow "No SunriseSunset.csv file detected, reverting to default times:"  
  $StartRecord = Get-Date -Hour 21 -Minute 00 -Second 00
  $StopRecord  = (Get-Date -Hour 5 -Minute 00 -Second 00).AddDays(1)
  Write-Host -ForegroundColor Yellow "Start Time:" $StartRecord.ToString("HH:mm:ss")
  Write-Host -ForegroundColor Yellow "Start Time:" $StopRecord.ToString("HH:mm:ss")
}

if((New-TimeSpan -end $StartRecord) -gt 0) {  # If The StartRecord time has not already passed
  Write-Host -ForegroundColor Blue "Will start recording at" $StartRecord.ToString("HH:mm:ss")
  Sleep -Seconds (New-TimeSpan -End $StartRecord).TotalSeconds
}


########################################### PM Recording ###########################################
# Establish current date and time and create a filename based on those variables for the PM recording. 

$PMFilename = "NFC " + (Get-Date).ToString("yyyy-MM-dd HHmm")
if($Test) { $PMRecordTime = "00:00:10" }  
else {
  $PMRecordTime = ((Get-Date -hour 0 -Minute 0 -Second 0).AddDays(1) - (Get-Date)).ToString("hh\:mm\:ss") # Establish the amount of time until midnight so your PM recording will stop then and your AM recording can begin at midnight.
}

Write-Host -ForegroundColor Green "Starting PM Recording:" (Get-Date -Format "yyyy-MM-dd HH:mm:ss") " - Record Time:" $PMRecordTime $AMFilename

& ".\soxrecord.bat" ($PMFilename + "." + "$Filetype") $PMRecordTime


########################################### AM Recording ###########################################
# Establish current date and time and create a filename based on those variables for the AM recording. 

if($Test) { $AMRecordTime = "00:00:10" }
else {
  $AMRecordTime = "04:30:00"
}

$AMFilename = "NFC " + (Get-Date).ToString("yyyy-MM-dd HHmm")

Write-Host -ForegroundColor Green "Starting AM Recording:" (Get-Date -Format "yyyy-MM-dd HH:mm:ss") "Record Time:" $AMRecordTime $AMFilename

& ".\soxrecord.bat" ($AMFilename + "." + "$Filetype") $AMRecordTime

Write-Host -ForegroundColor Green "Recording Complete:" (Get-Date -Format "yyyy-MM-dd HH:mm:ss")

########################################### BirdVoxDetect ###########################################
$birdvoxParam = @('-m',
             'birdvoxdetect',
             ('-t ' + $BirdVoxThreshold),
             '-c',
             ('-d ' + $BirdVoxDuration),
             '-v',
             ($PMFilename + "." + "$Filetype"),
             ($AMFilename + "." + "$Filetype")
             )


& C:\Windows\py.exe $birdvoxParam #Run BirdVoxDetect with above parameters.

#################################### Process Output of BirdvoxDetect ##################################

Process-Detections -NFCPath (".\" + $PMFilename + "_clips")
Process-Detections -NFCPath (".\" + $AMFilename + "_clips")

########################################### Convert to FLAC ###########################################

If($FIletype -eq "WAV") {  #Convert WAVs to FLAC for reduced storage. 
    & "C:\Program Files (x86)\sox-14-4-2\sox.exe" ($PMFilename + "." + $Filetype) ($PMFilename + "." + "flac")
    Remove-Item ($PMFilename + "." + $Filetype)
    & "C:\Program Files (x86)\sox-14-4-2\sox.exe" ($AMFilename + "." + $Filetype) ($AMFilename + "." + "flac")
    Remove-Item ($AMFilename + "." + $Filetype)
}


If($PauseForInput) {    #Use if you are running from Task Scheduler and want the window to remain open after completion.
  Write-Host 'Press any key to continue...'
  $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
}

# (Get-Date) -lt (Get-Date -Month 6 -Day 20 -Hour 0 -Minute 0 -Second 0) #Is it before the summer solstice?

# Grab $year string from a substring of $PMFilename
# $year = $PMFilename.Substring(4, 4)
# Convert string to base-10 number:
# [int]$intNum = [convert]::ToInt32($test, 10)