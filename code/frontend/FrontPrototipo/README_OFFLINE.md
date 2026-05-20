# 🚀 FitPaw - MODO OFFLINE (Sin conexión Backend)

> **Copia exacta de frotendWa pero SIN validación con backend. Todo funciona localmente.**

## 📱 ¿Qué es esto?

Esta es una versión de **FitPaw que funciona completamente sin backend**. Es idéntica visualmente a la versión original, pero:

✅ **NO requiere servidor corriendo**
✅ **NO requiere base de datos**
✅ **Todos los datos se guardan localmente** en la sesión
✅ **Todas las vistas y funcionalidades funcionan normalmente**
✅ **Los ejercicios aparecen marcados como completados**

## 🎯 Cómo usar

### Opción 1: Web (Recomendado para desarrollo rápido)

```bash
cd code/frontend/FrontPrototipo
flutter pub get
flutter run -d web-server --web-hostname 127.0.0.1 --web-port 8085
```

Luego abre: **http://127.0.0.1:8085**

### Opción 2: Android/iOS

```bash
flutter pub get
flutter run
```

## 👤 Usuarios de Prueba

Puedes crear cualquier usuario. No hay validación de backend:

**Ejemplo:**
- Teléfono: `3001234567`
- Contraseña: `password123`

**Simplemente registra e inicia sesión.** Funcionará sin problemas.

## ✨ Funcionalidades Disponibles

### Autenticación
- ✅ Crear cuenta
- ✅ Iniciar sesión
- ✅ Cerrar sesión

### Vistas
- ✅ Onboarding (Bienvenida)
- ✅ Auth Gateway
- ✅ Home Dashboard
- ✅ Seleccionar rutina de ejercicio
- ✅ Perfil del usuario
- ✅ Perfil de configuración
- ✅ Historial de actividades
- ✅ Notificaciones

### Ejercicios (Todos con vistas detalladas)
- ✅ Sentadillas
- ✅ Press de hombros
- ✅ Flexión de una pierna
- ✅ Carrera
- ✅ Cámara (para tomar fotos)
- ✅ Vista de respuestas

### Mascota Tamagotchi
- ✅ Ver estado de la mascota
- ✅ Alimentar mascota
- ✅ Progreso visual

### Datos Persistentes (En la sesión)
- ✅ Planes de ejercicio guardados
- ✅ Ejercicios marcados como completados
- ✅ Estado de la mascota actualizado
- ✅ Información del usuario

## 📂 Estructura

```
FrontPrototipo/
├── lib/
│   ├── main.dart                      # Punto de entrada
│   ├── core/                          # Configuración (colores, temas)
│   ├── services/                      # Servicios
│   │   ├── api_client.dart           # ⭐ Cliente mock sin HTTP
│   │   ├── auth_service.dart         # Autenticación
│   │   ├── pet_service.dart          # Mascota
│   │   └── workout_schedule_service.dart  # Entrenamientos
│   └── ui/
│       ├── screens/                   # 24 pantallas diferentes
│       └── widgets/                   # Componentes reutilizables
├── assets/                            # Imágenes y recursos
├── android/                           # Código Android nativo
├── ios/                               # Código iOS nativo
├── web/                               # Versión web
└── ...otros directorios...
```

## 🔄 Cambios Realizados

### api_client.dart
- ❌ Removida conexión a `http://127.0.0.1:8080`
- ✅ Agregado cliente mock que simula respuestas HTTP
- ✅ Mantiene los mismos métodos: `post()`, `get()`, `put()`

### Servicios
- ✅ Todos funcionan sin cambios
- ✅ Reciben respuestas mock automáticamente

### Flujos completos funcionales:
1. Registro → Login → Dashboard
2. Seleccionar ejercicio → Ver detalles → Marcar como completado
3. Ver mascota → Alimentar → Estado actualizado
4. Editar perfil → Guardar cambios → Datos preservados

## 💡 Ejemplo de Flujo

