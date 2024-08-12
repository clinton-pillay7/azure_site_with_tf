<#
.SYNOPSIS
Batch script to initialise a Azure Vm, by setting up necessary software - unattended using Powershell.


.DESCRIPTION
Installs\ Configures the following: 
1. Installs SQL Server
2. Initialises the database, by creating a database, table, and inserting sample data. 
3. Installs Python
4. Setups up a Scheduled task to start up a flask app. 


.NOTES
- Logging is setup, config logs for this script can be found on the target VM, at C:\sqllog.log
#>


# Create the file with the current date as the name
New-Item -Path "C:\" -Name "sqllog.log" -ItemType File

try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    New-Item -name setupdata -ItemType Directory -Path "C:\users\Public"
    $sqlurl =  "https://mypsscripts.blob.core.windows.net/scripts/SQLEXPRADV_x64_ENU.zip" 
    $configfileurl = "https://mypsscripts.blob.core.windows.net/scripts/configurationfile.ini"
    $sqlziplocation = "C:\users\Public\setupdata\SQLEXPRADV_x64_ENU.zip"
    $sqlsourcefolder = "C:\users\Public\setupdata"
    $sqlconfigfile = "C:\users\Public\setupdata\configurationfile.ini"
    $flaskappurl = "https://github.com/SashiDuratech/flaskhelloworld/raw/master/app.py"
    $taskscripturl = "https://mypsscripts.blob.core.windows.net/scripts/appscript.ps1"
    $taskscript = "C:\users\Public\setupdata\appscript.ps1"
    $flaskfile = "C:\users\Public\setupdata\app.py"
    $datevar = Get-Date
    Add-Content -Path "C:\sqllog.log" -Value "$datevar Successfully assigned variables"
    }
catch {
    $datevar = Get-Date
    Add-Content -Path "C:\sqllog.log" -Value "$datevar Couldnt assign variables"
}



try {
    Invoke-WebRequest $flaskappurl -OutFile $flaskfile
    Invoke-WebRequest $taskscripturl -OutFile $taskscript 
    Invoke-Webrequest $sqlurl -OutFile $sqlziplocation
    Expand-Archive -Path $sqlziplocation -DestinationPath $sqlsourcefolder 
    Invoke-Webrequest $configfileurl -OutFile $sqlconfigfile
    $datevar = Get-Date
    Add-Content -Path "C:\sqllog.log" -Value "$datevar Successfully downloaded and unzipped"
}
catch {
    $datevar = Get-Date
    Add-Content -Path "C:\sqllog.log" -Value "$datevar couldnt download and unzip"
}



try {
    Start-Service -Name 'MSSQL$SQLEXPRESS'
    Start-Service -Name 'SQLBrowser'
    #SQL Install
    $sqlcommand = "C:\users\Public\setupdata\SQLEXPRADV_x64_ENU\setup.exe /configurationFile=$($sqlconfigfile) /INDICATEPROGRESS /UpdateEnabled=False"
    Invoke-Expression -command $sqlcommand
    $datevar = Get-Date
    Add-Content -Path "C:\sqllog.log" -Value "$datevar Successfully installed SqlServer"
}
catch {
    $datevar = Get-Date
    Add-Content -Path "C:\sqllog.log" -Value "$datevar SqlServer Install failed"
}

try {
    Install-packageprovider -name nuget -minimumversion 2.8.5.201 -force 
    Install-Module -Name PowerShellGet -Force -AllowClobber
    Install-Module -Name PackageManagement -Force -AllowClobber
    Install-Module -Name SqlServer -Force -AllowClobber
    $datevar = Get-Date
    Add-Content -Path "C:\sqllog.log" -Value "$datevar Successfully installed modules"
}
catch {
    $datevar = Get-Date
    Add-Content -Path "C:\sqllog.log" -Value "$datevar Failed to Install modules"
}

