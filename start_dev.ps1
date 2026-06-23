$ADB = "C:\Users\narma\AppData\Local\Android\Sdk\platform-tools\adb.exe"
$BACKEND = "e:\brainsync-ai-app\backend"

Write-Host ""
Write-Host "=== BrainSync Dev Startup ===" -ForegroundColor Cyan
Write-Host ""

# 1. Check PostgreSQL running
$pg = Get-Service -Name "postgresql*" -ErrorAction SilentlyContinue | Where-Object { $_.Status -eq "Running" }
if (-not $pg) {
    Write-Host "[WARN] PostgreSQL not running. Starting it..." -ForegroundColor Yellow
    $pgService = Get-Service -Name "postgresql*" -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($pgService) {
        Start-Service $pgService.Name
        Start-Sleep -Seconds 2
        Write-Host "[OK] PostgreSQL started" -ForegroundColor Green
    } else {
        Write-Host "[ERROR] PostgreSQL service not found. Start it manually." -ForegroundColor Red
        Read-Host "Press Enter to exit"
        exit 1
    }
} else {
    Write-Host "[OK] PostgreSQL running" -ForegroundColor Green
}

# 2. Check phone connected
$devices = & $ADB devices | Select-String -Pattern "device$"
if (-not $devices) {
    Write-Host "[ERROR] No Android device connected via USB. Connect phone and enable USB Debugging." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}
Write-Host "[OK] Phone connected via USB" -ForegroundColor Green

# 3. ADB reverse tunnel
& $ADB reverse tcp:8001 tcp:8001 | Out-Null
Write-Host "[OK] ADB tunnel ready  (phone localhost:8001 -> PC port 8001)" -ForegroundColor Green

# 4. Start backend
Write-Host "[OK] Starting FastAPI backend on port 8001..." -ForegroundColor Green
Write-Host ""
Write-Host "----------------------------------------------" -ForegroundColor DarkGray
Write-Host "  App is ready. Open BrainSync on your phone." -ForegroundColor White
Write-Host "  Press Ctrl+C here to stop the backend." -ForegroundColor DarkGray
Write-Host "----------------------------------------------" -ForegroundColor DarkGray
Write-Host ""
Set-Location $BACKEND
& python -m uvicorn app.main:app --port 8001 --reload
