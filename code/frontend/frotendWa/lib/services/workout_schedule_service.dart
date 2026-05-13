import 'dart:convert';

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
    final response = await apiClient.post(
      '/training/rutinas/sentadillas',
      body: {
        'diaSemana': weekday,
        'hora': hour,
        'minuto': minute,
        'periodo': period,
        'dificultad': difficulty,
        'repeticiones': repetitions,
        'peso': weight,
      },
      needsAuth: true,
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('No se pudo guardar sentadillas: ${_extractErrorMessage(response.body, response.statusCode)}');
    }
  }

  Future<SentadillasPlan?> loadSentadillasPlan({required int weekday}) async {
    final response = await apiClient.get(
      '/training/rutinas/sentadillas?diaSemana=$weekday',
      needsAuth: true,
    );

    if (response.statusCode == 404) {
      return null;
    }

    if (response.statusCode != 200) {
      throw Exception('No se pudo cargar sentadillas: ${_extractErrorMessage(response.body, response.statusCode)}');
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
    );
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

  const SentadillasPlan({
    required this.weekday,
    required this.hour,
    required this.minute,
    required this.period,
    required this.difficulty,
    required this.repetitions,
    required this.weight,
  });

  String get timeLabel {
    final String minuteLabel = minute.toString().padLeft(2, '0');
    final int normalizedHour = hour == 0 ? 12 : hour;
    return '${normalizedHour.toString().padLeft(2, '0')}:$minuteLabel $period';
  }

  String get summaryLabel => 'Sentadillas, $repetitions reps, $weight';
}