function Get-Sensor {
    <#
    .SYNOPSIS

    Version 0.2
    Module for local and remote monitoring of load and temperature sensors via OpenHardwareMonitor and LibreHardwareMonitor
    The module realizes all ways of obtaining information: .NET library, CIM (Common Information Model) and REST API.
    Response speed through CIM is on average 5 times faster (200 milliseconds vs. 1 second) because a running instance of the application is used to read.
    .DESCRIPTION
    Default:
    Get-Sensor -Path "$home\Documents\OpenHardwareMonitor\OpenHardwareMonitor"
    Get-Sensor -Libre -Path "$home\Documents\LibreHardwareMonitor"
    Example:
    Get-Sensor 
    Get-Sensor -Libre
    Get-Sensor -Libre -CIM
    Get-Sensor -Server 192.168.3.100
    Get-Sensor -Server 192.168.3.100 - Port 8085
    Get-Sensor -Server 192.168.3.100 | Send-ToInfluxDB
    .LINK
    https://github.com/Lifailon/PowerShellHardwareMonitor
    #>
    param (
        [switch]$Libre,
        [switch]$CIM,
        $Path,
        $Server,
        [int]$Port = 8085
    )
    if ($Libre) {
        if ($null -eq $path) {
            $path = "$home\Documents\LibreHardwareMonitor"
        }
    }
    else {
        if ($null -eq $path) {
            $path = "$home\Documents\OpenHardwareMonitor\OpenHardwareMonitor"
        }
    }
    ### REST API
    if ($null -ne $Server) {
        $Data = Invoke-RestMethod "http://$($Server):$($Port)/data.json"
        $Collections = New-Object System.Collections.Generic.List[System.Object]
        foreach ($Hardware in $($Data.Children.Children)) {
            $HardwareName = $Hardware.Text
            foreach ($Sensor in $($Hardware.Children)) {
                $SensorName = $Sensor.Text
                foreach ($SensorChildren in $($Sensor.Children)) {
                    $Collections.Add([PSCustomObject]@{
                        HardwareName = $HardwareName
                        SensorName = $SensorName
                        SensorType = $SensorChildren.Text
                        Value = $SensorChildren.Value
                        Min = $SensorChildren.Min
                        Max = $SensorChildren.Max
                    })
                }
            }
        }
        $Collections
    }
    ### LibreHardwareMonitor via .NET library
    elseif (($Libre -eq $True) -and ($CIM -eq $False)) {
        Add-Type -Path "$path\LibreHardwareMonitorLib.dll"
        $Computer = New-Object -TypeName LibreHardwareMonitor.Hardware.Computer
        $Computer.IsCpuEnabled         = $true
        $Computer.IsGpuEnabled         = $true
        $Computer.IsMemoryEnabled      = $true
        $Computer.IsMotherboardEnabled = $true
        $Computer.IsNetworkEnabled     = $true
        $Computer.IsPsuEnabled         = $true
        $Computer.IsStorageEnabled     = $true
        $Computer.IsControllerEnabled  = $true
        $Computer.IsBatteryEnabled     = $true
        $Computer.Open()
        $Sensors  = $computer.Hardware.Sensors | Select-Object @{
            name = "HardwareName"
            expression = {
                $_.Hardware.Sensors[0].Hardware.Name
            }
        },
        @{name = "SensorName";expression = { $_.Name }},
        @{name = "SensorType";expression = { "$($_.SensorType) $($_.Index)" }},
        @{name = "Value";expression = { [int]$_.Value }},
        @{name = "Min";expression = { [int]$_.Min }},
        @{name = "Max";expression = { [int]$_.Max }}
        $Sensors | Sort-Object HardwareName,SensorType,SensorName
    }
    ### OpenHardwareMonitor or LibreHardwareMonitor via CIM
    else {
        $Process_Used = Get-Process OpenHardwareMonitor -ErrorAction Ignore
        if ($null -eq $Process_Used) {
            Start-Process "$path\OpenHardwareMonitor.exe" -WindowStyle Hidden # -NoNewWindow
        }
        if ($Libre -eq $True) {
            $Hardware = Get-CimInstance -Namespace "root/LibreHardwareMonitor" -ClassName Hardware | Select-Object Name,
            HardwareType,
            @{name = "Identifier";expression = {$_.Identifier -replace "\\|\?"}} # <<< Libre has a different parent ID from OpenHardwareMonitor
            $Sensors = Get-CimInstance -Namespace "root/LibreHardwareMonitor" -ClassName Sensor 
        }
        else {
            $Hardware = Get-CimInstance -Namespace "root/OpenHardwareMonitor" -ClassName Hardware | Select-Object Name,
            HardwareType,
            Identifier
            $Sensors = Get-CimInstance -Namespace "root/OpenHardwareMonitor" -ClassName Sensor 
        }
        $Sensors = $Sensors | Select-Object @{
            name = "HardwareName"
            expression = {
                $Parent = $_.Parent -replace "\\|\?"
                $Hardware | Where-Object Identifier -match $Parent | Select-Object -ExpandProperty Name
            }
        },
        @{name = "SensorName";expression = { $_.Name }},
        @{name = "SensorType";expression = { "$($_.SensorType) $($_.Index)" }},
        @{name = "Value";expression = { [int]$_.Value }},
        @{name = "Min";expression = { [int]$_.Min }},
        @{name = "Max";expression = { [int]$_.Max }}
        $Sensors | Sort-Object HardwareName,SensorType,SensorName
    }
}

