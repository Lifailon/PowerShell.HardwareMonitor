$Path = "$(($env:PSModulePath -split ";")[0])\PowerShellHardwareMonitor"
$proc_id = Get-Content "$path\process_id.txt"
Start-Process pwsh -ArgumentList "-Command Stop-Process -Id $proc_id" -Verb RunAs