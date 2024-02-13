# Inport-Module "C:\Users\lifailon\Documents\PowerShell\Modules\HardwareMonitor"
while ($True) {
    $Server_List = @(
        "192.168.3.100"
    )
    foreach ($Server in $Server_List) {
        $Data = Get-Sensor -ComputerName $Server -Port 8085 | Where-Object {($_.SensorName -match "Temperature") -or ($_.SensorType -match "Temperature")}
        Send-SensorToInfluxDB -ComputerName $Server -Data $Data -ServerInflux "192.168.3.102" -Port 8086 -Database "PowerShell" -Table "HardwareMonitor"
        Start-Sleep -Seconds 5
    }
}