# FitPaw - Conexión Backend-Frontend

## Estado Actual ✅

### Backend
- **Status**: ✅ CORRIENDO en `http://localhost:8080`
- **Tecnología**: Spring Boot Java
- **Base de datos**: PostgreSQL en Supabase
- **Autenticación**: JWT con SecurityConfig

### Frontend
- **Status**: ✅ DEPENDENCIAS INSTALADAS
- **Tecnología**: Flutter (Dart)
- **Servicios HTTP**: ✅ CREADOS

---

## Servicios HTTP Creados

### 1. `ApiClient` (lib/services/api_client.dart)
Cliente HTTP centralizado que:
- Gestiona base URL (`http://localhost:8080`)
- Maneja headers (Content-Type, JWT)
- Guarda/carga tokens en Flutter Secure Storage
- Timeout de 30 segundos
- Métodos: `get()`, `post()`, `put()`

### 2. `AuthService` (lib/services/auth_service.dart)
Métodos disponibles:
```dart
// Registrar nuevo usuario
await authService.register(
  nombreUsuario: "Juan",
  email: "juan@example.com",
  contrasena: "password123",
  telefono: "+5512345678"
);

// Login
await authService.login(
  email: "juan@example.com",
  contrasena: "password123"
);

// Logout
await authService.logout();

// Actualizar perfil
await authService.updateProfile(
  nombreUsuario: "Juan Nuevo",
  email: "nuevo@example.com",
  telefono: "+5512345679"
);
```

### 3. `PetService` (lib/services/pet_service.dart)
Métodos disponibles:
```dart
// Obtener estado de mascota
await petService.getPetStatus();

// Alimentar mascota
await petService.feedPet();
```

---

## Cómo Usar en las Pantallas

### Ejemplo en sign_in_screen.dart:
```dart
import 'package:fitpaw/main.dart'; // Importar authService global

class _SignInScreenState extends State<SignInScreen> {
  void _handleLogin(String email, String password) async {
    final result = await authService.login(
      email: email,
      contrasena: password,
    );
    
    if (result['success']) {
      // Navegar a home
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      // Mostrar error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['error']))
      );
    }
  }
}
```

---

## Lo Que Falta

### Inmediato:
1. **Conectar login** - sign_in_screen.dart
2. **Conectar registro** - sign_up_screen.dart  
3. **Conectar mascota** - pet_screen.dart

### Pendiente:
4. Crear `TrainingService` para /training endpoints
5. Crear `ProgressPhotoService` para /progress-photo endpoints
6. Crear `StreakService` para /streak endpoints
7. Manejar errores y loading states en UI
8. Testear con API real

---

## Cómo Testear Endpoints

### Via Curl (desde terminal):

**1. Registrar:**
```bash
curl -X POST http://localhost:8080/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "nombreUsuario": "testuser",
    "email": "test@example.com",
    "contrasena": "Test123!",
    "telefono": "+5512345678"
  }'
```

**2. Login:**
```bash
curl -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "contrasena": "Test123!"
  }'
```

**3. Ver status de mascota (requiere JWT):**
```bash
curl -X GET http://localhost:8080/pet/status \
  -H "Authorization: Bearer {TOKEN_JWT_AQUI}"
```

---

## Próximos Pasos

¿Cuál pantalla quieres que conectemos primero?
1. **Login** (sign_in_screen.dart)
2. **Registro** (sign_up_screen.dart)
3. **Mascota** (pet_screen.dart)
4. **Todas** - Las hago todas de una vez

Dime y continúo!
