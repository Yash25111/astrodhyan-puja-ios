import 'package:flutter/material.dart';
import '../../../widgets/app_appbar.dart';
import '../history/history_screen.dart';
import '../profile/profile_screen.dart';
import '../puja/home_puja_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int i = 0;
  static const titles = ['Home', 'My Bookings', 'Profile'];
  final pages = const [HomePujaScreen(), HistoryScreen(), ProfileScreen()];
  @override
  Widget build(BuildContext c) => Scaffold(
    appBar: i == 0
        ? null
        : AppAppBar(titleText: titles[i], automaticallyImplyLeading: false),
    body: IndexedStack(index: i, children: pages),
    bottomNavigationBar: NavigationBar(
      selectedIndex: i,
      onDestinationSelected: (v) => setState(() => i = v),
      indicatorColor: const Color(0xFFFFE4CF),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.history_outlined),
          selectedIcon: Icon(Icons.history),
          label: 'History',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    ),
  );
}
