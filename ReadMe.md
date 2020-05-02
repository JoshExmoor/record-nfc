## Record-NFC

Record-NFC is a Powershell script which triggers 

###Required programs:
SoX - https://sourceforge.net/projects/sox/files/sox/
BirdVoxDetect - https://pypi.org/project/birdvoxdetect/

###How to Run and Optional command line parameters:


###Creating a SunriseSunet.csv
1. Download either the Excel or Open Office **NOAA_Solar_Calculations_year** spreadsheet from this link . https://www.esrl.noaa.gov/gmd/grad/solcalc/calcdetails.html
2. Open the file in your spreadsheet program of choice. 
3. Edit the highlighted Latitude, Longitude, Time Zone, and Year fields in the upper left. **Note:** The spreadsheet does not adjust for daylight saving time. Future versions of this script may correct for this, but for now it is suggested that you use the summer DST offset since most NFC recording is done during this period. This would be -4 for EST, -5 for CST, -6 for MST, and -7 for PST. 
4. At this time, you should change the header of column Y to just "Sunrise" without quotes. Change column Z to "Sunset"
5. Select Save-As, select the directory where the script is saved, choose *CSV (Comma delimited)* from the *Save As Type* drop down below filename, enter "SunriseSunset.csv" as the filename. 



###Included Files: 
Record-NFC.ps1 - Powershell Script to record and process the files based on advanced criteria. 
Process-Detections.ps1 - Contains function to rename the output files from BirdVox

###Deprecated:
NFCSchedule.bat - Deprecated batch file for simple "Record at x time for x length, process files." 
soxrecord.bat - Batch file used to enable recording, which has so far I have been unable to do using Powershell directly. 
