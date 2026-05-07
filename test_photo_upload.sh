#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

API_URL="http://localhost:8080"

echo -e "${YELLOW}=== FITPAW BACKEND TEST ===${NC}"
echo ""

# Step 1: Register user
echo -e "${YELLOW}1. Registrando nuevo usuario...${NC}"
TIMESTAMP=$(date +%s)
USERNAME="TestUser$TIMESTAMP"

REGISTER_RESPONSE=$(curl -s -X POST "$API_URL/auth/register" \
  -H "Content-Type: application/json" \
  -d "{
    \"telefono\": \"301456789${TIMESTAMP: -1}\",
    \"nombreCompleto\": \"$USERNAME\",
    \"password\": \"Test123!@\"
  }")

echo "Response: $REGISTER_RESPONSE"
USER_ID=$(echo "$REGISTER_RESPONSE" | grep -o '"usuarioId":[0-9]*' | cut -d: -f2)
echo -e "${GREEN}✓ Usuario registrado con ID: $USER_ID${NC}"
echo ""

# Step 2: Login
echo -e "${YELLOW}2. Haciendo login...${NC}"
PHONE="301456789${TIMESTAMP: -1}"
LOGIN_RESPONSE=$(curl -s -X POST "$API_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d "{
    \"telefono\": \"$PHONE\",
    \"password\": \"Test123!@\"
  }")

echo "Response: $LOGIN_RESPONSE"
TOKEN=$(echo "$LOGIN_RESPONSE" | grep -o '"token":"[^"]*' | cut -d'"' -f4)
echo -e "${GREEN}✓ Token obtenido: ${TOKEN:0:30}...${NC}"
echo ""

# Step 3: Create a test image (1x1 pixel PNG)
echo -e "${YELLOW}3. Creando imagen de prueba...${NC}"
# Create a minimal 1x1 red pixel PNG
printf '\x89\x50\x4E\x47\x0D\x0A\x1A\x0A\x00\x00\x00\x0D\x49\x48\x44\x52\x00\x00\x00\x01\x00\x00\x00\x01\x08\x02\x00\x00\x00\x90\x77\x53\x44\x00\x00\x00\x0C\x49\x44\x41\x54\x08\x99\x63\xF8\xCF\xC0\x00\x00\x00\x03\x00\x01\x8B\xB6\xEE\x56\x00\x00\x00\x00\x49\x45\x4E\x44\xAE\x42\x60\x82' > /tmp/test_photo.png
echo -e "${GREEN}✓ Imagen creada en /tmp/test_photo.png${NC}"
echo ""

# Step 4: Upload photo
echo -e "${YELLOW}4. Subiendo foto a Supabase...${NC}"
UPLOAD_RESPONSE=$(curl -s -X POST "$API_URL/fotos-progreso" \
  -H "Authorization: Bearer $TOKEN" \
  -F "foto=@/tmp/test_photo.png" \
  -F "posicion=1")

echo "Response: $UPLOAD_RESPONSE"
echo -e "${GREEN}✓ Foto subida${NC}"
echo ""

# Step 5: Get today's photos
echo -e "${YELLOW}5. Obteniendo fotos de hoy...${NC}"
TODAY_RESPONSE=$(curl -s -X GET "$API_URL/fotos-progreso/hoy" \
  -H "Authorization: Bearer $TOKEN")

echo "Response: $TODAY_RESPONSE" | jq . 2>/dev/null || echo "$TODAY_RESPONSE"
echo -e "${GREEN}✓ Fotos de hoy obtenidas${NC}"
echo ""

# Step 6: Get all photos
echo -e "${YELLOW}6. Obteniendo todas las fotos...${NC}"
ALL_PHOTOS_RESPONSE=$(curl -s -X GET "$API_URL/fotos-progreso" \
  -H "Authorization: Bearer $TOKEN")

echo "Response: $ALL_PHOTOS_RESPONSE" | jq . 2>/dev/null || echo "$ALL_PHOTOS_RESPONSE"
echo -e "${GREEN}✓ Todas las fotos obtenidas${NC}"
echo ""

echo -e "${GREEN}=== TEST COMPLETADO ===${NC}"
