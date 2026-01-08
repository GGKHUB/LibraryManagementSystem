# Production Deployment Checklist

## Pre-Deployment

### Configuration
- [ ] Update `appsettings.Production.json` with production connection string
- [ ] Remove or secure development configuration files
- [ ] Set `ASPNETCORE_ENVIRONMENT=Production` environment variable
- [ ] Disable detailed error pages (already configured in Program.cs)
- [ ] Remove `RequireConfirmedAccount = true` or configure email service
- [ ] Configure logging for production (Application Insights, file logging, etc.)

### Database
- [ ] Create production database
- [ ] Update database connection string
- [ ] Test database connectivity from production server
- [ ] Ensure migrations are created and tested
- [ ] Plan database backup strategy

### Security
- [ ] Use strong SQL Server credentials
- [ ] Enable HTTPS/SSL
- [ ] Configure firewall rules
- [ ] Review authentication settings
- [ ] Set up secrets management (Azure Key Vault, AWS Secrets Manager, etc.)
- [ ] Review CORS settings if applicable
- [ ] Change default Identity password requirements if needed
- [ ] Disable runtime compilation in production (remove Razor Runtime Compilation)

### Dependencies
- [ ] Verify .NET 10 Runtime is installed on production server
- [ ] Install required Windows features (IIS, ASP.NET Core Module) for Windows
- [ ] Install required packages (nginx, dotnet) for Linux
- [ ] Test all NuGet packages are compatible with production environment

## Deployment

### Build & Publish
- [ ] Build solution in Release mode
- [ ] Run unit tests (if applicable)
- [ ] Publish application to deployment folder
- [ ] Verify all required files are in publish folder

### Server Configuration
#### Windows/IIS
- [ ] Create Application Pool with No Managed Code
- [ ] Create IIS Website
- [ ] Set proper file permissions
- [ ] Configure Application Pool identity
- [ ] Set up logging

#### Linux
- [ ] Create systemd service file
- [ ] Configure Nginx reverse proxy
- [ ] Set file permissions (www-data user)
- [ ] Enable and start service

#### Azure
- [ ] Create App Service
- [ ] Create SQL Database
- [ ] Configure connection strings
- [ ] Set environment variables
- [ ] Configure scaling settings

### Database Migration
- [ ] Backup existing database (if upgrading)
- [ ] Apply migrations to production database
- [ ] Verify migrations completed successfully
- [ ] Test database connectivity from application

## Post-Deployment

### Testing
- [ ] Verify application loads successfully
- [ ] Test user registration
- [ ] Test user login
- [ ] Test all CRUD operations (Books)
- [ ] Verify statistics are displaying correctly
- [ ] Test authentication is working (try accessing protected pages)
- [ ] Check all images and static files load correctly
- [ ] Test on different browsers
- [ ] Test responsive design on mobile devices

### Monitoring
- [ ] Set up application monitoring
- [ ] Configure log aggregation
- [ ] Set up alerts for errors
- [ ] Monitor CPU and memory usage
- [ ] Check database performance
- [ ] Review initial logs for errors

### Documentation
- [ ] Document production environment details
- [ ] Document database connection details (securely)
- [ ] Document troubleshooting steps
- [ ] Document backup and recovery procedures
- [ ] Update team on deployment completion

## Ongoing Maintenance

### Daily
- [ ] Monitor application logs
- [ ] Check error rates
- [ ] Review performance metrics

### Weekly
- [ ] Review and address any errors
- [ ] Check disk space
- [ ] Review user feedback
- [ ] Check for security updates

### Monthly
- [ ] Review and optimize database
- [ ] Update dependencies and packages
- [ ] Review and update security settings
- [ ] Test backup and recovery procedures

## Rollback Plan

In case of deployment issues:

1. **Stop the application**
   - Windows: Stop IIS Application Pool
   - Linux: `sudo systemctl stop librarymanagement`
   - Azure: Stop App Service

2. **Restore previous version**
   - Replace application files with previous version
   - Restore database backup if needed

3. **Restart application**

4. **Verify rollback successful**

## Emergency Contacts

- **System Administrator**: _______________
- **Database Administrator**: _______________
- **Development Team Lead**: _______________
- **Hosting Provider Support**: _______________

## Important URLs

- **Production URL**: https://_______________
- **Azure Portal**: https://portal.azure.com
- **Database Management**: _______________
- **Monitoring Dashboard**: _______________

## Notes

_Add any environment-specific notes here_
