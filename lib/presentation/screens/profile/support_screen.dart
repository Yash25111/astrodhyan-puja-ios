import 'package:flutter/material.dart';

import '../../../app_colors.dart';
import '../../../widgets/app_appbar.dart';
import '../../../widgets/app_card.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppAppBar(titleText: 'Help & Support'),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Need help?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 8),
                Text(
                  'For booking, payment, or puja-related support, contact the Astro Dhyaan support team.',
                  style: TextStyle(color: AppColors.subheading, height: 1.4),
                ),
                SizedBox(height: 16),
                _SupportRow(
                  icon: Icons.email_outlined,
                  title: 'Email',
                  value: 'support@astrodhyaan.com',
                ),
                Divider(),
                _SupportRow(
                  icon: Icons.phone_outlined,
                  title: 'Phone',
                  value: 'Contact support from the official app channel',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SupportRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _SupportRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 3),
              Text(value, style: const TextStyle(color: AppColors.subheading)),
            ],
          ),
        ),
      ],
    );
  }
}
