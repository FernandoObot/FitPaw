import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// ApiClient simulado sin conexiones HTTP
/// Todos los datos se manejan localmente - MODO OFFLINE
class ApiClient {
  static const String baseUrl = 'http://localhost:8080 (OFFLINE)';
  static const String _tokenKey = 'jwt_token';
  
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  String? _token;
  
  // Almacenamiento en memoria para ejercicios
  static final Map<String, dynamic> _exerciseStorage = {
    'sentadillas': {},      // weekday -> plan
    'press_hombros': {},    // weekday -> plan
    'flexion_una_pierna': {}, // weekday -> plan
    'running': {},          // weekday -> plan
    'ejercicio': {},        // name + weekday -> plan
    'completados': {},      // weekday -> Set<String>
  };

  ApiClient();

  Future<void> loadToken() async {
    _token = 'fake_offline_token_${DateTime.now().millisecondsSinceEpoch}';
    debugPrint('🔓 Token cargado (Modo Offline)');
  }

  Future<void> saveToken(String token) async {
    _token = token;
    try {
      await _secureStorage.write(key: _tokenKey, value: token);
    } catch (e) {
      debugPrint('⚠️ No se pudo guardar token: $e');
    }
    debugPrint('✅ Token guardado (Modo Offline)');
  }

  Future<void> clearToken() async {
    _token = null;
    try {
      await _secureStorage.delete(key: _tokenKey);
    } catch (e) {
      debugPrint('⚠️ Error al limpiar token: $e');
    }
    debugPrint('🔐 Token limpiado');
  }

  String? getToken() => _token;

  Map<String, String> _getHeaders({bool needsAuth = true}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Offline-Mode': 'true',
    };
    
    if (needsAuth && _token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    
    return headers;
  }

  /// Simula respuesta POST sin HTTP
  Future<MockHttpResponse> post(
    String endpoint, {
    required Map<String, dynamic> body,
    bool needsAuth = false,
  }) async {
    debugPrint('📤 POST $endpoint (OFFLINE)');
    await Future.delayed(const Duration(milliseconds: 800));

    if (endpoint == '/auth/register') {
      return MockHttpResponse(statusCode: 201, body: jsonEncode({
        'token': 'jwt_${DateTime.now().millisecondsSinceEpoch}',
        'usuario': {'id': 1, 'nombreCompleto': body['nombreCompleto'], 'telefono': body['telefono']},
      }));
    } else if (endpoint == '/auth/login') {
      return MockHttpResponse(statusCode: 200, body: jsonEncode({
        'token': 'jwt_${DateTime.now().millisecondsSinceEpoch}',
        'usuario': {'id': 1, 'nombreCompleto': 'Usuario', 'telefono': body['telefono']},
      }));
    } else if (endpoint.contains('sentadillas')) {
      // Guardar sentadillas en memoria
      final weekday = body['diaSemana'] as int?;
      if (weekday != null) {
        (_exerciseStorage['sentadillas'] as Map)[weekday] = {
          ...body,
          'completado': false,
        };
        debugPrint('✅ Sentadillas guardadas para día $weekday');
      }
      return MockHttpResponse(statusCode: 201, body: jsonEncode({'mensaje': 'Guardado', 'data': body}));
    } else if (endpoint.contains('press')) {
      // Guardar press en memoria
      final weekday = body['diaSemana'] as int?;
      if (weekday != null) {
        (_exerciseStorage['press_hombros'] as Map)[weekday] = {
          ...body,
          'completado': false,
        };
        debugPrint('✅ Press guardado para día $weekday');
      }
      return MockHttpResponse(statusCode: 201, body: jsonEncode({'mensaje': 'Guardado', 'data': body}));
    } else if (endpoint.contains('flexion')) {
      // Guardar flexión en memoria
      final weekday = body['diaSemana'] as int?;
      if (weekday != null) {
        (_exerciseStorage['flexion_una_pierna'] as Map)[weekday] = {
          ...body,
          'completado': false,
        };
        debugPrint('✅ Flexión guardada para día $weekday');
      }
      return MockHttpResponse(statusCode: 201, body: jsonEncode({'mensaje': 'Guardado', 'data': body}));
    } else if (endpoint.contains('running')) {
      // Guardar correr en memoria
      final weekday = body['diaSemana'] as int?;
      if (weekday != null) {
        (_exerciseStorage['running'] as Map)[weekday] = {
          ...body,
          'completado': false,
        };
        debugPrint('✅ Running guardado para día $weekday');
      }
      return MockHttpResponse(statusCode: 201, body: jsonEncode({'mensaje': 'Guardado', 'data': body}));
    } else if (endpoint.contains('ejercicio')) {
      // Guardar ejercicio genérico en memoria
      final weekday = body['diaSemana'] as int?;
      final exerciseName = body['ejercicio'] as String?;
      if (weekday != null && exerciseName != null) {
        final key = '${exerciseName}_$weekday';
        (_exerciseStorage['ejercicio'] as Map)[key] = {
          ...body,
          'completado': false,
        };
        debugPrint('✅ $exerciseName guardado para día $weekday');
      }
      return MockHttpResponse(statusCode: 201, body: jsonEncode({'mensaje': 'Guardado', 'data': body}));
    } else if (endpoint.contains('completadas')) {
      // Marcar ejercicio como completado
      final weekday = body['diaSemana'] as int?;
      final label = body['ejercicioEtiqueta'] as String?;
      if (weekday != null && label != null) {
        final completados = (_exerciseStorage['completados'] as Map);
        if (!completados.containsKey(weekday)) {
          completados[weekday] = <String>{};
        }
        (completados[weekday] as Set<String>).add(label);
        debugPrint('✅ $label marcado como completado para día $weekday');
      }
      return MockHttpResponse(statusCode: 201, body: jsonEncode({'mensaje': 'Completado'}));
    }
    
    return MockHttpResponse(statusCode: 200, body: jsonEncode({'data': body}));
  }

