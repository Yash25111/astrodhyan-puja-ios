import 'package:flutter/material.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/otp_screen.dart';
import '../screens/auth/splash_screen.dart';
import '../screens/home/home_shell.dart';
import '../screens/puja/puja_detail_screen.dart';
import '../screens/puja/puja_booking_screen.dart';
import '../screens/puja/puja_list_screen.dart';
import '../screens/booking/booking_success_screen.dart';
import '../screens/history/transaction_detail_screen.dart';
import '../screens/profile/profile_edit_screen.dart';

class AppRouter {
  static const splash = '/',
      login = '/login',
      otp = '/otp',
      home = '/home',
      detail = '/detail',
      pujaList = '/pujas',
      booking = '/booking',
      success = '/success',
      transaction = '/transaction',
      profileEdit = '/profile/edit';
  static Route<dynamic> onGenerateRoute(RouteSettings s) {
    switch (s.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case otp:
        return MaterialPageRoute(
          builder: (_) => OtpScreen(phone: s.arguments as String),
        );
      case home:
        return MaterialPageRoute(builder: (_) => const HomeShell());
      case pujaList:
        return MaterialPageRoute(builder: (_) => const PujaListScreen());
      case detail:
        return MaterialPageRoute(
          builder: (_) => PujaDetailScreen(id: s.arguments as String),
        );
      case booking:
        return MaterialPageRoute(
          builder: (_) => PujaBookingScreen(data: s.arguments as BookingData),
        );
      case success:
        return MaterialPageRoute(
          builder: (_) =>
              BookingSuccessScreen(data: s.arguments as SuccessData),
        );
      case transaction:
        return MaterialPageRoute(
          builder: (_) => TransactionDetailScreen(id: s.arguments as String),
        );
      case profileEdit:
        return MaterialPageRoute(builder: (_) => const ProfileEditScreen());
      default:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
    }
  }
}

class BookingData {
  final String pujaId, title, date, location, packageId, packageType;
  final num packagePrice;
  final int members;
  final List<BookingOffering> offerings;
  const BookingData({
    required this.pujaId,
    required this.title,
    required this.date,
    required this.location,
    required this.packageId,
    required this.packageType,
    required this.packagePrice,
    required this.members,
    required this.offerings,
  });
}

class BookingOffering {
  final String id, title, description, image;
  final num price;
  const BookingOffering({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.price,
  });
}

class SuccessData {
  final String orderId, transactionId, paymentId, signature;
  final num amount;
  const SuccessData({
    required this.orderId,
    required this.transactionId,
    required this.paymentId,
    required this.signature,
    required this.amount,
  });
}
