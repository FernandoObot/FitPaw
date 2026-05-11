import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io' show Platform;

import '../../core/app_colors.dart';
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
  List<XFile?> _todayPhotos = [null, null, null];
  
  // Simulamos un historial de fotos por día
  final Map<String, List<XFile>> _photoHistory = {
    '2 de junio': [],
    '5 de mayo': [],
  };

  Future<void> _takePicture(int index) async {
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
        setState(() {
          _todayPhotos[index] = photo;
          // Agregar al historial de hoy
          _photoHistory['2 de junio']!.add(photo!);
        });
      }
    } catch (e) {
      print('Error taking picture: $e');
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
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16 * scale),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: Responsive.phoneWidth(context)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _photoHistory.entries.map((entry) {
                        final date = entry.key;
                        final photos = entry.value;
                        
                        if (photos.isEmpty) {
                          return SizedBox.shrink();
                        }
                        
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              date,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: Responsive.fs(context, 12),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8 * scale),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 10 * scale,
                                mainAxisSpacing: 10 * scale,
                                childAspectRatio: 1,
                              ),
                              itemCount: photos.length,
                              itemBuilder: (context, index) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(14 * scale),
                                  child: Image.file(
                                    photos[index].path as dynamic,
                                    fit: BoxFit.cover,
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: 16 * scale),
                          ],
                        );
                      }).toList(),
                    ),
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
                  Text(
                    'Hoy',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: Responsive.fs(context, 12),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8 * scale),
                  Row(
                    children: [
                      _InteractivePhotoPlaceholder(
                        size: 92 * scale,
                        photoFile: _todayPhotos[0],
                        onTap: () => _takePicture(0),
                      ),
                      SizedBox(width: 10 * scale),
                      _InteractivePhotoPlaceholder(
                        size: 92 * scale,
                        photoFile: _todayPhotos[1],
                        onTap: () => _takePicture(1),
                      ),
                      SizedBox(width: 10 * scale),
                      _InteractivePhotoPlaceholder(
                        size: 92 * scale,
                        photoFile: _todayPhotos[2],
                        onTap: () => _takePicture(2),
                      ),
                    ],
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
                      _PhotoPlaceholder(size: 92 * scale),
                      SizedBox(width: 10 * scale),
                      _PhotoPlaceholder(size: 92 * scale),
                      SizedBox(width: 10 * scale),
                      _PhotoPlaceholder(size: 92 * scale),
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
    required this.onTap,
    required this.photoFile,
  });

  final double size;
  final VoidCallback onTap;
  final XFile? photoFile;

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
              color: widget.photoFile != null ? Colors.grey[300] : const Color(0xFFE8E8E8),
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
            child: widget.photoFile != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.file(
                      widget.photoFile!.path as dynamic,
                      fit: BoxFit.cover,
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
