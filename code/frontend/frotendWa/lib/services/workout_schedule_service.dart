import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'api_client.dart';

class WorkoutScheduleService {
  final ApiClient apiClient;

  WorkoutScheduleService(this.apiClient);

  Future<void> saveSentadillasPlan({
    required int weekday,
    required int hour,
    required int minute,
    required String period,
    required String difficulty,
    required String repetitions,
    required String weight,
  }) async {
    debugPrint('Guardando sentadillas para día $weekday: $hour:${minute.toString().padLeft(2, '0')} $period');
    
    final body = {
      'diaSemana': weekday,
      'hora': hour,
      'minuto': minute,
      'periodo': period,
      'dificultad': difficulty,
      'repeticiones': repetitions,
      'peso': weight,
    };
    
    try {
      final response = await apiClient.post(
        '/training/rutinas/sentadillas',
        body: body,
        needsAuth: true,
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        final errorMsg = _extractErrorMessage(response.body, response.statusCode);
        debugPrint('Error al guardar sentadillas: $errorMsg (status: ${response.statusCode})');
        throw Exception('No se pudo guardar sentadillas: $errorMsg');
      }
      
      debugPrint('Sentadillas guardadas exitosamente');
    } catch (e) {
      debugPrint('Excepción al guardar sentadillas: $e');
      rethrow;
    }
  }

  Future<SentadillasPlan?> loadSentadillasPlan({required int weekday}) async {
    try {
      final response = await apiClient.get(
        '/training/rutinas/sentadillas?diaSemana=$weekday',
        needsAuth: true,
      );

      if (response.statusCode == 404) {
        debugPrint('No hay plan de sentadillas para el día $weekday');
        return null;
      }

      if (response.statusCode != 200) {
        final errorMsg = _extractErrorMessage(response.body, response.statusCode);
        debugPrint('Error al cargar sentadillas: $errorMsg (status: ${response.statusCode})');
        throw Exception('No se pudo cargar sentadillas: $errorMsg');
      }

      final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
      final plan = SentadillasPlan(
        weekday: (data['diaSemana'] as num?)?.toInt() ?? weekday,
        hour: (data['hora'] as num?)?.toInt() ?? 9,
        minute: (data['minuto'] as num?)?.toInt() ?? 0,
        period: (data['periodo'] as String?) ?? 'AM',
        difficulty: (data['dificultad'] as String?) ?? 'Media',
        repetitions: (data['repeticiones'] as String?) ?? '8 - 12',
        weight: (data['peso'] as String?) ?? '12 kg',
        completed: (data['completado'] as bool?) ?? false,
      );
      debugPrint('Plan de sentadillas cargado: ${plan.summaryLabel} a ${plan.timeLabel}');
      return plan;
    } catch (e) {
      debugPrint('Excepción al cargar sentadillas: $e');
      rethrow;
    }
  }

  Future<Set<String>> loadCompletedExercises({required int weekday}) async {
    final response = await apiClient.get(
      '/training/rutinas/completadas?diaSemana=$weekday',
      needsAuth: true,
    );

    if (response.statusCode == 404) {
      return <String>{};
    }

    if (response.statusCode != 200) {
      throw Exception('No se pudieron cargar las rutinas completadas: ${_extractErrorMessage(response.body, response.statusCode)}');
    }

    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((item) => (item as Map<String, dynamic>)['ejercicioEtiqueta'] as String?)
        .whereType<String>()
        .toSet();
  }

  Future<void> markRoutineCompleted({required int weekday, required String exerciseLabel, String? detail}) async {
    final response = await apiClient.post(
      '/training/rutinas/completadas',
      body: {
        'diaSemana': weekday,
        'ejercicioEtiqueta': exerciseLabel,
        'detalle': detail,
      },
      needsAuth: true,
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('No se pudo marcar la rutina como completada: ${_extractErrorMessage(response.body, response.statusCode)}');
    }
  }

  Future<SentadillasPlan?> markSentadillasCompleted({required int weekday}) async {
    final response = await apiClient.post(
      '/training/rutinas/sentadillas/completar?diaSemana=$weekday',
      body: const {},
      needsAuth: true,
    );

    if (response.statusCode != 200) {
      throw Exception('No se pudo marcar sentadillas como completadas: ${_extractErrorMessage(response.body, response.statusCode)}');
    }

    final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
    return SentadillasPlan(
      weekday: (data['diaSemana'] as num?)?.toInt() ?? weekday,
      hour: (data['hora'] as num?)?.toInt() ?? 9,
      minute: (data['minuto'] as num?)?.toInt() ?? 0,
      period: (data['periodo'] as String?) ?? 'AM',
      difficulty: (data['dificultad'] as String?) ?? 'Media',
      repetitions: (data['repeticiones'] as String?) ?? '8 - 12',
      weight: (data['peso'] as String?) ?? '12 kg',
      completed: (data['completado'] as bool?) ?? true,
    );
  }

