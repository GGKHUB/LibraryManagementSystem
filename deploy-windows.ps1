# PowerShell Deployment Script for Library Management System
# Run this script on Windows to deploy to IIS

param(
    [string]$Environment = "Production",
    [string]$PublishPath = "C:\inetpub\LibraryManagement",
    [string]$SiteName = "LibraryManagement",
    [string]$AppPoolName = "LibraryManagementPool",
    [int]$Port = 80,
    [string]$HostName = "localhost"
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Library Management System Deployment" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "ERROR: This script must be run as Administrator!" -ForegroundColor Red
    exit 1
}

# Step 1: Build and Publish
Write-Host "Step 1: Building and publishing application..." -ForegroundColor Yellow
dotnet publish .\LibraryManagementSystem\LibraryManagementSystem.csproj -c Release -o $PublishPath --no-self-contained

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Build failed!" -ForegroundColor Red
    exit 1
}
Write-Host "? Application published to $PublishPath" -ForegroundColor Green
Write-Host ""

# Step 2: Import IIS Module
Write-Host "Step 2: Configuring IIS..." -ForegroundColor Yellow
Import-Module WebAdministration -ErrorAction SilentlyContinue
if (-not (Get-Module WebAdministration)) {
    Write-Host "ERROR: IIS is not installed or WebAdministration module is not available!" -ForegroundColor Red
    exit 1
}

# Step 3: Create Application Pool
Write-Host "Creating Application Pool: $AppPoolName" -ForegroundColor Yellow
if (Test-Path "IIS:\AppPools\$AppPoolName") {
    Write-Host "Application Pool already exists. Stopping..." -ForegroundColor Yellow
    Stop-WebAppPool -Name $AppPoolName
    Start-Sleep -Seconds 2
} else {
    New-WebAppPool -Name $AppPoolName
}

Set-ItemProperty "IIS:\AppPools\$AppPoolName" -Name managedRuntimeVersion -Value ""
Set-ItemProperty "IIS:\AppPools\$AppPoolName" -Name processModel.identityType -Value "ApplicationPoolIdentity"
Write-Host "? Application Pool configured" -ForegroundColor Green
Write-Host ""

# Step 4: Create Website
Write-Host "Creating Website: $SiteName" -ForegroundColor Yellow
if (Test-Path "IIS:\Sites\$SiteName") {
    Write-Host "Website already exists. Removing..." -ForegroundColor Yellow
    Remove-Website -Name $SiteName
    Start-Sleep -Seconds 2
}

New-Website -Name $SiteName `
    -PhysicalPath $PublishPath `
    -ApplicationPool $AppPoolName `
    -Port $Port `
    -HostHeader $HostName

Write-Host "? Website created" -ForegroundColor Green
Write-Host ""

# Step 5: Set Permissions
Write-Host "Step 3: Setting file permissions..." -ForegroundColor Yellow
$acl = Get-Acl $PublishPath
$permission = "IIS AppPool\$AppPoolName", "ReadAndExecute", "ContainerInherit,ObjectInherit", "None", "Allow"
$accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule $permission
$acl.SetAccessRule($accessRule)
Set-Acl $PublishPath $acl
Write-Host "? Permissions set" -ForegroundColor Green
Write-Host ""

# Step 6: Start Application Pool and Website
Write-Host "Step 4: Starting application..." -ForegroundColor Yellow
Start-WebAppPool -Name $AppPoolName
Start-Website -Name $SiteName
Write-Host "? Application started" -ForegroundColor Green
Write-Host ""

# Step 7: Test the deployment
Write-Host "Step 5: Testing deployment..." -ForegroundColor Yellow
Start-Sleep -Seconds 5
try {
    $response = Invoke-WebRequest -Uri "http://$HostName`:$Port" -UseBasicParsing -TimeoutSec 10
    if ($response.StatusCode -eq 200) {
        Write-Host "? Application is responding successfully!" -ForegroundColor Green
    } else {
        Write-Host "? Application responded with status code: $($response.StatusCode)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "? Could not verify application is running: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Host "   Please check the logs and IIS configuration." -ForegroundColor Yellow
}
Write-Host ""

# Summary
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Deployment Complete!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Website: http://$HostName`:$Port" -ForegroundColor White
Write-Host "Physical Path: $PublishPath" -ForegroundColor White
Write-Host "Application Pool: $AppPoolName" -ForegroundColor White
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "1. Update connection string in $PublishPath\appsettings.Production.json" -ForegroundColor White
Write-Host "2. Verify database migrations have been applied" -ForegroundColor White
Write-Host "3. Test the application by browsing to http://$HostName`:$Port" -ForegroundColor White
Write-Host "4. Configure SSL certificate for HTTPS" -ForegroundColor White
Write-Host ""
