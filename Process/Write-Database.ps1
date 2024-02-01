while ($True) {
    ### Local
    # $Data = Get-Sensor
    $Data = Get-Sensor -Libre
    # $Data = Get-Sensor -Libre -Library
    Send-TemperatureToInfluxDB -Data $Data -ServerInflux "192.168.3.102" -Port 8086 -Database "PowerShell" -Table "HardwareMonitor" # -LogWriteFile
    ### Remote
    # $Data = Get-Sensor -Server 192.168.3.100 -Port 8085
    # Send-TemperatureToInfluxDB -ComputerName "192.168.3.100" -Data $Data -ServerInflux "192.168.3.102" -Port 8086 -Database "PowerShell" -Table "HardwareMonitor"
    ### Timeout
    Start-Sleep -Seconds 5
}