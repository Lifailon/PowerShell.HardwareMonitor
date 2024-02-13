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

Get-Service HardwareMonitor | Start-Service
Get-Service HardwareMonitor