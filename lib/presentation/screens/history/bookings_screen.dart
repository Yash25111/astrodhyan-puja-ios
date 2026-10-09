import 'package:flutter/material.dart';

import '../../../widgets/app_appbar.dart';
import 'history_screen.dart';

class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: AppAppBar(titleText: 'My Bookings'),
      body: HistoryScreen(),
    );
  }
}
