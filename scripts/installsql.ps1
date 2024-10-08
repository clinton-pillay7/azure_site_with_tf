[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$sqlurl =  "https://mypsscripts.blob.core.windows.net/scripts/SQLEXPRADV_x64_ENU.zip" 
$configfileurl = "https://mypsscripts.blob.core.windows.net/scripts/configurationfile.ini"
$sqlziplocation = "C:\users\clintonpillay\downloads\SQLEXPRADV_x64_ENU.zip"
$sqlsourcefolder = "C:\users\clintonpillay\downloads\"
$sqlconfigfile = "C:\users\clintonpillay\Downloads\configurationfile.ini"


Invoke-Webrequest $sqlurl -OutFile $sqlziplocation
Expand-Archive -Path $sqlziplocation -DestinationPath $sqlsourcefolder 
Invoke-Webrequest $configfileurl -OutFile $sqlconfigfile



$sqlcommand = "C:\Users\clintonpillay\Downloads\SQLEXPRADV_x64_ENU\setup.exe /configurationFile=$($sqlconfigfile) /INDICATEPROGRESS"
Invoke-Expression -command $sqlcommand


install-packageprovider -name nuget -minimumversion 2.8.5.201 -force 
#Register-PSRepository -Default

# Update PowerShellGet and PackageManagement modules
Install-Module -Name PowerShellGet -Force -Scope CurrentUser -AllowClobber
Install-Module -Name PackageManagement -Force -Scope CurrentUser -AllowClobber
Install-Module -Name SqlServer -Force -Scope CurrentUser -AllowClobber



# Define the SQL Server connection details
$serverName = "localhost\SQLEXPRESS"
$username = "sa"
$password = "YourStrong!Passw0rd"

# Step 1: Create Database
$sqlCreateDatabase = @"
CREATE DATABASE mydb
"@
Invoke-Sqlcmd -ServerInstance $serverName -Username $username -Password $password -Query $sqlCreateDatabase -TrustServerCertificate


# Step 2: Create Table
$databaseName = "mydb"
$sqlCreateTable = @"
CREATE TABLE mytable (
    id INT PRIMARY KEY IDENTITY(1,1),
    name NVARCHAR(50),
    surname NVARCHAR(50)
)
"@
Invoke-Sqlcmd -ServerInstance $serverName -Database $databaseName -Username $username -Password $password -Query $sqlCreateTable -TrustServerCertificate


# Step 3: Insert Data
$serverName = "localhost\SQLEXPRESS"
$username = "sa"
$password = "YourStrong!Passw0rd"
$databaseName = "mydb"
$sqlInsertCommand = @"
INSERT INTO mytable (name, surname)
VALUES ('clinton', 'pillay')
"@

Invoke-Sqlcmd -ServerInstance $serverName -Database $databaseName -Username $username -Password $password -Query $sqlInsertCommand -TrustServerCertificate


$pythonInstallerUrl = "https://www.python.org/ftp/python/3.9.9/python-3.9.9-amd64.exe"
$installerPath = "$env:TEMP\python-installer.exe"
Invoke-WebRequest -Uri $pythonInstallerUrl -OutFile $installerPath
Start-Process -FilePath $installerPath -ArgumentList '/quiet InstallAllUsers=1 PrependPath=1' -Wait

