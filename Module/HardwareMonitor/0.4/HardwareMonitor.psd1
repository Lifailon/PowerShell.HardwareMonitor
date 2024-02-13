@{
    RootModule        = "HardwareMonitor.psm1"
    ModuleVersion     = "0.4"
    Author            = "Lifailon"
    Copyright         = "Mozilla Public License Version 2.0"
    Description       = "Module for local and remote data acquisition temperature, load and other sensors system, for implement monitoring via InfluxDB and Grafana"
    PowerShellVersion = "5.1"
    PrivateData       = @{
        PSData = @{
            Tags         = @("Hardware", "HardwareMonitor","OpenHardwareMonitor","LibreHardwareMonitor","Monitoring","Sensor","Temperature","InfluxDB","Grafana","dotNET","api")
            ProjectUri   = "https://github.com/Lifailon/PowerShell.HardwareMonitor"
            LicenseUri   = "https://github.com/Lifailon/PowerShell.HardwareMonitor/blob/rsa/LICENSE"
            ReleaseNotes = "Service management and added autorization"
        }
    }
}