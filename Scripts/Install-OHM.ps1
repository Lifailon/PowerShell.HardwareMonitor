$zip = "$home\Documents\ohm.zip"
Invoke-RestMethod https://openhardwaremonitor.org/files/openhardwaremonitor-v0.9.6.zip -OutFile $zip
$path = $zip -replace ".zip"
Expand-Archive -Path $zip -DestinationPath $path