  // Generic exercise methods for Press Hombros, Flexión, Correr
  Future<void> saveExercisePlan({
    required String exerciseName,
    required int weekday,
    required int hour,
    required int minute,
    required String period,
    required String difficulty,
    required String repetitions,
    required String weight,
  }) async {
    debugPrint('📝 Guardando $exerciseName para día $weekday: $hour:${minute.toString().padLeft(2, '0')} $period');
    
    final body = {
      'diaSemana': weekday,
      'hora': hour,
      'minuto': minute,
      'periodo': period,
      'dificultad': difficulty,
      'repeticiones': repetitions,
      'peso': weight,
      'ejercicio': exerciseName,
    };
    
    debugPrint('📤 Enviando: $body');
    
    try {
      final response = await apiClient.post(
        '/training/rutinas/ejercicio',
        body: body,
        needsAuth: true,
      );

      debugPrint('📡 Respuesta: status=${response.statusCode}');
      debugPrint('Cuerpo: ${response.body}');
      
      if (response.statusCode != 200 && response.statusCode != 201) {
        final errorMsg = _extractErrorMessage(response.body, response.statusCode);
        debugPrint('❌ Error al guardar $exerciseName: $errorMsg (status: ${response.statusCode})');
        throw Exception('No se pudo guardar $exerciseName: $errorMsg');
      }
      
      debugPrint('✅ $exerciseName guardado exitosamente');
    } catch (e) {
      debugPrint('💥 Excepción al guardar $exerciseName: $e');
      rethrow;
    }
  }

  Future<ExercisePlan?> loadExercisePlan({required String exerciseName, required int weekday}) async {
    try {
      final String encodedName = Uri.encodeComponent(exerciseName);
      final String url = '/training/rutinas/ejercicio?nombre=$encodedName&diaSemana=$weekday';
      debugPrint('🔍 Cargando ejercicio: URL=$url (nombre=$exerciseName, día=$weekday)');
      
      final response = await apiClient.get(
        url,
        needsAuth: true,
      );

      debugPrint('📡 Respuesta: status=${response.statusCode}');
      
      if (response.statusCode == 404) {
        debugPrint('⚠️ No hay plan de $exerciseName para el día $weekday');
        return null;
      }

      if (response.statusCode != 200) {
        final errorMsg = _extractErrorMessage(response.body, response.statusCode);
        debugPrint('❌ Error al cargar $exerciseName: $errorMsg (status: ${response.statusCode})');
        debugPrint('Respuesta: ${response.body}');
        throw Exception('No se pudo cargar $exerciseName: $errorMsg');
      }

      final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
      debugPrint('✅ Datos recibidos: $data');
      
      final plan = ExercisePlan(
        weekday: (data['diaSemana'] as num?)?.toInt() ?? weekday,
        hour: (data['hora'] as num?)?.toInt() ?? 9,
        minute: (data['minuto'] as num?)?.toInt() ?? 0,
        period: (data['periodo'] as String?) ?? 'AM',
        difficulty: (data['dificultad'] as String?) ?? 'Media',
        repetitions: (data['repeticiones'] as String?) ?? '8 - 12',
        weight: (data['peso'] as String?) ?? '12 kg',
        exerciseName: exerciseName,
        completed: (data['completado'] as bool?) ?? false,
      );
      debugPrint('✨ Plan de $exerciseName cargado: ${plan.summaryLabel}');
      return plan;
    } catch (e) {
      debugPrint('💥 Excepción al cargar $exerciseName: $e');
      rethrow;
    }
  }

  String _extractErrorMessage(String body, int statusCode) {
    if (body.trim().isEmpty) {
      return 'HTTP $statusCode';
    }

    try {
      final Map<String, dynamic> data = jsonDecode(body) as Map<String, dynamic>;
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

class SentadillasPlan {
  final int weekday;
  final int hour;
  final int minute;
  final String period;
  final String difficulty;
  final String repetitions;
  final String weight;
  final bool completed;

  const SentadillasPlan({
    required this.weekday,
    required this.hour,
    required this.minute,
    required this.period,
    required this.difficulty,
    required this.repetitions,
    required this.weight,
    required this.completed,
  });

  String get timeLabel {
    final int normalizedHour = hour == 0 ? 12 : hour;
    return '${normalizedHour.toString().padLeft(2, '0')}:00 $period';
  }

  String get summaryLabel => 'Sentadillas, $repetitions reps, $weight';

  SentadillasPlan copyWithCompleted(bool value) {
    return SentadillasPlan(
      weekday: weekday,
      hour: hour,
      minute: minute,
      period: period,
      difficulty: difficulty,
      repetitions: repetitions,
      weight: weight,
      completed: value,
    );
  }
}

// Generic exercise plan class for other exercises
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

  String get summaryLabel => '$exerciseName, $repetitions reps, $weight';
}