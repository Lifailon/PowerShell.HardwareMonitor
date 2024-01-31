# PowerShellHardwareMonitor

Module for local and remote data acquisition temperature, load and other sensors system via [OpenHardwareMonitor](https://github.com/openhardwaremonitor/openhardwaremonitor) and [LibreHardwareMonitor](https://github.com/LibreHardwareMonitor/LibreHardwareMonitor) to output PowerShell console.

This module implements an out-of-the-box and universal solution for configuring temperature sensor monitoring with InfluxDB and visualization in Grafana.

🔗 Implemented ways to get information:

✅ REST API
✅ .NET Library
✅ CIM (Common Information Model)

> Response speed through CIM is on average 5 times faster (200 milliseconds vs. 1 second) because a running instance of the application is used to retrieve the data, which stores the minimum and maximum values.

## 🚀 Install module

Dependencies: [PowerShell Core](https://github.com/PowerShell/PowerShell)

To quickly install or update the module, utilize the command in your PowerShell console:

```PowerShell
Invoke-Expression(New-Object Net.WebClient).DownloadString("https://raw.githubusercontent.com/Lifailon/PowerShellHardwareMonitor/rsa/Install/Install-PowerShellHardwareMonitor.ps1")
```

## Examples

```PowerShell
Import-Module PowerShellHardwareMonitor
```