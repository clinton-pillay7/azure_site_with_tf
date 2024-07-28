$configfile = "C:\users\clintonpillay\Downloads\ConfigurationFile.ini.txt"
$command = "C:\Users\clintonpillay\Downloads\SQLEXPRADV_x64_ENU\SETUP.EXE /configurationFile=$($configfile) /INDICATEPROGRESS"
Invoke-Expression -command $command