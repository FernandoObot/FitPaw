#!/bin/bash

# Array de archivos a verificar
files=(
  "AchievementEngine"
  "BitacoraExtra"
  "BitacoraFuerza"
  "CatalogoItem"
  "ConexionDB"
  "DeporteExtra"
  "EditProfileRequest"
  "Ejercicio"
  "EstadisticasResponse"
  "FeedRequest"
  "FotoProgreso"
  "HistorialAntropometrico"
  "Inventario"
  "Logro"
  "MetaEvaluacionService"
  "MetaUsuario"
  "Pet"
  "Racha"
  "RegistroActividad"
  "RutinaPersonalizada"
)

echo "Archivos no usados:"
for file in "${files[@]}"; do
  count=$(grep -r "import.*$file;" src --include="*.java" 2>/dev/null | grep -v "^src/main/java/com/fitpaw/backend/DTOs/$file.java" | grep -v "^src/main/java/com/fitpaw/backend/model/$file.java" | wc -l)
  if [ $count -eq 0 ]; then
    echo "- $file"
  fi
done
