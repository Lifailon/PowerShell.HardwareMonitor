function Get-Sensor {
    <#
    .SYNOPSIS
    Module for local and remote data acquisition temperature, load and other sensors system via OpenHardwareMonitor and LibreHardwareMonitor
    Implemented ways to get information: REST API, CIM (Common Information Model) and .NET Library
    .DESCRIPTION
    Example:
    Get-Sensor
    Get-Sensor -Path "$home\Documents\LibreHardwareMonitor"
    Get-Sensor -Open
    Get-Sensor -Open -Path "$home\Documents\OpenHardwareMonitor\OpenHardwareMonitor"
    Get-Sensor -Library
    Get-Sensor -Library | Where-Object Value -ne 0 | Format-Table
    Get-Sensor -ComputerName 192.168.3.100
    Get-Sensor -ComputerName 192.168.3.100 -User "hardware" -Password "monitor"
    Get-Sensor -ComputerName 192.168.3.100 -Port 8086 | Where-Object Value -notmatch "^0,0" | Format-Table
    .LINK
    https://github.com/Lifailon/PowerShell.HardwareMonitor
    https://github.com/openhardwaremonitor/openhardwaremonitor
    https://github.com/LibreHardwareMonitor/LibreHardwareMonitor
    #>
    param (
        [switch]$Open,
        [switch]$Library,
        $ComputerName,
        [int]$Port = 8085,
        $User,
        $Password,
        $Path
    )
    if ($Open) {
        if ($null -eq $path) {
            $path = "$home\Documents\OpenHardwareMonitor\OpenHardwareMonitor"
        }
    }
    else {
        if ($null -eq $path) {
            $path = "$home\Documents\LibreHardwareMonitor"
        }
    }
    ### REST API
    if ($null -ne $ComputerName) {
        if (($null -ne $User) -and ($null -ne $Password)) {
            $pass = $password | ConvertTo-SecureString -AsPlainText -Force
            $Cred = [System.Management.Automation.PSCredential]::new($user,$pass)
            if ($PSVersionTable.PSVersion.Major -eq 5) {
                $Data = Invoke-RestMethod "http://$($ComputerName):$($Port)/data.json" -Credential $Cred
            }
            else {
                $Data = Invoke-RestMethod "http://$($ComputerName):$($Port)/data.json" -Credential $Cred -AllowUnencryptedAuthentication
            }
        }
        else {
            $Data = Invoke-RestMethod "http://$($ComputerName):$($Port)/data.json"
        }
        $Collections = New-Object System.Collections.Generic.List[System.Object]
        foreach ($Hardware in $($Data.Children.Children)) {
            if ($null -ne $Hardware.Children.Children.Children) {
                $HardwareName = "$($Hardware.Text) $($Hardware.Children.Text)"
                $Sensors = $($Hardware.Children.Children)                
            }
            else {
                $HardwareName = $Hardware.Text
                $Sensors = $($Hardware.Children)
            }
            foreach ($Sensor in $Sensors) {
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
    else {
        ### .NET Library
        if ($Library -eq $True) {
            if ($Open) {
                Add-Type -Path "$path\OpenHardwareMonitorLib.dll"
                $Computer = New-Object -TypeName OpenHardwareMonitor.Hardware.Computer
                $Computer.MainboardEnabled = $True
                $Computer.CPUEnabled = $True
                $Computer.RAMEnabled = $True
                $Computer.GPUEnabled = $True
                $Computer.FanControllerEnabled = $True
                $Computer.HDDEnabled = $True
            }
            else {
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
            }
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
            $Computer.Close()
        }
        ### WMI
        else {
            if ($Open -eq $false) {
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
}

function Send-SensorToInfluxDB {
    <#
    .SYNOPSIS
    Module for send metrics sensors temperature to the database InfluxDB 1.x
    .DESCRIPTION
    Local example:
    $DataTemperature = Get-Sensor | Where-Object {($_.SensorName -match "Temperature") -or ($_.SensorType -match "Temperature")}
    Send-SensorToInfluxDB -Data $DataTemperature
    Remote example:
    while ($True) {
        $Server = "192.168.3.100"
        $Data = Get-Sensor -ComputerName $Server -Port 8085 | Where-Object {($_.SensorName -match "Temperature") -or ($_.SensorType -match "Temperature")}
        Send-SensorToInfluxDB -ComputerName $Server -Data $Data -ServerInflux "192.168.3.102" -Port 8086 -Database "PowerShell" -Table "HardwareMonitor"
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
        $User,
        $Password
    )
    if (($null -ne $User) -and ($null -ne $Password)) {
        $pass = $password | ConvertTo-SecureString -AsPlainText -Force
        $Cred = [System.Management.Automation.PSCredential]::new($user,$pass)
    }
    $url = "http://$($ServerInflux):$($Port)/write?db=$Database"
    $TimeZone  = (Get-TimeZone).BaseUtcOffset.TotalMinutes
    $UnixTime  = (New-TimeSpan -Start (Get-Date "01/01/1970") -End ((Get-Date).AddMinutes(-$TimeZone))).TotalSeconds # if + for UTC 0 
    $TimeStamp = ([string]$UnixTime -replace "\..+") + "000000000"
    foreach ($d in $Data) {
        $HardwareName = $d.HardwareName -replace "\s","_"
        $SensorName = $d.SensorName -replace "\s","_"
        $SensorType = $d.SensorType -replace "\s","_"
        $Value = $d.Value -replace "\,","." -replace "\s.+"
        $Body = "$Table,Host=$ComputerName,HardwareName=$HardwareName,SensorName=$SensorName,SensorType=$SensorType Value=$Value $TimeStamp"
        if ($PSVersionTable.PSVersion.Major -eq 5) {
            Invoke-RestMethod -Method POST -Uri $url -Body $Body -Credential $Cred | Out-Null
        }
        else {
            Invoke-RestMethod -Method POST -Uri $url -Body $Body -Credential $Cred -AllowUnencryptedAuthentication | Out-Null
        }
    }
}

function Install-LibreHardwareMonitor {
    $path = "$home\Documents\LibreHardwareMonitor"
    $zip = "$($path).zip"
    $url = "https://api.github.com/repos/LibreHardwareMonitor/LibreHardwareMonitor/releases/latest"
    $url_down = $(Invoke-RestMethod $url).assets.browser_download_url
    Invoke-RestMethod $url_down -OutFile $zip
    Expand-Archive -Path $zip -DestinationPath $path
    Remove-Item -Path $zip
}

function Install-OpenHardwareMonitor {
    $url = "https://openhardwaremonitor.org/files/openhardwaremonitor-v0.9.6.zip"
    $path = "$home\Documents\OpenHardwareMonitor"
    $zip = "$($path).zip"
    Invoke-RestMethod $url -OutFile $zip
    Expand-Archive -Path $zip -DestinationPath $path
    Remove-Item -Path $zip
}