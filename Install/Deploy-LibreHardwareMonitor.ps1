$ServerList = (
    "server-01",
    "server-02"
)
foreach ($Server in $ServerList) {
    Invoke-Command $Server -ScriptBlock {
        # Install LibreHardwareMonitor
        $path = "$home\Documents\LibreHardwareMonitor"
        $zip = "$($path).zip"
        $url = "https://api.github.com/repos/LibreHardwareMonitor/LibreHardwareMonitor/releases/latest"
        $url_down = $(Invoke-RestMethod $url).assets.browser_download_url
        Invoke-RestMethod $url_down -OutFile $zip
        Expand-Archive -Path $zip -DestinationPath $path
        Remove-Item -Path $zip
        # Run Web-Server
        $Config = Get-Content "$path\LibreHardwareMonitor.config"
        $Config = $Config -replace 'key="runWebServerMenuItem" value="false"','key="runWebServerMenuItem" value="true"'
        #$Config = $Config -replace 'key="listenerPort" value="8085"','key="listenerPort" value="8086"'
        $Config = $Config -replace 'key="minTrayMenuItem" value="false"','key="minTrayMenuItem" value="true"'
        $Config = $Config -replace 'key="minCloseMenuItem" value="false"','key="minCloseMenuItem" value="true"'
        $Config | Out-File "$path\LibreHardwareMonitor.config"
        # Run Application
        Start-Process "$path\LibreHardwareMonitor.exe" -WindowStyle Hidden
    }
}