  /// Simula respuesta GET sin HTTP
  Future<MockHttpResponse> get(
    String endpoint, {
    bool needsAuth = true,
  }) async {
    debugPrint('📥 GET $endpoint (OFFLINE)');
    await Future.delayed(const Duration(milliseconds: 600));

    if (endpoint.contains('pet/status')) {
      return MockHttpResponse(statusCode: 200, body: jsonEncode({
        'nombre': 'FitPaw', 'nivel': 5, 'energia': 85, 'salud': 90, 'felicidad': 88, 'hambre': 40,
      }));
    } else if (endpoint.contains('profile')) {
      return MockHttpResponse(statusCode: 200, body: jsonEncode({
        'id': 1, 'nombreCompleto': 'Usuario', 'telefono': '3001234567',
      }));
    } else if (endpoint.contains('sentadillas')) {
      // Cargar sentadillas desde memoria
      final weekdayStr = RegExp(r'diaSemana=(\d+)').firstMatch(endpoint)?.group(1);
      if (weekdayStr != null) {
        final weekday = int.tryParse(weekdayStr);
        if (weekday != null) {
          final plan = (_exerciseStorage['sentadillas'] as Map)[weekday];
          if (plan != null) {
            debugPrint('✅ Sentadillas encontradas para día $weekday');
            return MockHttpResponse(statusCode: 200, body: jsonEncode(plan));
          }
        }
      }
      return MockHttpResponse(statusCode: 404, body: jsonEncode({'mensaje': 'No encontrado'}));
    } else if (endpoint.contains('press')) {
      // Cargar press desde memoria
      final weekdayStr = RegExp(r'diaSemana=(\d+)').firstMatch(endpoint)?.group(1);
      if (weekdayStr != null) {
        final weekday = int.tryParse(weekdayStr);
        if (weekday != null) {
          final plan = (_exerciseStorage['press_hombros'] as Map)[weekday];
          if (plan != null) {
            debugPrint('✅ Press encontrado para día $weekday');
            return MockHttpResponse(statusCode: 200, body: jsonEncode(plan));
          }
        }
      }
      return MockHttpResponse(statusCode: 404, body: jsonEncode({'mensaje': 'No encontrado'}));
    } else if (endpoint.contains('flexion')) {
      // Cargar flexión desde memoria
      final weekdayStr = RegExp(r'diaSemana=(\d+)').firstMatch(endpoint)?.group(1);
      if (weekdayStr != null) {
        final weekday = int.tryParse(weekdayStr);
        if (weekday != null) {
          final plan = (_exerciseStorage['flexion_una_pierna'] as Map)[weekday];
          if (plan != null) {
            debugPrint('✅ Flexión encontrada para día $weekday');
            return MockHttpResponse(statusCode: 200, body: jsonEncode(plan));
          }
        }
      }
      return MockHttpResponse(statusCode: 404, body: jsonEncode({'mensaje': 'No encontrado'}));
    } else if (endpoint.contains('running')) {
      // Cargar running desde memoria
      final weekdayStr = RegExp(r'diaSemana=(\d+)').firstMatch(endpoint)?.group(1);
      if (weekdayStr != null) {
        final weekday = int.tryParse(weekdayStr);
        if (weekday != null) {
          final plan = (_exerciseStorage['running'] as Map)[weekday];
          if (plan != null) {
            debugPrint('✅ Running encontrado para día $weekday');
            return MockHttpResponse(statusCode: 200, body: jsonEncode(plan));
          }
        }
      }
      return MockHttpResponse(statusCode: 404, body: jsonEncode({'mensaje': 'No encontrado'}));
    } else if (endpoint.contains('ejercicio')) {
      // Cargar ejercicio genérico desde memoria
      final nameMatch = RegExp(r'nombre=([^&]+)').firstMatch(endpoint);
      final weekdayStr = RegExp(r'diaSemana=(\d+)').firstMatch(endpoint)?.group(1);
      
      if (nameMatch != null && weekdayStr != null) {
        final exerciseName = Uri.decodeComponent(nameMatch.group(1)!);
        final weekday = int.tryParse(weekdayStr);
        if (weekday != null) {
          final key = '${exerciseName}_$weekday';
          final plan = (_exerciseStorage['ejercicio'] as Map)[key];
          if (plan != null) {
            debugPrint('✅ $exerciseName encontrado para día $weekday');
            return MockHttpResponse(statusCode: 200, body: jsonEncode(plan));
          }
        }
      }
      return MockHttpResponse(statusCode: 404, body: jsonEncode({'mensaje': 'No encontrado'}));
    } else if (endpoint.contains('completadas')) {
      // Cargar ejercicios completados desde memoria
      final weekdayStr = RegExp(r'diaSemana=(\d+)').firstMatch(endpoint)?.group(1);
      if (weekdayStr != null) {
        final weekday = int.tryParse(weekdayStr);
        if (weekday != null) {
          final completados = (_exerciseStorage['completados'] as Map)[weekday] as Set<String>?;
          if (completados != null && completados.isNotEmpty) {
            debugPrint('✅ Completados encontrados: $completados');
            return MockHttpResponse(statusCode: 200, body: jsonEncode(
              completados.map((label) => {'ejercicioEtiqueta': label}).toList(),
            ));
          }
        }
      }
      return MockHttpResponse(statusCode: 404, body: jsonEncode([]));
    }
    
    return MockHttpResponse(statusCode: 404, body: jsonEncode({'mensaje': 'No encontrado'}));
  }

  /// Simula respuesta PUT sin HTTP
  Future<MockHttpResponse> put(
    String endpoint, {
    required Map<String, dynamic> body,
    bool needsAuth = true,
  }) async {
    debugPrint('📝 PUT $endpoint (OFFLINE)');
    await Future.delayed(const Duration(milliseconds: 700));
    return MockHttpResponse(statusCode: 200, body: jsonEncode({'data': body}));
  }
}

/// Simula respuestas HTTP sin hacer llamadas reales
class MockHttpResponse {
  final int statusCode;
  final String body;
  MockHttpResponse({required this.statusCode, required this.body});
}
