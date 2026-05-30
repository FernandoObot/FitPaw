import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'api_client.dart';

class RachaService {
  final ApiClient _apiClient = ApiClient();

  /// Obtiene la información de racha del usuario autenticado
  /// 
  /// Retorna un mapa con:
  /// - racha_id: ID de la racha
  /// - usuario_id: ID del usuario
  /// - cantidad_dias: Número real de días en usuarios_racha.cantidad_dias
  /// - fecha_ultima_actividad: Última fecha de actividad
  /// - activa: Si la racha está activa
  Future<Map<String, dynamic>> obtenerRachaInfo() async {
    try {
      final response = await _apiClient.get('/streak/info', needsAuth: true);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data;
      } else {
        throw Exception('Error al obtener racha: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error en RachaService.obtenerRachaInfo: $e');
      rethrow;
    }
  }

  /// Obtiene solo el conteo de días de racha
  Future<int> obtenerDiasRacha() async {
    final racha = await obtenerRachaInfo();
    return (racha['cantidad_dias'] as int?) ?? (racha['conteoDias'] as int?) ?? 0;
  }

  /// Obtiene solo si la racha está activa
  Future<bool> obtenerRachaActiva() async {
    final racha = await obtenerRachaInfo();
    return racha['activa'] as bool? ?? false;
  }

  /// Marca un ejercicio como completado y obtiene información de recompensas
  /// 
  /// [nombre]: Nombre del ejercicio
  /// [fecha]: Fecha del ejercicio (formato: yyyy-MM-dd)
  /// 
  /// Retorna un mapa con:
  /// - usuario_id: ID del usuario
  /// - success: Si fue exitoso
  /// - mensaje: Mensaje descriptivo
  /// - dias_racha: Días actuales de racha
  /// - racha_activa: Si la racha está activa
  Future<Map<String, dynamic>> marcarEjercicioCompletado({
    required String nombre,
    required String fecha,
  }) async {
    try {
      final response = await _apiClient.post(
        '/api/ejercicios/completar',
        body: {
          'nombre': nombre,
          'fecha': fecha,
        },
        needsAuth: true,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data;
      } else {
        throw Exception('Error al marcar ejercicio completado: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error en RachaService.marcarEjercicioCompletado: $e');
      rethrow;
    }
  }
}
