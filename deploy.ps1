# MediConnect Deployment Script
# Run this script to deploy everything to production

param(
    [string]$Step = "all"
)

Write-Host "🚀 MediConnect Deployment Script" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan

function Check-Command($cmd) {
    return (Get-Command $cmd -ErrorAction SilentlyContinue) -ne $null
}

# Step 1: Check prerequisites
if ($Step -eq "all" -or $Step -eq "check") {
    Write-Host "`n📋 Checking prerequisites..." -ForegroundColor Yellow
    
    if (Check-Command "firebase") {
        Write-Host "  ✅ Firebase CLI installed" -ForegroundColor Green
    } else {
        Write-Host "  ❌ Firebase CLI not found. Installing..." -ForegroundColor Red
        npm install -g firebase-tools
    }
    
    if (Check-Command "flutter") {
        Write-Host "  ✅ Flutter installed" -ForegroundColor Green
    } else {
        Write-Host "  ❌ Flutter not found!" -ForegroundColor Red
        exit 1
    }
    
    if (Check-Command "node") {
        Write-Host "  ✅ Node.js installed" -ForegroundColor Green
    } else {
        Write-Host "  ❌ Node.js not found!" -ForegroundColor Red
        exit 1
    }
}

# Step 2: Seed Firestore database
if ($Step -eq "all" -or $Step -eq "seed") {
    Write-Host "`n🔥 Seeding Firestore database..." -ForegroundColor Yellow
    Set-Location backend
    node src/scripts/create-firestore-db.js
    Set-Location ..
}

# Step 3: Build Flutter web app
if ($Step -eq "all" -or $Step -eq "build") {
    Write-Host "`n📱 Building Flutter web app..." -ForegroundColor Yellow
    Set-Location medi_connect
    flutter build web --release --dart-define=ENV=production
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✅ Flutter web build successful!" -ForegroundColor Green
    } else {
        Write-Host "  ❌ Flutter web build failed!" -ForegroundColor Red
        Set-Location ..
        exit 1
    }
    Set-Location ..
}

# Step 4: Deploy to Firebase Hosting
if ($Step -eq "all" -or $Step -eq "deploy-web") {
    Write-Host "`n🌐 Deploying to Firebase Hosting..." -ForegroundColor Yellow
    firebase deploy --only hosting
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✅ Deployed to Firebase Hosting!" -ForegroundColor Green
        Write-Host "  🌐 Live at: https://mediconnect-4b155.web.app" -ForegroundColor Cyan
    } else {
        Write-Host "  ❌ Firebase Hosting deployment failed!" -ForegroundColor Red
    }
}

# Step 5: Deploy Firestore rules
if ($Step -eq "all" -or $Step -eq "deploy-rules") {
    Write-Host "`n🔒 Deploying Firestore security rules..." -ForegroundColor Yellow
    firebase deploy --only firestore:rules
    firebase deploy --only storage:rules
    Write-Host "  ✅ Security rules deployed!" -ForegroundColor Green
}

Write-Host "`n✅ Deployment complete!" -ForegroundColor Green
Write-Host "`n📊 Your app is live at:" -ForegroundColor Cyan
Write-Host "   🌐 Web App: https://mediconnect-4b155.web.app" -ForegroundColor White
Write-Host "   🔧 Backend: http://localhost:3000 (deploy to Railway for internet access)" -ForegroundColor White
Write-Host "   📊 Admin: http://localhost:3001" -ForegroundColor White
