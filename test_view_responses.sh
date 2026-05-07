#!/bin/bash

API_URL="http://localhost:8080"
TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJmaXRwYXctYmFja2VuZCIsInN1YiI6IjMwMTQ1Njc4OTAiLCJpYXQiOjE3NzgxMjQ5MTIsImV4cCI6MTc3ODEyODUxMiwidXN1YXJpb0lkIjo1LCJ0ZWxlZm9ubyI6IjMwMTQ1Njc4OTAifQ.eDt-9iazSSZwxiUbN75CoftyaFF1AbukZ23RgiNEU9I"

echo "======================================"
echo "📱 RESPUESTA DE /fotos-progreso/hoy"
echo "======================================"
echo ""

curl -s -X GET "$API_URL/fotos-progreso/hoy" \
  -H "Authorization: Bearer $TOKEN" | jq . 2>/dev/null

echo ""
echo "======================================"
echo "📸 RESPUESTA DE /fotos-progreso (Todas)"
echo "======================================"
echo ""

curl -s -X GET "$API_URL/fotos-progreso" \
  -H "Authorization: Bearer $TOKEN" | jq . 2>/dev/null
