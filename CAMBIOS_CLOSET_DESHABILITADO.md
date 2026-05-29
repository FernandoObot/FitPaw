# Cambios Implementados - Closet Deshabilitado

## Resumen
Se implementó el sistema de prendas deshabilitadas en el closet. Ahora:
- ✅ Todas las prendas aparecen en el closet desde el inicio
- ✅ Las prendas están **deshabilitadas (bloqueadas)** hasta que se desbloqueen
- ✅ Al iniciar sesión, la mascota **no tiene ropa puesta**

---

## Cambios Realizados

### 1. **Base de Datos**
**Archivo**: `ALTER_TABLE_mascota_ropa.sql`

Se agregó un nuevo campo `esta_desbloqueada` a la tabla `mascota_ropa`:

```sql
ALTER TABLE public.mascota_ropa 
ADD COLUMN esta_desbloqueada boolean DEFAULT false;
```

**Acciones necesarias**:
- Ejecutar este script en la base de datos PostgreSQL
- Todas las prendas existentes se establecerán como `false` (deshabilitadas)

---

### 2. **Backend - Java**

#### Archivo: `AuthService.java`

Se agregó el método `crearRopaDefault()` que:
- Crea 5 prendas (Conjunto 1 al 5) cuando se registra un nuevo usuario
- Todas se crean con `esta_desbloqueada = false` (deshabilitadas)
- Todas se crean con `esta_equipado = false` (no equipadas)

Cambios:
```java
// En crearMascotaDefault() - se agregó la línea:
crearRopaDefault(conn, mascotaId);

// Nuevo método:
private void crearRopaDefault(Connection conn, int mascotaId) throws SQLException {
    // Crea 5 prendas deshabilitadas para la mascota
}
```

#### Archivo: `PetService.java`

Se modificó el método `getPetClothing()` para incluir el nuevo campo:

```java
String sqlClothing = "SELECT ropa_id, nombre_ropa, esta_equipado, 
                      COALESCE(esta_desbloqueada, false) as esta_desbloqueada 
                      FROM public.mascota_ropa WHERE mascota_id = ? ORDER BY ropa_id";

// Se agregó al mapa de respuesta:
item.put("estaDesbloqueada", rs.getBoolean("esta_desbloqueada"));
```

**Beneficios**:
- Usa `COALESCE` para compatibilidad con prendas antiguas
- Devuelve el estado de desbloqueada en la API

---

### 3. **Frontend - Flutter/Dart**

#### Archivo: `pet_screen.dart`

Se modificó el widget `_ClosetSheet` para usar el estado de desbloqueada:

**Antes**:
```dart
final bool isLocked = false;  // Todas desbloqueadas
```

**Después**:
```dart
final bool isLocked = !(clothingItem['estaDesbloqueada'] as bool? ?? false);
```

**Resultados**:
- Las prendas se muestran deshabilitadas visualmente (overlay blanco)
- Al tocar una prenda deshabilitada, se muestra: "Obten esta recompensa realizando tus metas"
- Solo las prendas desbloqueadas (`estaDesbloqueada = true`) pueden equiparse

---

## Lógica de Desbloqueada

### Estado Inicial
- **Nueva mascota**: Todas las 5 prendas se crean con `esta_desbloqueada = false`
- **Sin ropa puesta**: `esta_equipado = false` (la mascota aparece sin ropa)

### Desbloqueo
Para desbloquear prendas, el backend debe ejecutar (cuando corresponda):

```sql
UPDATE public.mascota_ropa 
SET esta_desbloqueada = true 
WHERE mascota_id = ? AND ropa_id = ?;
```

Esto puede hacerse como recompensa por:
- Completar rutinas de ejercicio
- Alcanzar rachas de días
- Logros del usuario
- Progreso en actividades

---

## Pasos para Implementar

### 1. Ejecutar el Script SQL
```bash
psql -U [usuario] -d [basedatos] -f ALTER_TABLE_mascota_ropa.sql
```

### 2. Recompilar el Backend
```bash
cd code/backend
mvn clean package -DskipTests
```

### 3. Reiniciar el Backend
- Detener el servidor actual
- Iniciar con la nueva versión compilada

### 4. Frontend (Sin cambios requeridos)
- El APK/IPA ya incluye los cambios
- O recompilar si se prefiere:
```bash
cd code/frontend/frotendWa
flutter clean
flutter pub get
flutter build [platform]
```

---

## Verificación

### En el Backend (logs)
```
[ROPA] Iniciando creación para mascota 1
  ✅ [ROPA] Conjunto 1: 1 filas
  ✅ [ROPA] Conjunto 2: 1 filas
  ...
✅ [ROPA] Todas las prendas creadas para mascota 1
```

### En el Frontend
1. Registrarse con nuevo usuario
2. Abrir el closet (pantalla de mascota)
3. Ver todas las 5 prendas deshabilitadas (con overlay blanco)
4. Tocar una prenda deshabilitada → muestra mensaje de recompensa

---

## Notas Técnicas

- **Compatibilidad**: El `COALESCE` en SQL garantiza que prendas antiguas se traten como deshabilitadas
- **Escalabilidad**: Fácil de agregar más prendas modificando el array en `crearRopaDefault()`
- **Persistencia**: El estado se guarda en la base de datos, no en caché del cliente
- **Performance**: Una consulta única devuelve todas las prendas con sus estados

---

## Próximos Pasos (Recomendados)

Para mejorar la experiencia:
1. **Crear API de desbloqueo**: `PATCH /pet/clothing/{ropaId}/unlock`
2. **Agregar animación**: Mostrar efecto cuando se desbloquea una prenda
3. **Notificaciones**: Alertar al usuario cuando desbloquee ropa nueva
4. **Logros**: Crear hitos basados en prendas desbloqueadas
