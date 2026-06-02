import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  static final String baseUrl = _getBaseUrl();
  static const String _tokenKey = 'jwt_token';

  static String _getBaseUrl() {
    const configuredUrl = String.fromEnvironment('API_BASE_URL');
    if (configuredUrl.isNotEmpty) {
      return configuredUrl;
    }

    return kIsWeb ? 'http://127.0.0.1:8080' : 'http://10.0.2.2:8080';
  }

  static final ApiClient _instance = ApiClient._internal();
  static String? _staticToken; // Token compartido globalmente

  factory ApiClient() {
    return _instance;
  }

  ApiClient._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  String? _token;

  Future<void> loadToken() async {
    // Primero intentar cargar del token estático
    if (_staticToken != null) {
      _token = _staticToken;
      return;
    }

    // Intentar cargar de FlutterSecureStorage
    try {
      _token = await _secureStorage.read(key: _tokenKey);
      if (_token != null) {
        _staticToken = _token; // Guardar en cache estático
      }
    } catch (e) {
      debugPrint('Error al cargar token: $e');
    }
  }

  Future<void> saveToken(String token) async {
    _token = token;
    _staticToken = token; // Guardar en cache estático
    try {
      await _secureStorage.write(key: _tokenKey, value: token);
    } catch (e) {
      debugPrint('No se pudo guardar token: $e');
    }
  }

  Future<void> clearToken() async {
    _token = null;
    _staticToken = null;
    try {
      await _secureStorage.delete(key: _tokenKey);
    } catch (e) {
      debugPrint('Error al limpiar token: $e');
    }
  }

  String? getToken() {
    if (_token != null) return _token;
    if (_staticToken != null) return _staticToken;
    return null;
  }

  Map<String, String> _getHeaders({bool needsAuth = true}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final token = getToken();
    if (needsAuth && token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  Future<http.Response> post(
    String endpoint, {
    required Map<String, dynamic> body,
    bool needsAuth = false,
  }) async {
    try {
      // Asegurar que el token esté cargado si se necesita autenticación
      if (needsAuth && _token == null) {
        await loadToken();
      }

      final response = await http
          .post(
            Uri.parse('$baseUrl$endpoint'),
            headers: _getHeaders(needsAuth: needsAuth),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));

      return response;
    } catch (e) {
      throw Exception('Error en POST $endpoint: $e');
    }
  }

  Future<http.Response> get(String endpoint, {bool needsAuth = true}) async {
    try {
      // Asegurar que el token esté cargado
      if (needsAuth && _token == null) {
        await loadToken();
      }

      final response = await http
          .get(
            Uri.parse('$baseUrl$endpoint'),
            headers: _getHeaders(needsAuth: needsAuth),
          )
          .timeout(const Duration(seconds: 30));

      return response;
    } catch (e) {
      throw Exception('Error en GET $endpoint: $e');
    }
  }

  Future<http.Response> put(
    String endpoint, {
    required Map<String, dynamic> body,
    bool needsAuth = true,
  }) async {
    try {
      // Asegurar que el token esté cargado
      if (needsAuth && _token == null) {
        await loadToken();
      }

      final response = await http
          .put(
            Uri.parse('$baseUrl$endpoint'),
            headers: _getHeaders(needsAuth: needsAuth),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));

      return response;
    } catch (e) {
      throw Exception('Error en PUT $endpoint: $e');
    }
  }

  Future<http.Response> patch(
    String endpoint, {
    required Map<String, dynamic> body,
    bool needsAuth = true,
  }) async {
    try {
      // Asegurar que el token esté cargado
      if (needsAuth && _token == null) {
        await loadToken();
      }

      final response = await http
          .patch(
            Uri.parse('$baseUrl$endpoint'),
            headers: _getHeaders(needsAuth: needsAuth),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));

      return response;
    } catch (e) {
      throw Exception('Error en PATCH $endpoint: $e');
    }
  }

  Future<http.Response> delete(String endpoint, {bool needsAuth = true}) async {
    try {
      // Asegurar que el token esté cargado
      if (needsAuth && _token == null) {
        await loadToken();
      }

      final response = await http
          .delete(
            Uri.parse('$baseUrl$endpoint'),
            headers: _getHeaders(needsAuth: needsAuth),
          )
          .timeout(const Duration(seconds: 30));

      return response;
    } catch (e) {
      throw Exception('Error en DELETE $endpoint: $e');
    }
  }

  // ===================== MASCOTA ENDPOINTS =====================

  /// Obtiene el estado de la mascota del usuario
  Future<Map<String, dynamic>> getPetStatus() async {
    final response = await get('/pet/status', needsAuth: true);
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception(
        'Error al obtener estado de mascota: ${response.statusCode}',
      );
    }
  }

  /// Obtiene el inventario de comidas de la mascota
  Future<List<Map<String, dynamic>>> getPetFoods() async {
    final response = await get('/pet/foods', needsAuth: true);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Error al obtener comidas: ${response.statusCode}');
    }
  }

  /// Alimenta la mascota con un tipo de comida
  Future<Map<String, dynamic>> feedPet(String itemName) async {
    final response = await post(
      '/pet/feed',
      body: {'item': itemName},
      needsAuth: true,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Error al alimentar mascota: ${response.statusCode}');
    }
  }

  /// Actualiza el nombre de la mascota
  Future<Map<String, dynamic>> updatePetName(String nuevoNombre) async {
    final response = await put(
      '/pet/name',
      body: {'nombre': nuevoNombre},
      needsAuth: true,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception(
        'Error al actualizar nombre de mascota: ${response.statusCode}',
      );
    }
  }

  /// Obtiene la ropa desbloqueada de la mascota
  Future<List<Map<String, dynamic>>> getPetClothing() async {
    final response = await get('/pet/clothing', needsAuth: true);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Error al obtener ropa: ${response.statusCode}');
    }
  }

  /// Actualiza el estado de equipado de una prenda
  Future<Map<String, dynamic>> updateClothingEquipped(
    int ropaId,
    bool estaEquipado,
  ) async {
    final response = await post(
      '/pet/clothing/equip',
      body: {'ropaId': ropaId, 'estaEquipado': estaEquipado},
      needsAuth: true,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Error al actualizar ropa: ${response.statusCode}');
    }
  }

  /// Equipa un conjunto por su posicion visual en el closet.
  Future<Map<String, dynamic>> updateClothingSlotEquipped(
    int slot,
    bool estaEquipado,
  ) async {
    final response = await post(
      '/pet/clothing/equip',
      body: {'slot': slot, 'estaEquipado': estaEquipado},
      needsAuth: true,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Error al actualizar conjunto: ${response.statusCode}');
    }
  }

  /// Equipa una prenda por nombre logico, por ejemplo "vacio".
  Future<Map<String, dynamic>> updateClothingNameEquipped(
    String nombreRopa,
    bool estaEquipado,
  ) async {
    final response = await post(
      '/pet/clothing/equip',
      body: {'nombreRopa': nombreRopa, 'estaEquipado': estaEquipado},
      needsAuth: true,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Error al actualizar ropa: ${response.statusCode}');
    }
  }
}
