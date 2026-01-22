# ========================================
# CLEAR ALL DATA - LOCAL & SERVER
# ========================================

$ErrorActionPreference = "Stop"

Write-Host "`n╔════════════════════════════════════════╗" -ForegroundColor Red
Write-Host "║   ⚠️  DATA CLEANUP SCRIPT  ⚠️          ║" -ForegroundColor Red
Write-Host "╚════════════════════════════════════════╝`n" -ForegroundColor Red

Write-Host "This will DELETE ALL transactional data from:" -ForegroundColor Yellow
Write-Host "  • Bookings & Payments" -ForegroundColor White
Write-Host "  • Inventory Transactions & Stock" -ForegroundColor White
Write-Host "  • Purchases & Stock Issues" -ForegroundColor White
Write-Host "  • Assets & Recipes" -ForegroundColor White
Write-Host "  • Food Orders & Service Requests" -ForegroundColor White
Write-Host "  • GST Reports & Expenses" -ForegroundColor White
Write-Host "`nMaster data (Rooms, Categories, Vendors, Users) will be PRESERVED`n" -ForegroundColor Green

$confirm = Read-Host "Type 'DELETE ALL' to confirm"
if ($confirm -ne "DELETE ALL") {
    Write-Host "`n❌ Cancelled" -ForegroundColor Red
    exit
}

# Load environment variables
$envPath = "c:\releasing\New Orchid\ResortApp\.env"
if (Test-Path $envPath) {
    Get-Content $envPath | ForEach-Object {
        if ($_ -match '^([^=]+)=(.*)$') {
            $key = $matches[1].Trim()
            $value = $matches[2].Trim()
            [Environment]::SetEnvironmentVariable($key, $value, "Process")
        }
    }
}

# Database credentials
$DB_HOST = "localhost"
$DB_PORT = "5432"
$DB_NAME = "orchidtrails"
$DB_USER = "postgres"
$DB_PASS = "qwerty123"

# Server database (if different)
$SERVER_DB_HOST = $env:SERVER_DB_HOST
$SERVER_DB_USER = $env:SERVER_DB_USER
$SERVER_DB_PASS = $env:SERVER_DB_PASS

$sqlFile = "c:\releasing\New Orchid\ResortApp\clear_all_data.sql"

Write-Host "`n🔄 Clearing LOCAL database..." -ForegroundColor Cyan
$env:PGPASSWORD = $DB_PASS
& psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f $sqlFile

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Local database cleared successfully!" -ForegroundColor Green
} else {
    Write-Host "❌ Error clearing local database" -ForegroundColor Red
    exit 1
}

# Clear server database if credentials are available
if ($SERVER_DB_HOST -and $SERVER_DB_USER -and $SERVER_DB_PASS) {
    Write-Host "`n🔄 Clearing SERVER database..." -ForegroundColor Cyan
    $env:PGPASSWORD = $SERVER_DB_PASS
    & psql -h $SERVER_DB_HOST -p $DB_PORT -U $SERVER_DB_USER -d $DB_NAME -f $sqlFile
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Server database cleared successfully!" -ForegroundColor Green
    } else {
        Write-Host "❌ Error clearing server database" -ForegroundColor Red
    }
} else {
    Write-Host "`n⚠️  Server database credentials not found in .env" -ForegroundColor Yellow
    Write-Host "Only local database was cleared" -ForegroundColor Yellow
}

Write-Host "`n╔════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║   ✅ DATA CLEANUP COMPLETE             ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════╝`n" -ForegroundColor Green

Write-Host "All transactional data has been removed." -ForegroundColor White
Write-Host "You can now start fresh with clean data!`n" -ForegroundColor White
