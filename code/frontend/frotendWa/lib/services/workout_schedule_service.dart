import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'api_client.dart';

class WorkoutScheduleService {
  final ApiClient apiClient;

  WorkoutScheduleService(this.apiClient);

  /// Guardar ejercicio cardio con nombre, dificultad, tiempo en minutos, fecha, hora y completado=false
  Future<void> saveCardioExercise({
    required String nombre,
    required String dificultad,
    required int tiempoMinutos,
    required DateTime fecha,
    required int hora, // 6-23 (6 AM a 11 PM)
  }) async {
    // Convertir dificultad a número: Baja=1, Media=2, Alta=3
    int difficultyValue = _difficultyToInt(dificultad);

    final body = {
      'nombre': nombre,
      'dificultad': difficultyValue,
      'tiempo_minutos': tiempoMinutos,
      'fecha': fecha.toString().split(' ')[0], // Formato YYYY-MM-DD
      'hora': hora,
      'completado': false,
    };

    try {
      final response = await apiClient.post(
        '/ejercicios/cardio',
        body: body,
        needsAuth: true,
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        final errorMsg = _extractErrorMessage(
          response.body,
          response.statusCode,
        );
        debugPrint('Error al guardar ejercicio cardio: $errorMsg');
        throw Exception('No se pudo guardar ejercicio: $errorMsg');
      }
    } catch (e) {
      debugPrint('Error al guardar ejercicio cardio: $e');
      rethrow;
    }
  }

  /// Guardar ejercicio de fuerza
  Future<void> saveFuerzaExercise({
    required String nombre,
    required String grupoMuscular,
    required String dificultad,
    required int repeticiones,
    required double peso,
    required DateTime fecha,
    required int hora,
  }) async {
    int difficultyValue = _difficultyToInt(dificultad);

    final body = {
      'nombre': nombre,
      'grupo_muscular': grupoMuscular,
      'dificultad': difficultyValue,
      'repeticiones': repeticiones,
      'peso': peso,
      'fecha': fecha.toString().split(' ')[0],
      'hora': hora,
      'completado': false,
    };

    try {
      final response = await apiClient.post(
        '/ejercicios/fuerza',
        body: body,
        needsAuth: true,
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        final errorMsg = _extractErrorMessage(
          response.body,
          response.statusCode,
        );
        debugPrint('Error al guardar ejercicio de fuerza: $errorMsg');
        throw Exception('No se pudo guardar ejercicio: $errorMsg');
      }
    } catch (e) {
      debugPrint('Error al guardar ejercicio de fuerza: $e');
      rethrow;
    }
  }

