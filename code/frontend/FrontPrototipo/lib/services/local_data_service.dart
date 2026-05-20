import 'dart:convert';

/// Servicio de almacenamiento de datos local (en memoria)
/// Reemplaza las llamadas HTTP al backend con datos locales
class LocalDataService {
  static final LocalDataService _instance = LocalDataService._internal();
  
  factory LocalDataService() {
    return _instance;
  }

  LocalDataService._internal();

  // Almacenamiento en memoria
  final Map<String, dynamic> _storage = {
    'users': {},
    'currentUser': null,
    'profiles': {},
    'petStatus': {
      'nombre': 'FitPaw',
      'nivel': 5,
      'energia': 85,
      'salud': 90,
      'felicidad': 88,
      'hambre': 40,
      'ultimaAlimentacion': DateTime.now().toString(),
    },
    'sentadillasPlans': {},
    'pressHombrosPlans': {},
    'flexionUnaPiernaPlans': {},
    'runningPlans': {},
    'completedExercises': {},
    'photoResponses': {},
  };

  // ==================== USUARIO ====================

  Future<void> registerUser({
    required String nombreCompleto,
    required String telefono,
    required String password,
  }) async {
    await Future.delayed(const Duration(seconds: 1)); // Simular delay
    
    _storage['users']![telefono] = {
      'nombreCompleto': nombreCompleto,
      'telefono': telefono,
      'password': password,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  Future<bool> loginUser({
    required String telefono,
    required String password,
  }) async {
    await Future.delayed(const Duration(seconds: 1)); // Simular delay
    
    final users = _storage['users'] as Map<String, dynamic>;
    if (!users.containsKey(telefono)) {
      return false;
    }

    final user = users[telefono] as Map<String, dynamic>;
    if (user['password'] != password) {
      return false;
    }

    _storage['currentUser'] = telefono;
    return true;
  }

  Future<void> logoutUser() async {
    _storage['currentUser'] = null;
  }

  String? getCurrentUserId() {
    return _storage['currentUser'] as String?;
  }

  Map<String, dynamic>? getCurrentUser() {
    final userId = getCurrentUserId();
    if (userId == null) return null;
    
    final users = _storage['users'] as Map<String, dynamic>;
    return users[userId] as Map<String, dynamic>?;
  }

  // ==================== PERFIL ====================

  Future<void> updateProfile({
    required String genero,
    required DateTime fechaNacimiento,
    required double pesoActual,
    required int estaturaCm,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final userId = getCurrentUserId();
    if (userId == null) return;

    final profiles = _storage['profiles'] as Map<String, dynamic>;
    profiles[userId] = {
      'genero': genero,
      'fechaNacimiento': fechaNacimiento.toIso8601String(),
      'pesoActual': pesoActual,
      'estaturaCm': estaturaCm,
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  Map<String, dynamic>? getProfile() {
    final userId = getCurrentUserId();
    if (userId == null) return null;

    final profiles = _storage['profiles'] as Map<String, dynamic>;
    return profiles[userId] as Map<String, dynamic>?;
  }

  // ==================== MASCOTA ====================

  Future<Map<String, dynamic>> getPetStatus() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _storage['petStatus'] as Map<String, dynamic>;
  }

  Future<void> feedPet() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final petStatus = _storage['petStatus'] as Map<String, dynamic>;
    petStatus['hambre'] = (petStatus['hambre'] as int) - 20;
    if (petStatus['hambre']! < 0) petStatus['hambre'] = 0;
    petStatus['felicidad'] = (petStatus['felicidad'] as int) + 10;
    if (petStatus['felicidad']! > 100) petStatus['felicidad'] = 100;
    petStatus['ultimaAlimentacion'] = DateTime.now().toString();
  }

  // ==================== ENTRENAMIENTOS ====================

  Future<void> saveSentadillasPlan({
    required int weekday,
    required int hour,
    required int minute,
    required String period,
    required String difficulty,
    required String repetitions,
    required String weight,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final plans = _storage['sentadillasPlans'] as Map<String, dynamic>;
    plans[weekday.toString()] = {
      'diaSemana': weekday,
      'hora': hour,
      'minuto': minute,
      'periodo': period,
      'dificultad': difficulty,
      'repeticiones': repetitions,
      'peso': weight,
      'completado': false,
      'guardadoAt': DateTime.now().toIso8601String(),
    };
  }

  Map<String, dynamic>? loadSentadillasPlan({required int weekday}) {
    final plans = _storage['sentadillasPlans'] as Map<String, dynamic>;
    return plans[weekday.toString()] as Map<String, dynamic>?;
  }

  Future<void> savePressHombros({
    required int weekday,
    required int hour,
    required int minute,
    required String period,
    required String difficulty,
    required String repetitions,
    required String weight,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final plans = _storage['pressHombrosPlans'] as Map<String, dynamic>;
    plans[weekday.toString()] = {
      'diaSemana': weekday,
      'hora': hour,
      'minuto': minute,
      'periodo': period,
      'dificultad': difficulty,
      'repeticiones': repetitions,
      'peso': weight,
      'completado': false,
      'guardadoAt': DateTime.now().toIso8601String(),
    };
  }

  Map<String, dynamic>? loadPressHombros({required int weekday}) {
    final plans = _storage['pressHombrosPlans'] as Map<String, dynamic>;
    return plans[weekday.toString()] as Map<String, dynamic>?;
  }

  Future<void> saveFlexionUnaPierna({
    required int weekday,
    required int hour,
    required int minute,
    required String period,
    required String difficulty,
    required String repetitions,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final plans = _storage['flexionUnaPiernaPlans'] as Map<String, dynamic>;
    plans[weekday.toString()] = {
      'diaSemana': weekday,
      'hora': hour,
      'minuto': minute,
      'periodo': period,
      'dificultad': difficulty,
      'repeticiones': repetitions,
      'completado': false,
      'guardadoAt': DateTime.now().toIso8601String(),
    };
  }

  Map<String, dynamic>? loadFlexionUnaPierna({required int weekday}) {
    final plans = _storage['flexionUnaPiernaPlans'] as Map<String, dynamic>;
    return plans[weekday.toString()] as Map<String, dynamic>?;
  }

  Future<void> saveRunning({
    required int weekday,
    required int hour,
    required int minute,
    required String period,
    required String difficulty,
    required String distance,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final plans = _storage['runningPlans'] as Map<String, dynamic>;
    plans[weekday.toString()] = {
      'diaSemana': weekday,
      'hora': hour,
      'minuto': minute,
      'periodo': period,
      'dificultad': difficulty,
      'distancia': distance,
      'completado': false,
      'guardadoAt': DateTime.now().toIso8601String(),
    };
  }

  Map<String, dynamic>? loadRunning({required int weekday}) {
    final plans = _storage['runningPlans'] as Map<String, dynamic>;
    return plans[weekday.toString()] as Map<String, dynamic>?;
  }

  // ==================== EJERCICIOS COMPLETADOS ====================

  Future<void> markExerciseCompleted({required String exerciseKey}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final completed = _storage['completedExercises'] as Map<String, dynamic>;
    completed[exerciseKey] = DateTime.now().toIso8601String();
  }

  bool isExerciseCompleted({required String exerciseKey}) {
    final completed = _storage['completedExercises'] as Map<String, dynamic>;
    return completed.containsKey(exerciseKey);
  }

  Future<void> clearDayCompletedExercises({required int weekday}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final completed = _storage['completedExercises'] as Map<String, dynamic>;
    final keysToRemove = completed.keys
        .where((key) => key.startsWith('day_$weekday_'))
        .toList();
    
    for (final key in keysToRemove) {
      completed.remove(key);
    }
  }

  // ==================== RESPUESTAS DE FOTOS ====================

  Future<void> savePhotoResponse({
    required String photoPath,
    required String response,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final responses = _storage['photoResponses'] as Map<String, dynamic>;
    responses[photoPath] = {
      'response': response,
      'savedAt': DateTime.now().toIso8601String(),
    };
  }

  String? getPhotoResponse({required String photoPath}) {
    final responses = _storage['photoResponses'] as Map<String, dynamic>;
    final data = responses[photoPath] as Map<String, dynamic>?;
    return data?['response'] as String?;
  }
}
