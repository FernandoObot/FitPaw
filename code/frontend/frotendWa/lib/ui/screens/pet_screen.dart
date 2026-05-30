import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../services/api_client.dart';
import '../widgets/responsive.dart';

class PetScreen extends StatefulWidget {
  const PetScreen({super.key});

  @override
  State<PetScreen> createState() => _PetScreenState();
}

  String _foodAssetForKey(String key) {
    switch (key) {
      case 'pez':
        return 'assets/images/Pez.png';
      case 'camaron':
        return 'assets/images/Camaron.png';
      case 'calamar':
        return 'assets/images/Calamar.png';
      case 'coctel':
        return 'assets/images/Coctel de mariscos.png';
      default:
        return 'assets/images/Pez.png';
    }
  }

class _PetScreenState extends State<PetScreen> with SingleTickerProviderStateMixin {
  static const String _defaultBase = 'assets/images/basico base.png';
  static const String _defaultHappy = 'assets/images/basico feliz.png';
  static const String _defaultSad = 'assets/images/basico triste.png';
  static const String _defaultCry = 'assets/images/basico llorando.png';
  static const String _conjunto1Base = 'assets/images/conjunto 1 base.png';
  static const String _conjunto1Happy = 'assets/images/conjunto 1 feliz.png';
  static const String _conjunto1Sad = 'assets/images/conjunto 1 triste.png';
  static const String _conjunto1Cry = 'assets/images/conjunto 1 llorando.png';
  static const String _conjunto2Base = 'assets/images/conjunto 2 base.png';
  static const String _conjunto2Happy = 'assets/images/conjunto 2 feliz.png';
  static const String _conjunto2Sad = 'assets/images/conjunto 2 triste.png';
  static const String _conjunto2Cry = 'assets/images/conjunto 2 llorando.png';

  int _selectedActionIndex = 0;
  String _petName = 'Pingui';
  bool _isEditingName = false;
  late final TextEditingController _nameController;
  final FocusNode _nameFocus = FocusNode();
  final math.Random _random = math.Random();
  AnimationController? _snowController;
  List<_Snowflake>? _flakes;
  Timer? _happyTimer;
  final List<Timer> _hungerTimers = [];
  // Tracks which food is being thrown for the feeding animation (null = none)
  Timer? _throwFoodTimer;
  
  String? _throwFoodKey;
  
  // Datos de la mascota desde el backend
  Map<String, dynamic>? _petStatus;
  List<Map<String, dynamic>> _foodInventory = [];
  List<Map<String, dynamic>> _petClothing = [];
  bool _isLoadingPet = true;
  String _loadErrorMessage = '';
  
  // Mapeo de nombres de comida del backend
  Map<String, String> get _foodNameMapping => {
    'Pez': 'pez',
    'Krill': 'camaron',
    'Calamar': 'calamar',
    'Coctel': 'coctel',
  };
  
  double get _foodLevel => _petStatus?['hambre']?.toDouble() ?? 100;
  String _statusMessage = '';
  String _penguinAsset = _defaultHappy;
  // Which outfit is applied: null = none, 0 = conjunto1, 1 = conjunto2
  int? _appliedConjunto;
  

  static const List<String> _feedMessages = [
    'que rico',
    'super peces!',
    'delicioso',
  ];

