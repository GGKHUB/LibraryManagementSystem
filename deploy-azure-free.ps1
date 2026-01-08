# Deploy to Azure Free Tier - Library Management System
# This script deploys your app to Azure using the FREE tier

param(
    [Parameter(Mandatory=$true)]
    [string]$AppName,
    
    [string]$ResourceGroup = "LibraryManagement-Free",
    [string]$Location = "eastus"
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Azure FREE Tier Deployment" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check Azure CLI
if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: Azure CLI not installed!" -ForegroundColor Red
    Write-Host "Download from: https://aka.ms/installazurecliwindows" -ForegroundColor Yellow
    exit 1
}

# Login check
Write-Host "Checking Azure login..." -ForegroundColor Yellow
$account = az account show 2>$null
if (-not $account) {
    Write-Host "Logging in to Azure..." -ForegroundColor Yellow
    az login
}

Write-Host "? Logged in to Azure" -ForegroundColor Green
Write-Host ""

# Create Resource Group
Write-Host "Creating Resource Group..." -ForegroundColor Yellow
az group create --name $ResourceGroup --location $Location --output none
Write-Host "? Resource Group: $ResourceGroup" -ForegroundColor Green
Write-Host ""

# Create FREE App Service Plan
Write-Host "Creating FREE App Service Plan..." -ForegroundColor Yellow
$planName = "$AppName-free-plan"
az appservice plan create `
    --name $planName `
    --resource-group $ResourceGroup `
    --sku FREE `
    --output none

Write-Host "? App Service Plan created (FREE tier)" -ForegroundColor Green
Write-Host ""

# Create Web App
Write-Host "Creating Web App..." -ForegroundColor Yellow
az webapp create `
    --name $AppName `
    --resource-group $ResourceGroup `
    --plan $planName `
    --runtime "DOTNET|8.0" `
    --output none

Write-Host "? Web App created" -ForegroundColor Green
Write-Host ""

# Configure App Settings
Write-Host "Configuring App Settings..." -ForegroundColor Yellow
az webapp config appsettings set `
    --name $AppName `
    --resource-group $ResourceGroup `
    --settings ASPNETCORE_ENVIRONMENT=Production `
    --output none

Write-Host "? App Settings configured" -ForegroundColor Green
Write-Host ""

# Build and Publish
Write-Host "Building application..." -ForegroundColor Yellow
dotnet publish .\LibraryManagementSystem\LibraryManagementSystem.csproj -c Release -o .\publish

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Build failed!" -ForegroundColor Red
    exit 1
}
Write-Host "? Application built" -ForegroundColor Green
Write-Host ""

# Create deployment package
Write-Host "Creating deployment package..." -ForegroundColor Yellow
if (Test-Path .\deploy.zip) { Remove-Item .\deploy.zip }
Compress-Archive -Path .\publish\* -DestinationPath .\deploy.zip -Force
Write-Host "? Package created" -ForegroundColor Green
Write-Host ""

# Deploy to Azure
Write-Host "Deploying to Azure (this may take a few minutes)..." -ForegroundColor Yellow
az webapp deployment source config-zip `
    --name $AppName `
    --resource-group $ResourceGroup `
    --src .\deploy.zip `
    --output none

Write-Host "? Deployment complete" -ForegroundColor Green
Write-Host ""

# Get URL
$webAppUrl = az webapp show --name $AppName --resource-group $ResourceGroup --query "defaultHostName" -o tsv

# Summary
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Deployment Complete! (FREE TIER)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Your app URL: https://$webAppUrl" -ForegroundColor Green -BackgroundColor Black
Write-Host ""
Write-Host "FREE Tier Limitations:" -ForegroundColor Yellow
Write-Host "  • 60 CPU minutes per day" -ForegroundColor White
Write-Host "  • App sleeps after 20 min inactivity" -ForegroundColor White
Write-Host "  • 1 GB disk space" -ForegroundColor White
Write-Host "  • Shared infrastructure" -ForegroundColor White
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "1. Get a FREE SQL Server database from:" -ForegroundColor White
Write-Host "   - https://somee.com (FREE SQL Server)" -ForegroundColor Cyan
Write-Host "   - https://www.freesqldatabase.com" -ForegroundColor Cyan
Write-Host ""
Write-Host "2. Update connection string in Azure Portal:" -ForegroundColor White
Write-Host "   https://portal.azure.com" -ForegroundColor Cyan
Write-Host "   ? App Services ? $AppName ? Configuration" -ForegroundColor White
Write-Host "   ? Connection strings ? Add new" -ForegroundColor White
Write-Host ""
Write-Host "3. Restart your app after adding connection string" -ForegroundColor White
Write-Host ""
Write-Host "Useful Commands:" -ForegroundColor Yellow
Write-Host "View logs: az webapp log tail --name $AppName --resource-group $ResourceGroup" -ForegroundColor White
Write-Host "Restart: az webapp restart --name $AppName --resource-group $ResourceGroup" -ForegroundColor White
Write-Host ""

# Clean up
Remove-Item .\deploy.zip -Force
Remove-Item .\publish -Recurse -Force

Write-Host "?? Your app is live at: https://$webAppUrl" -ForegroundColor Green
Write-Host ""
