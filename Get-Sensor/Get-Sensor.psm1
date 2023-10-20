function Get-Sensor {
<#
.SYNOPSIS
Module for monitoring of load and temperature sensors via Open Hardware Monitor
.DESCRIPTION
Example:
Get-Sensor -Server 192.168.3.100
Get-Sensor -Server 192.168.3.100 - Port 8085
Get-Sensor -Server 192.168.3.100 | Send-ToInfluxDB
.LINK
https://github.com/Lifailon/SensorsToInfluxDB
#>
param (
    [Parameter(Mandatory)][string]$Server,
    [int]$Port = 8085
)
$srv         = $Server+":"+$Port
$irm         = Invoke-RestMethod "http://$srv/data.json"
$Sensors     = $irm.Children.Children
$CPU         = $Sensors | Where-Object ImageURL -Match cpu
$CPU_Name    = $CPU.Text
$CPU_Temp    = $CPU.Children | Where-Object Text -Like Temperatures
$GPU         = $Sensors | Where-Object ImageURL -Match ati
$GPU_Name    = $GPU.Text
$GPU_Load    = $GPU.Children | Where-Object Text -Like Load
$GPU_Temp    = $GPU.Children | Where-Object Text -Like Temperatures
$GPU_Fan     = $GPU.Children | Where-Object Text -Like Fans
$HDD         = $Sensors | Where-Object ImageURL -Match hdd
$HDD_Name    = $HDD.Text
$HDD_Load    = $HDD.Children | Where-Object Text -Like Load
$HDD_Temp    = $HDD.Children | Where-Object Text -Like Temperatures
$Collections = New-Object System.Collections.Generic.List[System.Object]
$Collections.Add([PSCustomObject]@{
    Server = $Server;
    MEM_Used_Proc = ($Sensors.Children.Children | Where-Object Text -eq "Memory").Value;
    MEM_Used      = ($Sensors.Children.Children | Where-Object Text -eq "Used Memory").Value;
    MEM_Available = ($Sensors.Children.Children | Where-Object Text -eq "Available Memory").Value;
    CPU           = $CPU_Name;
    CPU_Load      = ($Sensors.Children.Children | Where-Object Text -eq "CPU Total").Value;
    CPU_Temp      = ($CPU_Temp.Children | Where-Object Text -eq "CPU Package").Value;
    GPU           = $GPU_Name;
    GPU_Load      = ($GPU_Load.Children | Where-Object Text -eq "GPU Core").Value;
    GPU_Temp      = ($GPU_Temp.Children | Where-Object Text -eq "GPU Core").Value;
    GPU_Fan       = ($GPU_Fan.Children | Where-Object Text -eq "GPU Fan").Value;
    HDD           = $HDD_Name;
    HDD_Load      = ($HDD_Load.Children | Where-Object Text -eq "Used Space").Value;
    HDD_Temp      = ($HDD_Temp.Children | Where-Object Text -eq "Temperature").Value
})
return $Collections
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