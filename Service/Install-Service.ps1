function Get-RunAs {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (!(Get-RunAs)) {
    $scriptPath = $MyInvocation.MyCommand.Definition
    $arguments = "-NoExit", "-File `"$scriptPath`""
    Start-Process pwsh -Verb RunAs -ArgumentList $arguments
    Exit
}

$script_path = "$home\Documents\Write-SensorToInfluxDB.ps1"

# Install nssm
$nssm_path = $(Get-ChildItem $env:TEMP | Where-Object Name -match "nssm")
if ($null -eq $nssm_path) {
    Invoke-RestMethod -Uri "https://nssm.cc/release/nssm-2.24.zip" -OutFile "$env:TEMP\nssm.zip"
    Expand-Archive -Path "$env:TEMP\nssm.zip" -DestinationPath $env:TEMP
    Remove-Item -Path "$env:TEMP\nssm.zip"
}

# Delete service
if (Get-Service HardwareMonitor -ErrorAction Ignore) {
    Get-Service HardwareMonitor | Stop-Service
    Remove-Service HardwareMonitor
}

# Install service
$service_name  = "HardwareMonitor"
$nssm_exe_path = $(Get-ChildItem $env:TEMP -Recurse | Where-Object name -match nssm.exe | Where-Object FullName -Match win64).FullName
$pwsh_path     = $(Get-Command pwsh.exe).Source
& $nssm_exe_path install $service_name $pwsh_path "-File $script_path"
& $nssm_exe_path set $Service_Name description "Sending HardwareMonitor sensors to the InfluxDB"
& $nssm_exe_path set $service_name AppExit Default Restart
# & $nssm_exe_path start $service_name
# & $nssm_exe_path status $service_name
Get-Service HardwareMonitor | Start-Service
Get-Service HardwareMonitor