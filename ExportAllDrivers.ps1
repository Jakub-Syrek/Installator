If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{   
$arguments = "& '" + $myinvocation.mycommand.definition + "'"
Start-Process powershell -Verb runAs -ArgumentList $arguments
Break
}
$invocation = (Get-Variable MyInvocation).Value
$directorypath = Split-Path $invocation.MyCommand.Path
$directorypathScript = $directorypath + "\ExportAllDrivers.ps1"
Unblock-File -Path $directorypathScript

$Model = (Get-WmiObject -Class win32_computersystem).Model
#Remove white characters from Model
$Model = $Model | Where { $_ -ne "" } | ForEach { $_.Replace(" ","") }
$Model
pause
#$Destinat = "E:Drivers\$($Model)"
#$pathServer = "\\10.120.7.29\Group_Data\Infra\DB\LS\_DB_Standard_Laptop_Model_Autoinstall\"
$pathServer = "\\10.120.7.175\e$\Drivers\"
$Destinat = $pathServer + $Model 
$Destinat
pause
Export-WindowsDriver -Destination $Destinat  -Online
pause