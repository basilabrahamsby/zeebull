#!/bin/bash
echo "=== NGINX ACCESS LOG DEBUG ==="
sudo tail -n 200 /var/log/nginx/access.log | grep "POST /api/auth/login" | tail -n 10
echo "=============================="