```
Usuario abre la app
    ↓
Ve pantalla de onboarding
    ↓
Toca "Crear cuenta"
    ↓
Rellena formulario (cualquier datos)
    ↓
Presiona registrarse
    ↓ (SIN llamar al backend)
Auto-login y entrada a dashboard
    ↓
Selecciona rutina de ejercicio
    ↓
Ve detalles del ejercicio
    ↓
Marca como completado
    ↓ (Dato guardado en memoria)
Vuelve atrás
    ↓
Ejercicio aparece marcado como ✅ completado
```

## ⚠️ Notas Importantes

### Datos Temporales
Los datos se pierden cuando cierras la app (se guardan en memoria, no en disco).

### Sin HTTP
No hay llamadas HTTP reales. Todo es simulado localmente.

### Para Convertir a Backend
Si luego quieres agregar el backend real:

1. Detener la app
2. Cambiar `api_client.dart` para hacer llamadas HTTP reales
3. Cambiar la URL del servidor
4. Listo

Vdeoguía: Ver `MIGRATION_GUIDE.md` en la carpeta raíz.

## 🎮 Características Adicionales

### Tamagotchi Mascota
La mascota tiene un estado:
- **Energía**: Sube después de entrenamientos
- **Salud**: Mejora con ejercicio regular
- **Felicidad**: Aumenta cuando alimentas la mascota
- **Hambre**: Disminuye cuando alimentas
- **Nivel**: Sube con actividades completadas

### Sistema de Progreso
- Ejercicios completados se marcan con ✅
- Historiales se guardan (en esta sesión)
- Estadísticas se pueden ver

### Interfaz Completa
24 pantallas diferentes con navegación fluida entre ellas.

## 🚀 Próximos Pasos

### Si quieres agregar persistencia (guardar datos al cerrar)
1. Usa `shared_preferences` para almacenamiento simple
2. O `sqflite` para base de datos local
3. Modifica `LocalDataService` para guardar/cargar datos

### Si quieres conectar con backend
1. Lee `MIGRATION_GUIDE.md`
2. Cambia `api_client.dart` para HTTP real
3. Inicia tu servidor backend
4. Actualiza URLs

## 📸 Pantallas Incluidas

| # | Pantalla | Función |
|----|----------|---------|
| 1 | Splash | Pantalla de carga |
| 2 | Onboarding | Bienvenida |
| 3 | Sign In | Iniciar sesión |
| 4 | Sign Up | Crear cuenta |
| 5 | Auth Gateway | Selección auth |
| 6 | Home Dashboard | Dashboard principal |
| 7 | Routine Selection | Elegir ejercicio |
| 8 | Profile Setup | Configurar perfil |
| 9 | Profile | Ver perfil |
| 10 | Goal Picker | Elegir objetivo |
| 11 | Sentadillas | Detalles sentadillas |
| 12 | Press Hombros | Detalles press |
| 13 | Flexión Una Pierna | Detalles flexión |
| 14 | Running | Detalles carrera |
| 15 | Exercise Detail | Detalles generales |
| 16 | Camera | Cámara |
| 17 | View Responses | Ver respuestas |
| 18 | Activity History | Historial |
| 19 | Notifications | Notificaciones |
| 20 | Progress | Progreso |
| 21 | Pet | Estado mascota |
| 22 | Streak Days | Racha de días |
| 23 | Training Schedule | Horarios |
| 24 | Front Home Stub | Home stub |

## ❓ Preguntas Frecuentes

**P: ¿Por qué no conecta al backend?**
R: Por diseño. Es OFFLINE. Todos los datos son locales.

**P: ¿Se guardan los datos?**
R: Solo en esta sesión. Si cierras y abres la app, los datos se pierden.

**P: ¿Qué pasa si quiero el backend después?**
R: Cambias `api_client.dart` a HTTP real. Ver `MIGRATION_GUIDE.md`.

**P: ¿Funciona en Android/iOS?**
R: ✅ Sí. Tienes las carpetas `android/`, `ios/`, `windows/`, `linux/`, `macos/`.

**P: ¿Puedo modificar el código?**
R: ✅ Claro. Es un proyecto Flutter normal.

---

**Creado**: 19 de mayo de 2026  
**Tipo**: Prototipo Offline / Demo  
**Versión**: 1.0.0  
**Status**: ✅ Fully Functional
