import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app_colors.dart';
import 'core/network/http_service.dart';
import 'core/storage/local_storage.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/booking_repository.dart';
import 'data/repositories/profile_repository.dart';
import 'data/repositories/puja_repository.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/booking/booking_bloc.dart';
import 'presentation/bloc/history/history_bloc.dart';
import 'presentation/bloc/profile/profile_bloc.dart';
import 'presentation/bloc/puja/puja_bloc.dart';
import 'presentation/router/app_router.dart';
class PujaApp extends StatefulWidget {
  const PujaApp({
    super.key
  }
  );
  @override
  State<PujaApp> createState() => _PujaAppState();
}
class _PujaAppState extends State<PujaApp> {
  late final LocalStorage storage;
  late final HttpService http;
  late final AuthRepository authRepository;
  late final PujaRepository pujaRepository;
  late final BookingRepository bookingRepository;
  late final ProfileRepository profileRepository;
  @override
  void initState() {
    super.initState();
    storage = LocalStorage();
    http = HttpService(storage: storage);
    authRepository = AuthRepository(http: http, storage: storage);
    pujaRepository = PujaRepository(http: http);
    bookingRepository = BookingRepository(http: http);
    profileRepository = ProfileRepository(http: http, storage: storage);
  }
  @override
  void dispose() {
    http.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
    providers: [
    RepositoryProvider.value(value: storage),
    RepositoryProvider.value(value: authRepository),
    RepositoryProvider.value(value: pujaRepository),
    RepositoryProvider.value(value: bookingRepository),
    RepositoryProvider.value(value: profileRepository),
    ],
    child: MultiBlocProvider(
    providers: [
    BlocProvider(
    create: (_) => AuthBloc(authRepository)..add(const AuthStarted()),
    ),
    BlocProvider(create: (_) => PujaBloc(pujaRepository)),
    BlocProvider(create: (_) => BookingBloc(bookingRepository)),
    BlocProvider(create: (_) => HistoryBloc(bookingRepository)),
    BlocProvider(create: (_) => ProfileBloc(profileRepository)),
    ],
    child: MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Divine Puja',
    theme: _theme,
    initialRoute: AppRouter.splash,
    onGenerateRoute: AppRouter.onGenerateRoute,
    ),
    ),
    );
  }
  ThemeData get _theme {
    final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.light,
    );
    return ThemeData(
    useMaterial3: true,
    colorScheme: scheme.copyWith(
    primary: AppColors.primary,
    onPrimary: Colors.white,
    surface: AppColors.surface,
    ),
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: 'sans',
    appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.appBar,
    foregroundColor: AppColors.heading,
    elevation: 0,
    centerTitle: false,
    ),
    inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surface,
    labelStyle: const TextStyle(color: AppColors.subheading),
    hintStyle: const TextStyle(color: AppColors.grey),
    border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(14)),
    borderSide: BorderSide(color: AppColors.border),
    ),
    enabledBorder: const OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(14)),
    borderSide: BorderSide(color: AppColors.border),
    ),
    focusedBorder: const OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(14)),
    borderSide: BorderSide(color: AppColors.primary, width: 1.5),
    ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
    minimumSize: const Size.fromHeight(52),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.border),
    );
  }
}
