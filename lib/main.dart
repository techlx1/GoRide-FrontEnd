import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/app_export.dart';
import '../routes/app_routes.dart';
import '../widgets/custom_error_widget.dart';
import '../theme/app_theme.dart';
import 'firebase_options.dart';

// Providers
import '../providers/auth_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool _hasShownError = false;

  // ---------------------------------------------------------
  // 🔥 Initialize Firebase
  // ---------------------------------------------------------
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // ---------------------------------------------------------
  // 🟢 Initialize Supabase
  // ---------------------------------------------------------
  await Supabase.initialize(
    url: 'https://YOUR-PROJECT-ID.supabase.co',
    anonKey: 'YOUR-ANON-KEY',
  );

  // ---------------------------------------------------------
  // GLOBAL ERROR WIDGET
  // ---------------------------------------------------------
  ErrorWidget.builder = (FlutterErrorDetails details) {
    if (!_hasShownError) {
      _hasShownError = true;
      Future.delayed(const Duration(seconds: 5), () {
        _hasShownError = false;
      });
      return CustomErrorWidget(errorDetails: details);
    }
    return const SizedBox.shrink();
  };

  // ---------------------------------------------------------
  // Force portrait mode
  // ---------------------------------------------------------
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // ---------------------------------------------------------
  // LOAD SAVED USER SESSION BEFORE runApp
  // ---------------------------------------------------------
  final prefs = await SharedPreferences.getInstance();

  final savedToken = prefs.getString("auth_token");
  final savedUserType = prefs.getString("user_type");
  final savedUserId = prefs.getString("user_id");

  String initialRoute;

  // ---------------------------------------------------------
  // Determine startup screens
  // ---------------------------------------------------------
  if (savedToken != null && savedUserType != null) {
    if (savedUserType == "driver" && savedUserId != null) {
      initialRoute = AppRoutes.driverDashboard;
    } else {
      initialRoute = AppRoutes.rideBookingConfirmation;
    }
  } else {
    initialRoute = AppRoutes.login;
  }

  // ---------------------------------------------------------
  // Start App with Providers Available
  // ---------------------------------------------------------
  runApp(
    ProviderScope(
      overrides: [
        authTokenProvider.overrideWith((ref) => savedToken),
        userTypeProvider.overrideWith((ref) => savedUserType),
        driverIdProvider.overrideWith(
              (ref) => savedUserType == "driver" ? savedUserId : null,
        ),
      ],
      child: MyApp(initialRoute: initialRoute),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, screenType) {
        return MaterialApp(
          title: 'RideGuyana',

          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.light,

          debugShowCheckedModeBanner: false,

          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: const TextScaler.linear(1.0),
              ),
              child: child!,
            );
          },

          // ---------------------------------------------------------
          // All Screens Registered Here
          // ---------------------------------------------------------
          routes: AppRoutes.routes,

          initialRoute: initialRoute,
        );
      },
    );
  }
}
