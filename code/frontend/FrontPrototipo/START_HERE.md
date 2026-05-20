# 📖 GUÍA RÁPIDA - FitPaw Offline

## ✅ Qué Ya Está Hecho

✨ Copia exacta de **frotendWa** pero **SIN conexión a backend**

```
FrontPrototipo/
├── ✅ Carpetas de Android, iOS, Web (igual que frotendWa)
├── ✅ Todas las 24 pantallas (sin cambios)
├── ✅ Assets e imágenes (igual)
├── ✅ Servicios funcionando (sin HTTP)
└── ✅ Todo listo para usar
```

---

## 🚀 PASO 1: Ejecutar en Web (Más Rápido)

Abre terminal y ejecuta:

```bash
cd code/frontend/FrontPrototipo
flutter pub get
flutter run -d web-server --web-hostname 127.0.0.1 --web-port 8086
```

Luego abre en navegador:
**http://127.0.0.1:8086**

---

## 🚀 PASO 2: O Ejecutar Script

Si usas Linux/Mac:

```bash
cd code/frontend/FrontPrototipo
./run.sh
# Selecciona opción [1] para Web
```

---

## 🎮 PASO 3: Usar la App

### Crear usuario:
1. Ve a "Crear Cuenta"
2. Rellena cualquier información:
   - Nombre: `Juan`
   - Teléfono: `3001234567`
   - Contraseña: `password123`
3. Presiona "Registrarse"
4. **¡Entra automáticamente al dashboard!**

### Usar ejercicios:
1. Ve a "Seleccionar Rutina"
2. Selecciona un ejercicio (ej: Sentadillas)
3. Configura:
   - Día: Lunes
   - Hora: 08:00 AM
   - Dificultad: Media
   - Peso: 50 kg
4. Presiona "Guardar"
5. Marca como completado ✅
6. **El ejercicio aparece completado**

### Ver mascota:
1. Ve a "Mascota"
2. Ves su estado (nivel, energía, hambre)
3. Presiona "Alimentar"
4. **Hambre disminuye, felicidad sube** 🎉

---

## ⚙️ Qué Cambió (Técnico)

### Archivo Principal Modificado: `api_client.dart`

**Antes** (HTTP real):
```dart
import 'package:http/http.dart' as http;

Future<http.Response> post(...) {
  return http.post(Uri.parse('http://127.0.0.1:8080$endpoint'), ...);
}
```

**Ahora** (Offline):
```dart
class MockHttpResponse {
  final int statusCode;
  final String body;
}

Future<MockHttpResponse> post(...) {
  return MockHttpResponse(statusCode: 201, body: jsonEncode({...}));
}
```

### Otros Servicios:
- ✅ **Sin cambios**
- ✅ Funcionan igual con `MockHttpResponse`

---

## 💡 Puntos Clave

| Aspecto | Estado |
|--------|--------|
| ¿Pide conexión al backend? | ❌ No |
| ¿Se guardan datos? | ✅ En la sesión |
| ¿Todas las vistas? | ✅ 24 pantallas |
| ¿Android/iOS incluido? | ✅ Sí |
| ¿Necesito servidor? | ❌ No |
| ¿Necesito base de datos? | ❌ No |

---

## 📱 Para Hacer APK/IPA Después

### APK (Android):
```bash
flutter build apk --release
# APK en: build/app/outputs/flutter-apk/app-release.apk
```

### IPA (iOS):
```bash
flutter build ios --release
# Usar Xcode para distribuir
```

### Windows/Linux/macOS:
```bash
flutter build windows
flutter build linux
flutter build macos
```

---

## 🔄 Si Quieres Agregar Backend Después

Ver archivo: **MIGRATION_GUIDE.md** (en la raíz del proyecto)

Resumen rápido:
1. Cambiar `api_client.dart` a HTTP real
2. Cambiar URL: `http://127.0.0.1:8080`
3. Iniciar servidor Spring Boot
4. Listo

---

## 📁 Documentación Disponible

Abre cualquiera de estos archivos:

- **RESUMEN_EJECUTIVO.md** ← Resumen general
- **README_OFFLINE.md** ← Guía completa
- **CHANGELOG.md** ← Cambios técnicos
- **MIGRATION_GUIDE.md** ← Cómo agregar backend

---

## ✨ Ejemplo de Uso Completo

```
[Abres la app]
          ↓
[Ves pantalla de bienvenida]
          ↓
[Toca "Crear Cuenta"]
          ↓
[Rellena: Juan, 3001234567, password123]
          ↓
[Toca "Registrar"] ← SIN conectar a backend ✨
          ↓
[Entra a Dashboard automáticamente]
          ↓
[Selecciona "Sentadillas"]
          ↓
[Configura plan: Lunes, 8 AM, Media dificultad]
          ↓
[Presiona "Guardar"] ← Guardado en memoria ✨
          ↓
[Marca como completado ✅]
          ↓
[Ejercicio aparece completado en el listado]
          ↓
[Cierra la app]
          ↓
[Abre de nuevo]
          ↓
[Registrase nuevamente (datos se limpian)]
```

---

## 🎯 AHORA:

1. **Terminal**:
   ```bash
   cd code/frontend/FrontPrototipo
   flutter run -d web-server --web-hostname 127.0.0.1 --web-port 8086
   ```

2. **Navegador**:
   ```
   http://127.0.0.1:8086
   ```

3. **Registrate** y **¡usa la app!** 🎉

---

## ❓ Si Algo No Funciona

```bash
# Limpia caché
flutter clean

# Obtén dependencias de nuevo
flutter pub get

# Intenta ejecutar de nuevo
flutter run -d web-server --web-hostname 127.0.0.1 --web-port 8086
```

---

## 📝 Resumen Final

✅ **Tienes una copia exacta de frotendWa**
✅ **Funciona sin backend**
✅ **Ejercicios se marcan completados**
✅ **Mascota funciona**
✅ **Todo en Android/iOS/Web**
✅ **Listo para usar ahora mismo**

**¡A disfrutar! 🚀**

---

**Versión**: 1.0.0-OFFLINE  
**Status**: ✅ Listo  
**Modo**: Demo/Prototipo sin backend
