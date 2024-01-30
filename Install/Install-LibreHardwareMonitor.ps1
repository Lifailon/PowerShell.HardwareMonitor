$path = "$home\Documents\LibreHardwareMonitor"
$zip = "$($path).zip"
$url = "https://api.github.com/repos/LibreHardwareMonitor/LibreHardwareMonitor/releases/latest"
$url_down = $(Invoke-RestMethod $url).assets.browser_download_url
Invoke-RestMethod $url_down -OutFile $zip
Expand-Archive -Path $zip -DestinationPath $path
Remove-Item -Path $zip