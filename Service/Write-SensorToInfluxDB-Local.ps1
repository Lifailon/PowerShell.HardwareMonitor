while ($True) {
    $Data = Get-Sensor | Where-Object {($_.SensorName -match "Temperature") -or ($_.SensorType -match "Temperature")}
    Send-SensorToInfluxDB -Data $Data -ServerInflux "192.168.3.102" -Port 8086 -Database "PowerShell" -Table "HardwareMonitor"
    Start-Sleep -Seconds 5
}