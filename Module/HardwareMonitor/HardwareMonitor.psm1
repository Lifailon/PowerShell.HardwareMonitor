function Get-Sensor {
    <#
    .SYNOPSIS
    Module for local and remote data acquisition temperature, load and other sensors system via OpenHardwareMonitor and LibreHardwareMonitor
    Implemented ways to get information: REST API, CIM (Common Information Model) and .NET Library
    .DESCRIPTION
    Example:
    Get-Sensor
    Get-Sensor -Path "$home\Documents\OpenHardwareMonitor\OpenHardwareMonitor"
    Get-Sensor -Libre
    Get-Sensor -Libre -Path "$home\Documents\LibreHardwareMonitor"
    Get-Sensor -Libre | Where-Object Value -ne 0 | Format-Table
    Get-Sensor -Libre -Library
    Get-Sensor -Libre -Library | Where-Object Value -ne 0 | Format-Table
    Get-Sensor -Server 192.168.3.99
    Get-Sensor -Server 192.168.3.99 -Port 8086 | Where-Object Value -notmatch "^0,0" | Format-Table
    .LINK
    https://github.com/Lifailon/PowerShell.HardwareMonitor
    https://github.com/openhardwaremonitor/openhardwaremonitor
    https://github.com/LibreHardwareMonitor/LibreHardwareMonitor
    #>
    param (
        [switch]$Libre,
        [switch]$Library,
        $Server,
        [int]$Port = 8085,
        $Path
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
    ### LibreHardwareMonitor via .NET Library
    elseif (($Libre -eq $True) -and ($Library -eq $True)) {
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
    Send-TemperatureToInfluxDB -Data $(Get-Sensor -Libre) -LogConsole
    Send-TemperatureToInfluxDB -Data $(Get-Sensor -Libre -Library) -LogWriteFile
    while ($True) {
        $Data = Get-Sensor -Server 192.168.3.100 -Port 8085
        Send-TemperatureToInfluxDB -ComputerName "192.168.3.100" -Data $Data -ServerInflux "192.168.3.102" -Port 8086 -Database "PowerShell" -Table "HardwareMonitor"
        Start-Sleep -Seconds 5
    }
    .LINK
    https://github.com/Lifailon/PowerShell.HardwareMonitor
    https://github.com/openhardwaremonitor/openhardwaremonitor
    https://github.com/LibreHardwareMonitor/LibreHardwareMonitor
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
        [string]$LogPath      = "$(($env:PSModulePath -split ";")[0])\HardwareMonitor\influxdb.log"
    )
    $url = "http://$($ServerInflux):$($Port)/write?db=$Database"
    $TimeZone  = (Get-TimeZone).BaseUtcOffset.TotalMinutes
    $UnixTime  = (New-TimeSpan -Start (Get-Date "01/01/1970") -End ((Get-Date).AddMinutes(-$TimeZone))).TotalSeconds # if + for UTC 0 
    $TimeStamp = ([string]$UnixTime -replace "\..+") + "000000000"
    ### Get data only Temperature
    $WhereData = $Data | Where-Object {($_.SensorName -match "Temperature") -or ($_.SensorType -match "Temperature")}
    foreach ($wd in $WhereData) {
        $HardwareName = $wd.HardwareName -replace "\s","_"
        $SensorName = $wd.SensorName -replace "\s","_"
        $SensorType = $wd.SensorType -replace "\s","_"
        $Value = $wd.Value -replace "\,","." -replace "\s.+"
        Invoke-RestMethod -Method POST -Uri $url -Body `
        "$Table,Host=$ComputerName,HardwareName=$HardwareName,SensorName=$SensorName,SensorType=$SensorType Value=$Value $TimeStamp" > $null
        $LogText = "$(Get-Date -Format "dd.MM.yyyy hh:mm:ss")  $ComputerName  $HardwareName  $SensorName  $SensorType  $Value"
        if ($LogConsole) {
            Write-Host $LogText
        }
        elseif ($LogWriteFile) {
            $LogText | Out-File $LogPath -Append
        }
    }
}

function Start-SensorToInfluxDB {
    param (
        $Path
    )
    if ($null -eq $Path) {
        $Path = "$(($env:PSModulePath -split ";")[0])\HardwareMonitor"
    }
    $proc_id = $(Start-Process pwsh -ArgumentList "-File $Path\Write-Database.ps1" -Verb RunAs -WindowStyle Hidden -PassThru).id
    $proc_id > "$Path\process_id.txt"
}

function Stop-SensorToInfluxDB {
    param (
        $Path
    )
    if ($null -eq $Path) {
        $Path = "$(($env:PSModulePath -split ";")[0])\HardwareMonitor"
    }
    $proc_id = Get-Content "$path\process_id.txt"
    Start-Process pwsh -ArgumentList "-Command Stop-Process -Id $proc_id" -Verb RunAs
}

function Test-SensorToInfluxDB {
    param (
        $Path
    )
    if ($null -eq $Path) {
        $Path = "$(($env:PSModulePath -split ";")[0])\HardwareMonitor"
    }
    $proc_id = Get-Content "$path\process_id.txt"
    $proc_test = Get-Process -id $proc_id -ErrorAction Ignore
    if ($null -ne $proc_test) {
        Write-Host $true
    }
    else {
        Write-Host $false
    }
}