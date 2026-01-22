#!/bin/bash
echo "=== REQUEST STATUSES ==="
sudo tail -n 200 /var/log/nginx/access.log | grep "POST /api/auth/login" | tail -n 10 | awk '{print $1 " " $9}'
echo "========================"
