import 'package:flutter/material.dart';

import '../../../app_colors.dart';
import '../../../widgets/app_appbar.dart';
import '../../../widgets/app_card.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppAppBar(titleText: 'Notifications'),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: const [
          AppCard(
            child: Row(
              children: [
                Icon(Icons.notifications_none, color: AppColors.primary),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'No notifications yet.',
                    style: TextStyle(
                      color: AppColors.subheading,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
