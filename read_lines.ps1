$pem = "$env:USERPROFILE\.ssh\gcp_key"
$remote = "basilabrahamaby@136.113.93.47"
ssh -o StrictHostKeyChecking=no -i $pem $remote "sed -n '96,110p' /etc/nginx/sites-enabled/pomma"
