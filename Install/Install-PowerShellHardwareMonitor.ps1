### Install module
$url = "https://raw.githubusercontent.com/Lifailon/PowerShellHardwareMonitor/rsa/Module/PowerShellHardwareMonitor/PowerShellHardwareMonitor.psm1"
$path = "$(($env:PSModulePath -split ";")[0])\PowerShellHardwareMonitor"
if (Test-Path $path) {
    Remove-Item "$path\*" -Force -Recurse
} else {
    New-Item -ItemType Directory -Path $path
}
Invoke-RestMethod $url -OutFile "$path\PowerShellHardwareMonitor.psm1"

### Install process scripts
$url_process = "https://api.github.com/repos/Lifailon/WinAPI/contents/WinAPI/Process"
$Process_Files = Invoke-RestMethod -Uri $url_process
foreach ($Process_File in $Process_Files) {
    $File_Name = $Process_File.name
    $Url_Download = $Process_File.download_url
    Invoke-RestMethod -Uri $Url_Download -OutFile "$path\$File_Name"
}