import 'package:flutter/material.dart';

import '../../../app_colors.dart';
import '../../../widgets/app_appbar.dart';
import '../../../widgets/app_card.dart';

class TermsPrivacyScreen extends StatelessWidget {
  const TermsPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppAppBar(titleText: 'Terms & Privacy'),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: const [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Terms of Use',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 8),
                Text(
                  'By using this app, you agree to use Astro Dhyaan services responsibly and provide accurate booking information.',
                  style: TextStyle(color: AppColors.subheading, height: 1.4),
                ),
                SizedBox(height: 18),
                Text(
                  'Privacy Policy',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 8),
                Text(
                  'Your account, booking, and payment details are used to provide puja services, order history, and customer support.',
                  style: TextStyle(color: AppColors.subheading, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
