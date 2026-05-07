#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

API_URL="http://localhost:8080"

echo -e "${YELLOW}=== TEST DE LÍMITE DIARIO DE FOTOS ===${NC}"
echo ""

# Use the same user from previous test
TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJmaXRwYXctYmFja2VuZCIsInN1YiI6IjMwMTQ1Njc4OTAiLCJpYXQiOjE3NzgxMjQ5MTIsImV4cCI6MTc3ODEyODUxMiwidXN1YXJpb0lkIjo1LCJ0ZWxlZm9ubyI6IjMwMTQ1Njc4OTAifQ.eDt-9iazSSZwxiUbN75CoftyaFF1AbukZ23RgiNEU9I"
USUARIO_ID="5"

# Create test images
echo -e "${YELLOW}Creando 3 imágenes de prueba...${NC}"
for i in 1 2 3; do
  printf '\x89\x50\x4E\x47\x0D\x0A\x1A\x0A\x00\x00\x00\x0D\x49\x48\x44\x52\x00\x00\x00\x01\x00\x00\x00\x01\x08\x02\x00\x00\x00\x90\x77\x53\x44\x00\x00\x00\x0C\x49\x44\x41\x54\x08\x99\x63\xF8\xCF\xC0\x00\x00\x00\x03\x00\x01\x8B\xB6\xEE\x56\x00\x00\x00\x00\x49\x45\x4E\x44\xAE\x42\x60\x82' > /tmp/test_photo_$i.png
done
echo -e "${GREEN}✓ Imágenes creadas${NC}"
echo ""

# Upload 2 more photos
for i in 2 3; do
  echo -e "${YELLOW}Subiendo foto $i...${NC}"
  RESPONSE=$(curl -s -X POST "$API_URL/fotos-progreso" \
    -H "Authorization: Bearer $TOKEN" \
    -F "foto=@/tmp/test_photo_$i.png" \
    -F "posicion=$i")
  
  echo "Response: $RESPONSE" | jq .limiteDiario 2>/dev/null && echo -e "${GREEN}✓ Foto $i subida${NC}" || echo -e "${RED}✗ Error en foto $i${NC}"
  echo ""
done

# Try to upload 4th photo (should fail)
echo -e "${YELLOW}Intentando subir foto 4 (debería fallar)...${NC}"
RESPONSE=$(curl -s -X POST "$API_URL/fotos-progreso" \
  -H "Authorization: Bearer $TOKEN" \
  -F "foto=@/tmp/test_photo_1.png")

echo "Response: $RESPONSE"
if echo "$RESPONSE" | grep -q "Solo se permiten"; then
  echo -e "${GREEN}✓ Correctamente rechazada - límite diario de 3 fotos alcanzado${NC}"
else
  echo -e "${RED}✗ Error - debería rechazar la 4ª foto${NC}"
fi
echo ""

# Get final status
echo -e "${YELLOW}Estado final de hoy...${NC}"
FINAL=$(curl -s -X GET "$API_URL/fotos-progreso/hoy" \
  -H "Authorization: Bearer $TOKEN")

echo "$FINAL" | jq '{limiteDiario, subidasHoy, restantesHoy, puedeSubirHoy}'
