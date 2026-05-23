#!/bin/bash

# Lista completa de todas las clases (solo nombres)
declare -a classes=(
"AchievementEngine"
"AuthController"
"AuthService"
"BackendApplication"
"BackendApplicationTests"
"BitacoraExtra"
"BitacoraFuerza"
"CatalogoItem"
"CompletarRutinaRequest"
"ConexionDB"
"ConexionDBIntegrationTest"
"CorrerDistanciaIntegrationTest"
"CreateEjercicioRequest"
"CumplimientoMetaRequest"
"DailyProgressPhotosResponse"
"DeporteExtra"
"EditProfileRequest"
"EjercicioCatalogoResponse"
"Ejercicio"
"EstadisticasResponse"
"FeedRequest"
"FotoProgreso"
"HistorialAntropometrico"
"Inventario"
"JwtAuthenticationFilter"
"JwtUtil"
"LoginRequest"
"Logro"
"MascotaLogrosService"
"MascotaLogrosServiceIntegrationTest"
"MetaEvaluacionService"
"MetaUsuario"
"OperacionResponse"
"Pet"
"PetController"
"PetService"
"PetStatusResponse"
"PhotoSlotResponse"
"ProgressPhotoController"
"ProgressPhotoResponse"
"ProgressService"
"Racha"
"RachaResponse"
"RecompensaRachaResponse"
"RegisterRequest"
"RegisterResponse"
"RegistrarDeporteExtraRequest"
"RegistrarSerieRequest"
"RegistroActividad"
"RegistroCorrerRequest"
"RegistroCorrerResponse"
"RutinaCompletadaResponse"
"RutinaPersonalizada"
"SecurityConfig"
"SentadillasPlanRequest"
"SentadillasPlanResponse"
"SerieFuerzaResponse"
"StorageService"
"StreakController"
"StreakService"
"SupabaseSimpleSeedIntegrationTest"
"TestController"
"TokenResponse"
"TrainingAppService"
"TrainingController"
"TrainingService"
"TrainingServiceTest"
"UpdateEjercicioRequest"
"UpdateProfileRequest"
"User"
)

echo "Archivos NO importados en ningún lado (candidatos a eliminar):"
for class in "${classes[@]}"; do
  # Buscar imports del archivo (excluyendo el archivo mismo)
  count=$(grep -r "import.*$class" src --include="*.java" | grep -v "src/main/java/com/fitpaw/backend" | grep -v "$class\.java:" | wc -l)
  
  # También buscar en clases dentro del proyecto
  count2=$(grep -r "import com.fitpaw.backend.*$class" src --include="*.java" | wc -l)
  
  total=$((count + count2))
  
  if [ $total -eq 0 ]; then
    echo "  - $class"
  fi
done
