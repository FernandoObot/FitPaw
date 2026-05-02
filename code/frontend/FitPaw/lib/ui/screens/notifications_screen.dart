import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../widgets/responsive.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double scale = Responsive.scale(context);

    final List<_NotificationItem> notifications = [
      _NotificationItem(
        icon: Icons.fitness_center_rounded,
        title: 'Hey, es tiempo de entrenar!',
        time: 'Hace un minuto',
        iconBackground: const Color(0xFFE6F4F0),
      ),
      _NotificationItem(
        icon: Icons.directions_run_rounded,
        title: 'No te pierdas tu entrenamiento de espalda',
        time: 'Hace 3 horas',
        iconBackground: const Color(0xFFE4F1FA),
      ),
      _NotificationItem(
        icon: Icons.restaurant_rounded,
        title: 'Alimentame por favor!!',
        time: 'Hace 3 horas',
        iconBackground: const Color(0xFFFFF0D9),
      ),
      _NotificationItem(
        icon: Icons.celebration_rounded,
        title: 'Felicidades, haz alcanzado tu meta ...',
        time: '29 de mayo',
        iconBackground: const Color(0xFFE9F6F2),
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: Responsive.phoneWidth(context)),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(20 * scale, 12 * scale, 20 * scale, 10 * scale),
                  child: Row(
                    children: [
                      Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12 * scale),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12 * scale),
                          onTap: () => Navigator.pop(context),
                          child: SizedBox(
                            width: 36 * scale,
                            height: 36 * scale,
                            child: Icon(
                              Icons.chevron_left_rounded,
                              color: AppColors.textPrimary,
                              size: 22 * scale,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            'Notificaciones',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: Responsive.fs(context, 18),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 36 * scale),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(20 * scale, 4 * scale, 20 * scale, 24 * scale),
                    child: Column(
                      children: [
                        for (int index = 0; index < notifications.length; index++)
                          _NotificationTile(
                            item: notifications[index],
                            showDivider: index != notifications.length - 1,
                          ),
                      ],
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

class _NotificationItem {
  const _NotificationItem({
    required this.icon,
    required this.title,
    required this.time,
    required this.iconBackground,
  });

  final IconData icon;
  final String title;
  final String time;
  final Color iconBackground;
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.item,
    required this.showDivider,
  });

  final _NotificationItem item;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final double scale = Responsive.scale(context);

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 12 * scale),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44 * scale,
                height: 44 * scale,
                decoration: BoxDecoration(
                  color: item.iconBackground,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item.icon,
                  color: AppColors.textPrimary,
                  size: 22 * scale,
                ),
              ),
              SizedBox(width: 12 * scale),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: Responsive.fs(context, 15),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4 * scale),
                    Text(
                      item.time,
                      style: TextStyle(
                        color: AppColors.faintText,
                        fontSize: Responsive.fs(context, 12),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Container(
            height: 1,
            color: const Color(0xFFE1E1E1),
          ),
      ],
    );
  }
}
