$pem = "$env:USERPROFILE\.ssh\gcp_key"
$remote = "basilabrahamaby@136.113.93.47"

Write-Host "Finding Line Number..."
$line = ssh -o StrictHostKeyChecking=no -i $pem $remote "grep -n 'location /inventoryapi/' /etc/nginx/sites-enabled/pomma"
Write-Host "Line Output: $line"

# Extract line number (e.g., '45:    location...')
$ln = $line -replace ':.*',''
if ($ln -match '^\d+$') {
    $end = [int]$ln + 10
    Write-Host "Reading lines $ln to $end..."
    ssh -o StrictHostKeyChecking=no -i $pem $remote "sed -n '${ln},${end}p' /etc/nginx/sites-enabled/pomma"
} else {
    Write-Host "Could not find line number."
}
