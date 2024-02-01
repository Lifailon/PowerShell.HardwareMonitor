$Path = "$(($env:PSModulePath -split ";")[0])\PowerShellHardwareMonitor"
$proc_id = $(Start-Process pwsh -ArgumentList "-File $Path\Write-Database.ps1" -Verb RunAs -WindowStyle Hidden -PassThru).id
$proc_id > "$Path\process_id.txt"