#!/bin/bash

models=(
"BitacoraExtra"
"BitacoraFuerza"
"CatalogoItem"
"DeporteExtra"
"Ejercicio"
"FotoProgreso"
"HistorialAntropometrico"
"Inventario"
"Logro"
"MetaUsuario"
"Pet"
"Racha"
"RegistroActividad"
"RutinaPersonalizada"
"User"
)

echo "Modelos NO importados:"
for model in "${models[@]}"; do
  count=$(grep -r "import.*model\.$model\|import.*\.$model" src --include="*.java" | wc -l)
  if [ $count -eq 0 ]; then
    echo "  - $model"
  fi
done
