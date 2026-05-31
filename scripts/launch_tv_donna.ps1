# Launch TradingView with CDP enabled for DONNA MCP connection
# Run this instead of opening TradingView from Start Menu

$Port = 9222

# Kill any existing TradingView instances
Get-Process -Name "TradingView" -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 2

# Find via Get-AppxPackage (no admin needed, version-agnostic)
$pkg = Get-AppxPackage -Name "*TradingView*" -ErrorAction SilentlyContinue
if ($pkg -and $pkg.InstallLocation) {
    $exe = Join-Path $pkg.InstallLocation "TradingView.exe"
} else {
    # Fallbacks
    $candidates = @(
        "$env:LOCALAPPDATA\TradingView\TradingView.exe",
        "$env:PROGRAMFILES\TradingView\TradingView.exe"
    )
    $exe = $candidates | Where-Object { Test-Path $_ } | Select-Object -First 1
}

if (-not $exe -or -not (Test-Path $exe)) {
    Write-Host "ERROR: TradingView not found. Install from Microsoft Store." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "Launching: $exe" -ForegroundColor Cyan
Write-Host "CDP port: $Port" -ForegroundColor Cyan
Start-Process -FilePath $exe -ArgumentList "--remote-debugging-port=$Port"

Write-Host "Waiting for CDP..." -ForegroundColor Yellow
$ready = $false
for ($i = 0; $i -lt 20; $i++) {
    Start-Sleep -Seconds 1
    try {
        $null = Invoke-WebRequest -Uri "http://localhost:$Port/json/version" -UseBasicParsing -TimeoutSec 2
        $ready = $true
        break
    } catch { }
}

if ($ready) {
    Write-Host "CDP ready at http://localhost:$Port — DONNA MCP can now connect." -ForegroundColor Green
} else {
    Write-Host "TradingView launched but CDP not responding yet. Give it a few more seconds." -ForegroundColor Yellow
}
