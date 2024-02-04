@{
    RootModule        = "PowerShell.HardwareMonitor.psm1"
    ModuleVersion     = "0.3"
    Author            = "Lifailon"
    Copyright         = "Apache-2.0"
    Description       = "Module for local and remote data acquisition temperature, load and other sensors system, for implement monitoring via InfluxDB and Grafana"
    PowerShellVersion = "7.3"
    PrivateData       = @{
        PSData = @{
            Tags         = @("HardwareMonitor","OpenHardwareMonitor","LibreHardwareMonitor","Monitoring","Temperature","Sensor","InfluxDB","dotNET","api")
            ProjectUri   = "https://github.com/Lifailon/PowerShell.HardwareMonitor"
            LicenseUri   = "https://github.com/Lifailon/PowerShell.HardwareMonitor/blob/rsa/README.md"
            ReleaseNotes = "Implemented ways to get information: REST API, CIM (Common Information Model) and .NET Library"
        }
    }
}