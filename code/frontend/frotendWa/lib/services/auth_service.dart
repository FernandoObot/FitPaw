import 'dart:convert';
import 'api_client.dart';

class AuthService {
  final ApiClient apiClient;

  AuthService(this.apiClient);

  Future<Map<String, dynamic>> register({
    required String nombreCompleto,
    required String telefono,
    required String password,
  }) async {
    try {
      final response = await apiClient.post(
        '/auth/register',
        body: {
          'nombreCompleto': nombreCompleto,
          'telefono': telefono,
          'password': password,
        },
        needsAuth: false,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        
        // Guardar token si viene en la respuesta
        if (data.containsKey('token')) {
          await apiClient.saveToken(data['token'] as String);
        }
        
        return {'success': true, 'data': data};
      } else if (response.statusCode == 409) {
        return {'success': false, 'error': 'El usuario ya existe'};
      } else if (response.statusCode == 400) {
        final error = jsonDecode(response.body);
        return {'success': false, 'error': error['mensaje'] ?? 'Error en registro'};
      } else {
        return {'success': false, 'error': 'Error en el registro. Código: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> login({
    required String telefono,
    required String password,
  }) async {
    try {
      final response = await apiClient.post(
        '/auth/login',
        body: {
          'telefono': telefono,
          'password': password,
        },
        needsAuth: false,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        
        // Guardar el token JWT
        if (data.containsKey('token')) {
          await apiClient.saveToken(data['token'] as String);
        }
        
        return {'success': true, 'data': data, 'token': data['token']};
      } else if (response.statusCode == 401) {
        return {'success': false, 'error': 'Credenciales inválidas'};
      } else if (response.statusCode == 400) {
        final error = jsonDecode(response.body);
        return {'success': false, 'error': error['mensaje'] ?? 'Error en login'};
      } else {
        return {'success': false, 'error': 'Error en login. Código: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> logout() async {
    try {
      await apiClient.clearToken();
      return {'success': true};
    } catch (e) {
      return {'success': false, 'error': 'Error al cerrar sesión: $e'};
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    required String genero,
    required DateTime fechaNacimiento,
    required double pesoActual,
    required int estaturaCm,
  }) async {
    try {
      final response = await apiClient.put(
        '/auth/profile',
        body: {
          'genero': genero,
          'fechaNacimiento': fechaNacimiento.year, // Enviar solo el año como integer
          'pesoActual': pesoActual,
          'estaturaCm': estaturaCm,
        },
        needsAuth: true,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return {'success': true, 'data': data};
      } else if (response.statusCode == 400) {
        final error = jsonDecode(response.body);
        return {'success': false, 'error': error['mensaje'] ?? 'Error al actualizar perfil'};
      } else {
        return {'success': false, 'error': 'Error: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await apiClient.get(
        '/auth/profile/me',
        needsAuth: true,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return {'success': true, 'data': data};
      } else if (response.statusCode == 404) {
        return {'success': false, 'error': 'Perfil no encontrado'};
      } else {
        return {'success': false, 'error': 'Error: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> editProfile({
    String? nombreCompleto,
    double? pesoActual,
    int? estaturaCm,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (nombreCompleto != null) body['nombre'] = nombreCompleto;
      if (pesoActual != null) body['peso'] = pesoActual;
      if (estaturaCm != null) body['estatura'] = estaturaCm;

      final response = await apiClient.put(
        '/auth/profile/edit',
        body: body,
        needsAuth: true,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return {'success': true, 'data': data};
      } else if (response.statusCode == 400) {
        final error = jsonDecode(response.body);
        return {'success': false, 'error': error['mensaje'] ?? 'Error al editar perfil'};
      } else {
        return {'success': false, 'error': 'Error: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Error: $e'};
    }
  }

  bool isLoggedIn() {
    return apiClient.getToken() != null;
  }
}
