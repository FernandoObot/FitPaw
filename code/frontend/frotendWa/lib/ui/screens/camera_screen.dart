import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../../core/app_colors.dart';
import '../../services/app_services.dart';
import '../../services/api_client.dart';
import '../widgets/responsive.dart';
import 'home_dashboard_screen.dart';
import 'pet_screen.dart';
import 'profile_screen.dart';
import 'activity_history_screen.dart';
import 'training_schedule_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  Uint8List? _todayPhoto;
  List<String?> _recentComparisonPhotos = [null, null, null];
  List<String?> _oldComparisonPhotos = [null, null, null];
  List<_StoredPhoto> _allComparisonPhotos = [];
  bool _loadingComparisonPhotos = true;
  String? _comparisonError;

  @override
  void initState() {
    super.initState();
    _loadComparisonPhotos();
  }

  Future<void> _loadComparisonPhotos() async {
    try {
      await apiClient.loadToken();
      final response = await apiClient.get('/fotos-progreso');

      if (response.statusCode != 200) {
        throw Exception('No se pudieron cargar las fotos guardadas');
      }

      final decoded = jsonDecode(response.body);
      final List<dynamic> rawPhotos = decoded is List<dynamic> ? decoded : <dynamic>[];
      final cutoff = DateTime.now().subtract(const Duration(days: 30));

      final photos = rawPhotos
          .whereType<Map<String, dynamic>>()
          .map((photo) {
            final fechaRaw = photo['fecha']?.toString();
            return _StoredPhoto(
              urlFoto: photo['urlFoto']?.toString() ?? '',
              fecha: fechaRaw != null ? DateTime.tryParse(fechaRaw) : null,
            );
          })
          .where((photo) => photo.urlFoto.isNotEmpty)
          .toList()
        ..sort((a, b) {
          final aFecha = a.fecha ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bFecha = b.fecha ?? DateTime.fromMillisecondsSinceEpoch(0);
          return aFecha.compareTo(bFecha);
        });

      // Store full list sorted by fecha DESC for the "Ver más" view
      final allPhotosDesc = List<_StoredPhoto>.from(photos)
        ..sort((a, b) {
          final aFecha = a.fecha ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bFecha = b.fecha ?? DateTime.fromMillisecondsSinceEpoch(0);
          return bFecha.compareTo(aFecha);
        });

        final oldUrls = photos
          .where((photo) => photo.fecha == null || photo.fecha!.isBefore(cutoff))
          .take(3)
          .map((photo) => photo.urlFoto)
          .toList();

        final recentUrls = photos
          .where((photo) => photo.fecha != null && !photo.fecha!.isBefore(cutoff))
          .take(3)
          .map((photo) => photo.urlFoto)
          .toList();

      if (!mounted) {
        return;
      }

      setState(() {
        _oldComparisonPhotos = oldUrls;
        _recentComparisonPhotos = recentUrls;
        _allComparisonPhotos = allPhotosDesc;
        _loadingComparisonPhotos = false;
        _comparisonError = null;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loadingComparisonPhotos = false;
        _comparisonError = 'No se pudieron cargar las fotos de comparación';
      });
    }
  }

  Future<void> _takePicture() async {
    try {
      late XFile? photo;
      
      // En Android/iOS, usa la cámara
      if (Platform.isAndroid || Platform.isIOS) {
        photo = await _imagePicker.pickImage(
          source: ImageSource.camera,
          preferredCameraDevice: CameraDevice.front,
        );
      } else {
        // En web y otros, aún usa image_picker pero intenta con cámara
        photo = await _imagePicker.pickImage(
          source: ImageSource.camera,
        );
      }
      
      if (photo != null) {
        final bytes = await photo.readAsBytes();
        setState(() {
          _todayPhoto = bytes;
        });

        await _uploadCapturedPhoto(photo, bytes);
        await _loadComparisonPhotos();
      }
    } catch (e) {
      print('Error taking picture: $e');
    }
  }

  Future<void> _uploadCapturedPhoto(XFile photo, Uint8List bytes) async {
    await apiClient.loadToken();
    final token = apiClient.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('No hay sesión activa para subir la foto');
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiClient.baseUrl}/fotos-progreso'),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(
      http.MultipartFile.fromBytes(
        'foto',
        bytes,
        filename: photo.name.isNotEmpty ? photo.name : 'captura.jpg',
      ),
    );

    final response = await request.send();
    if (response.statusCode != 200 && response.statusCode != 201) {
      final body = await response.stream.bytesToString();
      throw Exception('No se pudo guardar la foto: ${response.statusCode} $body');
    }
  }
  
  void _showAllPhotos(BuildContext context) {
    final double scale = Responsive.scale(context);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24 * scale)),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.95,
        decoration: BoxDecoration(
          color: const Color(0xFFF3F3F3),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24 * scale)),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16 * scale),
              child: Row(
                children: [
                  Text(
                    'Todas las fotos',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: Responsive.fs(context, 18),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.close, size: 24 * scale, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16 * scale),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: Responsive.phoneWidth(context)),
                    child: _allComparisonPhotos.isEmpty
                        ? Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: 24 * scale),
                              child: Text(
                                'No hay fotos disponibles',
                                style: TextStyle(color: AppColors.textSecondary, fontSize: Responsive.fs(context, 14)),
                              ),
                            ),
                          )
                        : LayoutBuilder(builder: (context, constraints) {
                            final width = constraints.maxWidth;
                            final int crossAxisCount = width >= 600 ? 4 : (width >= 400 ? 3 : 2);

                            return GridView.builder(
                              padding: EdgeInsets.only(top: 8 * scale, bottom: 24 * scale),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 10 * scale,
                                mainAxisSpacing: 10 * scale,
                                childAspectRatio: 0.82,
                              ),
                              itemCount: _allComparisonPhotos.length,
                              itemBuilder: (context, index) {
                                final photo = _allComparisonPhotos[index];
                                return GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (_) => Dialog(
                                        insetPadding: EdgeInsets.all(16 * scale),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            AspectRatio(
                                              aspectRatio: 1,
                                              child: Image.network(photo.urlFoto, fit: BoxFit.cover),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.all(8 * scale),
                                              child: Text(
                                                _formatPhotoDate(photo.fecha),
                                                style: TextStyle(
                                                  color: AppColors.textSecondary,
                                                  fontSize: Responsive.fs(context, 12),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(14 * scale),
                                          child: Image.network(
                                            photo.urlFoto,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) => Center(
                                              child: Icon(Icons.broken_image_outlined, color: AppColors.mintPrimary, size: 36 * scale),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 6 * scale),
                                      Text(
                                        _formatPhotoDate(photo.fecha),
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: Responsive.fs(context, 10),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          }),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double scale = Responsive.scale(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: Responsive.phoneWidth(context)),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(24 * scale, 16 * scale, 24 * scale, 24 * scale),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            'Fotos de progreso',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: Responsive.fs(context, 20),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        SizedBox(height: 8 * scale),
                  Row(
                    children: [
                      Text(
                        'Galería',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: Responsive.fs(context, 16),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      _VerMasButton(onTap: () => _showAllPhotos(context)),
                    ],
                  ),
                  SizedBox(height: 8 * scale),
                  Center(
                    child: Column(
                      children: [
                        _InteractivePhotoPlaceholder(
                          size: 112 * scale,
                          photoBytes: _todayPhoto,
                          onTap: _takePicture,
                        ),
                        SizedBox(height: 8 * scale),
                        Text(
                          'Toca para tomar una foto',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: Responsive.fs(context, 12),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24 * scale),
                  Center(
                    child: Text(
                      'Compara tu progreso',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: Responsive.fs(context, 16),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(height: 14 * scale),
                  Text(
                    'Fotos recientes',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: Responsive.fs(context, 12),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8 * scale),
                  if (_loadingComparisonPhotos)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 16 * scale),
                      child: const CircularProgressIndicator(),
                    )
                  else if (_comparisonError != null)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8 * scale),
                      child: Text(
                        _comparisonError!,
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: Responsive.fs(context, 12),
                        ),
                      ),
                    )
                  else
                    Row(
                      children: [
                        _InteractivePhotoPlaceholder(size: 92 * scale, imageUrl: _recentComparisonPhotos[0]),
                        SizedBox(width: 10 * scale),
                        _InteractivePhotoPlaceholder(size: 92 * scale, imageUrl: _recentComparisonPhotos[1]),
                        SizedBox(width: 10 * scale),
                        _InteractivePhotoPlaceholder(size: 92 * scale, imageUrl: _recentComparisonPhotos[2]),
                      ],
                    ),
                  SizedBox(height: 14 * scale),
                  Text(
                    'Hace tiempo',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: Responsive.fs(context, 12),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8 * scale),
                  Row(
                    children: [
                      _InteractivePhotoPlaceholder(size: 92 * scale, imageUrl: _oldComparisonPhotos[0]),
                      SizedBox(width: 10 * scale),
                      _InteractivePhotoPlaceholder(size: 92 * scale, imageUrl: _oldComparisonPhotos[1]),
                      SizedBox(width: 10 * scale),
                      _InteractivePhotoPlaceholder(size: 92 * scale, imageUrl: _oldComparisonPhotos[2]),
                    ],
                  ),
                      ],
                    ),
                  ),
                ),
                _BottomNavBar(scale: scale),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PhotoPlaceholder extends StatelessWidget {
  const _PhotoPlaceholder({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFE8E8E8),
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}

class _InteractivePhotoPlaceholder extends StatefulWidget {
  const _InteractivePhotoPlaceholder({
    required this.size,
    this.photoBytes,
    this.imageUrl,
    this.onTap,
  });

  final double size;
  final VoidCallback? onTap;
  final Uint8List? photoBytes;
  final String? imageUrl;

  @override
  State<_InteractivePhotoPlaceholder> createState() => _InteractivePhotoPlaceholderState();
}

class _InteractivePhotoPlaceholderState extends State<_InteractivePhotoPlaceholder> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _onHover(bool isHovered) {
    setState(() => _isHovered = isHovered);
    if (isHovered) {
      _scaleController.forward();
    } else {
      _scaleController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: ScaleTransition(
          scale: Tween<double>(begin: 1.0, end: 1.08).animate(
            CurvedAnimation(parent: _scaleController, curve: Curves.easeOut),
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: (widget.photoBytes != null || widget.imageUrl != null) ? Colors.grey[300] : const Color(0xFFE8E8E8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isHovered ? AppColors.mintPrimary : Colors.transparent,
                width: 2,
              ),
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: AppColors.mintPrimary.withValues(alpha: 0.3),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ]
                  : [],
            ),
            child: widget.photoBytes != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.memory(
                      widget.photoBytes!,
                      fit: BoxFit.cover,
                      width: widget.size,
                      height: widget.size,
                    ),
                  )
                : widget.imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(
                      widget.imageUrl!,
                      fit: BoxFit.cover,
                      width: widget.size,
                      height: widget.size,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(
                            Icons.broken_image_outlined,
                            color: AppColors.mintPrimary,
                            size: widget.size * 0.35,
                          ),
                        );
                      },
                    ),
                  )
                : Center(
                    child: Icon(
                      Icons.camera_alt_outlined,
                      color: AppColors.mintPrimary,
                      size: widget.size * 0.35,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _StoredPhoto {
  const _StoredPhoto({required this.urlFoto, required this.fecha});

  final String urlFoto;
  final DateTime? fecha;
}

String _formatPhotoDate(DateTime? dateTime) {
  if (dateTime == null) {
    return '';
  }

  final day = dateTime.day.toString().padLeft(2, '0');
  final month = dateTime.month.toString().padLeft(2, '0');
  final year = dateTime.year.toString();
  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');
  return '$day/$month/$year $hour:$minute';
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 88 * scale,
      decoration: BoxDecoration(
        color: const Color(0xFFF4EEEF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24 * scale)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _BottomBarIcon(
            icon: Icons.home_rounded,
            scale: scale,
            onTap: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => HomeDashboardScreen()),
                (route) => false,
              );
            },
          ),
          _BottomBarIcon(
            icon: Icons.query_stats_rounded,
            scale: scale,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => TrainingScheduleScreen(
                exerciseTitle: 'Programa de entrenamiento',
                exerciseSubtitle: 'Tu plan personalizado',
                exerciseIcon: Icons.query_stats_rounded,
              )));
            },
          ),
          _BottomBarIcon(
            icon: Icons.pets_rounded,
            scale: scale,
            isPrimary: true,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => PetScreen()));
            },
          ),
          _BottomBarIcon(
            icon: Icons.camera_alt_outlined,
            scale: scale,
            isActive: true,
            onTap: () {
              // If already on camera screen, do nothing; otherwise push camera screen.
              // Using pushReplacement to avoid stacking multiple camera screens.
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => CameraScreen()));
            },
          ),
          _BottomBarIcon(
            icon: Icons.person_outline_rounded,
            scale: scale,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
            },
          ),
        ],
      ),
    );
  }
}

