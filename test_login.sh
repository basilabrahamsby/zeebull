#!/bin/bash
curl -v -X POST http://localhost:8011/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@orchid.com","password":"admin123"}' \
  2>&1 | grep -A 20 "< HTTP"
