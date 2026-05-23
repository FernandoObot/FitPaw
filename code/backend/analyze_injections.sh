#!/bin/bash

# Array de servicios
services=(
"AchievementEngine"
"AuthService"
"MascotaLogrosService"
"MetaEvaluacionService"
"PetService"
"ProgressService"
"StorageService"
"StreakService"
"TrainingAppService"
"TrainingService"
)

echo "Servicios que NO se inyectan en ningún controlador:"
for service in "${services[@]}"; do
  count=$(grep -r "@Autowired\|private.*$service\|new $service" src/main/java/com/fitpaw/backend/controller --include="*.java" | wc -l)
  if [ $count -eq 0 ]; then
    echo "  - $service"
  fi
done
