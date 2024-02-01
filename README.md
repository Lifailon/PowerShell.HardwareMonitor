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

- Install **OpenHardwareMonitor** via the [GitHub repository](https://github.com/LibreHardwareMonitor/LibreHardwareMonitor):

```PowerShell
Invoke-Expression(New-Object Net.WebClient).DownloadString("https://raw.githubusercontent.com/Lifailon/PowerShellHardwareMonitor/rsa/Install/Install-OpenHardwareMonitor.ps1")
```

- Install **Library** from [website](https://openhardwaremonitor.org/):

```PowerShell
Invoke-Expression(New-Object Net.WebClient).DownloadString("https://raw.githubusercontent.com/Lifailon/PowerShellHardwareMonitor/rsa/Install/Install-LibreHardwareMonitor.ps1")
```

- **Quickly install or update the module**

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
> Get-Sensor -Server 192.168.3.99 | Where-Object Value -notmatch "^0,0" | Format-Table

HardwareName                 SensorName SensorType       Value   Min     Max
------------                 ---------- ----------       -----   ---     ---
12th Gen Intel Core i7-1260P Load       CPU Total        10,2 %  9,9 %   29,2 %
12th Gen Intel Core i7-1260P Load       CPU Core #1      16,4 %  10,1 %  50,0 %
12th Gen Intel Core i7-1260P Load       CPU Core #2      5,5 %   2,3 %   33,3 %
12th Gen Intel Core i7-1260P Load       CPU Core #3      4,0 %   0,8 %   33,3 %
12th Gen Intel Core i7-1260P Load       CPU Core #5      3,1 %   0,0 %   15,0 %
12th Gen Intel Core i7-1260P Load       CPU Core #6      1,6 %   0,0 %   33,3 %
12th Gen Intel Core i7-1260P Load       CPU Core #7      3,1 %   1,6 %   66,7 %
12th Gen Intel Core i7-1260P Load       CPU Core #8      4,7 %   0,0 %   40,6 %
12th Gen Intel Core i7-1260P Load       CPU Core #9      7,8 %   6,7 %   42,2 %
12th Gen Intel Core i7-1260P Load       CPU Core #10     17,2 %  0,0 %   34,4 %
12th Gen Intel Core i7-1260P Load       CPU Core #11     37,5 %  3,1 %   45,3 %
12th Gen Intel Core i7-1260P Load       CPU Core #12     35,9 %  0,0 %   35,9 %
Generic Memory               Load       Memory           96,2 %  95,9 %  96,2 %
Generic Memory               Data       Used Memory      15,1 GB 15,1 GB 15,1 GB
Generic Memory               Data       Available Memory 0,6 GB  0,6 GB  0,6 GB
Generic Hard Disk            Load       Used Space       51,7 %  51,7 %  51,7 %
```

### REST API via LibreHardwareMonitor

```PowerShell
> Get-Sensor -Server 192.168.3.99 | Where-Object Value -notmatch "^0,0" | Format-Table

HardwareName                  SensorName   SensorType                     Value      Min       Max
------------                  ----------   ----------                     -----      ---       ---
12th Gen Intel Core i7-1260P  Voltages     CPU Core                       1,233 V    0,585 V   1,353 V
12th Gen Intel Core i7-1260P  Voltages     CPU Core #1                    1,318 V    0,597 V   1,353 V
12th Gen Intel Core i7-1260P  Voltages     CPU Core #2                    1,338 V    0,604 V   1,358 V
12th Gen Intel Core i7-1260P  Voltages     CPU Core #3                    1,223 V    0,749 V   1,353 V
12th Gen Intel Core i7-1260P  Voltages     CPU Core #4                    1,253 V    0,569 V   1,356 V
12th Gen Intel Core i7-1260P  Voltages     CPU Core #5                    1,153 V    0,562 V   1,351 V
12th Gen Intel Core i7-1260P  Voltages     CPU Core #6                    1,308 V    0,581 V   1,349 V
12th Gen Intel Core i7-1260P  Voltages     CPU Core #7                    1,293 V    0,740 V   1,352 V
12th Gen Intel Core i7-1260P  Voltages     CPU Core #8                    1,168 V    0,572 V   1,348 V
12th Gen Intel Core i7-1260P  Voltages     CPU Core #9                    1,168 V    0,586 V   1,351 V
12th Gen Intel Core i7-1260P  Voltages     CPU Core #10                   1,159 V    0,570 V   1,348 V
12th Gen Intel Core i7-1260P  Voltages     CPU Core #11                   1,164 V    0,619 V   1,348 V
12th Gen Intel Core i7-1260P  Voltages     CPU Core #12                   1,159 V    0,710 V   1,350 V
12th Gen Intel Core i7-1260P  Powers       CPU Package                    20,2 W     1,3 W     45,7 W
12th Gen Intel Core i7-1260P  Powers       CPU Cores                      15,3 W     0,4 W     39,3 W
12th Gen Intel Core i7-1260P  Clocks       Bus Speed                      99,8 MHz   99,8 MHz  99,8 MHz
12th Gen Intel Core i7-1260P  Clocks       CPU Core #1                    4692,5 MHz 399,4 MHz 4692,7 MHz
12th Gen Intel Core i7-1260P  Clocks       CPU Core #2                    2995,2 MHz 399,4 MHz 4692,6 MHz
12th Gen Intel Core i7-1260P  Clocks       CPU Core #3                    3993,6 MHz 399,4 MHz 4692,6 MHz
12th Gen Intel Core i7-1260P  Clocks       CPU Core #4                    3793,9 MHz 399,4 MHz 4692,5 MHz
12th Gen Intel Core i7-1260P  Clocks       CPU Core #5                    2995,2 MHz 399,4 MHz 3394,6 MHz
12th Gen Intel Core i7-1260P  Clocks       CPU Core #6                    2995,2 MHz 399,4 MHz 3394,6 MHz
12th Gen Intel Core i7-1260P  Clocks       CPU Core #7                    3194,9 MHz 399,4 MHz 3394,6 MHz
12th Gen Intel Core i7-1260P  Clocks       CPU Core #8                    3194,9 MHz 399,4 MHz 3394,8 MHz
12th Gen Intel Core i7-1260P  Clocks       CPU Core #9                    3095,0 MHz 399,4 MHz 3394,7 MHz
12th Gen Intel Core i7-1260P  Clocks       CPU Core #10                   3394,6 MHz 399,4 MHz 3394,6 MHz
12th Gen Intel Core i7-1260P  Clocks       CPU Core #11                   2995,2 MHz 399,3 MHz 3394,6 MHz
12th Gen Intel Core i7-1260P  Clocks       CPU Core #12                   3194,9 MHz 399,4 MHz 3394,8 MHz
12th Gen Intel Core i7-1260P  Temperatures CPU Core #1                    97,0 °C    34,0 °C   100,0 °C
12th Gen Intel Core i7-1260P  Temperatures CPU Core #2                    78,0 °C    37,0 °C   99,0 °C
12th Gen Intel Core i7-1260P  Temperatures CPU Core #3                    83,0 °C    35,0 °C   97,0 °C
12th Gen Intel Core i7-1260P  Temperatures CPU Core #4                    74,0 °C    34,0 °C   97,0 °C
12th Gen Intel Core i7-1260P  Temperatures CPU Core #5                    77,0 °C    36,0 °C   97,0 °C
12th Gen Intel Core i7-1260P  Temperatures CPU Core #6                    77,0 °C    36,0 °C   97,0 °C
12th Gen Intel Core i7-1260P  Temperatures CPU Core #7                    77,0 °C    36,0 °C   97,0 °C
12th Gen Intel Core i7-1260P  Temperatures CPU Core #8                    77,0 °C    36,0 °C   97,0 °C
12th Gen Intel Core i7-1260P  Temperatures CPU Core #9                    82,0 °C    31,0 °C   97,0 °C
12th Gen Intel Core i7-1260P  Temperatures CPU Core #10                   82,0 °C    31,0 °C   97,0 °C
12th Gen Intel Core i7-1260P  Temperatures CPU Core #11                   82,0 °C    31,0 °C   97,0 °C
12th Gen Intel Core i7-1260P  Temperatures CPU Core #12                   82,0 °C    32,0 °C   97,0 °C
12th Gen Intel Core i7-1260P  Temperatures CPU Package                    93,0 °C    37,0 °C   100,0 °C
12th Gen Intel Core i7-1260P  Temperatures CPU Core #1 Distance to TjMax  3,0 °C     0,0 °C    66,0 °C
12th Gen Intel Core i7-1260P  Temperatures CPU Core #2 Distance to TjMax  22,0 °C    1,0 °C    63,0 °C
12th Gen Intel Core i7-1260P  Temperatures CPU Core #3 Distance to TjMax  17,0 °C    3,0 °C    65,0 °C
12th Gen Intel Core i7-1260P  Temperatures CPU Core #4 Distance to TjMax  26,0 °C    3,0 °C    66,0 °C
12th Gen Intel Core i7-1260P  Temperatures CPU Core #5 Distance to TjMax  23,0 °C    3,0 °C    64,0 °C
12th Gen Intel Core i7-1260P  Temperatures CPU Core #6 Distance to TjMax  23,0 °C    3,0 °C    64,0 °C
12th Gen Intel Core i7-1260P  Temperatures CPU Core #7 Distance to TjMax  23,0 °C    3,0 °C    64,0 °C
12th Gen Intel Core i7-1260P  Temperatures CPU Core #8 Distance to TjMax  23,0 °C    3,0 °C    64,0 °C
12th Gen Intel Core i7-1260P  Temperatures CPU Core #9 Distance to TjMax  18,0 °C    3,0 °C    69,0 °C
12th Gen Intel Core i7-1260P  Temperatures CPU Core #10 Distance to TjMax 18,0 °C    3,0 °C    69,0 °C
12th Gen Intel Core i7-1260P  Temperatures CPU Core #11 Distance to TjMax 18,0 °C    3,0 °C    69,0 °C
12th Gen Intel Core i7-1260P  Temperatures CPU Core #12 Distance to TjMax 18,0 °C    3,0 °C    68,0 °C
12th Gen Intel Core i7-1260P  Temperatures Core Max                       97,0 °C    37,0 °C   100,0 °C
12th Gen Intel Core i7-1260P  Temperatures Core Average                   80,7 °C    34,1 °C   91,7 °C
12th Gen Intel Core i7-1260P  Load         CPU Total                      11,0 %     1,4 %     100,0 %
12th Gen Intel Core i7-1260P  Load         CPU Core Max                   49,4 %     3,0 %     100,0 %
12th Gen Intel Core i7-1260P  Load         CPU Core #1 Thread #1          31,5 %     0,0 %     100,0 %
12th Gen Intel Core i7-1260P  Load         CPU Core #2 Thread #1          11,6 %     0,0 %     100,0 %
12th Gen Intel Core i7-1260P  Load         CPU Core #3 Thread #1          3,8 %      0,0 %     100,0 %
12th Gen Intel Core i7-1260P  Load         CPU Core #3 Thread #2          0,8 %      0,0 %     100,0 %
12th Gen Intel Core i7-1260P  Load         CPU Core #5                    7,6 %      0,0 %     100,0 %
12th Gen Intel Core i7-1260P  Load         CPU Core #6                    8,8 %      1,1 %     100,0 %
12th Gen Intel Core i7-1260P  Load         CPU Core #7                    8,3 %      0,8 %     100,0 %
12th Gen Intel Core i7-1260P  Load         CPU Core #8                    4,3 %      2,0 %     100,0 %
12th Gen Intel Core i7-1260P  Load         CPU Core #9                    6,8 %      0,0 %     100,0 %
12th Gen Intel Core i7-1260P  Load         CPU Core #10                   28,6 %     1,9 %     100,0 %
12th Gen Intel Core i7-1260P  Load         CPU Core #11                   49,4 %     0,0 %     100,0 %
12th Gen Intel Core i7-1260P  Load         CPU Core #12                   16,8 %     1,8 %     100,0 %
Generic Memory                Load         Memory                         95,7 %     86,1 %    100,0 %
Generic Memory                Load         Virtual Memory                 88,7 %     84,6 %    90,6 %
Generic Memory                Data         Memory Used                    15,1 GB    13,5 GB   15,7 GB
Generic Memory                Data         Memory Available               0,7 GB     0,0 GB    2,2 GB
Generic Memory                Data         Virtual Memory Used            51,9 GB    48,6 GB   52,9 GB
Generic Memory                Data         Virtual Memory Available       6,6 GB     5,5 GB    8,9 GB
Intel(R) Iris(R) Xe Graphics  Load         D3D 3D                         3,4 %      0,0 %     77,1 %
Intel(R) Iris(R) Xe Graphics  Data         D3D Shared Memory Used         1826,1 MB  1382,2 MB 3068,6 MB
WD PC SN740 SDDPNQD-1T00-1027 Temperatures Temperature                    64,0 °C    0,0 °C    75,0 °C
WD PC SN740 SDDPNQD-1T00-1027 Temperatures Temperature 1                  71,0 °C    0,0 °C    98,0 °C
WD PC SN740 SDDPNQD-1T00-1027 Temperatures Temperature 2                  64,0 °C    0,0 °C    72,0 °C
WD PC SN740 SDDPNQD-1T00-1027 Load         Used Space                     51,7 %     51,6 %    52,6 %
WD PC SN740 SDDPNQD-1T00-1027 Load         Read Activity                  0,5 %      0,0 %     100,0 %
WD PC SN740 SDDPNQD-1T00-1027 Load         Write Activity                 0,5 %      0,0 %     91,1 %
WD PC SN740 SDDPNQD-1T00-1027 Load         Total Activity                 1,0 %      0,0 %     100,0 %
WD PC SN740 SDDPNQD-1T00-1027 Data         Data Read                      9915,0 GB  0,0 GB    9915,0 GB
WD PC SN740 SDDPNQD-1T00-1027 Data         Data Written                   10092,0 GB 0,0 GB    10092,0 GB
WD PC SN740 SDDPNQD-1T00-1027 Throughput   Read Rate                      143,6 KB/s 0,0 KB/s  517,2 MB/s
WD PC SN740 SDDPNQD-1T00-1027 Throughput   Write Rate                     94,4 KB/s  0,0 KB/s  485,5 MB/s
Беспроводная сеть             Data         Data Uploaded                  0,9 GB     0,0 GB    0,9 GB
Беспроводная сеть             Data         Data Downloaded                11,6 GB    0,0 GB    11,6 GB
Беспроводная сеть             Throughput   Upload Speed                   3,2 KB/s   0,0 KB/s  5,1 MB/s
Беспроводная сеть             Throughput   Download Speed                 35,1 KB/s  0,0 KB/s  16,2 MB/s
HB5781P1EEW-31T               Voltages     Voltage                        11,601 V   10,654 V  11,794 V
HB5781P1EEW-31T               Currents     Charge Current                 0,438 A    0,000 A   6,225 A
HB5781P1EEW-31T               Powers       Charge Rate                    5,1 W      0,0 W     67,1 W
HB5781P1EEW-31T               Levels       Degradation Level              11,8 %     11,8 %    11,8 %
HB5781P1EEW-31T               Levels       Charge Level                   39,7 %     13,5 %    40,2 %
HB5781P1EEW-31T               Capacities   Designed Capacity              59424 mWh  59424 mWh 59424 mWh
HB5781P1EEW-31T               Capacities   Full Charged Capacity          52413 mWh  52413 mWh 52413 mWh
HB5781P1EEW-31T               Capacities   Remaining Capacity             20813 mWh  7057 mWh  21044 mWh
```

### .NET Library via LibreHardwareMonitor

> 💡 To get data from all sensors, you need to run the console with **administrator privileges**

```PowerShell
> Get-Sensor -Libre -Library | Where-Object Value -ne 0 | Format-Table

HardwareName                 SensorName                     SensorType     Value  Min  Max
------------                 ----------                     ----------     -----  ---  ---
12th Gen Intel Core i7-1260P Bus Speed                      Clock 0          100  100  100
12th Gen Intel Core i7-1260P CPU Core #1                    Clock 1         3495 3495 3495
12th Gen Intel Core i7-1260P CPU Core #10                   Clock 10        2596 2596 2596
12th Gen Intel Core i7-1260P CPU Core #11                   Clock 11        2596 2596 2596
12th Gen Intel Core i7-1260P CPU Core #12                   Clock 12        2696 2696 2696
12th Gen Intel Core i7-1260P CPU Core #2                    Clock 2         3594 3594 3594
12th Gen Intel Core i7-1260P CPU Core #3                    Clock 3         3594 3594 3594
12th Gen Intel Core i7-1260P CPU Core #4                    Clock 4         3594 3594 3594
12th Gen Intel Core i7-1260P CPU Core #5                    Clock 5         2796 2796 2796
12th Gen Intel Core i7-1260P CPU Core #6                    Clock 6         2796 2796 2796
12th Gen Intel Core i7-1260P CPU Core #7                    Clock 7         2895 2895 2895
12th Gen Intel Core i7-1260P CPU Core #8                    Clock 8         2895 2895 2895
12th Gen Intel Core i7-1260P CPU Core #9                    Clock 9         2596 2596 2596
12th Gen Intel Core i7-1260P CPU Total                      Load 0            31   31   31
12th Gen Intel Core i7-1260P CPU Core Max                   Load 1            87   87   87
12th Gen Intel Core i7-1260P CPU Core #5                    Load 10           34   34   34
12th Gen Intel Core i7-1260P CPU Core #6                    Load 11           31   31   31
12th Gen Intel Core i7-1260P CPU Core #7                    Load 12           37   37   37
12th Gen Intel Core i7-1260P CPU Core #8                    Load 13           39   39   39
12th Gen Intel Core i7-1260P CPU Core #9                    Load 14           32   32   32
12th Gen Intel Core i7-1260P CPU Core #10                   Load 15           72   72   72
12th Gen Intel Core i7-1260P CPU Core #11                   Load 16           24   24   24
12th Gen Intel Core i7-1260P CPU Core #12                   Load 17           42   42   42
12th Gen Intel Core i7-1260P CPU Core #1 Thread #1          Load 2            87   87   87
12th Gen Intel Core i7-1260P CPU Core #1 Thread #2          Load 3             6    6    6
12th Gen Intel Core i7-1260P CPU Core #2 Thread #1          Load 4            30   30   30
12th Gen Intel Core i7-1260P CPU Core #2 Thread #2          Load 5            11   11   11
12th Gen Intel Core i7-1260P CPU Core #3 Thread #1          Load 6            28   28   28
12th Gen Intel Core i7-1260P CPU Core #4 Thread #1          Load 8            33   33   33
12th Gen Intel Core i7-1260P CPU Package                    Power 0           18   18   18
12th Gen Intel Core i7-1260P CPU Cores                      Power 1           13   13   13
12th Gen Intel Core i7-1260P CPU Core #1                    Temperature 0     83   83   83
12th Gen Intel Core i7-1260P CPU Core #2                    Temperature 1     80   80   80
12th Gen Intel Core i7-1260P CPU Core #11                   Temperature 10    81   81   81
12th Gen Intel Core i7-1260P CPU Core #12                   Temperature 11    84   84   84
12th Gen Intel Core i7-1260P CPU Package                    Temperature 12    84   84   84
12th Gen Intel Core i7-1260P CPU Core #1 Distance to TjMax  Temperature 13    17   17   17
12th Gen Intel Core i7-1260P CPU Core #2 Distance to TjMax  Temperature 14    20   20   20
12th Gen Intel Core i7-1260P CPU Core #3 Distance to TjMax  Temperature 15    19   19   19
12th Gen Intel Core i7-1260P CPU Core #4 Distance to TjMax  Temperature 16    23   23   23
12th Gen Intel Core i7-1260P CPU Core #5 Distance to TjMax  Temperature 17    20   20   20
12th Gen Intel Core i7-1260P CPU Core #6 Distance to TjMax  Temperature 18    20   20   20
12th Gen Intel Core i7-1260P CPU Core #7 Distance to TjMax  Temperature 19    20   20   20
12th Gen Intel Core i7-1260P CPU Core #3                    Temperature 2     81   81   81
12th Gen Intel Core i7-1260P CPU Core #8 Distance to TjMax  Temperature 20    20   20   20
12th Gen Intel Core i7-1260P CPU Core #9 Distance to TjMax  Temperature 21    19   19   19
12th Gen Intel Core i7-1260P CPU Core #10 Distance to TjMax Temperature 22    19   19   19
12th Gen Intel Core i7-1260P CPU Core #11 Distance to TjMax Temperature 23    19   19   19
12th Gen Intel Core i7-1260P CPU Core #12 Distance to TjMax Temperature 24    16   16   16
12th Gen Intel Core i7-1260P Core Max                       Temperature 25    84   84   84
12th Gen Intel Core i7-1260P Core Average                   Temperature 26    81   81   81
12th Gen Intel Core i7-1260P CPU Core #4                    Temperature 3     77   77   77
12th Gen Intel Core i7-1260P CPU Core #5                    Temperature 4     80   80   80
12th Gen Intel Core i7-1260P CPU Core #6                    Temperature 5     80   80   80
12th Gen Intel Core i7-1260P CPU Core #7                    Temperature 6     80   80   80
12th Gen Intel Core i7-1260P CPU Core #8                    Temperature 7     80   80   80
12th Gen Intel Core i7-1260P CPU Core #9                    Temperature 8     81   81   81
12th Gen Intel Core i7-1260P CPU Core #10                   Temperature 9     81   81   81
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

> On neither of my two systems has it worked to open the .NET library for OpenHardwareMonitor

### CIM (Common Information Model) via OpenHardwareMonitor

The computer used is an **Intel Core i5 10400 based computer**

```PowerShell
> Get-Sensor | Format-Table

HardwareName           SensorName       SensorType    Value Min  Max
------------           ----------       ----------    ----- ---  ---
Generic Hard Disk      Used Space       Load 0           34  33   34
Generic Memory         Used Memory      Data 0           13  11   15
Generic Memory         Available Memory Data 1           18  17   21
Generic Memory         Memory           Load 0           42  36   46
Intel Core i5-10400    Bus Speed        Clock 0         100 100  100
Intel Core i5-10400    CPU Core #1      Clock 1        4006 801 4106
Intel Core i5-10400    CPU Core #2      Clock 2        4006 801 4106
Intel Core i5-10400    CPU Core #3      Clock 3        4006 801 4106
Intel Core i5-10400    CPU Core #4      Clock 4        4006 801 4106
Intel Core i5-10400    CPU Core #5      Clock 5        4006 801 4106
Intel Core i5-10400    CPU Core #6      Clock 6        3505 801 4106
Intel Core i5-10400    CPU Total        Load 0            5   0  100
Intel Core i5-10400    CPU Core #1      Load 1            4   0  100
Intel Core i5-10400    CPU Core #2      Load 2            9   0  100
Intel Core i5-10400    CPU Core #3      Load 3            3   0  100
Intel Core i5-10400    CPU Core #4      Load 4            5   0  100
Intel Core i5-10400    CPU Core #5      Load 5            5   0   99
Intel Core i5-10400    CPU Core #6      Load 6            5   0  100
Intel Core i5-10400    CPU Package      Power 0          14   8   68
Intel Core i5-10400    CPU Cores        Power 1           7   2   62
Intel Core i5-10400    CPU Graphics     Power 2           0   0    0
Intel Core i5-10400    CPU DRAM         Power 3           1   1    4
Intel Core i5-10400    CPU Core #1      Temperature 0    30  24   51
Intel Core i5-10400    CPU Core #2      Temperature 1    30  25   50
Intel Core i5-10400    CPU Core #3      Temperature 2    29  24   52
Intel Core i5-10400    CPU Core #4      Temperature 3    28  23   50
Intel Core i5-10400    CPU Core #5      Temperature 4    30  24   50
Intel Core i5-10400    CPU Core #6      Temperature 5    28  24   50
Intel Core i5-10400    CPU Package      Temperature 6    31  26   51
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
ST1000DM003-1CH162     Temperature      Temperature 0    36  32   36
WDC WD2005FBYZ-01YCBB2 Used Space       Load 0           70  70   73
WDC WD2005FBYZ-01YCBB2 Temperature      Temperature 0    37  33   37
```

### CIM (Common Information Model) via LibreHardwareMonitor

```PowerShell
> Get-Sensor -Libre | Format-Table

HardwareName                  SensorName                    SensorType       Value     Min     Max
------------                  ----------                    ----------       -----     ---     ---
Подключение по локальной сети Data Uploaded                 Data 2               0       0       0
Подключение по локальной сети Data Downloaded               Data 3               0       0       0
Подключение по локальной сети Network Utilization           Load 1               0       0       0
Подключение по локальной сети Upload Speed                  Throughput 7         0       0       0
Подключение по локальной сети Download Speed                Throughput 8         0       0       0
Generic Memory                Memory Used                   Data 0              13      13      13
Generic Memory                Memory Available              Data 1              18      18      18
Generic Memory                Virtual Memory Used           Data 2              17      17      17
Generic Memory                Virtual Memory Available      Data 3              19      19      19
Generic Memory                Memory                        Load 0              42      42      42
Generic Memory                Virtual Memory                Load 1              47      47      48
HotspotShield Network Adapter Data Uploaded                 Data 2               0       0       0
HotspotShield Network Adapter Data Downloaded               Data 3               0       0       0
HotspotShield Network Adapter Network Utilization           Load 1               0       0       0
HotspotShield Network Adapter Upload Speed                  Throughput 7         0       0    1859
HotspotShield Network Adapter Download Speed                Throughput 8         0       0   36276
Intel Core i5-10400           Bus Speed                     Clock 0            100     100     100
Intel Core i5-10400           CPU Core #1                   Clock 1           4006     801    4106
Intel Core i5-10400           CPU Core #2                   Clock 2           4006     801    4106
Intel Core i5-10400           CPU Core #3                   Clock 3           3705     801    4106
Intel Core i5-10400           CPU Core #4                   Clock 4           4006     801    4106
Intel Core i5-10400           CPU Core #5                   Clock 5           4006     801    4006
Intel Core i5-10400           CPU Core #6                   Clock 6           4006     801    4006
Intel Core i5-10400           CPU Total                     Load 0               8       5      25
Intel Core i5-10400           CPU Core Max                  Load 1              17       9     100
Intel Core i5-10400           CPU Core #5 Thread #1         Load 10              9       3      16
Intel Core i5-10400           CPU Core #5 Thread #2         Load 11              4       0      16
Intel Core i5-10400           CPU Core #6 Thread #1         Load 12              6       4      27
Intel Core i5-10400           CPU Core #6 Thread #2         Load 13              4       0      15
Intel Core i5-10400           CPU Core #1 Thread #1         Load 2               9       7      95
Intel Core i5-10400           CPU Core #1 Thread #2         Load 3               3       0      15
Intel Core i5-10400           CPU Core #2 Thread #1         Load 4              10       9      21
Intel Core i5-10400           CPU Core #2 Thread #2         Load 5               9       0      15
Intel Core i5-10400           CPU Core #3 Thread #1         Load 6              17       3      30
Intel Core i5-10400           CPU Core #3 Thread #2         Load 7               5       1     100
Intel Core i5-10400           CPU Core #4 Thread #1         Load 8               6       3      18
Intel Core i5-10400           CPU Core #4 Thread #2         Load 9               8       2      36
Intel Core i5-10400           CPU Package                   Power 0             17      13      25
Intel Core i5-10400           CPU Cores                     Power 1             10       7      20
Intel Core i5-10400           CPU Memory                    Power 3              1       1       2
Intel Core i5-10400           CPU Core #1                   Temperature 0       32      29      39
Intel Core i5-10400           CPU Core #2                   Temperature 1       32      30      42
Intel Core i5-10400           CPU Core #4 Distance to TjMax Temperature 10      72      64      72
Intel Core i5-10400           CPU Core #5 Distance to TjMax Temperature 11      70      61      71
Intel Core i5-10400           CPU Core #6 Distance to TjMax Temperature 12      70      60      72
Intel Core i5-10400           Core Max                      Temperature 13      32      30      45
Intel Core i5-10400           Core Average                  Temperature 14      30      29      36
Intel Core i5-10400           CPU Core #3                   Temperature 2       30      29      45
Intel Core i5-10400           CPU Core #4                   Temperature 3       28      28      36
Intel Core i5-10400           CPU Core #5                   Temperature 4       30      29      39
Intel Core i5-10400           CPU Core #6                   Temperature 5       30      28      40
Intel Core i5-10400           CPU Package                   Temperature 6       34      31      45
Intel Core i5-10400           CPU Core #1 Distance to TjMax Temperature 7       68      61      71
Intel Core i5-10400           CPU Core #2 Distance to TjMax Temperature 8       68      58      70
Intel Core i5-10400           CPU Core #3 Distance to TjMax Temperature 9       70      55      71
Intel Core i5-10400           CPU Core                      Voltage 0            1       1       1
Intel Core i5-10400           CPU Core #1                   Voltage 1            1       1       1
Intel Core i5-10400           CPU Core #2                   Voltage 2            1       1       1
Intel Core i5-10400           CPU Core #3                   Voltage 3            1       1       1
Intel Core i5-10400           CPU Core #4                   Voltage 4            1       1       1
Intel Core i5-10400           CPU Core #5                   Voltage 5            1       1       1
Intel Core i5-10400           CPU Core #6                   Voltage 6            1       1       1
MSI M390 250GB                Data Read                     Data 4            6124       0    6124
MSI M390 250GB                Data Written                  Data 5           34086       0   34086
MSI M390 250GB                Available Spare               Level 1            100       0     100
MSI M390 250GB                Available Spare Threshold     Level 2              5       0       5
MSI M390 250GB                Percentage Used               Level 3             36       0      36
MSI M390 250GB                Used Space                    Load 0              34      34      34
MSI M390 250GB                Read Activity                 Load 31              0       0       1
MSI M390 250GB                Write Activity                Load 32              0       0      10
MSI M390 250GB                Total Activity                Load 33              0       0     100
MSI M390 250GB                Temperature                   Temperature 0       40       0      40
MSI M390 250GB                Read Rate                     Throughput 34        0       0  572761
MSI M390 250GB                Write Rate                    Throughput 35     8095       0  705178
Nuvoton NCT6687D              CPU Fan                       Control 0           13      13      13
Nuvoton NCT6687D              Pump Fan                      Control 1          100     100     100
Nuvoton NCT6687D              System Fan #1                 Control 2           60      60      60
Nuvoton NCT6687D              System Fan #2                 Control 3           60      60      60
Nuvoton NCT6687D              System Fan #3                 Control 4           60      60      60
Nuvoton NCT6687D              System Fan #4                 Control 5           60      60      60
Nuvoton NCT6687D              System Fan #5                 Control 6           60      60      60
Nuvoton NCT6687D              System Fan #6                 Control 7           60      60      60
Nuvoton NCT6687D              CPU Fan                       Fan 0             1015    1012    1056
Nuvoton NCT6687D              Pump Fan                      Fan 1                0       0       0
Nuvoton NCT6687D              System Fan #1                 Fan 2                0       0       0
Nuvoton NCT6687D              System Fan #2                 Fan 3                0       0       0
Nuvoton NCT6687D              System Fan #3                 Fan 4                0       0       0
Nuvoton NCT6687D              System Fan #4                 Fan 5                0       0       0
Nuvoton NCT6687D              System Fan #5                 Fan 6                0       0       0
Nuvoton NCT6687D              System Fan #6                 Fan 7              797     784     800
Nuvoton NCT6687D              CPU                           Temperature 0       34      32      37
Nuvoton NCT6687D              System                        Temperature 1       36      35      36
Nuvoton NCT6687D              VRM MOS                       Temperature 2       40      40      40
Nuvoton NCT6687D              PCH                           Temperature 3       42      40      43
Nuvoton NCT6687D              CPU Socket                    Temperature 4       34      34      34
Nuvoton NCT6687D              PCIe x1                       Temperature 5       29      29      29
Nuvoton NCT6687D              M2_1                          Temperature 6       23      23      23
Nuvoton NCT6687D              +12V                          Voltage 0           12      12      12
Nuvoton NCT6687D              +5V                           Voltage 1            5       5       5
Nuvoton NCT6687D              VRef                          Voltage 10           2       2       2
Nuvoton NCT6687D              VSB                           Voltage 11           3       3       3
Nuvoton NCT6687D              AVSB                          Voltage 12           3       3       3
Nuvoton NCT6687D              VBat                          Voltage 13           3       3       3
Nuvoton NCT6687D              Vcore                         Voltage 2            1       1       1
Nuvoton NCT6687D              Voltage #1                    Voltage 3            1       1       1
Nuvoton NCT6687D              DIMM                          Voltage 4            1       1       1
Nuvoton NCT6687D              CPU I/O                       Voltage 5            1       1       1
Nuvoton NCT6687D              CPU SA                        Voltage 6            1       1       1
Nuvoton NCT6687D              Voltage #2                    Voltage 7            2       2       2
Nuvoton NCT6687D              AVCC3                         Voltage 8            3       3       3
Nuvoton NCT6687D              VTT                           Voltage 9            1       1       1
OpenVPN Wintun                Data Uploaded                 Data 2               0       0       0
OpenVPN Wintun                Data Downloaded               Data 3               0       0       0
OpenVPN Wintun                Network Utilization           Load 1               0       0       0
OpenVPN Wintun                Upload Speed                  Throughput 7         0       0       0
OpenVPN Wintun                Download Speed                Throughput 8         0       0       0
ProtonVPN TUN                 Data Uploaded                 Data 2               0       0       0
ProtonVPN TUN                 Data Downloaded               Data 3               0       0       0
ProtonVPN TUN                 Network Utilization           Load 1               0       0       0
ProtonVPN TUN                 Upload Speed                  Throughput 7         0       0       0
ProtonVPN TUN                 Download Speed                Throughput 8         0       0       0
Radeon RX 570 Series          GPU Core                      Clock 0            300     300     322
Radeon RX 570 Series          GPU Memory                    Clock 2            300     300     300
Radeon RX 570 Series          GPU Fan                       Control 0            0       0       0
Radeon RX 570 Series          Fullscreen FPS                Factor 0            -1      -1      -1
Radeon RX 570 Series          GPU Fan                       Fan 0                0       0       0
Radeon RX 570 Series          GPU Core                      Load 0               0       0       1
Radeon RX 570 Series          D3D Security 0                Load 10              0       0       0
Radeon RX 570 Series          D3D Timer 0                   Load 11              0       0       0
Radeon RX 570 Series          D3D True Audio 0              Load 12              0       0       0
Radeon RX 570 Series          D3D True Audio 1              Load 13              0       0       0
Radeon RX 570 Series          D3D Video Decode              Load 14              0       0       0
Radeon RX 570 Series          D3D Video Encode              Load 15              0       0       0
Radeon RX 570 Series          D3D Video Encode              Load 16              0       0       0
Radeon RX 570 Series          D3D Video Encode              Load 17              0       0       0
Radeon RX 570 Series          D3D Video Encode              Load 18              0       0       0
Radeon RX 570 Series          D3D Video Encode              Load 19              0       0       0
Radeon RX 570 Series          D3D 3D                        Load 2               1       0      20
Radeon RX 570 Series          D3D Compute 0                 Load 3               0       0       0
Radeon RX 570 Series          D3D Compute 1                 Load 4               0       0       0
Radeon RX 570 Series          D3D Compute 3                 Load 5               0       0       0
Radeon RX 570 Series          D3D Copy                      Load 6               0       0       0
Radeon RX 570 Series          D3D Copy                      Load 7               0       0       0
Radeon RX 570 Series          D3D High Priority 3D          Load 8               0       0       0
Radeon RX 570 Series          D3D High Priority Compute     Load 9               0       0       0
Radeon RX 570 Series          GPU Package                   Power 3              6       6       7
Radeon RX 570 Series          D3D Dedicated Memory Used     SmallData 0        610     610     610
Radeon RX 570 Series          D3D Shared Memory Used        SmallData 1         21      21      21
Radeon RX 570 Series          GPU Core                      Temperature 0       36      36      37
Radeon RX 570 Series          GPU Core                      Voltage 0            1       1       1
Radmin VPN                    Data Uploaded                 Data 2               0       0       0
Radmin VPN                    Data Downloaded               Data 3               0       0       0
Radmin VPN                    Network Utilization           Load 1               0       0       0
Radmin VPN                    Upload Speed                  Throughput 7         0       0    1593
Radmin VPN                    Download Speed                Throughput 8         0       0       0
ST1000DM003-1CH162            Used Space                    Load 0              44      44      44
ST1000DM003-1CH162            Read Activity                 Load 31              0       0       0
ST1000DM003-1CH162            Write Activity                Load 32              0       0      18
ST1000DM003-1CH162            Total Activity                Load 33              0       0     100
ST1000DM003-1CH162            Temperature                   Temperature 0       36      36      36
ST1000DM003-1CH162            Read Rate                     Throughput 34        0       0       0
ST1000DM003-1CH162            Write Rate                    Throughput 35   720422       0 1149511
vEthernet (Default Switch)    Data Uploaded                 Data 2               0       0       0
vEthernet (Default Switch)    Data Downloaded               Data 3               0       0       0
vEthernet (Default Switch)    Network Utilization           Load 1               0       0       0
vEthernet (Default Switch)    Upload Speed                  Throughput 7         0       0     218
vEthernet (Default Switch)    Download Speed                Throughput 8         0       0       0
vEthernet (NAT)               Data Uploaded                 Data 2             100     100     100
vEthernet (NAT)               Data Downloaded               Data 3            1064    1064    1064
vEthernet (NAT)               Network Utilization           Load 1               1       1       2
vEthernet (NAT)               Upload Speed                  Throughput 7     44227   42254  276867
vEthernet (NAT)               Download Speed                Throughput 8   1825610 1325738 2389344
VMware Network Adapter VMnet1 Data Uploaded                 Data 2               0       0       0
VMware Network Adapter VMnet1 Data Downloaded               Data 3               0       0       0
VMware Network Adapter VMnet1 Network Utilization           Load 1               0       0       0
VMware Network Adapter VMnet1 Upload Speed                  Throughput 7         0       0       1
VMware Network Adapter VMnet1 Download Speed                Throughput 8         0       0       0
VMware Network Adapter VMnet8 Data Uploaded                 Data 2               0       0       0
VMware Network Adapter VMnet8 Data Downloaded               Data 3               0       0       0
VMware Network Adapter VMnet8 Network Utilization           Load 1               0       0       0
VMware Network Adapter VMnet8 Upload Speed                  Throughput 7         0       0       1
VMware Network Adapter VMnet8 Download Speed                Throughput 8         0       0       0
WDC WD2005FBYZ-01YCBB2        Used Space                    Load 0              70      70      70
WDC WD2005FBYZ-01YCBB2        Read Activity                 Load 31              0       0      22
WDC WD2005FBYZ-01YCBB2        Write Activity                Load 32              0       0     100
WDC WD2005FBYZ-01YCBB2        Total Activity                Load 33              0       0     100
WDC WD2005FBYZ-01YCBB2        Temperature                   Temperature 0       37      37      37
WDC WD2005FBYZ-01YCBB2        Read Rate                     Throughput 34        0       0   37001
WDC WD2005FBYZ-01YCBB2        Write Rate                    Throughput 35        0       0 4379267
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

First, filter the data by HardwareName and SensorType tags and set each request to a different name using GUI:

![Image alt](https://github.com/Lifailon/PowerShellHardwareMonitor/blob/rsa/Screen/InfluxDB-Query.jpg)

For clarity and convenience, customize the celsius and legends data type (displaying minimum, maximum, and average readings for the specified time period).

![Image alt](https://github.com/Lifailon/PowerShellHardwareMonitor/blob/rsa/Screen/Grafana-Legend-Unit.jpg)
