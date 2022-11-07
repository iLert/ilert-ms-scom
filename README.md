# iLert-MS-SCOM
iLert Integration Script for Microsoft SCOM

For setup instructions, refer to our integration guide below.
## Integration Guide
[iLert Microsoft SCOM Integration](https://docs.ilert.com/integrations/ms-scom)

Command line parameters:
```
-F "C:\scripts\ilert\ilert.ps1" -AlertID "$Data[Default='NotPresent']/Context/DataItem/AlertId$" -AlertSourceKey "Enter API Key"
```
Startup folder for the command line:
```
C:\windows\system32\windowspowershell\v1.0\
```
Full path of the command file:
```
C:\windows\system32\windowspowershell\v1.0\powershell.exe
```
