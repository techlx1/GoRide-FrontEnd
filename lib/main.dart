import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/app_export.dart';
import '../routes/app_routes.dart';
import '../widgets/custom_error_widget.dart';
import '../theme/app_theme.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool _hasShownError = false;

  // ✅ Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // ✅ Initialize Supabase
  await Supabase.initialize(
    url: 'https://YOUR-PROJECT-ID.supabase.co', // 🔗 Replace with your Supabase URL
    anonKey: 'YOUR-ANON-KEY', // 🗝 Replace with your Supabase anon key
  );

  // 🚨 Global error widget (to avoid red crash screens)
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

  // 🔒 Lock orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // 🧠 Clear any old session (forces login on first open)
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear(); // 💥 ensures app always opens at login

  // 🚀 Always start from login
  const String initialRoute = AppRoutes.login;

  runApp(MyApp(initialRoute: initialRoute));
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

          routes: AppRoutes.routes,
          initialRoute: initialRoute,
        );
      },
    );
  }
}
