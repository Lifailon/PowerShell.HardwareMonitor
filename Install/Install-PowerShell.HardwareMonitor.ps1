$version = "0.4"
$path = "$(($env:PSModulePath -split ";")[0])\HardwareMonitor\$version"
if (Test-Path $path) {
    Remove-Item "$path\*" -Force -Recurse
} else {
    New-Item -ItemType Directory -Path $path
    New-Item -ItemType Directory -Path "$path\Service"
}

$url = "https://api.github.com/repos/Lifailon/PowerShell.HardwareMonitor/contents/Module/HardwareMonitor/$version"
$Files = Invoke-RestMethod -Uri $url
foreach ($File in $Files) {
    $File_Name = $File.name
    $Url_Download = $File.download_url
    Invoke-RestMethod -Uri $Url_Download -OutFile "$path\$File_Name"
}

$url = "https://api.github.com/repos/Lifailon/PowerShell.HardwareMonitor/contents/Service"
$Files = Invoke-RestMethod -Uri $url
foreach ($File in $Files) {
    $File_Name = $File.name
    $Url_Download = $File.download_url
    Invoke-RestMethod -Uri $Url_Download -OutFile "$path\Service\$File_Name"
}