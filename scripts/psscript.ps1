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
