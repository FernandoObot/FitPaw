#!/bin/bash

dtos=(
"CompletarRutinaRequest"
"CreateEjercicioRequest"
"CumplimientoMetaRequest"
"DailyProgressPhotosResponse"
"EditProfileRequest"
"EjercicioCatalogoResponse"
"EstadisticasResponse"
"FeedRequest"
"LoginRequest"
"OperacionResponse"
"PetStatusResponse"
"PhotoSlotResponse"
"ProgressPhotoResponse"
"RachaResponse"
"RecompensaRachaResponse"
"RegisterRequest"
"RegisterResponse"
"RegistrarDeporteExtraRequest"
"RegistrarSerieRequest"
"RegistroCorrerRequest"
"RegistroCorrerResponse"
"RutinaCompletadaResponse"
"SentadillasPlanRequest"
"SentadillasPlanResponse"
"SerieFuerzaResponse"
"TokenResponse"
"UpdateEjercicioRequest"
"UpdateProfileRequest"
)

echo "DTOs NO importados:"
for dto in "${dtos[@]}"; do
  count=$(grep -r "import.*DTOs\.$dto\|import.*\.$dto" src --include="*.java" | wc -l)
  if [ $count -eq 0 ]; then
    echo "  - $dto"
  fi
done
