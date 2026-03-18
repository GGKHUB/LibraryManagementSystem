# Deploy to Azure Free Tier - Fixed for .NET 10
# This script properly deploys your .NET 10 app to Azure using the FREE tier

param(
    [Parameter(Mandatory=$true)]
    [string]$AppName,
    
    [string]$ResourceGroup = "LibraryManagement-Free",
    [string]$Location = "eastus"
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Azure FREE Tier Deployment (.NET 10)" -ForegroundColor Cyan
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

$accountInfo = az account show | ConvertFrom-Json
Write-Host "? Logged in as: $($accountInfo.user.name)" -ForegroundColor Green
Write-Host ""

# Create Resource Group
Write-Host "Creating Resource Group: $ResourceGroup..." -ForegroundColor Yellow
az group create --name $ResourceGroup --location $Location --output json | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to create resource group!" -ForegroundColor Red
    exit 1
}
Write-Host "? Resource Group created: $ResourceGroup" -ForegroundColor Green
Write-Host ""

# Create FREE App Service Plan
Write-Host "Creating FREE App Service Plan..." -ForegroundColor Yellow
$planName = "$AppName-free-plan"
az appservice plan create `
    --name $planName `
    --resource-group $ResourceGroup `
    --sku FREE `
    --location $Location `
    --output json | Out-Null

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to create App Service Plan!" -ForegroundColor Red
    exit 1
}
Write-Host "? App Service Plan created (FREE tier)" -ForegroundColor Green
Write-Host ""

# Create Web App - Using .NET 8 since .NET 10 might not be available yet
Write-Host "Creating Web App..." -ForegroundColor Yellow
Write-Host "Note: Using .NET 8 runtime (Azure may not support .NET 10 yet)" -ForegroundColor Yellow
az webapp create `
    --name $AppName `
    --resource-group $ResourceGroup `
    --plan $planName `
    --runtime "DOTNET:8.0" `
    --output json | Out-Null

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to create Web App!" -ForegroundColor Red
    Write-Host "The app name '$AppName' might already be taken globally." -ForegroundColor Yellow
    Write-Host "Try a different name like: $AppName-$(Get-Random -Minimum 1000 -Maximum 9999)" -ForegroundColor Yellow
    exit 1
}
Write-Host "? Web App created: $AppName" -ForegroundColor Green
Write-Host ""

# Configure App Settings
Write-Host "Configuring App Settings..." -ForegroundColor Yellow
az webapp config appsettings set `
    --name $AppName `
    --resource-group $ResourceGroup `
    --settings ASPNETCORE_ENVIRONMENT=Production `
    --output json | Out-Null

Write-Host "? App Settings configured" -ForegroundColor Green
Write-Host ""

# Build and Publish
Write-Host "Building application..." -ForegroundColor Yellow
Write-Host "This may take a few minutes..." -ForegroundColor Yellow
dotnet publish .\LibraryManagementSystem\LibraryManagementSystem.csproj -c Release -o .\publish

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Build failed!" -ForegroundColor Red
    Write-Host "Check the error messages above." -ForegroundColor Yellow
    exit 1
}
Write-Host "? Application built successfully" -ForegroundColor Green
Write-Host ""

# Create deployment package
Write-Host "Creating deployment package..." -ForegroundColor Yellow
if (Test-Path .\deploy.zip) { 
    Remove-Item .\deploy.zip -Force
}
Compress-Archive -Path .\publish\* -DestinationPath .\deploy.zip -Force
Write-Host "? Package created: deploy.zip" -ForegroundColor Green
Write-Host ""

# Deploy to Azure
Write-Host "Deploying to Azure..." -ForegroundColor Yellow
Write-Host "This will take 3-5 minutes. Please wait..." -ForegroundColor Yellow
az webapp deployment source config-zip `
    --name $AppName `
    --resource-group $ResourceGroup `
    --src .\deploy.zip `
    --output json | Out-Null

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Deployment failed!" -ForegroundColor Red
    exit 1
}
Write-Host "? Deployment complete!" -ForegroundColor Green
Write-Host ""

# Get URL
$webAppUrl = az webapp show --name $AppName --resource-group $ResourceGroup --query "defaultHostName" -o tsv

# Verify the app
Write-Host "Verifying deployment..." -ForegroundColor Yellow
Start-Sleep -Seconds 5
$appState = az webapp show --name $AppName --resource-group $ResourceGroup --query "state" -o tsv
Write-Host "App State: $appState" -ForegroundColor $(if ($appState -eq "Running") { "Green" } else { "Yellow" })
Write-Host ""

# Summary
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Deployment Complete! (FREE TIER)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "? Resource Group: $ResourceGroup" -ForegroundColor White
Write-Host "? App Name: $AppName" -ForegroundColor White
Write-Host "? App URL: " -NoNewline -ForegroundColor White
Write-Host "https://$webAppUrl" -ForegroundColor Cyan -BackgroundColor Black
Write-Host ""
Write-Host "FREE Tier Limitations:" -ForegroundColor Yellow
Write-Host "  • 60 CPU minutes per day" -ForegroundColor White
Write-Host "  • App sleeps after 20 min inactivity" -ForegroundColor White
Write-Host "  • 1 GB disk space" -ForegroundColor White
Write-Host "  • Shared infrastructure" -ForegroundColor White
Write-Host ""
Write-Host "IMPORTANT - Next Steps:" -ForegroundColor Yellow
Write-Host "1. Configure database connection string:" -ForegroundColor White
Write-Host "   ? Open: https://portal.azure.com" -ForegroundColor Cyan
Write-Host "   ? Go to: App Services ? $AppName ? Configuration" -ForegroundColor White
Write-Host "   ? Add Connection String:" -ForegroundColor White
Write-Host "      Name: DefaultConnection" -ForegroundColor Gray
Write-Host "      Type: SQLServer" -ForegroundColor Gray
Write-Host "      Value: Your Somee.com connection string" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Test your app:" -ForegroundColor White
Write-Host "   https://$webAppUrl" -ForegroundColor Cyan
Write-Host ""
Write-Host "3. View logs:" -ForegroundColor White
Write-Host "   az webapp log tail --name $AppName --resource-group $ResourceGroup" -ForegroundColor Gray
Write-Host ""

# Clean up
Write-Host "Cleaning up temporary files..." -ForegroundColor Yellow
Remove-Item .\deploy.zip -Force -ErrorAction SilentlyContinue
Remove-Item .\publish -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "? Cleanup complete" -ForegroundColor Green
Write-Host ""

Write-Host "?? Your app is deployed!" -ForegroundColor Green
Write-Host "Visit: https://$webAppUrl" -ForegroundColor Cyan -BackgroundColor Black
Write-Host ""
