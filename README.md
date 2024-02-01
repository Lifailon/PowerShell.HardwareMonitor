# PowerShellHardwareMonitor

Module for local and remote data acquisition temperature, load and other sensors system via [OpenHardwareMonitor](https://github.com/openhardwaremonitor/openhardwaremonitor) and [LibreHardwareMonitor](https://github.com/LibreHardwareMonitor/LibreHardwareMonitor) to output PowerShell console.

This module implements an out-of-the-box and universal solution for configuring temperature sensor monitoring with **InfluxDB v1.x** and visualization in **Grafana**.

🔗 Implemented ways to get information:

✅ REST API \
✅ .NET Library \
✅ CIM (Common Information Model)

> Response speed through CIM is on average 5 times faster (200 milliseconds vs. 1 second) because a running instance of the application is used to retrieve the data, which stores the minimum and maximum values.

- [🚀 Install](#-install)
- [📑 Get data](#-get-data)
- [📊 Monitoring settings](#-monitoring-settings)

## 🚀 Install

💡 Dependencies:

- [PowerShell Core](https://github.com/PowerShell/PowerShell)

Set the data retrieval source of your choice with a single cmdlet in your PowerShell console (default installation path: `C:\Users\<UserName>\Documents`).

- Install **OpenHardwareMonitor** from [website](https://openhardwaremonitor.org/):

```PowerShell
Invoke-Expression(New-Object Net.WebClient).DownloadString("https://raw.githubusercontent.com/Lifailon/PowerShellHardwareMonitor/rsa/Install/Install-OpenHardwareMonitor.ps1")
```

- Install **LibreHardwareMonitor** from the [GitHub repository](https://github.com/LibreHardwareMonitor/LibreHardwareMonitor):

```PowerShell
Invoke-Expression(New-Object Net.WebClient).DownloadString("https://raw.githubusercontent.com/Lifailon/PowerShellHardwareMonitor/rsa/Install/Install-LibreHardwareMonitor.ps1")
```

- Quickly **install or update the module and scripts** for creat background process send sensors to the database

```PowerShell
Invoke-Expression(New-Object Net.WebClient).DownloadString("https://raw.githubusercontent.com/Lifailon/PowerShellHardwareMonitor/rsa/Install/Install-PowerShellHardwareMonitor.ps1")
```

Import the module and get a list of available commands:

```PowerShell
Import-Module PowerShellHardwareMonitor

Get-Command -Module PowerShellHardwareMonitor | Select-Object Name,Source

Name                       Source
----                       ------
Get-Sensor                 PowerShellHardwareMonitor
Send-TemperatureToInfluxDB PowerShellHardwareMonitor
```

## 📑 Get data

Difference in the amount of data (non-empty) for **HUAWEI MateBook X Pro laptop**.

### REST API via OpenHardwareMonitor

```PowerShell
> Get-Sensor -Server 192.168.3.99 | Format-Table

HardwareName                 SensorName SensorType       Value   Min     Max
------------                 ---------- ----------       -----   ---     ---
12th Gen Intel Core i7-1260P Load       CPU Total        13,4 %  10,2 %  21,9 %
12th Gen Intel Core i7-1260P Load       CPU Core #1      22,7 %  7,0 %   50,0 %
12th Gen Intel Core i7-1260P Load       CPU Core #2      13,3 %  0,0 %   24,5 %
12th Gen Intel Core i7-1260P Load       CPU Core #3      4,7 %   0,8 %   25,0 %
12th Gen Intel Core i7-1260P Load       CPU Core #4      3,0 %   0,0 %   25,0 %
12th Gen Intel Core i7-1260P Load       CPU Core #5      12,5 %  0,0 %   12,5 %
12th Gen Intel Core i7-1260P Load       CPU Core #6      18,8 %  0,0 %   100,0 %
12th Gen Intel Core i7-1260P Load       CPU Core #7      3,1 %   0,0 %   25,0 %
12th Gen Intel Core i7-1260P Load       CPU Core #8      15,6 %  0,0 %   62,5 %
12th Gen Intel Core i7-1260P Load       CPU Core #9      18,8 %  0,0 %   23,5 %
12th Gen Intel Core i7-1260P Load       CPU Core #10     15,6 %  0,0 %   50,0 %
12th Gen Intel Core i7-1260P Load       CPU Core #11     12,5 %  0,0 %   37,5 %
12th Gen Intel Core i7-1260P Load       CPU Core #12     29,7 %  0,0 %   68,8 %
Generic Memory               Load       Memory           98,1 %  98,0 %  99,0 %
Generic Memory               Data       Used Memory      15,4 GB 15,4 GB 15,6 GB
Generic Memory               Data       Available Memory 0,3 GB  0,2 GB  0,3 GB
Generic Hard Disk            Load       Used Space       51,8 %  51,8 %  51,8 %
```

### REST API via LibreHardwareMonitor

```PowerShell
> Get-Sensor -Server 192.168.3.99 -Port 8086 | Where-Object Value -notmatch "^0,0" | Format-Table

HardwareName                  SensorName   SensorType                     Value       Min        Max
------------                  ----------   ----------                     -----       ---        ---
12th Gen Intel Core i7-1260P  Voltages     CPU Core                       1,309 V     0,928 V    1,329 V
12th Gen Intel Core i7-1260P  Voltages     CPU Core #1                    1,309 V     0,921 V    1,328 V
12th Gen Intel Core i7-1260P  Voltages     CPU Core #2                    1,309 V     0,880 V    1,329 V
12th Gen Intel Core i7-1260P  Voltages     CPU Core #3                    1,209 V     0,885 V    1,323 V
12th Gen Intel Core i7-1260P  Voltages     CPU Core #4                    1,159 V     0,918 V    1,343 V
12th Gen Intel Core i7-1260P  Voltages     CPU Core #5                    1,141 V     0,928 V    1,319 V
12th Gen Intel Core i7-1260P  Voltages     CPU Core #6                    1,141 V     0,928 V    1,316 V
12th Gen Intel Core i7-1260P  Voltages     CPU Core #7                    1,141 V     0,979 V    1,318 V
12th Gen Intel Core i7-1260P  Voltages     CPU Core #8                    1,141 V     0,974 V    1,327 V
12th Gen Intel Core i7-1260P  Voltages     CPU Core #9                    1,146 V     0,963 V    1,319 V
12th Gen Intel Core i7-1260P  Voltages     CPU Core #10                   1,156 V     0,964 V    1,309 V
12th Gen Intel Core i7-1260P  Voltages     CPU Core #11                   1,141 V     0,969 V    1,321 V
12th Gen Intel Core i7-1260P  Voltages     CPU Core #12                   1,141 V     0,934 V    1,312 V
12th Gen Intel Core i7-1260P  Powers       CPU Package                    25,1 W      21,6 W     32,5 W
12th Gen Intel Core i7-1260P  Powers       CPU Cores                      19,8 W      16,4 W     26,7 W
12th Gen Intel Core i7-1260P  Clocks       Bus Speed                      99,8 MHz    99,8 MHz   99,8 MHz
12th Gen Intel Core i7-1260P  Clocks       CPU Core #1                    4492,8 MHz  2695,7 MHz 4692,5 MHz
12th Gen Intel Core i7-1260P  Clocks       CPU Core #2                    4393,0 MHz  2595,8 MHz 4692,5 MHz
12th Gen Intel Core i7-1260P  Clocks       CPU Core #3                    3993,6 MHz  2595,8 MHz 4692,5 MHz
12th Gen Intel Core i7-1260P  Clocks       CPU Core #4                    3993,6 MHz  399,4 MHz  4692,5 MHz
12th Gen Intel Core i7-1260P  Clocks       CPU Core #5                    3095,0 MHz  2196,5 MHz 3194,9 MHz
12th Gen Intel Core i7-1260P  Clocks       CPU Core #6                    3194,9 MHz  2196,5 MHz 3394,6 MHz
12th Gen Intel Core i7-1260P  Clocks       CPU Core #7                    3095,0 MHz  2196,5 MHz 3394,6 MHz
12th Gen Intel Core i7-1260P  Clocks       CPU Core #8                    3194,9 MHz  2196,5 MHz 3394,6 MHz
12th Gen Intel Core i7-1260P  Clocks       CPU Core #9                    3095,0 MHz  2196,5 MHz 3394,6 MHz
12th Gen Intel Core i7-1260P  Clocks       CPU Core #10                   3095,0 MHz  2196,5 MHz 3394,6 MHz
12th Gen Intel Core i7-1260P  Clocks       CPU Core #11                   3194,9 MHz  2296,3 MHz 3394,6 MHz
12th Gen Intel Core i7-1260P  Clocks       CPU Core #12                   3194,9 MHz  2296,3 MHz 3394,7 MHz
12th Gen Intel Core i7-1260P  Temperatures CPU Core #1                    72,0 °C     71,0 °C    94,0 °C
12th Gen Intel Core i7-1260P  Temperatures CPU Core #2                    73,0 °C     72,0 °C    92,0 °C
12th Gen Intel Core i7-1260P  Temperatures CPU Core #3                    74,0 °C     71,0 °C    97,0 °C
12th Gen Intel Core i7-1260P  Temperatures CPU Core #4                    71,0 °C     70,0 °C    85,0 °C
12th Gen Intel Core i7-1260P  Temperatures CPU Core #5                    75,0 °C     72,0 °C    85,0 °C
12th Gen Intel Core i7-1260P  Temperatures CPU Core #6                    75,0 °C     72,0 °C    85,0 °C
12th Gen Intel Core i7-1260P  Temperatures CPU Core #7                    75,0 °C     72,0 °C    85,0 °C
12th Gen Intel Core i7-1260P  Temperatures CPU Core #8                    75,0 °C     72,0 °C    85,0 °C
12th Gen Intel Core i7-1260P  Temperatures CPU Core #9                    78,0 °C     69,0 °C    85,0 °C
12th Gen Intel Core i7-1260P  Temperatures CPU Core #10                   78,0 °C     69,0 °C    85,0 °C
12th Gen Intel Core i7-1260P  Temperatures CPU Core #11                   78,0 °C     69,0 °C    85,0 °C
12th Gen Intel Core i7-1260P  Temperatures CPU Core #12                   78,0 °C     69,0 °C    85,0 °C
12th Gen Intel Core i7-1260P  Temperatures CPU Package                    94,0 °C     76,0 °C    96,0 °C
12th Gen Intel Core i7-1260P  Temperatures CPU Core #1 Distance to TjMax  28,0 °C     6,0 °C     29,0 °C
12th Gen Intel Core i7-1260P  Temperatures CPU Core #2 Distance to TjMax  27,0 °C     8,0 °C     28,0 °C
12th Gen Intel Core i7-1260P  Temperatures CPU Core #3 Distance to TjMax  26,0 °C     3,0 °C     29,0 °C
12th Gen Intel Core i7-1260P  Temperatures CPU Core #4 Distance to TjMax  29,0 °C     15,0 °C    30,0 °C
12th Gen Intel Core i7-1260P  Temperatures CPU Core #5 Distance to TjMax  25,0 °C     15,0 °C    28,0 °C
12th Gen Intel Core i7-1260P  Temperatures CPU Core #6 Distance to TjMax  25,0 °C     15,0 °C    28,0 °C
12th Gen Intel Core i7-1260P  Temperatures CPU Core #7 Distance to TjMax  25,0 °C     15,0 °C    28,0 °C
12th Gen Intel Core i7-1260P  Temperatures CPU Core #8 Distance to TjMax  25,0 °C     15,0 °C    28,0 °C
12th Gen Intel Core i7-1260P  Temperatures CPU Core #9 Distance to TjMax  22,0 °C     15,0 °C    31,0 °C
12th Gen Intel Core i7-1260P  Temperatures CPU Core #10 Distance to TjMax 22,0 °C     15,0 °C    31,0 °C
12th Gen Intel Core i7-1260P  Temperatures CPU Core #11 Distance to TjMax 22,0 °C     15,0 °C    31,0 °C
12th Gen Intel Core i7-1260P  Temperatures CPU Core #12 Distance to TjMax 22,0 °C     15,0 °C    31,0 °C
12th Gen Intel Core i7-1260P  Temperatures Core Max                       78,0 °C     76,0 °C    97,0 °C
12th Gen Intel Core i7-1260P  Temperatures Core Average                   75,2 °C     73,0 °C    81,3 °C
12th Gen Intel Core i7-1260P  Load         CPU Total                      14,0 %      11,4 %     27,3 %
12th Gen Intel Core i7-1260P  Load         CPU Core Max                   36,0 %      36,0 %     89,7 %
12th Gen Intel Core i7-1260P  Load         CPU Core #1 Thread #1          24,5 %      20,2 %     77,7 %
12th Gen Intel Core i7-1260P  Load         CPU Core #1 Thread #2          4,0 %       0,0 %      24,8 %
12th Gen Intel Core i7-1260P  Load         CPU Core #2 Thread #1          36,0 %      12,0 %     89,7 %
12th Gen Intel Core i7-1260P  Load         CPU Core #2 Thread #2          2,4 %       0,0 %      12,1 %
12th Gen Intel Core i7-1260P  Load         CPU Core #3 Thread #1          11,8 %      2,3 %      80,2 %
12th Gen Intel Core i7-1260P  Load         CPU Core #3 Thread #2          0,7 %       0,0 %      12,7 %
12th Gen Intel Core i7-1260P  Load         CPU Core #4 Thread #1          14,5 %      0,0 %      66,8 %
12th Gen Intel Core i7-1260P  Load         CPU Core #4 Thread #2          2,5 %       0,0 %      3,2 %
12th Gen Intel Core i7-1260P  Load         CPU Core #5                    9,6 %       2,7 %      28,4 %
12th Gen Intel Core i7-1260P  Load         CPU Core #6                    15,6 %      1,9 %      44,5 %
12th Gen Intel Core i7-1260P  Load         CPU Core #7                    12,8 %      2,4 %      50,2 %
12th Gen Intel Core i7-1260P  Load         CPU Core #8                    12,9 %      3,7 %      50,5 %
12th Gen Intel Core i7-1260P  Load         CPU Core #9                    21,3 %      2,9 %      53,2 %
12th Gen Intel Core i7-1260P  Load         CPU Core #10                   18,1 %      3,8 %      74,3 %
12th Gen Intel Core i7-1260P  Load         CPU Core #11                   22,4 %      3,5 %      65,6 %
12th Gen Intel Core i7-1260P  Load         CPU Core #12                   14,3 %      6,3 %      80,3 %
Generic Memory                Load         Memory                         97,4 %      97,0 %     99,1 %
Generic Memory                Load         Virtual Memory                 91,3 %      90,9 %     91,5 %
Generic Memory                Data         Memory Used                    15,3 GB     15,3 GB    15,6 GB
Generic Memory                Data         Memory Available               0,4 GB      0,1 GB     0,5 GB
Generic Memory                Data         Virtual Memory Used            54,0 GB     53,8 GB    54,1 GB
Generic Memory                Data         Virtual Memory Available       5,2 GB      5,0 GB     5,4 GB
Intel(R) Iris(R) Xe Graphics  Powers       GPU Power                      0,1 W       0,0 W      931,7 W
Intel(R) Iris(R) Xe Graphics  Load         D3D 3D                         6,3 %       2,4 %      55,1 %
Intel(R) Iris(R) Xe Graphics  Data         D3D Shared Memory Used         3455,4 MB   3403,9 MB  3519,1 MB
WD PC SN740 SDDPNQD-1T00-1027 Temperatures Temperature                    64,0 °C     0,0 °C     64,0 °C
WD PC SN740 SDDPNQD-1T00-1027 Temperatures Temperature 1                  84,0 °C     0,0 °C     86,0 °C
WD PC SN740 SDDPNQD-1T00-1027 Temperatures Temperature 2                  64,0 °C     0,0 °C     64,0 °C
WD PC SN740 SDDPNQD-1T00-1027 Load         Used Space                     51,8 %      51,8 %     51,8 %
WD PC SN740 SDDPNQD-1T00-1027 Load         Read Activity                  2,0 %       0,0 %      100,0 %
WD PC SN740 SDDPNQD-1T00-1027 Load         Write Activity                 0,2 %       0,0 %      6,0 %
WD PC SN740 SDDPNQD-1T00-1027 Load         Total Activity                 1,1 %       0,3 %      100,0 %
WD PC SN740 SDDPNQD-1T00-1027 Levels       Available Spare                100,0 %     0,0 %      100,0 %
WD PC SN740 SDDPNQD-1T00-1027 Levels       Available Spare Threshold      10,0 %      0,0 %      10,0 %
WD PC SN740 SDDPNQD-1T00-1027 Data         Data Read                      10162,0 GB  0,0 GB     10162,0 GB
WD PC SN740 SDDPNQD-1T00-1027 Data         Data Written                   10155,0 GB  0,0 GB     10155,0 GB
WD PC SN740 SDDPNQD-1T00-1027 Throughput   Read Rate                      376,9 KB/s  16,3 KB/s  59,1 MB/s
WD PC SN740 SDDPNQD-1T00-1027 Throughput   Write Rate                     215,1 KB/s  0,0 KB/s   32,5 MB/s
Беспроводная сеть             Load         Network Utilization            0,1 %       0,0 %      0,1 %
Беспроводная сеть             Data         Data Uploaded                  1,7 GB      1,7 GB     1,7 GB
Беспроводная сеть             Data         Data Downloaded                14,7 GB     14,7 GB    14,7 GB
Беспроводная сеть             Throughput   Upload Speed                   29,3 KB/s   2,0 KB/s   44,6 KB/s
Беспроводная сеть             Throughput   Download Speed                 63,3 KB/s   8,5 KB/s   85,4 KB/s
HB5781P1EEW-31T               Voltages     Voltage                        12,968 V    12,961 V   12,974 V
HB5781P1EEW-31T               Powers       Discharge Rate                 0,1 W       0,0 W      1,1 W
HB5781P1EEW-31T               Levels       Degradation Level              9,5 %       9,5 %      9,5 %
HB5781P1EEW-31T               Levels       Charge Level                   100,0 %     100,0 %    100,0 %
HB5781P1EEW-31T               Times        Remaining Time (Estimated)     17:15:20:47 2:1:00:39  65:21:19:24
HB5781P1EEW-31T               Capacities   Designed Capacity              59424 mWh   59424 mWh  59424 mWh
HB5781P1EEW-31T               Capacities   Full Charged Capacity          53765 mWh   53765 mWh  53765 mWh
HB5781P1EEW-31T               Capacities   Remaining Capacity             53765 mWh   53765 mWh  53765 mWh
```

### .NET Library via LibreHardwareMonitor

To get data from all sensors, you need to run the console with 💡 **administrator privileges**

```PowerShell
> Get-Sensor -Libre -Library | Where-Object Value -ne 0 | Format-Table

HardwareName                 SensorName                     SensorType     Value  Min  Max
------------                 ----------                     ----------     -----  ---  ---
12th Gen Intel Core i7-1260P Bus Speed                      Clock 0          100  100  100
12th Gen Intel Core i7-1260P CPU Core #1                    Clock 1         3994 3994 3994
12th Gen Intel Core i7-1260P CPU Core #10                   Clock 10        3195 3195 3195
12th Gen Intel Core i7-1260P CPU Core #11                   Clock 11        2995 2995 2995
12th Gen Intel Core i7-1260P CPU Core #12                   Clock 12        3195 3195 3195
12th Gen Intel Core i7-1260P CPU Core #2                    Clock 2         3994 3994 3994
12th Gen Intel Core i7-1260P CPU Core #3                    Clock 3         3994 3994 3994
12th Gen Intel Core i7-1260P CPU Core #4                    Clock 4         4493 4493 4493
12th Gen Intel Core i7-1260P CPU Core #5                    Clock 5         2995 2995 2995
12th Gen Intel Core i7-1260P CPU Core #6                    Clock 6         3195 3195 3195
12th Gen Intel Core i7-1260P CPU Core #7                    Clock 7         3195 3195 3195
12th Gen Intel Core i7-1260P CPU Core #8                    Clock 8         2796 2796 2796
12th Gen Intel Core i7-1260P CPU Core #9                    Clock 9         3195 3195 3195
12th Gen Intel Core i7-1260P CPU Total                      Load 0             9    9    9
12th Gen Intel Core i7-1260P CPU Core Max                   Load 1            93   93   93
12th Gen Intel Core i7-1260P CPU Core #5                    Load 10           16   16   16
12th Gen Intel Core i7-1260P CPU Core #6                    Load 11           23   23   23
12th Gen Intel Core i7-1260P CPU Core #7                    Load 12            1    1    1
12th Gen Intel Core i7-1260P CPU Core #8                    Load 13           12   12   12
12th Gen Intel Core i7-1260P CPU Core #9                    Load 14           27   27   27
12th Gen Intel Core i7-1260P CPU Core #10                   Load 15            5    5    5
12th Gen Intel Core i7-1260P CPU Core #11                   Load 16           69   69   69
12th Gen Intel Core i7-1260P CPU Core #12                   Load 17           19   19   19
12th Gen Intel Core i7-1260P CPU Core #1 Thread #1          Load 2            93   93   93
12th Gen Intel Core i7-1260P CPU Core #2 Thread #1          Load 4            24   24   24
12th Gen Intel Core i7-1260P CPU Core #3 Thread #1          Load 6             8    8    8
12th Gen Intel Core i7-1260P CPU Package                    Power 0           22   22   22
12th Gen Intel Core i7-1260P CPU Cores                      Power 1           17   17   17
12th Gen Intel Core i7-1260P CPU Core #1                    Temperature 0     78   78   78
12th Gen Intel Core i7-1260P CPU Core #2                    Temperature 1     77   77   77
12th Gen Intel Core i7-1260P CPU Core #11                   Temperature 10    75   75   75
12th Gen Intel Core i7-1260P CPU Core #12                   Temperature 11    75   75   75
12th Gen Intel Core i7-1260P CPU Package                    Temperature 12    81   81   81
12th Gen Intel Core i7-1260P CPU Core #1 Distance to TjMax  Temperature 13    22   22   22
12th Gen Intel Core i7-1260P CPU Core #2 Distance to TjMax  Temperature 14    23   23   23
12th Gen Intel Core i7-1260P CPU Core #3 Distance to TjMax  Temperature 15    22   22   22
12th Gen Intel Core i7-1260P CPU Core #4 Distance to TjMax  Temperature 16    27   27   27
12th Gen Intel Core i7-1260P CPU Core #5 Distance to TjMax  Temperature 17    20   20   20
12th Gen Intel Core i7-1260P CPU Core #6 Distance to TjMax  Temperature 18    18   18   18
12th Gen Intel Core i7-1260P CPU Core #7 Distance to TjMax  Temperature 19    18   18   18
12th Gen Intel Core i7-1260P CPU Core #3                    Temperature 2     78   78   78
12th Gen Intel Core i7-1260P CPU Core #8 Distance to TjMax  Temperature 20    18   18   18
12th Gen Intel Core i7-1260P CPU Core #9 Distance to TjMax  Temperature 21    25   25   25
12th Gen Intel Core i7-1260P CPU Core #10 Distance to TjMax Temperature 22    25   25   25
12th Gen Intel Core i7-1260P CPU Core #11 Distance to TjMax Temperature 23    25   25   25
12th Gen Intel Core i7-1260P CPU Core #12 Distance to TjMax Temperature 24    25   25   25
12th Gen Intel Core i7-1260P Core Max                       Temperature 25    82   82   82
12th Gen Intel Core i7-1260P Core Average                   Temperature 26    78   78   78
12th Gen Intel Core i7-1260P CPU Core #4                    Temperature 3     73   73   73
12th Gen Intel Core i7-1260P CPU Core #5                    Temperature 4     80   80   80
12th Gen Intel Core i7-1260P CPU Core #6                    Temperature 5     82   82   82
12th Gen Intel Core i7-1260P CPU Core #7                    Temperature 6     82   82   82
12th Gen Intel Core i7-1260P CPU Core #8                    Temperature 7     82   82   82
12th Gen Intel Core i7-1260P CPU Core #9                    Temperature 8     75   75   75
12th Gen Intel Core i7-1260P CPU Core #10                   Temperature 9     75   75   75
12th Gen Intel Core i7-1260P CPU Core                       Voltage 0          1    1    1
12th Gen Intel Core i7-1260P CPU Core #1                    Voltage 1          1    1    1
12th Gen Intel Core i7-1260P CPU Core #10                   Voltage 10         1    1    1
12th Gen Intel Core i7-1260P CPU Core #11                   Voltage 11         1    1    1
12th Gen Intel Core i7-1260P CPU Core #12                   Voltage 12         1    1    1
12th Gen Intel Core i7-1260P CPU Core #2                    Voltage 2          1    1    1
12th Gen Intel Core i7-1260P CPU Core #3                    Voltage 3          1    1    1
12th Gen Intel Core i7-1260P CPU Core #4                    Voltage 4          1    1    1
12th Gen Intel Core i7-1260P CPU Core #5                    Voltage 5          1    1    1
12th Gen Intel Core i7-1260P CPU Core #6                    Voltage 6          1    1    1
12th Gen Intel Core i7-1260P CPU Core #7                    Voltage 7          1    1    1
12th Gen Intel Core i7-1260P CPU Core #8                    Voltage 8          1    1    1
12th Gen Intel Core i7-1260P CPU Core #9                    Voltage 9          1    1    1
```

> On neither of my two systems has it worked to get data from the .NET library OpenHardwareMonitor

### CIM (Common Information Model) via OpenHardwareMonitor

The computer used is an **Intel Core i5 10400 based computer**. The default method of retrieving data, checks that the application process is running.

```PowerShell
> Get-Sensor | Format-Table

HardwareName           SensorName       SensorType    Value Min  Max
------------           ----------       ----------    ----- ---  ---
Generic Hard Disk      Used Space       Load 0           34  33   34
Generic Memory         Used Memory      Data 0           13  11   15
Generic Memory         Available Memory Data 1           19  17   21
Generic Memory         Memory           Load 0           40  36   46
Intel Core i5-10400    Bus Speed        Clock 0         100 100  100
Intel Core i5-10400    CPU Core #1      Clock 1        4006 801 4106
Intel Core i5-10400    CPU Core #2      Clock 2        4006 801 4106
Intel Core i5-10400    CPU Core #3      Clock 3        4006 801 4106
Intel Core i5-10400    CPU Core #4      Clock 4        4006 801 4106
Intel Core i5-10400    CPU Core #5      Clock 5        4006 801 4106
Intel Core i5-10400    CPU Core #6      Clock 6        4006 801 4106
Intel Core i5-10400    CPU Total        Load 0            8   0  100
Intel Core i5-10400    CPU Core #1      Load 1            3   0  100
Intel Core i5-10400    CPU Core #2      Load 2            2   0  100
Intel Core i5-10400    CPU Core #3      Load 3           13   0  100
Intel Core i5-10400    CPU Core #4      Load 4           12   0  100
Intel Core i5-10400    CPU Core #5      Load 5           12   0  100
Intel Core i5-10400    CPU Core #6      Load 6            4   0  100
Intel Core i5-10400    CPU Package      Power 0          17   8   68
Intel Core i5-10400    CPU Cores        Power 1          10   1   62
Intel Core i5-10400    CPU Graphics     Power 2           0   0    0
Intel Core i5-10400    CPU DRAM         Power 3           1   1    4
Intel Core i5-10400    CPU Core #1      Temperature 0    30  23   51
Intel Core i5-10400    CPU Core #2      Temperature 1    35  24   50
Intel Core i5-10400    CPU Core #3      Temperature 2    30  23   52
Intel Core i5-10400    CPU Core #4      Temperature 3    30  22   50
Intel Core i5-10400    CPU Core #5      Temperature 4    31  23   50
Intel Core i5-10400    CPU Core #6      Temperature 5    33  23   50
Intel Core i5-10400    CPU Package      Temperature 6    35  26   51
Radeon RX 570 Series   GPU Core         Clock 0         300 300 1268
Radeon RX 570 Series   GPU Memory       Clock 1         300 300 1750
Radeon RX 570 Series   GPU Fan          Control 0         0   0   24
Radeon RX 570 Series   GPU Fan          Fan 0             0   0  982
Radeon RX 570 Series   GPU Core         Load 0            0   0  100
Radeon RX 570 Series   GPU Total        Power 0           6   6   58
Radeon RX 570 Series   GPU Core         Temperature 0    36  32   56
Radeon RX 570 Series   GPU Memory       Temperature 1    36  32   56
Radeon RX 570 Series   GPU VRM Core     Temperature 2    36  32   56
Radeon RX 570 Series   GPU VRM Memory   Temperature 3    36  32   56
Radeon RX 570 Series   GPU Liquid       Temperature 7    36  32   56
Radeon RX 570 Series   GPU PLX          Temperature 8    36  32   56
Radeon RX 570 Series   GPU Hot Spot     Temperature 9    36  32   56
Radeon RX 570 Series   GPU Core         Voltage 0         1   1    1
ST1000DM003-1CH162     Used Space       Load 0           44  43   44
ST1000DM003-1CH162     Temperature      Temperature 0    36  32   37
WDC WD2005FBYZ-01YCBB2 Used Space       Load 0           69  68   73
WDC WD2005FBYZ-01YCBB2 Temperature      Temperature 0    36  33   37
```

### CIM (Common Information Model) via LibreHardwareMonitor

Gets more sensors, for the motherboard (Nuvoton NCT6687D) and NVMe SSD m.2 (MSI M390).

```PowerShell
> Get-Sensor -Libre | Where-Object Value -ne 0 | Format-Table

HardwareName           SensorName                    SensorType       Value   Min      Max
------------           ----------                    ----------       -----   ---      ---
Generic Memory         Memory Used                   Data 0              13    12       14
Generic Memory         Memory Available              Data 1              19    18       20
Generic Memory         Virtual Memory Used           Data 2              16    16       18
Generic Memory         Virtual Memory Available      Data 3              20    19       21
Generic Memory         Memory                        Load 0              40    39       45
Generic Memory         Virtual Memory                Load 1              44    43       48
Intel Core i5-10400    Bus Speed                     Clock 0            100   100      100
Intel Core i5-10400    CPU Core #1                   Clock 1           4006   801     4106
Intel Core i5-10400    CPU Core #2                   Clock 2           4006   801     4106
Intel Core i5-10400    CPU Core #3                   Clock 3           4006   801     4206
Intel Core i5-10400    CPU Core #4                   Clock 4           4006   801     4106
Intel Core i5-10400    CPU Core #5                   Clock 5           4006   801     4106
Intel Core i5-10400    CPU Core #6                   Clock 6           4006   801     4106
Intel Core i5-10400    CPU Total                     Load 0               7     1      100
Intel Core i5-10400    CPU Core Max                  Load 1              43     5      100
Intel Core i5-10400    CPU Core #5 Thread #1         Load 10              9     0      100
Intel Core i5-10400    CPU Core #5 Thread #2         Load 11              1     0      100
Intel Core i5-10400    CPU Core #6 Thread #1         Load 12              3     0      100
Intel Core i5-10400    CPU Core #6 Thread #2         Load 13              2     0      100
Intel Core i5-10400    CPU Core #1 Thread #1         Load 2               6     1      100
Intel Core i5-10400    CPU Core #2 Thread #1         Load 4               4     1      100
Intel Core i5-10400    CPU Core #2 Thread #2         Load 5               1     0      100
Intel Core i5-10400    CPU Core #3 Thread #1         Load 6              43     1      100
Intel Core i5-10400    CPU Core #3 Thread #2         Load 7               4     0      100
Intel Core i5-10400    CPU Core #4 Thread #1         Load 8               8     0      100
Intel Core i5-10400    CPU Core #4 Thread #2         Load 9               6     0      100
Intel Core i5-10400    CPU Package                   Power 0             17     8       54
Intel Core i5-10400    CPU Cores                     Power 1             10     1       48
Intel Core i5-10400    CPU Memory                    Power 3              1     1        3
Intel Core i5-10400    CPU Core #1                   Temperature 0       32    23       45
Intel Core i5-10400    CPU Core #2                   Temperature 1       37    24       45
Intel Core i5-10400    CPU Core #4 Distance to TjMax Temperature 10      70    55       78
Intel Core i5-10400    CPU Core #5 Distance to TjMax Temperature 11      58    55       77
Intel Core i5-10400    CPU Core #6 Distance to TjMax Temperature 12      70    57       77
Intel Core i5-10400    Core Max                      Temperature 13      42    24       48
Intel Core i5-10400    Core Average                  Temperature 14      34    23       43
Intel Core i5-10400    CPU Core #3                   Temperature 2       30    23       48
Intel Core i5-10400    CPU Core #4                   Temperature 3       30    22       45
Intel Core i5-10400    CPU Core #5                   Temperature 4       42    23       45
Intel Core i5-10400    CPU Core #6                   Temperature 5       30    23       43
Intel Core i5-10400    CPU Package                   Temperature 6       42    26       48
Intel Core i5-10400    CPU Core #1 Distance to TjMax Temperature 7       68    55       77
Intel Core i5-10400    CPU Core #2 Distance to TjMax Temperature 8       63    55       76
Intel Core i5-10400    CPU Core #3 Distance to TjMax Temperature 9       70    52       77
Intel Core i5-10400    CPU Core                      Voltage 0            1     1        1
Intel Core i5-10400    CPU Core #1                   Voltage 1            1     1        1
Intel Core i5-10400    CPU Core #2                   Voltage 2            1     1        1
Intel Core i5-10400    CPU Core #3                   Voltage 3            1     1        1
Intel Core i5-10400    CPU Core #4                   Voltage 4            1     1        1
Intel Core i5-10400    CPU Core #5                   Voltage 5            1     1        1
Intel Core i5-10400    CPU Core #6                   Voltage 6            1     1        1
MSI M390 250GB         Data Read                     Data 4            6131     0     6131
MSI M390 250GB         Data Written                  Data 5           34098     0    34098
MSI M390 250GB         Available Spare               Level 1            100     0      100
MSI M390 250GB         Available Spare Threshold     Level 2              5     0        5
MSI M390 250GB         Percentage Used               Level 3             36     0       36
MSI M390 250GB         Used Space                    Load 0              34    34       34
MSI M390 250GB         Temperature                   Temperature 0       41     0       41
Nuvoton NCT6687D       CPU Fan                       Control 0           13    13       21
Nuvoton NCT6687D       Pump Fan                      Control 1          100   100      100
Nuvoton NCT6687D       System Fan #1                 Control 2           60    60       60
Nuvoton NCT6687D       System Fan #2                 Control 3           60    60       60
Nuvoton NCT6687D       System Fan #3                 Control 4           60    60       60
Nuvoton NCT6687D       System Fan #4                 Control 5           60    60       60
Nuvoton NCT6687D       System Fan #5                 Control 6           60    60       60
Nuvoton NCT6687D       System Fan #6                 Control 7           60    60       60
Nuvoton NCT6687D       CPU Fan                       Fan 0             1056   795     1060
Nuvoton NCT6687D       System Fan #6                 Fan 7              803   777      806
Nuvoton NCT6687D       CPU                           Temperature 0       38    26       44
Nuvoton NCT6687D       System                        Temperature 1       36    32       36
Nuvoton NCT6687D       VRM MOS                       Temperature 2       42    35       42
Nuvoton NCT6687D       PCH                           Temperature 3       41    35       44
Nuvoton NCT6687D       CPU Socket                    Temperature 4       34    28       34
Nuvoton NCT6687D       PCIe x1                       Temperature 5       29    29       29
Nuvoton NCT6687D       M2_1                          Temperature 6       23    23       23
Nuvoton NCT6687D       +12V                          Voltage 0           12    12       12
Nuvoton NCT6687D       +5V                           Voltage 1            5     5        5
Nuvoton NCT6687D       VRef                          Voltage 10           2     2        2
Nuvoton NCT6687D       VSB                           Voltage 11           3     3        3
Nuvoton NCT6687D       AVSB                          Voltage 12           3     3        3
Nuvoton NCT6687D       VBat                          Voltage 13           3     3        3
Nuvoton NCT6687D       Vcore                         Voltage 2            1     1        1
Nuvoton NCT6687D       Voltage #1                    Voltage 3            1     1        1
Nuvoton NCT6687D       DIMM                          Voltage 4            1     1        1
Nuvoton NCT6687D       CPU I/O                       Voltage 5            1     1        1
Nuvoton NCT6687D       CPU SA                        Voltage 6            1     1        1
Nuvoton NCT6687D       Voltage #2                    Voltage 7            2     2        2
Nuvoton NCT6687D       AVCC3                         Voltage 8            3     3        3
Nuvoton NCT6687D       VTT                           Voltage 9            1     1        1
Radeon RX 570 Series   GPU Core                      Clock 0            300   300      387
Radeon RX 570 Series   GPU Memory                    Clock 2            300   300      300
Radeon RX 570 Series   Fullscreen FPS                Factor 0            -1    -1       -1
Radeon RX 570 Series   D3D 3D                        Load 2               1     0       20
Radeon RX 570 Series   GPU Package                   Power 3              6     6        8
Radeon RX 570 Series   D3D Dedicated Memory Used     SmallData 0        408   313      675
Radeon RX 570 Series   D3D Shared Memory Used        SmallData 1         25     2       60
Radeon RX 570 Series   GPU Core                      Temperature 0       36    32       37
Radeon RX 570 Series   GPU Core                      Voltage 0            1     1        1
Radmin VPN             Upload Speed                  Throughput 7       139     0     2149
ST1000DM003-1CH162     Used Space                    Load 0              44    44       44
ST1000DM003-1CH162     Temperature                   Temperature 0       36    32       37
vEthernet (NAT)        Data Uploaded                 Data 2             110   100      110
vEthernet (NAT)        Data Downloaded               Data 3            1191  1064     1191
vEthernet (NAT)        Network Utilization           Load 1               1     0       47
vEthernet (NAT)        Upload Speed                  Throughput 7     78443  2252 37866380
vEthernet (NAT)        Download Speed                Throughput 8   1366642 92291 58636480
WDC WD2005FBYZ-01YCBB2 Used Space                    Load 0              69    68       70
WDC WD2005FBYZ-01YCBB2 Temperature                   Temperature 0       36    34       37
```

## 📊 Monitoring settings

Process configuring **temperature sensor monitoring**.

- 1. Install [InfluxDB](https://www.influxdata.com/downloads) version 1.x in Ubuntu:

> Define the server on which the time series database will be installed (it can be WSL or a virtual machine).

```Bash
wget https://dl.influxdata.com/influxdb/releases/influxdb_1.8.10_amd64.deb
sudo dpkg -i influxdb_1.8.10_amd64.deb
systemctl start influxdb
systemctl status influxdb
```

- 2. Creat background process to send sensors to the database.

> Administrator rights are required for library and cim

When installing the module, it includes a template script to send data to InfluxDB and to start and stop the background process. Pre-configure the script and check the database for data availability.

Change the script `Write-Database.ps1` for local or remote data collection (select the data source using the module parameters):

**Local**:

```PowerShell
while ($True) {
    # $Data = Get-Sensor
    $Data = Get-Sensor -Libre
    # $Data = Get-Sensor -Libre -Library
    Send-TemperatureToInfluxDB -Data $Data -ServerInflux "192.168.3.102" -Port 8086 -Database "PowerShell" -Table "HardwareMonitor" # -LogWriteFile
    Start-Sleep -Seconds 5
}
```

**Remote**:

```PowerShell
while ($True) {
    $Data = Get-Sensor -Server 192.168.3.100 -Port 8085
    Send-TemperatureToInfluxDB -ComputerName "192.168.3.100" -Data $Data -ServerInflux "192.168.3.102" -Port 8086 -Database "PowerShell" -Table "HardwareMonitor"
    Start-Sleep -Seconds 5
}
```

**Run a background process** to send sensors to the database with a specified timeout (`Process-Start.ps1`):

```PowerShell
$Path = "$(($env:PSModulePath -split ";")[0])\PowerShellHardwareMonitor"
$proc_id = $(Start-Process pwsh -ArgumentList "-File $Path\Write-Database.ps1" -Verb RunAs -WindowStyle Hidden -PassThru).id
$proc_id > "$Path\process_id.txt"
```

We commit the id of the process when it is created to a temporary file so that it can be **stopped** (`Process-Stop.ps1`):

```PowerShell
$Path = "$(($env:PSModulePath -split ";")[0])\PowerShellHardwareMonitor"
$proc_id = Get-Content "$path\process_id.txt"
Start-Process pwsh -ArgumentList "-Command Stop-Process -Id $proc_id" -Verb RunAs
```

- 3. Check the received data using [InfluxDB Studio](https://github.com/CymaticLabs/InfluxDBStudio):

> In the example, the critical processor temperature is 99 degrees for the last 2 hours.

![Image alt](https://github.com/Lifailon/PowerShellHardwareMonitor/blob/rsa/Screen/InfluxDB-Data.jpg)

- 4. Install [Grafana Enterprise](https://grafana.com/grafana/download).

```Bash
apt-get install -y adduser libfontconfig1 musl
wget https://dl.grafana.com/enterprise/release/grafana-enterprise_10.3.1_amd64.deb
dpkg -i grafana-enterprise_10.3.1_amd64.deb
systemctl start grafana-server
systemctl status grafana-server
```

- 5. Dashboard settings:

The example shows the very same indicator that we have recorded in the database:

![Image alt](https://github.com/Lifailon/PowerShellHardwareMonitor/blob/rsa/Screen/Grafana-Dashboard.jpg)

For simple setting (without using variables or regular expressions), use grouping by host and hardware name tags and filters by sensor name:

![Image alt](https://github.com/Lifailon/PowerShellHardwareMonitor/blob/rsa/Screen/InfluxDB-Query.jpg)

For clarity and convenience, customize the celsius data type and legends (displaying minimum, maximum, and average readings for the specified time period).

![Image alt](https://github.com/Lifailon/PowerShellHardwareMonitor/blob/rsa/Screen/Grafana-Legend-Celsius.jpg)

Monitoring two hosts:

![Image alt](https://github.com/Lifailon/PowerShellHardwareMonitor/blob/rsa/Screen/Grafana-Dashboard-Group.jpg)