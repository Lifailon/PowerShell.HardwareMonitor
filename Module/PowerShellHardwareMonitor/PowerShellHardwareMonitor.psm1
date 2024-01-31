function Get-Sensor {
    <#
    .SYNOPSIS
    Module for local and remote data acquisition temperature, load and other sensors system via OpenHardwareMonitor and LibreHardwareMonitor
    Implemented ways to get information: REST API, .NET library and CIM (Common Information Model)
    .DESCRIPTION
    Example:
    Get-Sensor
    Get-Sensor -Path "$home\Documents\OpenHardwareMonitor\OpenHardwareMonitor"
    Get-Sensor -Libre
    Get-Sensor -Libre -Path "$home\Documents\LibreHardwareMonitor"
    Get-Sensor -Libre -CIM
    Get-Sensor -Libre | Where-Object Value -ne 0 | Format-Table
    Get-Sensor -Server 192.168.3.99 | Where-Object Value -notmatch "^0,0" | Format-Table
    Get-Sensor -Server 192.168.3.99 -Port 8085
    .LINK
    https://github.com/Lifailon/PowerShellHardwareMonitor
    https://github.com/openhardwaremonitor/openhardwaremonitor
    https://github.com/LibreHardwareMonitor/LibreHardwareMonitor
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
    ### OpenHardwareMonitor and LibreHardwareMonitor REST API
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
    ### OpenHardwareMonitor and LibreHardwareMonitor via CIM
    else {
        if ($Libre -eq $True) {
            $ProcessName = "LibreHardwareMonitor"
            $NameSpace   = "root/LibreHardwareMonitor"
        }
        else {
            $ProcessName = "OpenHardwareMonitor"
            $NameSpace   = "root/OpenHardwareMonitor"
        }
        $Process_Used = Get-Process $ProcessName -ErrorAction Ignore
        if ($null -eq $Process_Used) {
            Start-Process "$path\$($ProcessName).exe" -WindowStyle Hidden # -NoNewWindow
        }
        $Hardware = Get-CimInstance -Namespace $NameSpace -ClassName Hardware | Select-Object Name,
        HardwareType,
        @{name = "Identifier";expression = {$_.Identifier -replace "\\|\?"}} # <<< Libre has a different parent ID compared to OpenHardwareMonitor
        $Sensors = Get-CimInstance -Namespace $NameSpace -ClassName Sensor 
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

function Send-TemperatureToInfluxDB {
    <#
    .SYNOPSIS
    Module for send metrics sensors temperature to the database InfluxDB 1.x
    .DESCRIPTION
    Example:
    Send-TemperatureToInfluxDB -Data $(Get-Sensor -Server 192.168.3.99) -LogConsole
    Send-TemperatureToInfluxDB -Data $(Get-Sensor -Server 192.168.3.99) -LogWriteFile
    while ($True) {
        $Data = Get-Sensor -Server 192.168.3.99
        Send-TemperatureToInfluxDB -Data $Data
        Start-Sleep -Seconds 3
    }
    .LINK
    https://github.com/Lifailon/PowerShellHardwareMonitor
    #>
    param (
        [Parameter(Mandatory,ValueFromPipeline)]$Data,
        [string]$ComputerName = $($(Get-CimInstance CIM_ComputerSystem).Name),
        [string]$ServerInflux = "192.168.3.102",
        [int]$Port            = 8086,
        [string]$Database     = "PowerShell",
        [string]$Table        = "HardwareMonitor",
        [switch]$LogConsole,
        [switch]$LogWriteFile,
        [string]$LogPath      = "$(($env:PSModulePath -split ";")[0])\PowerShellHardwareMonitor\influxdb.log"
    )
    $url = "http://$($ServerInflux):$($Port)/write?db=$Database"
    $TimeZone  = (Get-TimeZone).BaseUtcOffset.TotalMinutes
    $UnixTime  = (New-TimeSpan -Start (Get-Date "01/01/1970") -End ((Get-Date).AddMinutes(-$TimeZone))).TotalSeconds # if + for UTC 0 
    $TimeStamp = ([string]$UnixTime -replace "\..+") + "000000000"
    ### Get data only Temperatures
    $WhereData = $Data | Where-Object SensorName -eq Temperatures
    foreach ($wd in $WhereData) {
        $HardwareName = $wd.HardwareName -replace "\s","_"
        $SensorName = $wd.SensorName -replace "\s","_"
        $SensorType = $wd.SensorType -replace "\s","_"
        $Value = $wd.Value -replace "\,","." -replace "\s.+"
        Invoke-RestMethod -Method POST -Uri $url -Body `
        "$Table,Host=$ComputerName,HardwareName=$HardwareName,SensorName=$SensorName,SensorType=$SensorType Value=$Value $TimeStamp" > $null
        $LogText = "$(Get-Date)  $ComputerName  $HardwareName  $SensorName  $SensorType  $Value"
        if ($LogConsole) {
            Write-Host $LogText
        }
        elseif ($LogWriteFile) {
            $LogText | Out-File $LogPath
        }
    }
}