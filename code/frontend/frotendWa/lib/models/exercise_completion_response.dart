/// Model for the response when an exercise is completed.
/// 
/// Fields:
/// - usuarioId: The ID of the user
/// - success: Whether the operation was successful
/// - mensaje: A message describing the result
/// - diasRacha: The current number of days in the streak
/// - rachaActiva: Whether the streak is currently active
class ExerciseCompletionResponse {
  final int? usuarioId;
  final bool success;
  final String? mensaje;
  final int diasRacha;
  final bool rachaActiva;

  ExerciseCompletionResponse({
    this.usuarioId,
    required this.success,
    this.mensaje,
    required this.diasRacha,
    required this.rachaActiva,
  });

  /// Creates an instance from a JSON map (from API response)
  factory ExerciseCompletionResponse.fromJson(Map<String, dynamic> json) {
    return ExerciseCompletionResponse(
      usuarioId: json['usuario_id'] as int?,
      success: json['success'] as bool? ?? false,
      mensaje: json['mensaje'] as String?,
      diasRacha: json['dias_racha'] as int? ?? 0,
      rachaActiva: json['racha_activa'] as bool? ?? false,
    );
  }

  /// Converts this instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'usuario_id': usuarioId,
      'success': success,
      'mensaje': mensaje,
      'dias_racha': diasRacha,
      'racha_activa': rachaActiva,
    };
  }

  @override
  String toString() => 'ExerciseCompletionResponse('
      'usuarioId: $usuarioId, '
      'success: $success, '
      'mensaje: $mensaje, '
      'diasRacha: $diasRacha, '
      'rachaActiva: $rachaActiva)';
}
