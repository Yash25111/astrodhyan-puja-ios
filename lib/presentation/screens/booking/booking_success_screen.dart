import 'package:flutter/material.dart';

import '../../../app_colors.dart';
import '../../../widgets/app_appbar.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_card.dart';
import '../../router/app_router.dart';

class BookingSuccessScreen extends StatelessWidget {
  final SuccessData data;

  const BookingSuccessScreen({super.key, required this.data});

  @override
  Widget build(BuildContext c) {
    return Scaffold(
      appBar: const AppAppBar(
        titleText: 'Booking Confirmed',
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 30),
            Container(
              width: 90,
              height: 90,
              decoration: const BoxDecoration(
                color: Color(0xFFDDF5E8),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                size: 52,
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'Booking Confirmed!',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your payment was completed and your puja booking is confirmed.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.subheading, height: 1.5),
            ),
            const SizedBox(height: 24),
            AppCard(
              child: Column(
                children: [
                  _r('Order ID', data.orderId),
                  const SizedBox(height: 10),
                  _r('Payment ID', data.paymentId),
                  const SizedBox(height: 10),
                  _r('Total Amount', '₹${data.amount}'),
                  const SizedBox(height: 10),
                  _r('Status', 'Confirmed', color: AppColors.success),
                ],
              ),
            ),
            const Spacer(),
            AppButton(
              text: 'Go to Home',
              width: double.infinity,
              onPressed: () => Navigator.pushNamedAndRemoveUntil(
                c,
                AppRouter.home,
                (_) => false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _r(String a, String b, {Color? color}) {
  return Row(
    children: [
      Expanded(
        child: Text(a, style: const TextStyle(color: AppColors.subheading)),
      ),
      Flexible(
        child: Text(
          b,
          textAlign: TextAlign.end,
          style: TextStyle(fontWeight: FontWeight.w800, color: color),
        ),
      ),
    ],
  );
}
