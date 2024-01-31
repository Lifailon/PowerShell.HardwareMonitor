# SensorsToInfluxDB

Module for monitoring of load and temperature sensors via Open Hardware Monitor with sending to Influx database and visualization in Grafana.

This module is convenient to use to quickly get the status of sensors on a remote computer, using only the PowerShell console at hand.

## 🚀 Install

1. **Download software [Open Hardware Monitor](https://openhardwaremonitor.org) on the server side:**

```PowerShell
$zip = "$home\Documents\ohm.zip"
Invoke-RestMethod https://openhardwaremonitor.org/files/openhardwaremonitor-v0.9.6.zip -OutFile $zip
$path = $zip -replace ".zip"
Expand-Archive -Path $zip -DestinationPath $path
```

2. **Run the server:**

Run **OpenHardwareMonitor.exe** and click Options -> Remote Web Server -> **Run**.

Port default: **8085** (configured in the section: Options -> Remote Web Server -> **Port**)

3. **Install module:**

Use the following construction to quickly install the module:

```PowerShell
$path = $(($env:PSModulePath -split ";")[0]) + "\Get-Sensor"
if (Test-Path $path) {
    Remove-Item $path -Force -Recurse
    New-Item -ItemType Directory -Path $path
} else {
    New-Item -ItemType Directory -Path $path
}
Invoke-RestMethod https://raw.githubusercontent.com/Lifailon/SensorsToInfluxDB/rsa/Get-Sensor/Get-Sensor.psm1 -OutFile "$path\Get-Sensor.psm1"
```

4. **Server connection:**

On the client side (this can be locally) check the module operation:

```PowerShell
PS C:\Users\lifailon\Desktop> Import-Module Get-Sensor
PS C:\Users\lifailon\Desktop> Get-Command -Module Get-Sensor

CommandType     Name                                               Version    Source    
-----------     ----                                               -------    ------    
Function        Get-Sensor                                         0.0        Get-Sensor
Function        Send-ToInfluxDB                                    0.0        Get-Sensor

PS C:\Users\lifailon\Desktop> Get-Sensor -Server localhost

Server        : localhost
MEM_Used_Proc : 65,4 %
MEM_Used      : 10,3 GB
MEM_Available : 5,4 GB
CPU           : 12th Gen Intel Core i7-1260P
CPU_Load      : 5,4 %
CPU_Temp      : 
GPU           : 
GPU_Load      : 
GPU_Temp      : 
GPU_Fan       : 
HDD           : Generic Hard Disk
HDD_Load      : 41,9 %
HDD_Temp      : 
```

😟 Temperature sensors are not supported in modern models for lack of support, this has been seen on multiple laptops.

## 📡 Remote workstation

```PowerShell
PS C:\Users\lifailon\Desktop> Get-Sensor -Server 192.168.3.100

Server        : 192.168.3.100
MEM_Used_Proc : 49,6 %
MEM_Used      : 15,8 GB
MEM_Available : 16,1 GB
CPU           : Intel Core i5-10400
CPU_Load      : 2,7 %
CPU_Temp      : 26,0 °C
GPU           : Radeon RX 570 Series
GPU_Load      : 0,0 %
GPU_Temp      : 36,0 °C
GPU_Fan       : 0 RPM
HDD           : {WDC WD2005FBYZ-01YCBB2, Generic Hard Disk}
HDD_Load      : {89,2 %, 28,6 %}
HDD_Temp      : 33,0 °C
```

## 📊 Send metrics to the database

Get help with the **Send-ToInfluxDB** cmdlet:

```PowerShell
PS C:\Users\lifailon\Desktop> (Get-Help Send-ToInfluxDB).Description

Example:
Get-Sensor -Server 192.168.3.100 | Send-ToInfluxDB -Server 192.168.3.104 -Port 8086 -Database powershell -Table sensors -Log
Use this construct to create service:
while ($True) {
    Get-Sensor -Server 192.168.3.100 | Send-ToInfluxDB
    Start-Sleep -Seconds 5
}
```

This design is suitable for continuously sending data to a database with the possibility of **creating a service**. With **Start-Sleep** you can set the frequency of sending messages. Using the **Server, Port, Database and Table parameters to module**, you can specify the settings for connecting to the database. The **Log parameter** is used to debug the output.

## 📑 Example

Output metrics to the console in **debug mode (-Log)**:

```PowerShell
PS C:\Users\lifailon\Desktop> while ($True) {
>>     Get-Sensor -Server 192.168.3.100 | Send-ToInfluxDB -Log
>>     Start-Sleep -Seconds 5
>> }
...
True
Host=192.168.3.100
Memory=50.7       
CPU=7.7
CPU_Temp=40.0     
GPU=0.0
GPU_Temp=42.0     
HDD_Temp=33.0     

True
Host=192.168.3.100
Memory=50.6       
CPU=6.0
CPU_Temp=35.0     
GPU=0.0
GPU_Temp=41.0     
HDD_Temp=33.0     

True
Host=192.168.3.100
Memory=50.6
CPU=2.1
CPU_Temp=35.0
GPU=0.0
GPU_Temp=42.0
HDD_Temp=33.0
...
```

**Data visualization in InfluxDB Studio:**

![Image alt](https://github.com/Lifailon/SensorsToInfluxDB/blob/rsa/Screen/InfluxDB-Data.jpg)

### 📈 Grafana

![Image alt](https://github.com/Lifailon/SensorsToInfluxDB/blob/rsa/Screen/Grafana-Dashboard.jpg)