class _BottomBarIcon extends StatelessWidget {
  const _BottomBarIcon({
    required this.icon,
    required this.scale,
    required this.onTap,
    this.isActive = false,
    this.isPrimary = false,
  });

  final IconData icon;
  final double scale;
  final VoidCallback onTap;
  final bool isActive;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    if (isPrimary) {
      return GestureDetector(
        onTap: onTap,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          scale: isActive ? 1.08 : 1,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: isActive ? 62 * scale : 58 * scale,
            height: isActive ? 62 * scale : 58 * scale,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.primaryGradient,
              boxShadow: [
                BoxShadow(
                  color: AppColors.blueSecondary.withValues(alpha: isActive ? 0.35 : 0.20),
                  blurRadius: (isActive ? 18 : 12) * scale,
                  offset: Offset(0, 8 * scale),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 30 * scale),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(horizontal: 8 * scale, vertical: 6 * scale),
        decoration: BoxDecoration(
          color: isActive ? AppColors.mintPrimary.withValues(alpha: 0.16) : Colors.transparent,
          borderRadius: BorderRadius.circular(14 * scale),
        ),
        child: Icon(
          icon,
          size: 27 * scale,
          color: isActive ? AppColors.mintPrimary : AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _VerMasButton extends StatefulWidget {
  const _VerMasButton({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_VerMasButton> createState() => _VerMasButtonState();
}

class _VerMasButtonState extends State<_VerMasButton> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _onHover(bool isHovered) {
    setState(() => _isHovered = isHovered);
    if (isHovered) {
      _scaleController.forward();
    } else {
      _scaleController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: ScaleTransition(
          scale: Tween<double>(begin: 1.0, end: 1.1).animate(
            CurvedAnimation(parent: _scaleController, curve: Curves.easeOut),
          ),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 150),
            style: TextStyle(
              color: _isHovered ? AppColors.mintPrimary : AppColors.textSecondary,
              fontSize: Responsive.fs(context, 12),
              fontWeight: FontWeight.w600,
            ),
            child: const Text('Ver más'),
          ),
        ),
      ),
    );
  }
}
