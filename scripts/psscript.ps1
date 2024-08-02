#Ensures TLS1.2 Usage, this is needed for my VM to download the website from github further down.
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

#Creating the website root directory
$path = "C:\wwwroot"
# Check if the folder exists
if (-Not (Test-Path -Path $Path)) {
    # Create the folder if it doesn't exist
    New-Item -Path $Path -ItemType Directory
    Write-Output "Folder created at $Path"
} else {
    Write-Output "Folder already exists at $Path"
}

#Download the website to the website root directory
$url = "https://github.com/clinton-pillay7/htmlsamplesite/raw/master/index.html"
Invoke-WebRequest -Uri $url -OutFile C:\wwwroot\index.html

#Install and start IIS 
Install-WindowsFeature -name Web-Server -IncludeManagementTools
$iisstatus = Get-Service -Name W3SVC
if ($iisstatus.Status -eq 'Stopped'){
    Start-Service W3SVC
    Write-Host "Service started"
}
else {
    Write-Host "Service already running"
}

#Delete the standard Windows IIS sample loading page
$websiteName = "Default Web Site"
# Check if the website exists
if (Get-Website -Name $websiteName) {
    # Remove the website
    Remove-Website -Name $websiteName
    Write-Output "Website '$websiteName' has been deleted."
} else {
    Write-Output "Website '$websiteName' does not exist."
}

#Create a new site in IIS Manager
$mysite = "my_site"
New-WebSite -Name $mysite -PhysicalPath $path -Port 80 -Force

# Start the new website
Start-WebSite -Name $websiteName

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

#Python install
$pythonInstallerUrl = "https://www.python.org/ftp/python/3.9.9/python-3.9.9-amd64.exe"
$installerPath = "$env:TEMP\python-installer.exe"
Invoke-WebRequest -Uri $pythonInstallerUrl -OutFile $installerPath
Start-Process -FilePath $installerPath -ArgumentList '/quiet InstallAllUsers=1 PrependPath=1' -Wait

New-NetFirewallRule -DisplayName "Allow HTTP" -Direction Inbound -Protocol TCP -LocalPort 8080 -Action Allow


Invoke-WebRequest "https://mypsscripts.blob.core.windows.net/scripts/py-st-script.ps1" -OutFile "C:\users\Public\flaskapp\py-st-script.ps1" 
$action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument 'C:\users\Public\flaskapp\py-st-script.ps1'49
$trigger = New-ScheduledTaskTrigger -AtStartup
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
Register-ScheduledTask -Action $action -Trigger $trigger -Principal $principal -TaskName "flaskapp" -Description "Start my flask app"
