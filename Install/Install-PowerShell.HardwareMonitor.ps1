$path = "$(($env:PSModulePath -split ";")[0])\HardwareMonitor"
if (Test-Path $path) {
    Remove-Item "$path\*" -Force -Recurse
} else {
    New-Item -ItemType Directory -Path $path
}

$url = "https://api.github.com/repos/Lifailon/PowerShell.HardwareMonitor/contents/Module/HardwareMonitor"
$Files = Invoke-RestMethod -Uri $url
foreach ($File in $Files) {
    $File_Name = $File.name
    $Url_Download = $File.download_url
    Invoke-RestMethod -Uri $Url_Download -OutFile "$path\$File_Name"
}

$url = "https://api.github.com/repos/Lifailon/PowerShell.HardwareMonitor/contents/InfluxDB"
$Files = Invoke-RestMethod -Uri $url
foreach ($File in $Files) {
    $File_Name = $File.name
    $Url_Download = $File.download_url
    Invoke-RestMethod -Uri $Url_Download -OutFile "$path\$File_Name"
}