  int _difficultyToInt(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'baja':
        return 1;
      case 'media':
        return 2;
      case 'alta':
        return 3;
      default:
        return 2; // Media por defecto
    }
  }

  /// Cargar ejercicios guardados para una fecha (cardio + fuerza)
  Future<List<Map<String, dynamic>>> loadExercisesForDate({
    required DateTime fecha,
  }) async {
    final String dateStr = fecha.toString().split(' ')[0];
    final response = await apiClient.get(
      '/ejercicios?fecha=$dateStr',
      needsAuth: true,
    );

    if (response.statusCode == 404) {
      return [];
    }

    if (response.statusCode != 200) {
      throw Exception(
        'No se pudieron cargar ejercicios: ${_extractErrorMessage(response.body, response.statusCode)}',
      );
    }

    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
    return data.map((e) => e as Map<String, dynamic>).toList();
  }

  /// Validar conflictos de ejercicio antes de guardar
  /// Retorna null si no hay conflictos
  /// Retorna un mensaje de error si hay conflictos
  Future<String?> checkExerciseConflicts({
    required String nombreEjercicio,
    required DateTime fecha,
    required int hora,
  }) async {
    try {
      final ejerciciosDelDia = await loadExercisesForDate(fecha: fecha);

      for (final ejercicio in ejerciciosDelDia) {
        final String nombreExistente = (ejercicio['nombre'] as String?) ?? '';
        final int horaExistente = (ejercicio['hora'] is num)
            ? (ejercicio['hora'] as num).toInt()
            : 0;

        // Validación 1: ¿Hay ejercicio en este horario?
        if (horaExistente == hora) {
          return 'Ya tienes "$nombreExistente" a las $hora:00. No puedes poner dos ejercicios en el mismo horario.';
        }

        // Validación 2: ¿Hay del mismo tipo en este día?
        if (nombreExistente.toLowerCase() == nombreEjercicio.toLowerCase()) {
          return 'Ya tienes "$nombreEjercicio" registrado en este día. Solo puedes hacer uno de cada tipo por día.';
        }
      }

      return null; // Sin conflictos
    } catch (e) {
      debugPrint('Error al validar conflictos: $e');
      return null; // Si hay error en la validación, permitir guardar igual
    }
  }

  /// Marcar ejercicio como completado (actualizar campo completado a true)
  Future<void> markExerciseCompleted({
    required String nombre,
    required DateTime fecha,
  }) async {
    final String dateStr = fecha.toString().split(' ')[0];
    try {
      final response = await apiClient.patch(
        '/ejercicios/completar',
        body: {'nombre': nombre, 'fecha': dateStr, 'completado': true},
        needsAuth: true,
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        final errorMsg = _extractErrorMessage(
          response.body,
          response.statusCode,
        );
        debugPrint('Error al marcar como completado: $errorMsg');
        throw Exception('No se pudo marcar como completado: $errorMsg');
      }
    } catch (e) {
      debugPrint('Error al marcar como completado: $e');
      rethrow;
    }
  }

  /// Eliminar un ejercicio de la base de datos
  Future<void> deleteExercise({
    required String nombre,
    required DateTime fecha,
  }) async {
    final String dateStr = fecha.toString().split(' ')[0];
    try {
      final response = await apiClient.delete(
        '/ejercicios/eliminar?nombre=${Uri.encodeComponent(nombre)}&fecha=$dateStr',
        needsAuth: true,
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        final errorMsg = _extractErrorMessage(
          response.body,
          response.statusCode,
        );
        debugPrint('Error al eliminar ejercicio: $errorMsg');
        throw Exception('No se pudo eliminar el ejercicio: $errorMsg');
      }
    } catch (e) {
      debugPrint('Error al eliminar ejercicio: $e');
      rethrow;
    }
  }

  String _extractErrorMessage(String body, int statusCode) {
    if (body.trim().isEmpty) {
      return 'HTTP $statusCode';
    }

    try {
      final Map<String, dynamic> data =
          jsonDecode(body) as Map<String, dynamic>;
      final String? mensaje = data['mensaje'] as String?;
      if (mensaje != null && mensaje.trim().isNotEmpty) {
        return mensaje;
      }
    } catch (_) {
      // If the response is not JSON, return the raw body below.
    }

    return body;
  }
}

// Exercise plan class for all exercises
class ExercisePlan {
  final int weekday;
  final int hour;
  final int minute;
  final String period;
  final String difficulty;
  final String repetitions;
  final String weight;
  final String exerciseName;
  final bool completed;

  const ExercisePlan({
    required this.weekday,
    required this.hour,
    required this.minute,
    required this.period,
    required this.difficulty,
    required this.repetitions,
    required this.weight,
    required this.exerciseName,
    required this.completed,
  });

  String get timeLabel {
    final int normalizedHour = hour == 0 ? 12 : hour;
    return '${normalizedHour.toString().padLeft(2, '0')}:00 $period';
  }

  String get summaryLabel {
    // Para cardio (sin peso, solo tiempo)
    if (weight.isEmpty || weight == '0 kg') {
      return '$exerciseName, $repetitions';
    }
    // Para fuerza (con reps y peso)
    if (repetitions.contains('min')) {
      return '$exerciseName, $repetitions';
    }
    return '$exerciseName, $repetitions reps, $weight';
  }
}