function Send-ToInfluxDB {
<#
.SYNOPSIS
Module for send metrics sensors to the database
.DESCRIPTION
Example:
Get-Sensor -Server 192.168.3.100 | Send-ToInfluxDB -Server 192.168.3.104 -Port 8086 -Database powershell -Table sensors -Log
Use this construct to create service:
while ($True) {
    Get-Sensor -Server 192.168.3.100 | Send-ToInfluxDB
    Start-Sleep -Seconds 5
}
.LINK
https://github.com/Lifailon/SensorsToInfluxDB
#>
param (
    [Parameter(Mandatory,ValueFromPipeline)][array]$Data,
    [string]$Server       = "192.168.3.104",
    [int]$Port            = 8086,
    [string]$Database     = "powershell",
    [string]$Table        = "sensors",
    [switch]$Log
)
$srv = $Server+":"+$Port
$url = "http://$srv/write?db=$Database"
$tz  = (Get-TimeZone).BaseUtcOffset.TotalMinutes
$unixtime  = (New-TimeSpan -Start (Get-Date "01/01/1970") -End ((Get-Date).AddMinutes(-$tz))).TotalSeconds # UTC 0 (if +)
$timestamp = ([string]$unixtime -replace "\..+") + "000000000"
$ComputerName  = $Data.Server
$Memory        = $Data.MEM_Used_Proc -replace "\,","." -replace "\s.+"
$CPU           = $Data.CPU_Load -replace "\,","." -replace "\s.+"
$CPU_Temp      = $Data.CPU_Temp -replace "\,","." -replace "\s.+"
$GPU           = $Data.GPU_Load -replace "\,","." -replace "\s.+"
$GPU_Temp      = $Data.GPU_Temp -replace "\,","." -replace "\s.+"
$HDD_Temp      = $Data.HDD_Temp -replace "\,","." -replace "\s.+"
try {
    Invoke-RestMethod -Method POST -Uri $url -Body `
    "$Table,Host=$ComputerName Memory=$Memory,CPU=$CPU,CPU_Temp=$CPU_Temp,GPU=$GPU,GPU_Temp=$GPU_Temp,HDD_Temp=$HDD_Temp $timestamp" > $null
    Write-Host True -ForegroundColor Green
}
catch {
    Write-Error False
}
finally {
    if ($Log) {
        Write-Host Host=$ComputerName
        Write-Host Memory=$Memory
        Write-Host CPU=$CPU
        Write-Host CPU_Temp=$CPU_Temp
        Write-Host GPU=$GPU
        Write-Host GPU_Temp=$GPU_Temp
        Write-Host HDD_Temp=$HDD_Temp
        Write-Host
    }
}
}