try {
    Start-Service -Name 'MSSQL$SQLEXPRESS'
    Start-Service -Name 'SQLBrowser'
    # Define the SQL Server connection details




    # Step 1: Create Database
    $sqlCreateDatabase = @"
    CREATE DATABASE mydb
"@
    $constringdbnew = "Server=localhost\SQLEXPRESS;User ID=sa;Password=YourStrong!Passw0rd;TrustServerCertificate=True;"
    Invoke-Sqlcmd -ConnectionString $constringdbnew -Query $sqlCreateDatabase  -DisableVariables


    # Step 2: Create Table
    $sqlCreateTable = @"
    CREATE TABLE mytable (
    id INT PRIMARY KEY IDENTITY(1,1),
    name NVARCHAR(50),
    surname NVARCHAR(50)
)
"@
    $constringdb = "Server=localhost\SQLEXPRESS;User ID=sa;Password=YourStrong!Passw0rd;Database=mydb;TrustServerCertificate=True;"
    Invoke-Sqlcmd  -ConnectionString $constringdb -Query $sqlCreateTable -DisableVariables


    # Step 3: Insert Data

    $sqlInsertCommand = @"
    INSERT INTO mytable (name, surname)
    VALUES ('clinton', 'pillay')
"@
    $constringdb = "Server=localhost\SQLEXPRESS;User ID=sa;Password=YourStrong!Passw0rd;Database=mydb;TrustServerCertificate=True;"
    Invoke-Sqlcmd -ConnectionString $constringdb -Query $sqlInsertCommand -DisableVariables
    $datevar = Get-Date
    Add-Content -Path "C:\sqllog.log" -Value "$datevar SQL Commands run successfully"
}
catch {
    
    $datevar = Get-Date
    Add-Content -Path "C:\sqllog.log" -Value "$datevar Failed to run SQL Commands with error: $($_.Exception.GetType().FullName, $_.Exception.Message)"

}


try {
    #Python install
    $pythonInstallerUrl = "https://www.python.org/ftp/python/3.9.9/python-3.9.9-amd64.exe"
    $installerPath = "$env:TEMP\python-installer.exe"
    Invoke-WebRequest -Uri $pythonInstallerUrl -OutFile $installerPath
    Start-Process -FilePath $installerPath -ArgumentList '/quiet InstallAllUsers=1 PrependPath=1' -Wait
    $datevar = Get-Date
    Add-Content -Path "C:\sqllog.log" -Value "$datevar Successfully installed python"
}
catch {
    $datevar = Get-Date
    Add-Content -Path "C:\sqllog.log" -Value "$datevar Python installed failed"
}


try {
    New-NetFirewallRule -DisplayName "Allow SQL" -Direction Inbound -Protocol TCP -LocalPort 1433 -Action Allow
    $datevar = Get-Date
    Add-Content -Path "C:\sqllog.log" -Value "$datevar Successfully created SQL firewall rule"
}
catch {
    $datevar = Get-Date
    Add-Content -Path "C:\sqllog.log" -Value "$datevar Couldnt create SQL firewall rule"
}

try {
    New-NetFirewallRule -DisplayName "Allow HTTPFlask" -Direction Inbound -Protocol TCP -LocalPort 8080 -Action Allow
    $datevar = Get-Date
    Add-Content -Path "C:\sqllog.log" -Value "$datevar Successfully created HTTPFlask firewall rule"
    
}
catch {
    $datevar = Get-Date
    Add-Content -Path "C:\sqllog.log" -Value "$datevar Couldnt create HTTPFlask firewall rule"
}


try {
    $action = New-ScheduledTaskAction -Execute 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -Argument "-ExecutionPolicy Bypass .\appscript.ps1" -WorkingDirectory "C:\Users\Public\setupdata\"
    $trigger = New-ScheduledTaskTrigger -AtStartup
    $principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
    Register-ScheduledTask -Action $action -Trigger $trigger -Principal $principal -TaskName "flaskapp" -Description "Start my flask app"
    $datevar = Get-Date
    Add-Content -Path "C:\sqllog.log" -Value "$datevar successfully created scheduled task"
}
catch {
    $datevar = Get-Date
    Add-Content -Path "C:\sqllog.log" -Value "$datevar Couldnt create scheduled task"
}

Restart-Computer -Force


