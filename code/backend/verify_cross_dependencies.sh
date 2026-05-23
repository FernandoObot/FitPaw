#!/bin/bash

services=(
"AchievementEngine"
"MascotaLogrosService"
"MetaEvaluacionService"
"ProgressService"
"TrainingService"
)

echo "Verificando si estos servicios se usan entre sí o en otros servicios:"
for service in "${services[@]}"; do
  echo -n "$service: "
  count=$(grep -r "import.*$service\|new $service\|@Autowired.*$service\|private.*$service" src/main/java/com/fitpaw/backend --include="*.java" | grep -v "^src/main/java/com/fitpaw/backend/service/$service.java" | wc -l)
  if [ $count -eq 0 ]; then
    echo "NO SE USA"
  else
    echo "Se usa ($count referencias)"
    grep -r "import.*$service\|new $service\|@Autowired.*$service\|private.*$service" src/main/java/com/fitpaw/backend --include="*.java" | grep -v "^src/main/java/com/fitpaw/backend/service/$service.java" | head -3
  fi
done
