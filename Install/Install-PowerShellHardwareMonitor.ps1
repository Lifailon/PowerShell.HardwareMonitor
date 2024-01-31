$url = "https://raw.githubusercontent.com/Lifailon/PowerShellHardwareMonitor/rsa/Module/PowerShellHardwareMonitor/PowerShellHardwareMonitor.psm1"
$path = "$(($env:PSModulePath -split ";")[0])\PowerShellHardwareMonitor"
if (Test-Path $path) {
    Remove-Item "$path\*" -Force -Recurse
} else {
    New-Item -ItemType Directory -Path $path
}
Invoke-RestMethod $url -OutFile "$path\PowerShellHardwareMonitor.psm1"