# Clear Server Database via SSH
$pem = "$env:USERPROFILE\.ssh\gcp_key"
$remote = "basilabrahamaby@136.113.93.47"

Write-Host "`n╔════════════════════════════════════════╗" -ForegroundColor Red
Write-Host "║   🌐 CLEARING SERVER DATABASE         ║" -ForegroundColor Red
Write-Host "╚════════════════════════════════════════╝`n" -ForegroundColor Red

# Upload the cleanup SQL script to server
Write-Host "📤 Uploading cleanup script to server..." -ForegroundColor Cyan
scp -o StrictHostKeyChecking=no -i $pem "c:\releasing\New Orchid\ResortApp\cleanup_now.sql" "${remote}:~/cleanup_now.sql"

# Execute the cleanup on server database
Write-Host "`n🗑️ Executing cleanup on server database..." -ForegroundColor Yellow
$commands = @"
export PGPASSWORD='qwerty123'
psql -h localhost -U postgres -d orchiddb -f ~/cleanup_now.sql
echo ""
echo "Server database cleanup complete!"
"@

ssh -o StrictHostKeyChecking=no -i $pem $remote $commands

# Restart the server backend
Write-Host "`n🔄 Restarting server backend..." -ForegroundColor Cyan
ssh -o StrictHostKeyChecking=no -i $pem $remote "sudo systemctl restart inventory-resort.service"

Write-Host "`n╔════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║   ✅ SERVER CLEANUP COMPLETE           ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════╝`n" -ForegroundColor Green

Write-Host "Both LOCAL and SERVER databases are now clean!" -ForegroundColor White
Write-Host "Hard refresh your browser to see the changes." -ForegroundColor Gray

