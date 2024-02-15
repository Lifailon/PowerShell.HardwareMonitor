# PowerShell.HardwareMonitor

[![GitHub Tag](https://img.shields.io/github/v/tag/Lifailon/PowerShell.HardwareMonitor?logo=GitHub&label=GitHub&link=https%3A%2F%2Fgithub.com%2FLifailon%2FPowerShell.HardwareMonitor)
](https://github.com/Lifailon/PowerShell.HardwareMonitor)
[![NuGet Version](https://img.shields.io/nuget/v/HardwareMonitor?logo=NuGet&label=NuGet&link=https%3A%2F%2Fwww.nuget.org%2Fpackages%2FHardwareMonitor)](https://www.nuget.org/packages/HardwareMonitor)
[![GitHub top language](https://img.shields.io/github/languages/top/Lifailon/PowerShell.HardwareMonitor?logo=PowerShell&link=https%3A%2F%2Fgithub.com%2FPowerShell%2FPowerShell)](https://github.com/PowerShell/PowerShell)

Publication on **Habr** (ru language): [Мониторинг температуры Windows. Создание метрик, настройка InfluxDB и Grafana](https://habr.com/ru/articles/793296/)

Module for local and remote data acquisition temperature, fan speeds, load and other sensors system via [LibreHardwareMonitor](https://github.com/LibreHardwareMonitor/LibreHardwareMonitor) and [OpenHardwareMonitor](https://github.com/openhardwaremonitor/openhardwaremonitor) to output PowerShell console.

This module implements an out-of-the-box and universal solution for configuring temperature sensor monitoring with **InfluxDB v1.x** and visualization in **Grafana**.

🔗 Implemented methods to get information:

- ✅ REST API
- ✅ WMI/CIM
- ✅ Library .NET (incomplete)

📌 Notes:

- [🚀 Install](#-install)
- [📑 Data](#-data)
- [📊 InfluxDB connection](#-influxdb-connection)
- [🔔 Creat service](#-creat-service)
- [📈 Grafana dashboard](#-grafana-dashboard)

## 🚀 Install

### 📥 Module

Install module from [NuGet repository](https://www.nuget.org/packages/HardwareMonitor):

```PowerShell
Install-Module HardwareMonitor -Repository NuGet -Scope AllUsers
```

> Use the installation for all users (parameter `Scoop`) to avoid importing the module during script configuration to send data to the database during service creation.

💡 You must have a NuGet repository registered:

```PowerShell
Register-PSRepository -Name "NuGet" -SourceLocation "https://www.nuget.org/api/v2" -InstallationPolicy Trusted
```

Import the module and get a list of available commands:

```PowerShell
Import-Module HardwareMonitor
Get-Command -Module HardwareMonitor

CommandType     Name                               Version    Source
-----------     ----                               -------    ------
Function        Get-Sensor                         0.4        HardwareMonitor
Function        Install-LibreHardwareMonitor       0.4        HardwareMonitor
Function        Install-OpenHardwareMonitor        0.4        HardwareMonitor
Function        Send-SensorToInfluxDB              0.4        HardwareMonitor
```

### 💡 Dependencies

You need to set one of the two data retrieval sources. You can use the functions built into the module to set them (default installation path `C:\Users\<UserName>\Documents`):

```PowerShell
Install-LibreHardwareMonitor
Install-OpenHardwareMonitor
```

## 📑 Data

Difference in the amount of unique (non-empty) data, using the **HUAWEI MateBook X Pro** laptop as an example.

### REST API via OpenHardwareMonitor

The software can act as an agent for data from which it can be collected remotely.

```PowerShell
> Get-Sensor -ComputerName 192.168.3.99 -Port 8086 | Format-Table

HardwareName                 SensorName SensorType       Value   Min     Max
------------                 ---------- ----------       -----   ---     ---
12th Gen Intel Core i7-1260P Load       CPU Total        7,3 %   2,0 %   17,2 %
12th Gen Intel Core i7-1260P Load       CPU Core #1      11,7 %  0,0 %   50,0 %
12th Gen Intel Core i7-1260P Load       CPU Core #2      0,0 %   0,0 %   27,3 %
12th Gen Intel Core i7-1260P Load       CPU Core #3      0,0 %   0,0 %   18,0 %
12th Gen Intel Core i7-1260P Load       CPU Core #4      0,0 %   0,0 %   4,8 %
12th Gen Intel Core i7-1260P Load       CPU Core #5      10,9 %  0,0 %   28,1 %
12th Gen Intel Core i7-1260P Load       CPU Core #6      7,8 %   0,0 %   45,3 %
12th Gen Intel Core i7-1260P Load       CPU Core #7      9,4 %   0,0 %   51,6 %
12th Gen Intel Core i7-1260P Load       CPU Core #8      18,8 %  0,0 %   46,9 %
12th Gen Intel Core i7-1260P Load       CPU Core #9      9,4 %   0,0 %   18,8 %
12th Gen Intel Core i7-1260P Load       CPU Core #10     4,7 %   0,0 %   23,4 %
12th Gen Intel Core i7-1260P Load       CPU Core #11     21,9 %  0,0 %   34,4 %
12th Gen Intel Core i7-1260P Load       CPU Core #12     10,9 %  0,0 %   26,6 %
Generic Memory               Load       Memory           75,3 %  73,5 %  76,3 %
Generic Memory               Data       Used Memory      11,8 GB 11,6 GB 12,0 GB
Generic Memory               Data       Available Memory 3,9 GB  3,7 GB  4,2 GB
```

### REST API via LibreHardwareMonitor

You can also **use authorization** (if it is configured on the LibreHardwareMonitor side):

```PowerShell
> Get-Sensor -ComputerName 192.168.3.99 -Port 8085
Invoke-RestMethod: Response status code does not indicate success: 401 (Unauthorized).
> Get-Sensor -ComputerName 192.168.3.99 -Port 8085 -User hardware -Password monitor | Where-Object Value -notmatch "^0,0" | Format-Table

HardwareName                     SensorName                     SensorType      Value   Min       Max
------------                     ----------                     ----------      -----   ---       ---
12th Gen Intel Core i7-1260P     Bus Speed                      Clock 0           100   100       100
12th Gen Intel Core i7-1260P     CPU Core #1                    Clock 1          4593   399      4693
12th Gen Intel Core i7-1260P     CPU Core #10                   Clock 10          998   399      3395
12th Gen Intel Core i7-1260P     CPU Core #11                   Clock 11         1997   399      3395
12th Gen Intel Core i7-1260P     CPU Core #12                   Clock 12          998   399      3395
12th Gen Intel Core i7-1260P     CPU Core #2                    Clock 2          2396   399      4693
12th Gen Intel Core i7-1260P     CPU Core #3                    Clock 3          2097   399      4693
12th Gen Intel Core i7-1260P     CPU Core #4                    Clock 4          1498   399      4693
12th Gen Intel Core i7-1260P     CPU Core #5                    Clock 5          1098   399      3395
12th Gen Intel Core i7-1260P     CPU Core #6                    Clock 6          1098   399      3395
12th Gen Intel Core i7-1260P     CPU Core #7                    Clock 7          1198   399      3395
12th Gen Intel Core i7-1260P     CPU Core #8                    Clock 8          1098   399      3395
12th Gen Intel Core i7-1260P     CPU Core #9                    Clock 9          1198   399      3395
12th Gen Intel Core i7-1260P     CPU Total                      Load 0              7     0        96
12th Gen Intel Core i7-1260P     CPU Core Max                   Load 1             20     1       100
12th Gen Intel Core i7-1260P     CPU Core #5                    Load 10            12     0       100
12th Gen Intel Core i7-1260P     CPU Core #6                    Load 11            10     0       100
12th Gen Intel Core i7-1260P     CPU Core #7                    Load 12             9     0       100
12th Gen Intel Core i7-1260P     CPU Core #8                    Load 13            11     0       100
12th Gen Intel Core i7-1260P     CPU Core #9                    Load 14            11     0       100
12th Gen Intel Core i7-1260P     CPU Core #10                   Load 15             8     0       100
12th Gen Intel Core i7-1260P     CPU Core #11                   Load 16             9     0       100
12th Gen Intel Core i7-1260P     CPU Core #12                   Load 17             9     0       100
12th Gen Intel Core i7-1260P     CPU Core #1 Thread #1          Load 2             20     0       100
12th Gen Intel Core i7-1260P     CPU Core #1 Thread #2          Load 3              0     0        94
12th Gen Intel Core i7-1260P     CPU Core #2 Thread #1          Load 4              7     0        95
12th Gen Intel Core i7-1260P     CPU Core #2 Thread #2          Load 5              0     0        97
12th Gen Intel Core i7-1260P     CPU Core #3 Thread #1          Load 6              5     0        99
12th Gen Intel Core i7-1260P     CPU Core #3 Thread #2          Load 7              0     0        97
12th Gen Intel Core i7-1260P     CPU Core #4 Thread #1          Load 8              6     0        95
12th Gen Intel Core i7-1260P     CPU Core #4 Thread #2          Load 9              0     0        97
12th Gen Intel Core i7-1260P     CPU Package                    Power 0            10     0        58
12th Gen Intel Core i7-1260P     CPU Cores                      Power 1             5     0        51
12th Gen Intel Core i7-1260P     CPU Memory                     Power 3             0     0         0
12th Gen Intel Core i7-1260P     CPU Core #1                    Temperature 0      47    23        98
12th Gen Intel Core i7-1260P     CPU Core #2                    Temperature 1      50    28        97
12th Gen Intel Core i7-1260P     CPU Core #11                   Temperature 10     47    23        85
12th Gen Intel Core i7-1260P     CPU Core #12                   Temperature 11     47    23        85
12th Gen Intel Core i7-1260P     CPU Package                    Temperature 12     57    30        98
12th Gen Intel Core i7-1260P     CPU Core #1 Distance to TjMax  Temperature 13     53     2        77
12th Gen Intel Core i7-1260P     CPU Core #2 Distance to TjMax  Temperature 14     50     3        72
12th Gen Intel Core i7-1260P     CPU Core #3 Distance to TjMax  Temperature 15     50     6        75
12th Gen Intel Core i7-1260P     CPU Core #4 Distance to TjMax  Temperature 16     51     4        75
12th Gen Intel Core i7-1260P     CPU Core #5 Distance to TjMax  Temperature 17     49    11        70
12th Gen Intel Core i7-1260P     CPU Core #6 Distance to TjMax  Temperature 18     43    11        70
12th Gen Intel Core i7-1260P     CPU Core #7 Distance to TjMax  Temperature 19     43    11        70
12th Gen Intel Core i7-1260P     CPU Core #3                    Temperature 2      50    25        94
12th Gen Intel Core i7-1260P     CPU Core #8 Distance to TjMax  Temperature 20     43    11        70
12th Gen Intel Core i7-1260P     CPU Core #9 Distance to TjMax  Temperature 21     53    15        77
12th Gen Intel Core i7-1260P     CPU Core #10 Distance to TjMax Temperature 22     53    15        77
12th Gen Intel Core i7-1260P     CPU Core #11 Distance to TjMax Temperature 23     53    15        77
12th Gen Intel Core i7-1260P     CPU Core #12 Distance to TjMax Temperature 24     53    15        77
12th Gen Intel Core i7-1260P     Core Max                       Temperature 25     57    30        98
12th Gen Intel Core i7-1260P     Core Average                   Temperature 26     50    27        86
12th Gen Intel Core i7-1260P     CPU Core #4                    Temperature 3      49    25        96
12th Gen Intel Core i7-1260P     CPU Core #5                    Temperature 4      51    30        89
12th Gen Intel Core i7-1260P     CPU Core #6                    Temperature 5      57    30        89
12th Gen Intel Core i7-1260P     CPU Core #7                    Temperature 6      57    30        89
12th Gen Intel Core i7-1260P     CPU Core #8                    Temperature 7      57    30        89
12th Gen Intel Core i7-1260P     CPU Core #9                    Temperature 8      47    23        85
12th Gen Intel Core i7-1260P     CPU Core #10                   Temperature 9      47    23        85
12th Gen Intel Core i7-1260P     CPU Core                       Voltage 0           1     1         1
12th Gen Intel Core i7-1260P     CPU Core #1                    Voltage 1           1     1         1
12th Gen Intel Core i7-1260P     CPU Core #10                   Voltage 10          1     1         1
12th Gen Intel Core i7-1260P     CPU Core #11                   Voltage 11          1     1         1
12th Gen Intel Core i7-1260P     CPU Core #12                   Voltage 12          1     1         1
12th Gen Intel Core i7-1260P     CPU Core #2                    Voltage 2           1     1         1
12th Gen Intel Core i7-1260P     CPU Core #3                    Voltage 3           1     1         1
12th Gen Intel Core i7-1260P     CPU Core #4                    Voltage 4           1     1         1
12th Gen Intel Core i7-1260P     CPU Core #5                    Voltage 5           1     1         1
12th Gen Intel Core i7-1260P     CPU Core #6                    Voltage 6           1     1         1
12th Gen Intel Core i7-1260P     CPU Core #7                    Voltage 7           1     1         1
12th Gen Intel Core i7-1260P     CPU Core #8                    Voltage 8           1     1         1
12th Gen Intel Core i7-1260P     CPU Core #9                    Voltage 9           1     1         1
Беспроводная сеть                Data Uploaded                  Data 2              0     0         0
Беспроводная сеть                Data Downloaded                Data 3              6     0         6
Беспроводная сеть                Network Utilization            Load 1              0     0        51
Беспроводная сеть                Upload Speed                   Throughput 7     2687     0   1944587
Беспроводная сеть                Download Speed                 Throughput 8   143893     0  44829424
Подключение по локальной сети    Data Uploaded                  Data 2              0     0         0
Подключение по локальной сети    Data Downloaded                Data 3              0     0         0
Подключение по локальной сети    Network Utilization            Load 1              0     0         0
Подключение по локальной сети    Upload Speed                   Throughput 7        0     0         0
Подключение по локальной сети    Download Speed                 Throughput 8        0     0         0
Подключение по локальной сети* 9 Data Uploaded                  Data 2              0     0         0
Подключение по локальной сети* 9 Data Downloaded                Data 3              0     0         0
Подключение по локальной сети* 9 Network Utilization            Load 1              0     0         0
Подключение по локальной сети* 9 Upload Speed                   Throughput 7        0     0         0
Подключение по локальной сети* 9 Download Speed                 Throughput 8        0     0         0
Сетевое подключение Bluetooth    Data Uploaded                  Data 2              0     0         0
Сетевое подключение Bluetooth    Data Downloaded                Data 3              0     0         0
Сетевое подключение Bluetooth    Network Utilization            Load 1              0     0         0
Сетевое подключение Bluetooth    Upload Speed                   Throughput 7        0     0         0
Сетевое подключение Bluetooth    Download Speed                 Throughput 8        0     0         0
Generic Memory                   Memory Used                    Data 0             12     7        12
Generic Memory                   Memory Available               Data 1              4     3         8
Generic Memory                   Virtual Memory Used            Data 2             16    11        17
Generic Memory                   Virtual Memory Available       Data 3             46    45        51
Generic Memory                   Memory                         Load 0             74    47        79
Generic Memory                   Virtual Memory                 Load 1             26    18        28
HB5781P1EEW-31T                  Charge Current                 Current 2           1     0         3
HB5781P1EEW-31T                  Designed Capacity              Energy 3        59424 59424     59424
HB5781P1EEW-31T                  Full Charged Capacity          Energy 4        52587 52587     52587
HB5781P1EEW-31T                  Remaining Capacity             Energy 5        52587 42400     52587
HB5781P1EEW-31T                  Charge Level                   Level 0           100    81       100
HB5781P1EEW-31T                  Degradation Level              Level 0            12    12        12
HB5781P1EEW-31T                  Charge Rate                    Power 0             7     6        39
HB5781P1EEW-31T                  Voltage                        Voltage 1          13    13        13
HotspotShield Network Adapter    Data Uploaded                  Data 2              0     0         0
HotspotShield Network Adapter    Data Downloaded                Data 3              0     0         0
HotspotShield Network Adapter    Network Utilization            Load 1              0     0         0
HotspotShield Network Adapter    Upload Speed                   Throughput 7        0     0         0
HotspotShield Network Adapter    Download Speed                 Throughput 8        0     0         0
Intel(R) Iris(R) Xe Graphics     D3D 3D                         Load 0              8     0       100
Intel(R) Iris(R) Xe Graphics     D3D Copy                       Load 1              0     0         0
Intel(R) Iris(R) Xe Graphics     D3D Video Decode               Load 10             0     0        23
Intel(R) Iris(R) Xe Graphics     D3D Video Processing           Load 11             0     0        15
Intel(R) Iris(R) Xe Graphics     D3D Video Processing           Load 12             0     0         0
Intel(R) Iris(R) Xe Graphics     D3D GDI Render                 Load 2              0     0         0
Intel(R) Iris(R) Xe Graphics     D3D Other                      Load 3              0     0         0
Intel(R) Iris(R) Xe Graphics     D3D Other                      Load 4              0     0         0
Intel(R) Iris(R) Xe Graphics     D3D Other                      Load 5              0     0         0
Intel(R) Iris(R) Xe Graphics     D3D Other                      Load 6              0     0         0
Intel(R) Iris(R) Xe Graphics     D3D Other                      Load 7              0     0         0
Intel(R) Iris(R) Xe Graphics     D3D Other                      Load 8              0     0         0
Intel(R) Iris(R) Xe Graphics     D3D Video Decode               Load 9              0     0        51
Intel(R) Iris(R) Xe Graphics     GPU Power                      Power 0             0     0       190
Intel(R) Iris(R) Xe Graphics     D3D Shared Memory Used         SmallData 0      2726  1080      3226
ProtonVPN TUN                    Data Uploaded                  Data 2              0     0         0
ProtonVPN TUN                    Data Downloaded                Data 3              0     0         0
ProtonVPN TUN                    Network Utilization            Load 1              0     0         0
ProtonVPN TUN                    Upload Speed                   Throughput 7        0     0         0
ProtonVPN TUN                    Download Speed                 Throughput 8        0     0         0
Radmin VPN                       Data Uploaded                  Data 2              0     0         0
Radmin VPN                       Data Downloaded                Data 3              0     0         0
Radmin VPN                       Network Utilization            Load 1              0     0         0
Radmin VPN                       Upload Speed                   Throughput 7      211     0      5032
Radmin VPN                       Download Speed                 Throughput 8        0     0        62
vEthernet (Default Switch)       Data Uploaded                  Data 2              0     0         0
vEthernet (Default Switch)       Data Downloaded                Data 3              0     0         0
vEthernet (Default Switch)       Network Utilization            Load 1              0     0         0
vEthernet (Default Switch)       Upload Speed                   Throughput 7      211     0      4900
vEthernet (Default Switch)       Download Speed                 Throughput 8        0     0         0
WD PC SN740 SDDPNQD-1T00-1027    Data Read                      Data 4          10761     0     10761
WD PC SN740 SDDPNQD-1T00-1027    Data Written                   Data 5          10962     0     10962
WD PC SN740 SDDPNQD-1T00-1027    Available Spare                Level 1           100     0       100
WD PC SN740 SDDPNQD-1T00-1027    Available Spare Threshold      Level 2            10     0        10
WD PC SN740 SDDPNQD-1T00-1027    Percentage Used                Level 3             0     0         0
WD PC SN740 SDDPNQD-1T00-1027    Used Space                     Load 0             52    52        53
WD PC SN740 SDDPNQD-1T00-1027    Read Activity                  Load 31             0     0       100
WD PC SN740 SDDPNQD-1T00-1027    Write Activity                 Load 32             2     0       100
WD PC SN740 SDDPNQD-1T00-1027    Total Activity                 Load 33             2     0       100
WD PC SN740 SDDPNQD-1T00-1027    Temperature                    Temperature 0      48     0        66
WD PC SN740 SDDPNQD-1T00-1027    Temperature 1                  Temperature 6      58     0        87
WD PC SN740 SDDPNQD-1T00-1027    Temperature 2                  Temperature 7      48     0        66
WD PC SN740 SDDPNQD-1T00-1027    Read Rate                      Throughput 34  180039     0 476410144
WD PC SN740 SDDPNQD-1T00-1027    Write Rate                     Throughput 35  311204     0 693865152
```

### WMI (Windows Management Instrumentation)

The computer used is an **Intel Core i5 10400 based computer** to example. Filter the data to get temperature data only.

```PowerShell
> Get-Sensor | Where-Object {($_.SensorName -match "Temperature") -or ($_.SensorType -match "Temperature")} | Format-Table

HardwareName           SensorName                    SensorType     Value Min Max
------------           ----------                    ----------     ----- --- ---
Intel Core i5-10400    CPU Core #1                   Temperature 0     29  26  48
Intel Core i5-10400    CPU Core #2                   Temperature 1     30  27  48
Intel Core i5-10400    CPU Core #4 Distance to TjMax Temperature 10    73  57  75
Intel Core i5-10400    CPU Core #5 Distance to TjMax Temperature 11    72  52  74
Intel Core i5-10400    CPU Core #6 Distance to TjMax Temperature 12    70  51  73
Intel Core i5-10400    Core Max                      Temperature 13    30  28  49
Intel Core i5-10400    Core Average                  Temperature 14    29  27  40
Intel Core i5-10400    CPU Core #3                   Temperature 2     28  26  47
Intel Core i5-10400    CPU Core #4                   Temperature 3     27  25  43
Intel Core i5-10400    CPU Core #5                   Temperature 4     28  26  48
Intel Core i5-10400    CPU Core #6                   Temperature 5     30  27  49
Intel Core i5-10400    CPU Package                   Temperature 6     30  29  49
Intel Core i5-10400    CPU Core #1 Distance to TjMax Temperature 7     71  52  74
Intel Core i5-10400    CPU Core #2 Distance to TjMax Temperature 8     70  52  73
Intel Core i5-10400    CPU Core #3 Distance to TjMax Temperature 9     72  53  74
MSI M390 250GB         Temperature                   Temperature 0     40   0  42
Nuvoton NCT6687D       CPU                           Temperature 0     36  29  47
Nuvoton NCT6687D       System                        Temperature 1     34  34  37
Nuvoton NCT6687D       VRM MOS                       Temperature 2     40  39  42
Nuvoton NCT6687D       PCH                           Temperature 3     40  38  44
Nuvoton NCT6687D       CPU Socket                    Temperature 4     32  32  34
Nuvoton NCT6687D       PCIe x1                       Temperature 5     29  29  29
Nuvoton NCT6687D       M2_1                          Temperature 6     23  23  23
Radeon RX 570 Series   GPU Core                      Temperature 0     40  39  42
ST1000DM003-1CH162     Temperature                   Temperature 0     33  33  35
WDC WD2005FBYZ-01YCBB2 Temperature                   Temperature 0     36  36  36
```

### Library .NET

💡 To get data from all sensors, you need to run the console with **administrator privileges**.

💡 Response speed through WMI is on average 5 times faster (200 milliseconds vs. 1 second to .NET Library) because a running instance of the application is used to retrieve the data, which also stores the minimum and maximum values.

💡 On all systems tested, I was able to collect CPU and some disk data. In connection with this problem I have created a [request](https://github.com/LibreHardwareMonitor/LibreHardwareMonitor/issues/1260) in the GitHub repository of LibreHardwareMonitor developers. For OpenHardwareMonitor, I have not been able to get the data.

```PowerShell
> Get-Sensor -Library | Where-Object Value -ne 0 | Format-Table

HardwareName         SensorName                    SensorType     Value  Min  Max
------------         ----------                    ----------     -----  ---  ---
Intel Core i5-10400  Bus Speed                     Clock 0          100  100  100
Intel Core i5-10400  CPU Core #1                   Clock 1         4006 4006 4006
Intel Core i5-10400  CPU Core #2                   Clock 2         4006 4006 4006
Intel Core i5-10400  CPU Core #3                   Clock 3         4006 4006 4006
Intel Core i5-10400  CPU Core #4                   Clock 4         4006 4006 4006
Intel Core i5-10400  CPU Core #5                   Clock 5         4006 4006 4006
Intel Core i5-10400  CPU Core #6                   Clock 6         4006 4006 4006
Intel Core i5-10400  CPU Package                   Power 0           20   20   20
Intel Core i5-10400  CPU Cores                     Power 1           13   13   13
Intel Core i5-10400  CPU Memory                    Power 3            1    1    1
Intel Core i5-10400  CPU Core #1                   Temperature 0     34   34   34
Intel Core i5-10400  CPU Core #2                   Temperature 1     35   35   35
Intel Core i5-10400  CPU Core #4 Distance to TjMax Temperature 10    74   74   74
Intel Core i5-10400  CPU Core #5 Distance to TjMax Temperature 11    74   74   74
Intel Core i5-10400  CPU Core #6 Distance to TjMax Temperature 12    74   74   74
Intel Core i5-10400  Core Max                      Temperature 13    35   35   35
Intel Core i5-10400  Core Average                  Temperature 14    29   29   29
Intel Core i5-10400  CPU Core #3                   Temperature 2     26   26   26
Intel Core i5-10400  CPU Core #4                   Temperature 3     26   26   26
Intel Core i5-10400  CPU Core #5                   Temperature 4     26   26   26
Intel Core i5-10400  CPU Core #6                   Temperature 5     26   26   26
Intel Core i5-10400  CPU Package                   Temperature 6     35   35   35
Intel Core i5-10400  CPU Core #1 Distance to TjMax Temperature 7     66   66   66
Intel Core i5-10400  CPU Core #2 Distance to TjMax Temperature 8     65   65   65
Intel Core i5-10400  CPU Core #3 Distance to TjMax Temperature 9     74   74   74
Intel Core i5-10400  CPU Core                      Voltage 0          1    1    1
Intel Core i5-10400  CPU Core #1                   Voltage 1          1    1    1
Intel Core i5-10400  CPU Core #2                   Voltage 2          1    1    1
Intel Core i5-10400  CPU Core #3                   Voltage 3          1    1    1
Intel Core i5-10400  CPU Core #4                   Voltage 4          1    1    1
Intel Core i5-10400  CPU Core #5                   Voltage 5          1    1    1
Intel Core i5-10400  CPU Core #6                   Voltage 6          1    1    1
Radeon RX 570 Series GPU Core                      Clock 0          300  300  300
Radeon RX 570 Series GPU Memory                    Clock 2          300  300  300
Radeon RX 570 Series Fullscreen FPS                Factor 0          -1   -1   -1
Radeon RX 570 Series GPU Package                   Power 3           10   10   10
Radeon RX 570 Series D3D Dedicated Memory Used     SmallData 0      504  504  504
Radeon RX 570 Series D3D Shared Memory Used        SmallData 1       20   20   20
Radeon RX 570 Series GPU Core                      Temperature 0     37   37   37
Radeon RX 570 Series GPU Core                      Voltage 0          1    1    1
```

## 📊 InfluxDB connection

Process configuring **temperature sensor monitoring**.

- Install [InfluxDB](https://www.influxdata.com/downloads) version 1.x

Define the server on which the time series database will be installed. It can be Windows, Linux (WSL or a virtual machine) or use [Docker image](https://hub.docker.com/_/influxdb).

Install to Windows:

```PowerShell
Invoke-RestMethod "https://dl.influxdata.com/influxdb/releases/influxdb-1.8.10_windows_amd64.zip" -OutFile "$home\Downloads\influxdb-1.8.10_windows_amd64.zip"
Expand-Archive "$home\Downloads\influxdb-1.8.10_windows_amd64.zip" -DestinationPath "$home\Downloads\"
Remove-Item "$home\Downloads\influxdb-1.8.10_windows_amd64.zip"
& "$home\Downloads\influxdb-1.8.10-1\influxd.exe"
```

Example for Ubuntu:

```Bash
wget https://dl.influxdata.com/influxdb/releases/influxdb_1.8.10_amd64.deb
sudo dpkg -i influxdb_1.8.10_amd64.deb
systemctl start influxdb
systemctl status influxdb
```

- Create database using [InfluxDB Studio](https://github.com/CymaticLabs/InfluxDBStudio) or [psinfluxdb](https://github.com/Lifailon/psinfluxdb) module

```PowerShell
Install-Module psinfluxdb -Repository NuGet
Import-Module psinfluxdb
Get-Command -Module psinfluxdb
Get-InfluxDatabases -server 192.168.3.102
Get-InfluxDatabases -server 192.168.3.102 -creat -database PowerShell
```

- Configure script to send the data and check it out in the console

Local:

```PowerShell
# Inport-Module "C:\Users\lifailon\Documents\PowerShell\Modules\HardwareMonitor"
while ($True) {
    $Data = Get-Sensor | Where-Object {($_.SensorName -match "Temperature") -or ($_.SensorType -match "Temperature")}
    Send-SensorToInfluxDB -Data $Data -ServerInflux "192.168.3.102" -Port 8086 -Database "PowerShell" -Table "HardwareMonitor"
    Start-Sleep -Seconds 5
}
```

Remote:

```PowerShell
# Inport-Module "C:\Users\lifailon\Documents\PowerShell\Modules\HardwareMonitor"
while ($True) {
    $Server_List = @(
        "192.168.3.99"
        "192.168.3.100"
    )
    foreach ($Server in $Server_List) {
        $Data = Get-Sensor -ComputerName $Server -Port 8085 | Where-Object {($_.SensorName -match "Temperature") -or ($_.SensorType -match "Temperature")}
        Send-SensorToInfluxDB -ComputerName $Server -Data $Data -ServerInflux "192.168.3.102" -Port 8086 -Database "PowerShell" -Table "HardwareMonitor"
        Start-Sleep -Seconds 5
    }
}
```

- Check the received data

SQL query for InstalDB Studio:

```SQL
SELECT * FROM "HardwareMonitor" WHERE time > now() - 5m
```

Filtering the data:

```SQL
SELECT * FROM "HardwareMonitor" WHERE SensorName =~/.+Package/ and Value > 90 and time > now() - 30m
```

![Image alt](https://github.com/Lifailon/PowerShell.HardwareMonitor/blob/rsa/Screen/InfluxDB-Data.jpg)

Getting and filtering data via PowerShell:

```PowerShell
Get-InfluxTables -server 192.168.3.102 -database PowerShell
$Data =  Get-InfluxData -server 192.168.3.102 -database PowerShell -table HardwareMonitor -minutes 30
$Data | Where-Object {$_.SensorName -match "Package" -and $_.Value -gt 90} | Format-Table
```

![Image alt](https://github.com/Lifailon/PowerShell.HardwareMonitor/blob/rsa/Screen/psinfluxdb-data.jpg)

💡 The example in the screenshot uses the [oh-my-posh](https://github.com/JanDeDobbeleer/oh-my-posh) theme [System-Sensors](https://github.com/Lifailon/oh-my-posh-themes-performance) to retrieve data from LibreHardwareMonitor.

## 🔔 Creat service

Save the data sending script to database and specify the path to it at the beginning of the script creat service (a set of [scripts](https://github.com/Lifailon/PowerShell.HardwareMonitor/tree/rsa/Service) for creating, starting, stopping and deleting a service are included with the module):

```PowerShell
$script_path = "$home\Documents\Write-SensorToInfluxDB.ps1" # set the path to your script

# Install nssm
$nssm_path = $(Get-ChildItem $env:TEMP | Where-Object Name -match "nssm")
if ($null -eq $nssm_path) {
    Invoke-RestMethod -Uri "https://nssm.cc/release/nssm-2.24.zip" -OutFile "$env:TEMP\nssm.zip"
    Expand-Archive -Path "$env:TEMP\nssm.zip" -DestinationPath $env:TEMP
    Remove-Item -Path "$env:TEMP\nssm.zip"
}

# Delete service
if (Get-Service HardwareMonitor -ErrorAction Ignore) {
    Get-Service HardwareMonitor | Stop-Service
    Remove-Service HardwareMonitor
    # Для удаления в PowerShell 5.1
    # (Get-CimInstance win32_service -Filter 'name="HardwareMonitor"').Delete()
    # & $nssm_exe_path remove HardwareMonitor
}

# Creat service
$service_name  = "HardwareMonitor"
$nssm_exe_path = $(Get-ChildItem $env:TEMP -Recurse | Where-Object name -match nssm.exe | Where-Object FullName -Match win64).FullName
$pwsh_path     = $(Get-Command pwsh.exe).Source
& $nssm_exe_path install $service_name $pwsh_path "-File $script_path"
& $nssm_exe_path set $Service_Name description "Sending HardwareMonitor sensors to the InfluxDB"
& $nssm_exe_path set $service_name AppExit Default Restart

# Start service
Get-Service HardwareMonitor | Start-Service
Get-Service HardwareMonitor
```

## 📈 Grafana dashnoard

- Install [Grafana Enterprise](https://grafana.com/grafana/download).

Example for Ubuntu:

```Bash
apt-get install -y adduser libfontconfig1 musl
wget https://dl.grafana.com/enterprise/release/grafana-enterprise_10.3.1_amd64.deb
dpkg -i grafana-enterprise_10.3.1_amd64.deb
systemctl start grafana-server
systemctl status grafana-server
```

- Dashboard settings.

![Image alt](https://github.com/Lifailon/PowerShell.HardwareMonitor/blob/rsa/Screen/Grafana-Dashboard.jpg)

For simple setting (without using variables or regular expressions), use grouping by host and hardware name tags and filters by sensor name:

![Image alt](https://github.com/Lifailon/PowerShell.HardwareMonitor/blob/rsa/Screen/InfluxDB-Query.jpg)

For clarity and convenience, customize the celsius data type and legends (displaying minimum, maximum, and average readings for the specified time period):

![Image alt](https://github.com/Lifailon/PowerShell.HardwareMonitor/blob/rsa/Screen/Grafana-Legend-Celsius.jpg)

Monitoring two hosts:

![Image alt](https://github.com/Lifailon/PowerShell.HardwareMonitor/blob/rsa/Screen/Grafana-Dashboard-Group.jpg)

## Deployment

For deployment LibreHardwareMonitor as a monitoring agent and collect data on a single computer from multiple machines simultaneously, you can use the following approach via the **WinRM protocol** (you must have administrator rights in the domain and have the appropriate group policies configured beforehand):

```PowerShell
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
```

Downloads the latest version from the GitHub repository, customizes the configuration file and starts the process.