# ?? FREE DEPLOYMENT - Quick Start

## Your Best FREE Option: Azure + Free SQL Database

### Total Cost: $0 Forever! ??

---

## 3 Simple Steps to Deploy FREE

### **Step 1: Get FREE Database** (5 minutes)
1. Visit: https://somee.com
2. Sign up FREE
3. Create database
4. Save credentials

### **Step 2: Update Config** (2 minutes)
Edit `LibraryManagementSystem\appsettings.Production.json`:
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=YOUR_SOMEE_SERVER;Database=YOUR_DB;User Id=YOUR_USER;Password=YOUR_PASS;TrustServerCertificate=True;Encrypt=False;MultipleActiveResultSets=true"
  }
}
```

### **Step 3: Deploy** (10 minutes)
```powershell
# Install Azure CLI (one-time)
# Download from: https://aka.ms/installazurecliwindows

# Deploy (replace with unique name)
.\deploy-azure-free.ps1 -AppName "librarymanagement-yourname"
```

---

## What You Get FREE

? **Live Web App** - yourapp.azurewebsites.net  
? **HTTPS/SSL** - Automatic secure connection  
? **SQL Server Database** - Full featured  
? **60 CPU min/day** - Enough for personal use  
? **1 GB Storage** - Plenty for this app  
? **No Credit Card** - Really free!  

---

## Limitations (FREE Tier)

?? App sleeps after 20 min (10 sec wake time)  
?? 60 CPU minutes daily limit  
?? No custom domain on free tier  

**Perfect for:** Portfolio, demo, personal use, learning

---

## Full Guide

See: `DEPLOYMENT-FREE.md` for complete instructions

---

## Quick Deploy Now!

```powershell
.\deploy-azure-free.ps1 -AppName "librarymanagement-yourname"
```

**Time to live app:** 15 minutes total! ??
