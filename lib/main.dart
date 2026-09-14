import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/splash_screen.dart';
import 'services/background_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppColors.background,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  await BackgroundService.initialize();
  await BackgroundService.registerPeriodicCheck();

  runApp(const NaiApp());
}

class NaiApp extends StatelessWidget {
  const NaiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NAI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.dark,
      home: const SplashScreen(),
    );
  }
}
