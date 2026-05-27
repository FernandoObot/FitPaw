# 🎮 Sistema de Mascota FitPaw - Implementación Completa

## ✅ CAMBIOS REALIZADOS

### Backend (Spring Boot)

**1. AuthService - Creación automática de mascota al registrarse**
- Cuando un usuario se registra, se crea automáticamente:
  - Nombre: "Pingui"
  - Hambre inicial: 100
  - Última alimentación: hoy
  - Nivel: 1
  - Experiencia: 0
- Archivo: `AuthService.java` → método `crearMascotaDefault()`

**2. PetService - Nuevo método para obtener comidas**
- Método: `getPetFoods(int usuarioId)`
- Devuelve lista de comidas disponibles desde `mascota_alimento`
- Archivo: `PetService.java` (línea 196+)

**3. PetController - Nuevo endpoint GET**
```
GET /pet/foods
Headers: Authorization: Bearer <token>
Response: List<PetFoodResponse>
  - nombreComida: String
  - cantidad: Integer
  - beneficioPuntos: Integer
```

**4. StreakRewardService - Logging mejorado**
- Agregado debugging para rastrear:
  - Obtención de mascota_id
  - Intentos de otorgar comida
  - Inserciones/actualizaciones exitosas
- Archivo: `StreakRewardService.java`

### Frontend (Flutter)

**1. ApiClient - Nuevos métodos para mascota**
```dart
getPetStatus()      → obtiene estado actual de mascota
getPetFoods()       → obtiene inventario de comidas
feedPet(itemName)   → alimenta la mascota y actualiza BD
```

**2. PetScreen - Conexión con backend en tiempo real**
- `initState()` ahora carga datos del backend en lugar de simulación
- Hambre se calcula dinámicamente: `_foodLevel = _petStatus['hambre']`
- Barra de progreso de "Comida" se actualiza automáticamente
- Al alimentar mascota:
  1. Se llama POST /pet/feed
  2. Se actualiza estado local con respuesta
  3. Se recargan comidas disponibles
  4. Se muestran animaciones

**3. Eliminada simulación con timers**
- Removidos timers que simulaban cambios de hambre
- Ahora todo es en tiempo real desde la BD

## 🧪 CÓMO PROBAR

### Paso 1: Compilar el backend
```bash
cd code/backend
mvn clean package -DskipTests
java -jar target/backend-0.0.1-SNAPSHOT.jar
```
Debería ver en console:
```
✅ Mascota creada para usuario <id>
```

### Paso 2: Ejecutar el frontend
```bash
cd code/frontend/frotendWa
flutter run -d chrome  # o tu device
```

### Paso 3: Registrarse con nuevo usuario
- En la app, crea una cuenta nueva
- Se debe crear automáticamente la mascota "Pingui"

### Paso 4: Ver mascota
- Navega a la pantalla de mascota
- Deberías ver:
  - Nombre: "Pingui" (editable)
  - Barra de hambre: 100/100 inicialmente
  - Menú de comida: Cargando items desde BD

### Paso 5: Alimentar mascota
1. Toca el botón de comida (icono de tenedor)
2. Se abre menú con comidas disponibles
3. Al alimentar:
   - Hambre aumenta (reduce valor de hambre en BD)
   - Cantidad de comida disminuye
   - Mascota muestra animación feliz + mensaje

### Paso 6: Integración con recompensas
- Al completar ejercicios:
  - Se llena tabla `usuarios_racha` ✅
  - Se llena tabla `mascota_alimento` con comidas:
    - Calamar (x1) - primer ejercicio del día
    - Krill (x1) - cada ejercicio
    - Pez (x2) - cuando completan 4 ejercicios específicos
    - Coctel (x1) - cada 5 días de racha

## 🔍 DEBUGGING

### Si la mascota no carga:
1. Revisa logs del backend:
   ```
   ❌ No se encontró mascota para usuario <id>
   ```
   Significa que `mascota_estado` no tiene registro para ese usuario.
   
   Solución: Asegúrate que al registrarse se crea la mascota.

### Si la barra de hambre no actualiza:
1. Verifica respuesta de `/pet/status`:
   ```bash
   curl -H "Authorization: Bearer <token>" \
     http://localhost:8080/pet/status
   ```
   Debe retornar con campo `hambre`

### Si alimentar no funciona:
1. Revisa logs del backend para:
   ```
   ✅ Mascota encontrada para usuario X: mascota_id=Y
   🍽️ Intentando otorgar: 1x <comida> a usuario X
   ✅ Nuevo alimento insertado: <comida> x<cant>
   ```

## 📊 FLUJO COMPLETO

```
Usuario se registra
    ↓
AuthService crea mascota_estado (Pingui, hambre=100)
    ↓
Usuario ve pantalla de mascota
    ↓
PetScreen carga: getPetStatus() + getPetFoods()
    ↓
Muestra barra de hambre y comidas disponibles
    ↓
Usuario alimenta mascota → feedPet(nombre)
    ↓
Backend: actualiza mascota_estado.hambre
Backend: decrementa mascota_alimento.cantidad
    ↓
Frontend recibe respuesta con nuevo hambre
    ↓
Recarga comidas y actualiza UI
```

## ⚙️ CONFIGURACIÓN BD REQUERIDA

Asegúrate que existe la tabla `mascota_alimento`:
```sql
CREATE TABLE mascota_alimento (
  alimento_id SERIAL PRIMARY KEY,
  mascota_id INTEGER NOT NULL,
  nombre_comida VARCHAR(100),
  cantidad INTEGER DEFAULT 0,
  beneficio_puntos INTEGER,
  FOREIGN KEY (mascota_id) REFERENCES mascota_estado(mascota_id)
);
```

## 🐛 CONOCIDOS/TODO

- [x] Mascota se crea al registrarse
- [x] Hambre en tiempo real
- [x] Comidas desde BD
- [x] Animación al alimentar
- [x] Integración con sistema de recompensas
- [ ] Persistencia de datos de ropa (closet) en BD
- [ ] Animaciones mejoradas
- [ ] Sonidos al alimentar
