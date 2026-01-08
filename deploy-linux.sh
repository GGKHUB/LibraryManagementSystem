#!/bin/bash

# Bash Deployment Script for Library Management System
# Run this script on Linux to deploy the application

set -e

# Configuration
APP_NAME="librarymanagement"
PUBLISH_DIR="/var/www/$APP_NAME"
SERVICE_NAME="$APP_NAME.service"
NGINX_CONFIG="/etc/nginx/sites-available/$APP_NAME"
DOMAIN="your-domain.com"

echo "========================================"
echo "Library Management System Deployment"
echo "========================================"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "ERROR: This script must be run as root (use sudo)"
    exit 1
fi

# Step 1: Build and Publish
echo "Step 1: Building and publishing application..."
dotnet publish ./LibraryManagementSystem/LibraryManagementSystem.csproj -c Release -o ./publish

if [ $? -ne 0 ]; then
    echo "ERROR: Build failed!"
    exit 1
fi
echo "? Application published"
echo ""

# Step 2: Copy files to publish directory
echo "Step 2: Copying files to $PUBLISH_DIR..."
mkdir -p $PUBLISH_DIR
cp -r ./publish/* $PUBLISH_DIR/
chown -R www-data:www-data $PUBLISH_DIR
chmod -R 755 $PUBLISH_DIR
echo "? Files copied and permissions set"
echo ""

# Step 3: Create systemd service
echo "Step 3: Creating systemd service..."
cat > /etc/systemd/system/$SERVICE_NAME << EOF
[Unit]
Description=Library Management System
After=network.target

[Service]
WorkingDirectory=$PUBLISH_DIR
ExecStart=/usr/bin/dotnet $PUBLISH_DIR/LibraryManagementSystem.dll
Restart=always
RestartSec=10
KillSignal=SIGINT
SyslogIdentifier=$APP_NAME
User=www-data
Environment=ASPNETCORE_ENVIRONMENT=Production
Environment=DOTNET_PRINT_TELEMETRY_MESSAGE=false

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable $SERVICE_NAME
echo "? Systemd service created"
echo ""

# Step 4: Configure Nginx
echo "Step 4: Configuring Nginx..."
cat > $NGINX_CONFIG << EOF
server {
    listen 80;
    server_name $DOMAIN;
    
    location / {
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection keep-alive;
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

# Enable the site
ln -sf $NGINX_CONFIG /etc/nginx/sites-enabled/
nginx -t
if [ $? -eq 0 ]; then
    systemctl reload nginx
    echo "? Nginx configured and reloaded"
else
    echo "ERROR: Nginx configuration test failed!"
    exit 1
fi
echo ""

# Step 5: Start the application
echo "Step 5: Starting application..."
systemctl restart $SERVICE_NAME
sleep 3

if systemctl is-active --quiet $SERVICE_NAME; then
    echo "? Application is running"
else
    echo "ERROR: Application failed to start"
    echo "Check logs with: journalctl -u $SERVICE_NAME -n 50"
    exit 1
fi
echo ""

# Step 6: Test the deployment
echo "Step 6: Testing deployment..."
sleep 2
response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:5000)
if [ "$response" -eq 200 ] || [ "$response" -eq 302 ]; then
    echo "? Application is responding successfully!"
else
    echo "? Application responded with status code: $response"
    echo "   Please check the logs with: journalctl -u $SERVICE_NAME -n 50"
fi
echo ""

# Summary
echo "========================================"
echo "Deployment Complete!"
echo "========================================"
echo "Website: http://$DOMAIN"
echo "Physical Path: $PUBLISH_DIR"
echo "Service: $SERVICE_NAME"
echo ""
echo "Next Steps:"
echo "1. Update connection string in $PUBLISH_DIR/appsettings.Production.json"
echo "2. Restart the service: sudo systemctl restart $SERVICE_NAME"
echo "3. Verify database migrations have been applied"
echo "4. Configure SSL certificate with certbot:"
echo "   sudo apt install certbot python3-certbot-nginx"
echo "   sudo certbot --nginx -d $DOMAIN"
echo ""
echo "Useful Commands:"
echo "View logs: journalctl -u $SERVICE_NAME -f"
echo "Restart: sudo systemctl restart $SERVICE_NAME"
echo "Status: sudo systemctl status $SERVICE_NAME"
echo ""
