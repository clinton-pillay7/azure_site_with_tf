
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12


$path = "C:\wwwroot"
# Check if the folder exists
if (-Not (Test-Path -Path $Path)) {
    # Create the folder if it doesn't exist
    New-Item -Path $Path -ItemType Directory
    Write-Output "Folder created at $Path"
} else {
    Write-Output "Folder already exists at $Path"
}

$url = "https://github.com/clinton-pillay7/htmlsamplesite/raw/master/index.html"
Invoke-WebRequest -Uri $url -OutFile C:\wwwroot\index.html

$websiteName = "MyNewWebsite"


Install-WindowsFeature -name Web-Server -IncludeManagementTools


$iisstatus = Get-Service -Name W3SVC
if ($iisstatus.Status -eq 'Stopped'){
    Start-Service W3SVC
    Write-Host "Service started"
}
else {
    Write-Host "Service already running"
}

########################

# Define the name of the website to delete
$websiteName = "Default Web Site"

# Check if the website exists
if (Get-Website -Name $websiteName) {
    # Remove the website
    Remove-Website -Name $websiteName
    Write-Output "Website '$websiteName' has been deleted."
} else {
    Write-Output "Website '$websiteName' does not exist."
}

########################

# Create the new website with IIS
New-WebSite -Name $websiteName -PhysicalPath $path -Port 80 -Force

# Start the new website
Start-WebSite -Name $websiteName
