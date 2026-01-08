# ?? FREE Deployment Guide - Library Management System

## Best FREE Option: Azure App Service (Free Tier) + Free SQL Database

### Why This Option?
- ? **Completely FREE** - No credit card required
- ? **Easy to deploy** - One PowerShell script
- ? **Professional URL** - yourapp.azurewebsites.net
- ? **SSL included** - HTTPS by default
- ? **No server maintenance** - Fully managed

### FREE Tier Limitations
- ?? **60 CPU minutes per day** - Enough for personal/demo use
- ?? **App sleeps after 20 minutes** - First request after sleep takes ~10 seconds
- ?? **1 GB disk space** - Plenty for this app
- ?? **No custom domain on free tier** - Use .azurewebsites.net

---

## ?? Step-by-Step FREE Deployment

### **Step 1: Get FREE SQL Server Database**

Choose one of these **FREE** SQL Server hosting providers:

#### **Option A: Somee.com (Recommended)**
1. Go to: https://somee.com
2. Click "Sign Up" ? Create free account
3. After login ? "Add Website" ? Select "ASP.NET"
4. Go to "Control Panel" ? "Database"
5. Note down:
   ```
   Server: sql...somee.com
   Database: dbXXXXXX
   Username: dbXXXXXX_admin
   Password: (your password)
   ```

#### **Option B: FreeSQLDatabase.com**
1. Go to: https://www.freesqldatabase.com
2. Fill the form and submit
3. Check email for database credentials

---

### **Step 2: Update Configuration**

Open `LibraryManagementSystem\appsettings.Production.json` and update:

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=sql123.somee.com;Database=dbXXXXX;User Id=dbXXXXX_admin;Password=YOUR_PASSWORD;TrustServerCertificate=True;MultipleActiveResultSets=true;Encrypt=False"
  },
  "Logging": {
    "LogLevel": {
      "Default": "Warning",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*"
}
```

**?? Important:** Add `Encrypt=False` to the connection string for compatibility with free SQL Server hosts.

---

### **Step 3: Install Azure CLI** (One-time setup)

Download and install from: https://aka.ms/installazurecliwindows

Or use this PowerShell command:
```powershell
Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi; Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'; Remove-Item .\AzureCLI.msi
```

---

### **Step 4: Deploy to Azure (FREE)**

Open PowerShell in your project directory and run:

```powershell
.\deploy-azure-free.ps1 -AppName "your-unique-app-name"
```

**Note:** App name must be globally unique. Try: `librarymanagement-yourname`

The script will:
1. ? Login to Azure (you'll need a Microsoft account - FREE to create)
2. ? Create FREE App Service Plan
3. ? Create Web App
4. ? Build and deploy your application
5. ? Give you the live URL

**Time to deploy:** ~5-10 minutes

---

### **Step 5: Configure Connection String in Azure**

After deployment:

1. Go to: https://portal.azure.com
2. Navigate to: **App Services** ? **your-app-name**
3. Click **Configuration** (left menu)
4. Under **Connection strings**, click **+ New connection string**
5. Enter:
   - **Name:** `DefaultConnection`
   - **Value:** Your connection string from Step 2
   - **Type:** `SQLServer`
6. Click **OK** then **Save**
7. Click **Continue** to restart the app

---

### **Step 6: Visit Your Live App!**

Your app will be live at: `https://your-app-name.azurewebsites.net`

**First visit:** May take 10-15 seconds (free tier cold start)

---

## ?? Alternative FREE Options

### **Option 2: Railway.app** (If you prefer PostgreSQL)

**Setup:**
1. Push code to GitHub (you already have it!)
2. Go to: https://railway.app
3. Sign in with GitHub
4. Click "New Project" ? "Deploy from GitHub repo"
5. Select your repository
6. Railway deploys automatically!

**Note:** Would need to change from SQL Server to PostgreSQL (requires code changes)

---

### **Option 3: Keep it Local + Share via Ngrok** (For testing only)

**Completely FREE, no sign-ups:**

```powershell
# 1. Download ngrok
Invoke-WebRequest https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-windows-amd64.zip -OutFile ngrok.zip
Expand-Archive ngrok.zip -DestinationPath .
Remove-Item ngrok.zip

# 2. Run your app
Start-Process powershell -ArgumentList "dotnet run --project LibraryManagementSystem"

# 3. Wait 10 seconds for app to start
Start-Sleep -Seconds 10

# 4. Expose with ngrok
.\ngrok http 5000
```

**Your app will be accessible at:** `https://xxxx-xx-xx-xx-xx.ngrok-free.app`

**Limitations:**
- Your PC must stay on
- URL changes every restart
- Not suitable for production

---

## ?? Cost Comparison

| Option | Monthly Cost | Database | Uptime |
|--------|-------------|----------|--------|
| **Azure Free + Somee** | $0 | SQL Server | 99%* |
| **Railway** | $0 ($5 credit) | PostgreSQL | 99% |
| **Ngrok (local)** | $0 | LocalDB | When PC is on |

*App sleeps after inactivity but restarts automatically

---

## ?? Important Notes for FREE Azure Deployment

### **FREE Tier Quotas:**
- **60 CPU minutes per day** - Resets at midnight UTC
- If exceeded, app stops until next day
- Typically enough for 200-500 page views per day

### **Cold Start:**
- App sleeps after 20 minutes of no traffic
- First request after sleep: ~10-15 seconds
- Subsequent requests: Normal speed

### **How to Keep App Awake** (Optional):
Use a free service like UptimeRobot to ping your app every 5 minutes:
1. Go to: https://uptimerobot.com
2. Create free account
3. Add monitor with your app URL
4. Set interval to 5 minutes

---

## ?? Troubleshooting

### **Issue: "App name already exists"**
- App names must be globally unique
- Try: `librarymanagement-yourname-123`

### **Issue: "Cannot connect to database"**
- Verify connection string in Azure Configuration
- Ensure `Encrypt=False` is in connection string
- Check database credentials from hosting provider

### **Issue: "502 Bad Gateway"**
- App is starting (cold start) - Wait 30 seconds and refresh
- Check logs: `az webapp log tail --name your-app-name --resource-group LibraryManagement-Free`

### **Issue: "CPU quota exceeded"**
- You've used your 60 minutes for the day
- Wait until midnight UTC, or upgrade to paid tier

---

## ? Recommended: Azure FREE Tier

**Run this command to deploy:**

```powershell
.\deploy-azure-free.ps1 -AppName "librarymanagement-yourname"
```

**Total time:** 10-15 minutes from start to live app!

**Total cost:** $0.00 forever! ??

---

## ?? Need Help?

1. Check Azure logs:
   ```powershell
   az webapp log tail --name your-app-name --resource-group LibraryManagement-Free
   ```

2. View in browser: https://portal.azure.com ? Your App ? Log stream

3. Check deployment status: Azure Portal ? Your App ? Deployment Center

---

## ?? That's It!

Your Library Management System will be live and FREE! Perfect for:
- Personal use
- Portfolio/demo
- Learning and testing
- Small user base (<100 users)

**Want to upgrade later?** Easy! Just change the App Service Plan from F1 (Free) to B1 (Basic) in Azure Portal.

---

**Ready? Let's deploy! ??**

```powershell
.\deploy-azure-free.ps1 -AppName "your-unique-app-name"
```
