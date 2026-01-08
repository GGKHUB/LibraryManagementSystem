# Azure Deployment Script for Library Management System
# Prerequisites: Azure CLI installed and logged in (az login)

param(
    [Parameter(Mandatory=$true)]
    [string]$ResourceGroup,
    
    [Parameter(Mandatory=$true)]
    [string]$AppServiceName,
    
    [Parameter(Mandatory=$true)]
    [string]$Location = "eastus",
    
    [Parameter(Mandatory=$false)]
    [string]$SqlServerName,
    
    [Parameter(Mandatory=$false)]
    [string]$SqlAdminUser = "sqladmin",
    
    [Parameter(Mandatory=$false)]
    [string]$SqlAdminPassword
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Azure Deployment - Library Management" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if Azure CLI is installed
if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: Azure CLI is not installed!" -ForegroundColor Red
    Write-Host "Please install from: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli" -ForegroundColor Yellow
    exit 1
}

# Check if logged in to Azure
$account = az account show 2>$null
if (-not $account) {
    Write-Host "ERROR: Not logged in to Azure!" -ForegroundColor Red
    Write-Host "Please run: az login" -ForegroundColor Yellow
    exit 1
}

Write-Host "Logged in to Azure as: $(az account show --query user.name -o tsv)" -ForegroundColor Green
Write-Host ""

# Step 1: Create Resource Group
Write-Host "Step 1: Creating Resource Group..." -ForegroundColor Yellow
az group create --name $ResourceGroup --location $Location
Write-Host "? Resource Group created" -ForegroundColor Green
Write-Host ""

# Step 2: Create App Service Plan
Write-Host "Step 2: Creating App Service Plan..." -ForegroundColor Yellow
$planName = "$AppServiceName-plan"
az appservice plan create `
    --name $planName `
    --resource-group $ResourceGroup `
    --sku B1 `
    --is-linux
Write-Host "? App Service Plan created" -ForegroundColor Green
Write-Host ""

# Step 3: Create Web App
Write-Host "Step 3: Creating Web App..." -ForegroundColor Yellow
az webapp create `
    --name $AppServiceName `
    --resource-group $ResourceGroup `
    --plan $planName `
    --runtime "DOTNET|10.0"

az webapp config set `
    --name $AppServiceName `
    --resource-group $ResourceGroup `
    --always-on true
Write-Host "? Web App created" -ForegroundColor Green
Write-Host ""

# Step 4: Create SQL Server and Database (optional)
if ($SqlServerName) {
    Write-Host "Step 4: Creating SQL Server and Database..." -ForegroundColor Yellow
    
    if (-not $SqlAdminPassword) {
        $SecurePassword = Read-Host "Enter SQL Server admin password" -AsSecureString
        $SqlAdminPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecurePassword))
    }
    
    # Create SQL Server
    az sql server create `
        --name $SqlServerName `
        --resource-group $ResourceGroup `
        --location $Location `
        --admin-user $SqlAdminUser `
        --admin-password $SqlAdminPassword
    
    # Configure firewall to allow Azure services
    az sql server firewall-rule create `
        --resource-group $ResourceGroup `
        --server $SqlServerName `
        --name AllowAzureServices `
        --start-ip-address 0.0.0.0 `
        --end-ip-address 0.0.0.0
    
    # Create database
    az sql db create `
        --resource-group $ResourceGroup `
        --server $SqlServerName `
        --name LibraryDb `
        --service-objective S0
    
    # Get connection string
    $connectionString = "Server=tcp:$SqlServerName.database.windows.net,1433;Initial Catalog=LibraryDb;Persist Security Info=False;User ID=$SqlAdminUser;Password=$SqlAdminPassword;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
    
    # Set connection string in App Service
    az webapp config connection-string set `
        --name $AppServiceName `
        --resource-group $ResourceGroup `
        --connection-string-type SQLAzure `
        --settings DefaultConnection="$connectionString"
    
    Write-Host "? SQL Server and Database created" -ForegroundColor Green
    Write-Host ""
}

# Step 5: Configure App Settings
Write-Host "Step 5: Configuring App Settings..." -ForegroundColor Yellow
az webapp config appsettings set `
    --name $AppServiceName `
    --resource-group $ResourceGroup `
    --settings ASPNETCORE_ENVIRONMENT=Production

Write-Host "? App Settings configured" -ForegroundColor Green
Write-Host ""

# Step 6: Build and Deploy
Write-Host "Step 6: Building and deploying application..." -ForegroundColor Yellow
dotnet publish .\LibraryManagementSystem\LibraryManagementSystem.csproj -c Release -o .\publish

# Create deployment package
Compress-Archive -Path .\publish\* -DestinationPath .\deploy.zip -Force

# Deploy to Azure
az webapp deployment source config-zip `
    --name $AppServiceName `
    --resource-group $ResourceGroup `
    --src .\deploy.zip

Write-Host "? Application deployed" -ForegroundColor Green
Write-Host ""

# Clean up
Remove-Item .\deploy.zip -Force

# Step 7: Get deployment info
Write-Host "Step 7: Retrieving deployment information..." -ForegroundColor Yellow
$webAppUrl = az webapp show --name $AppServiceName --resource-group $ResourceGroup --query "defaultHostName" -o tsv

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Deployment Complete!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Resource Group: $ResourceGroup" -ForegroundColor White
Write-Host "App Service: $AppServiceName" -ForegroundColor White
Write-Host "URL: https://$webAppUrl" -ForegroundColor Green
if ($SqlServerName) {
    Write-Host "SQL Server: $SqlServerName.database.windows.net" -ForegroundColor White
    Write-Host "Database: LibraryDb" -ForegroundColor White
}
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "1. Visit https://$webAppUrl to test the application" -ForegroundColor White
Write-Host "2. Configure custom domain (optional)" -ForegroundColor White
Write-Host "3. Set up SSL certificate" -ForegroundColor White
Write-Host "4. Monitor logs: az webapp log tail --name $AppServiceName --resource-group $ResourceGroup" -ForegroundColor White
Write-Host ""