  void _ensureSnow() {
    if (_snowController != null && _flakes != null) {
      return;
    }

    _snowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    final math.Random random = math.Random(17);
    _flakes = List.generate(42, (index) {
      return _Snowflake(
        x: random.nextDouble(),
        y: random.nextDouble(),
        radius: 1.2 + random.nextDouble() * 2.6,
        speed: 0.18 + random.nextDouble() * 0.38,
        drift: (random.nextDouble() * 2 - 1) * 0.06,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: _petName);
    _ensureSnow();
    _loadPetData();
    _updatePenguinByLevel();
  }

  /// Carga los datos de la mascota desde el backend
  Future<void> _loadPetData() async {
    try {
      setState(() => _isLoadingPet = true);
      
      // Cargar estado de mascota, comidas y ropa en paralelo
      final petStatus = await ApiClient().getPetStatus();
      final foods = await ApiClient().getPetFoods();
      final clothing = await ApiClient().getPetClothing();
      
      setState(() {
        _petStatus = petStatus;
        _foodInventory = foods;
        _petClothing = clothing;
        _petName = petStatus['nombre'] ?? 'Pingui';
        _nameController.text = _petName;
        _isLoadingPet = false;
        _loadErrorMessage = '';
        
        // Obtener la ropa que está equipada actualmente
        final equipadaIndex = _petClothing.indexWhere((r) => r['esta_equipado'] == true);
        if (equipadaIndex >= 0) {
          final nombreEquipado = (_petClothing[equipadaIndex]['nombre_ropa'] as String?)?.toLowerCase() ?? '';
          // Si la equipada es "vacio", significa que la mascota no tiene ropa
          if (nombreEquipado == 'vacio') {
            _appliedConjunto = null;
          } else {
            _appliedConjunto = equipadaIndex;
          }
        }
      });
      
      debugPrint('✅ Datos de mascota cargados: ${_petName}, hambre=${_foodLevel.toInt()}');
      debugPrint('🍽️ Comidas cargadas: ${_foodInventory.length} tipos');
      debugPrint('👕 Ropa cargada: ${_petClothing.length} prendas');
      
      _updatePenguinByLevel();
      
      // Iniciar timer de descenso de hambre
      _startHungerDecreaseTimer();
    } catch (e) {
      setState(() {
        _isLoadingPet = false;
        _loadErrorMessage = 'Error: $e';
      });
      debugPrint('❌ Error cargando mascota: $e');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ensureSnow();
  }

  @override
  void dispose() {
    _snowController?.dispose();
    _happyTimer?.cancel();
    _cancelHungerTimers();
    _throwFoodTimer?.cancel();
    _nameController.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  void _selectAction(int index) {
    setState(() => _selectedActionIndex = index);
  }

  void _cancelHungerTimers() {
    for (final Timer timer in _hungerTimers) {
      timer.cancel();
    }
    _hungerTimers.clear();
  }

  /// Inicia el timer para disminuir el hambre cada 60 segundos (1 punto por minuto)
  void _startHungerDecreaseTimer() {
    _cancelHungerTimers();
    
    final timer = Timer.periodic(const Duration(seconds: 60), (_) async {
      if (!mounted || _petStatus == null) return;
      
      final currentHunger = _foodLevel.toInt();
      
      if (currentHunger > 0) {
        final newHunger = (currentHunger - 1).clamp(0, 100);
        
        debugPrint('🍽️ Hambre disminuyendo: $currentHunger → $newHunger');
        
        try {
          // Actualizar en BD
          final response = await ApiClient().post(
            '/pet/hunger-decrease',
            body: {'cantidad': newHunger},
            needsAuth: true,
          );
          
          // Actualizar UI
          setState(() {
            _petStatus?['hambre'] = newHunger;
          });
          
          _updatePenguinByLevel();
        } catch (e) {
          debugPrint('❌ Error disminuyendo hambre: $e');
        }
      }
    });
    
    _hungerTimers.add(timer);
  }

  void _updatePenguinByLevel() {
    if (!mounted) {
      return;
    }

    String nextAsset;
    String nextStatus = '';

    if (_appliedConjunto != null) {
      if (_appliedConjunto == 0) {
        if (_foodLevel <= 0) {
          nextAsset = _conjunto1Cry;
        } else if (_foodLevel <= 25) {
          nextAsset = _conjunto1Sad;
        } else {
          nextAsset = _conjunto1Base;
        }
      } else if (_appliedConjunto == 1) {
        if (_foodLevel <= 0) {
          nextAsset = _conjunto2Cry;
        } else if (_foodLevel <= 25) {
          nextAsset = _conjunto2Sad;
        } else {
          nextAsset = _conjunto2Base;
        }
      } else {
        nextAsset = _defaultHappy;
      }
    } else {
      if (_foodLevel <= 0) {
        nextAsset = _defaultCry;
      } else if (_foodLevel <= 25) {
        nextAsset = _defaultSad;
      } else {
        nextAsset = _defaultBase;
      }
    }

    if (_foodLevel <= 0) {
      nextStatus = 'deberias alimentarme';
    } else if (_foodLevel <= 25) {
      nextStatus = 'tengo hambre';
    } else if (_foodLevel < 75) {
      nextStatus = 'se me antojan unos peces';
    }

    setState(() {
      _penguinAsset = nextAsset;
      _statusMessage = nextStatus;
    });
  }

  
  void _triggerFoodThrow(String key) {
    _throwFoodTimer?.cancel();
    setState(() => _throwFoodKey = key);
    _throwFoodTimer = Timer(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() => _throwFoodKey = null);
    });
  }

  void _feedPet(String foodName) async {
    // Encontrar la comida en el inventario
    final foodData = _foodInventory.firstWhere(
      (f) => (f['nombreComida'] as String?)?.toLowerCase() == foodName.toLowerCase(),
      orElse: () => {},
    );

    final int available = (foodData['cantidad'] as int?) ?? 0;
    if (available <= 0) {
      setState(() {
        _statusMessage = 'No hay más de ese alimento';
      });
      return;
    }

    _triggerFoodThrow(foodName);
    _happyTimer?.cancel();

    try {
      // Llamar al backend para alimentar la mascota
      final response = await ApiClient().feedPet(foodName);
      
      // Actualizar estado con la respuesta del backend
      setState(() {
        _petStatus = response;
        _statusMessage = _feedMessages[_random.nextInt(_feedMessages.length)];
        
        if (_appliedConjunto == 0) {
          _penguinAsset = _conjunto1Happy;
        } else if (_appliedConjunto == 1) {
          _penguinAsset = _conjunto2Happy;
        } else {
          _penguinAsset = _defaultHappy;
        }
      });

      debugPrint('✅ Mascota alimentada con $foodName, nuevo hambre: ${_foodLevel.toInt()}');

      // Recargar comidas después de 500ms para obtener el inventario actualizado
      _happyTimer = Timer(const Duration(milliseconds: 900), () {
        _loadPetData();
        _updatePenguinByLevel();
      });
    } catch (e) {
      debugPrint('❌ Error alimentando mascota: $e');
      setState(() {
        _statusMessage = 'Error al alimentar';
      });
    }
  }

  void _openCloset() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
            return _ClosetSheet(
          scale: Responsive.scale(context),
          petClothing: _petClothing,
          appliedConjunto: _appliedConjunto,
          onApply: (index) async {
            // Obtener el ID de la ropa
            if (index < _petClothing.length) {
              final ropaId = _petClothing[index]['ropa_id'] as int;
              try {
                await ApiClient().updateClothingEquipped(ropaId, true);
                setState(() {
                  _appliedConjunto = index;
                  // Actualizar visualmente según el nombre de la ropa
                  final nombreRopa = (_petClothing[index]['nombre_ropa'] as String).toLowerCase();
                  if (nombreRopa.contains('conjunto 1') || nombreRopa.contains('paw celeste')) {
                    _penguinAsset = _conjunto1Base;
                  } else if (nombreRopa.contains('conjunto 2') || nombreRopa.contains('paw rosa')) {
                    _penguinAsset = _conjunto2Base;
                  }
                });
                _updatePenguinByLevel();
                debugPrint('✅ Ropa equipada: ${_petClothing[index]['nombre_ropa']}');
              } catch (e) {
                debugPrint('❌ Error equipando ropa: $e');
                _statusMessage = 'Error al equipar ropa';
              }
            }
          },
          onRemove: (index) async {
            // Al remover ropa, equipar la prenda "vacio" (sin ropa)
            final vacioIndex = _petClothing.indexWhere((r) => (r['nombre_ropa'] as String?)?.toLowerCase() == 'vacio');
            if (vacioIndex >= 0) {
              final ropaId = _petClothing[vacioIndex]['ropa_id'] as int;
              try {
                await ApiClient().updateClothingEquipped(ropaId, true);
                setState(() {
                  _appliedConjunto = null;
                  _penguinAsset = _defaultHappy;
                });
                _updatePenguinByLevel();
                debugPrint('✅ Ropa removida - equipada prenda vacio');
              } catch (e) {
                debugPrint('❌ Error removiendo ropa: $e');
                _statusMessage = 'Error al remover ropa';
              }
            }
          },
        );
      },
    );
  }

  void _openFoodMenu() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final double scale = Responsive.scale(context);
        final Map<String, String> assetMap = {
          'pez': 'assets/images/Pez.png',
          'krill': 'assets/images/Camaron.png',
          'camaron': 'assets/images/Camaron.png',
          'calamar': 'assets/images/Calamar.png',
          'coctel': 'assets/images/Coctel de mariscos.png',
        };

        return SafeArea(
          child: LayoutBuilder(builder: (context, constraints) {
            final double maxSheetHeight = constraints.maxHeight * 0.78;
            return Align(
              alignment: Alignment.bottomCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: maxSheetHeight,
                  maxWidth: Responsive.phoneWidth(context),
                ),
                child: Container(
                  margin: EdgeInsets.fromLTRB(16 * scale, 16 * scale, 16 * scale, 24 * scale),
                  padding: EdgeInsets.symmetric(horizontal: 20 * scale, vertical: 18 * scale),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24 * scale),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 24 * scale,
                        offset: Offset(0, 12 * scale),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Menu de comida',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: Responsive.fs(context, 18),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 16 * scale),
                        if (_isLoadingPet)
                          Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.mintPrimary),
                            ),
                          )
                        else if (_foodInventory.isEmpty)
                          Center(
                            child: Text(
                              'Sin comida disponible',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          )
                        else
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _foodInventory.length,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 12 * scale,
                              crossAxisSpacing: 12 * scale,
                              childAspectRatio: 1,
                            ),
                            itemBuilder: (context, index) {
                              final food = _foodInventory[index];
                              final String foodName = food['nombreComida'] ?? '';
                              final int cantidad = food['cantidad'] ?? 0;
                              final String keyLower = foodName.toLowerCase();
                              final String asset = assetMap[keyLower] ?? assetMap['pez'] ?? '';
                              
                              return _buildFoodTile(
                                context,
                                scale,
                                foodName,
                                asset,
                                foodName,
                                cantidad,
                              );
                            },
                          ),
                        SizedBox(height: 8 * scale),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(
                              'Cerrar',
                              style: TextStyle(
                                color: AppColors.blueSecondary,
                                fontSize: Responsive.fs(context, 13),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildFoodTile(BuildContext context, double scale, String label, String? asset, String foodName, int count) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
        _feedPet(foodName);
      },
      borderRadius: BorderRadius.circular(16 * scale),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16 * scale),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.fieldBackground.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(16 * scale),
                border: Border.all(color: AppColors.blueSecondary.withValues(alpha: 0.4), width: 1 * scale),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16 * scale),
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(8 * scale),
                    child: SizedBox(
                      height: (88 * scale).clamp(56, 140),
                      child: asset != null && asset.isNotEmpty
                          ? Image.asset(
                              asset,
                              fit: BoxFit.contain,
                              errorBuilder: (c, e, s) => Center(child: Icon(Icons.fastfood, size: 40 * scale)),
                            )
                          : Icon(Icons.fastfood, size: 40 * scale, color: AppColors.mintPrimary),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 8 * scale,
              top: 8 * scale,
              child: Container(
                width: (36 * scale).clamp(28, 48),
                height: (36 * scale).clamp(28, 48),
                decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: const Color(0xFFECECEC))),
                child: Center(child: Text('$count', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleNameEditing() {
    if (_isEditingName) {
      final String nextName = _nameController.text.trim();
      if (nextName.isNotEmpty && nextName != _petName) {
        // Guardar en BD
        _savePetName(nextName);
      }
      setState(() => _isEditingName = false);
      _nameFocus.unfocus();
    } else {
      setState(() => _isEditingName = true);
      _nameController
        ..text = _petName
        ..selection = TextSelection(baseOffset: 0, extentOffset: _petName.length);
      _nameFocus.requestFocus();
    }
  }

  Future<void> _savePetName(String nuevoNombre) async {
    try {
      final response = await ApiClient().updatePetName(nuevoNombre);
      setState(() {
        _petName = response['nombre'] ?? nuevoNombre;
      });
      debugPrint('✅ Nombre de mascota actualizado a: $_petName');
    } catch (e) {
      debugPrint('❌ Error al actualizar nombre: $e');
      // Revertir en UI si falla
      _nameController.text = _petName;
    }
  }

  @override
  Widget build(BuildContext context) {
    _ensureSnow();
    final double scale = Responsive.scale(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: Responsive.phoneWidth(context)),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/Fondo de mascota.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: const BoxDecoration(gradient: AppColors.splashGradient),
                      );
                    },
                  ),
                ),
                Column(
                  children: [
                    SizedBox(height: 8 * scale),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12 * scale),
                      child: Row(
                        children: [
                          Material(
                            color: Colors.white.withValues(alpha: 0.72),
                            borderRadius: BorderRadius.circular(12 * scale),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12 * scale),
                              onTap: () => Navigator.of(context).pop(),
                              child: SizedBox(
                                width: 42 * scale,
                                height: 42 * scale,
                                child: Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  size: 20 * scale,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12 * scale),
                          Expanded(
                            child: _isEditingName
                                ? TextField(
                                    focusNode: _nameFocus,
                                    controller: _nameController,
                                    textAlign: TextAlign.center,
                                    textCapitalization: TextCapitalization.words,
                                    onSubmitted: (_) => _toggleNameEditing(),
                                    decoration: const InputDecoration(
                                      isDense: true,
                                      border: InputBorder.none,
                                      hintText: 'Nombre de tu mascota',
                                    ),
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: Responsive.fs(context, 18),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  )
                                : Text(
                                    _petName,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: Responsive.fs(context, 18),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                          Material(
                            color: Colors.white.withValues(alpha: 0.72),
                            borderRadius: BorderRadius.circular(12 * scale),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12 * scale),
                              onTap: _toggleNameEditing,
                              child: SizedBox(
                                width: 42 * scale,
                                height: 42 * scale,
                                child: Icon(
                                  Icons.edit_rounded,
                                  size: 20 * scale,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_statusMessage.isNotEmpty)
                            Container(
                              margin: EdgeInsets.only(bottom: 8 * scale),
                              padding: EdgeInsets.symmetric(
                                horizontal: 12 * scale,
                                vertical: 6 * scale,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.82),
                                borderRadius: BorderRadius.circular(16 * scale),
                              ),
                              child: Text(
                                _statusMessage,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: Responsive.fs(context, 12),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Transform.translate(
                                offset: Offset(0, 170 * scale),
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 350),
                                  child: Image.asset(
                                    _penguinAsset,
                                    key: ValueKey<String>(_penguinAsset),
                                    width: 190 * scale,
                                    height: 220 * scale,
                                    fit: BoxFit.contain,
                                    alignment: Alignment.bottomCenter,
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 0 * scale,
                                bottom: 56 * scale,
                                child: AnimatedSlide(
                                  duration: const Duration(milliseconds: 700),
                                  curve: Curves.easeOut,
                                  offset: _throwFoodKey != null ? const Offset(0.95, -1.05) : const Offset(0, 0.35),
                                  child: AnimatedOpacity(
                                    duration: const Duration(milliseconds: 700),
                                            opacity: _throwFoodKey != null ? 1 : 0,
                                            child: IgnorePointer(
                                              child: _throwFoodKey != null
                                                  ? Image.asset(
                                                      _foodAssetForKey(_throwFoodKey!),
                                                      width: 70 * scale,
                                                      fit: BoxFit.contain,
                                                    )
                                                  : const SizedBox.shrink(),
                                            ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 200 * scale),
                          Text(
                            'Comida',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: Responsive.fs(context, 14),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 6 * scale),
                          Container(
                            width: 220 * scale,
                            height: 16 * scale,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.55),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return Align(
                                  alignment: Alignment.centerLeft,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 800),
                                    curve: Curves.easeOut,
                                    width: constraints.maxWidth * (_foodLevel / 100),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFFFF6B6B), Color(0xFFFF5252)],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(height: 12 * scale),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 36 * scale),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _PetActionButton(
                            icon: Icons.restaurant_rounded,
                            isSelected: _selectedActionIndex == 0,
                            scale: scale,
                            onTap: () {
                              _selectAction(0);
                              _openFoodMenu();
                            },
                          ),
                          SizedBox(width: 18 * scale),
                          _PetActionButton(
                            icon: Icons.checkroom_rounded,
                            isSelected: _selectedActionIndex == 1,
                            scale: scale,
                              onTap: () {
                                _selectAction(1);
                                _openCloset();
                              },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedBuilder(
                      animation: _snowController!,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: _SnowPainter(
                            flakes: _flakes!,
                            progress: _snowController!.value,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Snowflake {
  const _Snowflake({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.drift,
  });

  final double x;
  final double y;
  final double radius;
  final double speed;
  final double drift;
}

class _SnowPainter extends CustomPainter {
  const _SnowPainter({
    required this.flakes,
    required this.progress,
  });

  final List<_Snowflake> flakes;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.72)
      ..style = PaintingStyle.fill;

    for (final _Snowflake flake in flakes) {
      final double y = (flake.y + progress * flake.speed) % 1.0;
      double x = (flake.x + progress * flake.drift) % 1.0;
      if (x < 0) {
        x += 1.0;
      }
      canvas.drawCircle(
        Offset(x * size.width, y * size.height),
        flake.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SnowPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.flakes != flakes;
  }
}

class _PetActionButton extends StatelessWidget {
  const _PetActionButton({
    required this.icon,
    required this.isSelected,
    required this.scale,
    required this.onTap,
  });

  final IconData icon;
  final bool isSelected;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final double size = (isSelected ? 64 : 58) * scale;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppColors.primaryGradient,
          boxShadow: [
            BoxShadow(
              color: AppColors.blueSecondary.withValues(alpha: isSelected ? 0.35 : 0.22),
              blurRadius: (isSelected ? 18 : 12) * scale,
              offset: Offset(0, 8 * scale),
            ),
          ],
          border: isSelected
              ? Border.all(color: Colors.white.withValues(alpha: 0.9), width: 2 * scale)
              : null,
        ),
        child: Icon(icon, color: Colors.white, size: 28 * scale),
      ),
    );
  }
}

class _ClosetSheet extends StatefulWidget {
  const _ClosetSheet({
    required this.scale,
    required this.appliedConjunto,
    required this.petClothing,
    this.onApply,
    this.onRemove,
  });

  final double scale;
  final List<Map<String, dynamic>> petClothing;
  // currently applied conjunto index (null = none)
  final int? appliedConjunto;
  final void Function(int)? onApply;
  final void Function(int)? onRemove;

  @override
  State<_ClosetSheet> createState() => _ClosetSheetState();
}

class _ClosetSheetState extends State<_ClosetSheet> {
  static const List<String> _orderedOutfits = [
    'Conjunto 1',
    'Conjunto 2',
    'Conjunto 3',
    'Conjunto 4',
    'Conjunto 5',
  ];

  int? _appliedConjunto;
  // conjunto actualmente seleccionado en el modal (null = ninguno)
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _appliedConjunto = widget.appliedConjunto;
  }

  void _handleSelect(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  String _getClothingImagePath(String nombreRopa) {
    final lower = nombreRopa.toLowerCase();
    if (lower.contains('conjunto 1') || lower.contains('celeste')) {
      return 'assets/images/conjunto 1 base.png';
    } else if (lower.contains('conjunto 2') || lower.contains('rosa')) {
      return 'assets/images/conjunto 2.png';
    } else if (lower.contains('conjunto 3')) {
      return 'assets/images/conjunto 3.png';
    } else if (lower.contains('conjunto 4') || lower.contains('pirata')) {
      return 'assets/images/conjunto 4.png';
    } else if (lower.contains('conjunto 5') || lower.contains('lentes')) {
      return 'assets/images/conjunto 5.png';
    }
    return 'assets/images/conjunto 1 base.png';
  }

  bool _matchesOutfitName(String backendName, String outfitName) {
    final nombre = backendName.toLowerCase();
    final target = outfitName.toLowerCase();
    if (nombre == target || nombre.contains(target)) {
      return true;
    }
    if (target == 'conjunto 1') {
      return nombre.contains('verde') || nombre.contains('celeste');
    }
    if (target == 'conjunto 2') {
      return nombre.contains('morada') || nombre.contains('morado') || nombre.contains('rosa');
    }
    if (target == 'conjunto 4') {
      return nombre.contains('pirata');
    }
    if (target == 'conjunto 5') {
      return nombre.contains('lentes');
    }
    return false;
  }

  Map<String, dynamic>? _findUnlockedOutfit(String outfitName) {
    for (final ropa in widget.petClothing) {
      final nombre = (ropa['nombre_ropa'] as String?)?.toLowerCase() ?? '';
      if (_matchesOutfitName(nombre, outfitName)) {
        return ropa;
      }
    }
    return null;
  }

  int? _originalIndexFor(Map<String, dynamic>? clothingItem) {
    if (clothingItem == null) return null;
    final index = widget.petClothing.indexOf(clothingItem);
    return index >= 0 ? index : null;
  }

  @override
  Widget build(BuildContext context) {
    final double scale = widget.scale;

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double maxSheetHeight = constraints.maxHeight * 0.78;
          return Align(
            alignment: Alignment.bottomCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: maxSheetHeight,
                maxWidth: Responsive.phoneWidth(context),
              ),
              child: Container(
                margin: EdgeInsets.fromLTRB(16 * scale, 16 * scale, 16 * scale, 24 * scale),
                padding: EdgeInsets.symmetric(horizontal: 20 * scale, vertical: 18 * scale),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24 * scale),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 24 * scale,
                      offset: Offset(0, 12 * scale),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(
                    'Closet',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: Responsive.fs(context, 18),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 4 * scale),
                  Text(
                    'Selecciona un conjunto (5 espacios).',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: Responsive.fs(context, 12),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 16 * scale),
                  Builder(
                    builder: (context) {
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _orderedOutfits.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12 * scale,
                          crossAxisSpacing: 12 * scale,
                          childAspectRatio: 1,
                        ),
                        itemBuilder: (context, index) {
                          final String nombreRopa = _orderedOutfits[index];
                          final clothingItem = _findUnlockedOutfit(nombreRopa);
                          final originalIndex = _originalIndexFor(clothingItem);
                          final bool unlocked = clothingItem != null && originalIndex != null;
                          final String imagePath = _getClothingImagePath(nombreRopa);

                          return InkWell(
                            borderRadius: BorderRadius.circular(16 * scale),
                            onTap: unlocked ? () => _handleSelect(originalIndex) : null,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16 * scale),
                              child: Stack(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.fieldBackground.withValues(alpha: 0.8),
                                      borderRadius: BorderRadius.circular(16 * scale),
                                      border: Border.all(
                                        color: unlocked && originalIndex == _appliedConjunto
                                            ? AppColors.mintPrimary
                                            : AppColors.blueSecondary.withValues(alpha: 0.4),
                                        width: 1 * scale,
                                      ),
                                    ),
                                    child: Opacity(
                                      opacity: unlocked ? 1 : 0.38,
                                      child: SizedBox.expand(
                                        child: Image.asset(
                                          imagePath,
                                          fit: BoxFit.cover,
                                          alignment: Alignment.center,
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (!unlocked)
                                    Positioned.fill(
                                      child: Container(
                                        color: Colors.white.withValues(alpha: 0.42),
                                        padding: EdgeInsets.symmetric(horizontal: 8 * scale),
                                        child: Center(
                                          child: Text(
                                            'Obtén esta recompensa realizando tus metas',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: AppColors.textPrimary,
                                              fontSize: Responsive.fs(context, 13),
                                              fontWeight: FontWeight.w800,
                                              height: 1.15,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  if (unlocked && _selectedIndex == originalIndex)
                                    Positioned(
                                      left: 8 * scale,
                                      right: 8 * scale,
                                      bottom: 8 * scale,
                                      child: SizedBox(
                                        height: 36 * scale,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            setState(() {
                                              if (_appliedConjunto == originalIndex) {
                                                _appliedConjunto = null;
                                                widget.onRemove?.call(originalIndex);
                                                return;
                                              }
                                              _appliedConjunto = originalIndex;
                                              widget.onApply?.call(originalIndex);
                                            });
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: _appliedConjunto == originalIndex
                                                ? Colors.white
                                                : AppColors.mintPrimary,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12 * scale),
                                            ),
                                            elevation: 2 * scale,
                                          ),
                                          child: Text(
                                            _appliedConjunto == originalIndex ? 'Quitar' : 'Aplicar',
                                            style: TextStyle(
                                              color: _appliedConjunto == originalIndex ? AppColors.textPrimary : Colors.white,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),

                  SizedBox(height: 8 * scale),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Cerrar',
                        style: TextStyle(
                          color: AppColors.blueSecondary,
                          fontSize: Responsive.fs(context, 13),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
