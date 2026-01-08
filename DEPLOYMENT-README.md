# Library Management System - Quick Deployment Guide

## ?? Quick Start Deployment

### Option 1: Azure App Service (Easiest)

```powershell
# 1. Login to Azure
az login

# 2. Run the deployment script
.\deploy-azure.ps1 -ResourceGroup "LibraryManagement-RG" -AppServiceName "my-library-app" -Location "eastus" -SqlServerName "my-library-sql"

# 3. Visit your app at: https://my-library-app.azurewebsites.net
```

### Option 2: Windows Server with IIS

```powershell
# Run as Administrator
.\deploy-windows.ps1 -PublishPath "C:\inetpub\LibraryManagement" -SiteName "LibraryManagement" -Port 80
```

### Option 3: Linux Server

```bash
# Run with sudo
sudo chmod +x deploy-linux.sh
sudo ./deploy-linux.sh
```

## ?? Before You Deploy

1. **Update Production Configuration**
   - Edit `LibraryManagementSystem/appsettings.Production.json`
   - Update the connection string with your production database details

2. **Review Security Settings**
   - See `DEPLOYMENT-CHECKLIST.md` for full checklist

## ?? Documentation

- **Full Deployment Guide**: See `DEPLOYMENT.md`
- **Deployment Checklist**: See `DEPLOYMENT-CHECKLIST.md`

## ??? Manual Deployment

### Build for Production

```bash
dotnet publish -c Release -o ./publish
```

### Apply Database Migrations

```bash
dotnet ef database update --context AppDbContext
dotnet ef database update --context ApplicationDbContext
```

## ?? Configuration

### Development
- Uses LocalDB (SQL Server)
- Database auto-created on startup
- Detailed error pages enabled

### Production  
- Uses migrations for database versioning
- Requires production SQL Server
- Error handling enabled
- HTTPS enforced

## ?? Security Notes

1. **Change Connection Strings** in `appsettings.Production.json`
2. **Enable HTTPS** with SSL certificate
3. **Set Strong Passwords** for database and admin users
4. **Review Identity Settings** - Email confirmation is required by default

## ?? Support

For detailed instructions, see the comprehensive guides:
- `DEPLOYMENT.md` - Complete deployment instructions
- `DEPLOYMENT-CHECKLIST.md` - Pre/post-deployment checklist

## ? Post-Deployment Testing

After deployment, verify:
- [ ] Application loads successfully
- [ ] User registration works
- [ ] User login works
- [ ] Books CRUD operations work
- [ ] Statistics display correctly on homepage
- [ ] HTTPS is working (if configured)

## ?? Updates and Rollback

### Deploying Updates
```bash
# Build new version
dotnet publish -c Release -o ./publish

# Copy to production (method depends on your hosting)
# For Azure: Redeploy using the same script
# For IIS: Copy files and restart application pool
# For Linux: Copy files and restart systemd service
```

### Rollback
See `DEPLOYMENT-CHECKLIST.md` for rollback procedures

## ?? Monitoring

Monitor your application:
- Check application logs regularly
- Monitor database performance
- Set up alerts for errors
- Review user feedback

---

**Ready to deploy?** Start with `DEPLOYMENT-CHECKLIST.md` to ensure everything is configured correctly!
