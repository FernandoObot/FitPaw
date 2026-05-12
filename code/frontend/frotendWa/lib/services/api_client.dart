import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  static const String baseUrl = 'http://localhost:8080';
  static const String _tokenKey = 'jwt_token';
  
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  String? _token;

  ApiClient();

  Future<void> loadToken() async {
    _token = await _secureStorage.read(key: _tokenKey);
  }

  Future<void> saveToken(String token) async {
    _token = token;
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  Future<void> clearToken() async {
    _token = null;
    await _secureStorage.delete(key: _tokenKey);
  }

  String? getToken() => _token;

  Map<String, String> _getHeaders({bool needsAuth = true}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (needsAuth && _token != null) {
      headers['Authorization'] = 'Bearer $_token';
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
      
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(needsAuth: needsAuth),
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 30));
      
      return response;
    } catch (e) {
      throw Exception('Error en POST $endpoint: $e');
    }
  }

  Future<http.Response> get(
    String endpoint, {
    bool needsAuth = true,
  }) async {
    try {
      // Asegurar que el token esté cargado
      if (needsAuth && _token == null) {
        await loadToken();
      }
      
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(needsAuth: needsAuth),
      ).timeout(const Duration(seconds: 30));
      
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
      
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(needsAuth: needsAuth),
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 30));
      
      return response;
    } catch (e) {
      throw Exception('Error en PUT $endpoint: $e');
    }
  }
}
