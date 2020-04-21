# Get Parameters 
Param(
    [Parameter(ValueFromPipeline=$true)][String]$Gain = 10,  #Currently Not In Use
    [Parameter(ValueFromPipeline=$true)][String]$Filetype = "WAV",
    [Parameter(ValueFromPipeline=$true)][String]$BirdVoxThreshold = 10,
    [Parameter(ValueFromPipeline=$true)][switch]$Test = $false
)


function Process-Detections {
    Param(
        [Parameter(Mandatory=$true)][string]$NFCPath
        )
        
    If(-not (Test-Path -Path $NFCPath)) {   # If $NFCPath is not a valid path
        Write-Host -ForegroundColor Red "'$NFCPath' Does not exist. Exiting..."
        Exit
        }

    # Get a list of valid NFC*.wav files in the specified subdirectory
    $NFCRegex = "^NFC \d{4}-\d\d-\d\d \d{4}_\d\d_\d\d_\d\d-\d\d_\d\d_\w{4}\.wav$" # Matches typical file pattern:  "NFC YYYY-MM-DD HHMM_HH_MM_SS-MS_%%_SPEC.wav"
    $NFCFiles = Get-ChildItem -Path $NFCPath | Where-Object -FilterScript {$_.Name -match $NFCRegex} | Select-Object -Property "Name"
        

    ForEach($NFCFile in $NFCFiles) {
      $NFCStartTime = Get-Date -Year ([convert]::ToInt32($NFCFile.name.Substring(4,4), 10)) -Month ([convert]::ToInt32($NFCFile.Name.Substring(9,2), 10)) -Day ([convert]::ToInt32($NFCFile.Name.Substring(12,2), 10)) -Hour ([convert]::ToInt32($NFCFile.Name.Substring(15,2), 10)) -Minute ([convert]::ToInt32($NFCFile.Name.Substring(17,2), 10)) -Second 0
      $NFCFileTime = $NFCStartTime.AddHours([convert]::ToInt32($NFCFile.Name.Substring(20,2), 10)).AddMinutes([convert]::ToInt32($NFCFile.Name.Substring(23,2), 10)).AddSeconds([convert]::ToInt32($NFCFile.Name.Substring(26,2), 10))
      
      # String of the banding code guessed by BirdVoxDetect: $NFCFile.Name.Substring(35,4)

      $NewFilename = "NFC " + $NFCFileTime.ToString("yyyy-MM-dd HH-mm-ss") + " - " + "PASS" + $NFCFile.Name.Substring(39,4)

      If(Test-Path -Path ($NFCPath + "\" + $NewFilename)) {   # If a file created on the same second as this already exists and would overlap, delete that file.
        Remove-Item -Path ($NFCPath + "\" + $NFCFile.Name)
      }
      Else {
        Rename-Item -Path ($NFCPath + "\" + $NFCFile.Name) -NewName $NewFilename
      }

      # Write-Host $NewFilename
        
    }
}


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
    [PSCustomObject]@{Month="March";	    MonthNum=03;	StartHour=20;	StartMin=0;		EndHour=06;	EndMin=0}
    [PSCustomObject]@{Month="April";	    MonthNum=04;	StartHour=20;	StartMin=30;	EndHour=05;	EndMin=15}
    [PSCustomObject]@{Month="May";	      MonthNum=05;	StartHour=21;	StartMin=30;	EndHour=04;	EndMin=15}
    [PSCustomObject]@{Month="June";	      MonthNum=06;	StartHour=20;	StartMin=0;		EndHour=06;	EndMin=0}
    [PSCustomObject]@{Month="July"; 	    MonthNum=07;	StartHour=20;	StartMin=0;		EndHour=06;	EndMin=0}
    [PSCustomObject]@{Month="August";	    MonthNum=08;	StartHour=20;	StartMin=0;		EndHour=06;	EndMin=0}
    [PSCustomObject]@{Month="September";	MonthNum=09;	StartHour=20;	StartMin=0;		EndHour=06;	EndMin=0}
    [PSCustomObject]@{Month="October";	  MonthNum=10;	StartHour=20;	StartMin=0;		EndHour=06;	EndMin=0}
    [PSCustomObject]@{Month="November";	  MonthNum=11;	StartHour=20;	StartMin=0;		EndHour=06;	EndMin=0}
	)







########################################### PM Recording ###########################################
# Establish current date and time and create a filename based on those variables for the PM recording. 

$PMFilename = "NFC " + (Get-Date).ToString("yyyy-MM-dd HHmm")
if($Test) { $PMRecordTime = "00:00:10" }
else {
  $PMRecordTime = ((Get-Date -hour 0 -Minute 0 -Second 0).AddDays(1) - (Get-Date)).ToString("hh\:mm\:ss") # Establish the amount of time until midnight so your PM recording will stop then and your AM recording can begin at midnight.
}

Write-Host -ForegroundColor Yellow "Starting PM Recording:" (Get-Date -Format "yyyy-MM-dd HH:mm:ss") " - Record Time:" $PMRecordTime

& ".\soxrecord.bat" ($PMFilename + "." + "$Filetype") $PMRecordTime


########################################### AM Recording ###########################################
# Establish current date and time and create a filename based on those variables for the AM recording. 

if($Test) { $AMRecordTime = "00:00:10" }
else {
  $AMFilename = "NFC " + (Get-Date).ToString("yyyy-MM-dd HHmm")
}

Write-Host -ForegroundColor Yellow "Starting AM Recording:" (Get-Date -Format "yyyy-MM-dd HH:mm:ss") "Record Time:" $AMRecordTime

& ".\soxrecord.bat" ($AMFilename + "." + "$Filetype") $AMRecordTime

Write-Host -ForegroundColor Yellow "Recording Complete:" (Get-Date -Format "yyyy-MM-dd HH:mm:ss")

########################################### BirdVoxDetect ###########################################
$birdvoxParam = @('-m',
             'birdvoxdetect',
             ('-t ' + $BirdVoxThreshold),
             '-c',
             '-d 3',
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
    & "C:\Program Files (x86)\sox-14-4-2\sox.exe" ($AMFilename + "." + $Filetype) ($AMFilename + "." + "flac")
    Remove-Item ($PMFilename + "." + $Filetype)
    & "C:\Program Files (x86)\sox-14-4-2\sox.exe" ($AMFilename + "." + $Filetype) ($AMFilename + "." + "flac")
    Remove-Item ($AMFilename + "." + $Filetype)
}


# (Get-Date) -lt (Get-Date -Month 6 -Day 20 -Hour 0 -Minute 0 -Second 0) #Is it before the summer solstice?

# Grab $year string from a substring of $PMFilename
# $year = $PMFilename.Substring(4, 4)
# Convert string to base-10 number:
# [int]$intNum = [convert]::ToInt32($test, 10)