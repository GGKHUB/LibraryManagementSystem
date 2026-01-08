# Library Management System - Production Deployment Guide

## Prerequisites

1. **.NET 10 Runtime** installed on the production server
2. **SQL Server** (2019 or later recommended)
3. **IIS** (Internet Information Services) for Windows Server deployment or
4. **Linux server** with Nginx/Apache for Linux deployment

## Deployment Options

### Option 1: Deploy to Azure App Service (Recommended)

#### Step 1: Prepare the Application
1. Update `appsettings.Production.json` with your Azure SQL connection string
2. Build the application in Release mode:
   ```
   dotnet publish -c Release -o ./publish
   ```

#### Step 2: Create Azure Resources
1. Create an Azure App Service (Web App)
2. Create an Azure SQL Database
3. Get the SQL connection string from Azure Portal

#### Step 3: Update Configuration
Update `appsettings.Production.json`:
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=tcp:your-server.database.windows.net,1433;Initial Catalog=LibraryDb;Persist Security Info=False;User ID=your-username;Password=your-password;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  }
}
```

#### Step 4: Deploy
Using Visual Studio:
1. Right-click the project ? Publish
2. Select Azure ? Azure App Service
3. Follow the wizard

Using Azure CLI:
```bash
az webapp up --name your-app-name --resource-group your-rg --runtime "DOTNET|10.0"
```

---

### Option 2: Deploy to Windows Server with IIS

#### Step 1: Install Prerequisites
1. Install .NET 10 Hosting Bundle from Microsoft
2. Install IIS with ASP.NET Core Module
3. Install SQL Server (or use existing instance)

#### Step 2: Build the Application
```powershell
dotnet publish -c Release -o C:\inetpub\LibraryManagement
```

#### Step 3: Configure IIS
1. Open IIS Manager
2. Create new Application Pool (.NET CLR version: No Managed Code)
3. Create new website pointing to C:\inetpub\LibraryManagement
4. Set Application Pool to the one created

#### Step 4: Update Connection String
Edit `appsettings.Production.json` in the published folder:
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost\\SQLEXPRESS;Database=LibraryDb;Trusted_Connection=True;MultipleActiveResultSets=true"
  }
}
```

#### Step 5: Apply Database Migrations
```powershell
cd C:\inetpub\LibraryManagement
dotnet LibraryManagementSystem.dll --environment Production
```

---

### Option 3: Deploy to Linux Server (Ubuntu/Debian)

#### Step 1: Install Prerequisites
```bash
# Install .NET 10 Runtime
wget https://dot.net/v1/dotnet-install.sh
chmod +x dotnet-install.sh
./dotnet-install.sh --channel 10.0

# Install Nginx
sudo apt update
sudo apt install nginx
```

#### Step 2: Publish Application
On your development machine:
```bash
dotnet publish -c Release -o ./publish
```

Copy files to server:
```bash
scp -r ./publish/* user@your-server:/var/www/librarymanagement/
```

#### Step 3: Configure Nginx
Create `/etc/nginx/sites-available/librarymanagement`:
```nginx
server {
    listen 80;
    server_name your-domain.com;
    
    location / {
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection keep-alive;
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

Enable the site:
```bash
sudo ln -s /etc/nginx/sites-available/librarymanagement /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

#### Step 4: Create Systemd Service
Create `/etc/systemd/system/librarymanagement.service`:
```ini
[Unit]
Description=Library Management System
After=network.target

[Service]
WorkingDirectory=/var/www/librarymanagement
ExecStart=/usr/bin/dotnet /var/www/librarymanagement/LibraryManagementSystem.dll
Restart=always
RestartSec=10
KillSignal=SIGINT
SyslogIdentifier=librarymanagement
User=www-data
Environment=ASPNETCORE_ENVIRONMENT=Production
Environment=DOTNET_PRINT_TELEMETRY_MESSAGE=false

[Install]
WantedBy=multi-user.target
```

Enable and start:
```bash
sudo systemctl enable librarymanagement
sudo systemctl start librarymanagement
sudo systemctl status librarymanagement
```

---

## Database Migration

### Before First Deployment
Ensure migrations are created:
```bash
dotnet ef migrations add InitialCreate --context AppDbContext --output-dir Migrations/AppDb
dotnet ef migrations add InitialCreate --context ApplicationDbContext --output-dir Migrations/ApplicationDb
```

### On Production Server
The application will automatically apply migrations on startup in production mode.

Alternatively, manually apply migrations:
```bash
dotnet ef database update --context AppDbContext --connection "YOUR_CONNECTION_STRING"
dotnet ef database update --context ApplicationDbContext --connection "YOUR_CONNECTION_STRING"
```

---

## Security Checklist

- [ ] Update connection strings in `appsettings.Production.json`
- [ ] Remove `RequireConfirmedAccount = true` or set up email confirmation
- [ ] Enable HTTPS (SSL certificate)
- [ ] Set strong password policies
- [ ] Configure CORS if needed
- [ ] Set up application insights/logging
- [ ] Configure backup strategy for database
- [ ] Set environment variable: `ASPNETCORE_ENVIRONMENT=Production`
- [ ] Remove or secure `appsettings.Development.json` from production
- [ ] Disable detailed error pages in production

---

## Environment Variables

Set these on your production server:

```bash
ASPNETCORE_ENVIRONMENT=Production
ASPNETCORE_URLS=http://localhost:5000
ConnectionStrings__DefaultConnection="Your-Connection-String-Here"
```

---

## Post-Deployment Verification

1. Check logs: `/var/log/nginx/error.log` or Event Viewer (Windows)
2. Verify database tables were created
3. Test user registration and login
4. Test CRUD operations on Books
5. Verify authentication is working

---

## Troubleshooting

### Issue: 500 Internal Server Error
- Check application logs
- Verify connection string is correct
- Ensure database is accessible
- Check .NET runtime is installed

### Issue: Database Connection Failed
- Verify SQL Server is running
- Check firewall rules
- Test connection string manually
- Verify user permissions

### Issue: Pages not loading correctly
- Check static files are being served
- Verify wwwroot folder exists in published output
- Check Nginx/IIS configuration

---

## Monitoring

Consider setting up:
- Application Insights (Azure)
- ELK Stack (Elasticsearch, Logstash, Kibana)
- Prometheus + Grafana
- Custom logging to file or database

---

## Backup Strategy

1. **Database Backups**: Set up automated SQL Server backups
2. **Application Files**: Version control with Git
3. **Configuration**: Store sensitive configs in Azure Key Vault or similar

---

## Scaling Considerations

For high traffic:
1. Use Azure App Service with auto-scaling
2. Implement caching (Redis)
3. Use CDN for static files
4. Consider database read replicas
5. Implement application-level caching

---

## Support

For issues, check:
- Application logs
- SQL Server logs
- IIS/Nginx error logs
- Windows Event Viewer (Windows deployments)
