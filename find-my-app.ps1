# Script to find your deployed Azure app

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Finding Your Azure App" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if logged in
Write-Host "Checking Azure login..." -ForegroundColor Yellow
$account = az account show 2>$null
if (-not $account) {
    Write-Host "Not logged in. Logging in..." -ForegroundColor Yellow
    az login
}

Write-Host "? Logged in to Azure" -ForegroundColor Green
Write-Host ""

# List all resource groups
Write-Host "Your Resource Groups:" -ForegroundColor Yellow
az group list --query "[].{Name:name, Location:location}" -o table
Write-Host ""

# Check for LibraryManagement-Free resource group
Write-Host "Checking LibraryManagement-Free resource group..." -ForegroundColor Yellow
$rgExists = az group exists --name LibraryManagement-Free
if ($rgExists -eq "true") {
    Write-Host "? Resource Group found" -ForegroundColor Green
    Write-Host ""
    
    Write-Host "Apps in LibraryManagement-Free:" -ForegroundColor Yellow
    Write-Host "--------------------------------" -ForegroundColor Yellow
    $apps = az webapp list --resource-group LibraryManagement-Free --query "[].{Name:name, URL:defaultHostName, State:state}" -o json | ConvertFrom-Json
    
    if ($apps.Count -eq 0) {
        Write-Host "No apps found in this resource group." -ForegroundColor Red
        Write-Host ""
        Write-Host "This might mean:" -ForegroundColor Yellow
        Write-Host "  1. Deployment didn't complete successfully" -ForegroundColor White
        Write-Host "  2. App was deployed to a different resource group" -ForegroundColor White
        Write-Host "  3. App was deployed with a different name" -ForegroundColor White
        Write-Host ""
        Write-Host "Let's check all your apps across all resource groups..." -ForegroundColor Yellow
        Write-Host ""
        az webapp list --query "[].{Name:name, URL:defaultHostName, ResourceGroup:resourceGroup, State:state}" -o table
    } else {
        foreach ($app in $apps) {
            Write-Host "App Name: $($app.Name)" -ForegroundColor Green
            Write-Host "URL: https://$($app.URL)" -ForegroundColor Cyan -BackgroundColor Black
            Write-Host "State: $($app.State)" -ForegroundColor White
            Write-Host ""
        }
        
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host "? Found your app(s)!" -ForegroundColor Green
        Write-Host "========================================" -ForegroundColor Cyan
    }
} else {
    Write-Host "? LibraryManagement-Free resource group not found" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Let's check all your apps:" -ForegroundColor Yellow
    az webapp list --query "[].{Name:name, URL:defaultHostName, ResourceGroup:resourceGroup, State:state}" -o table
}

Write-Host ""
Write-Host "Done!" -ForegroundColor Green
