import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/splash_screen.dart';
import 'theme/aqua_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF091438),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const AquaControlApp());
}

class AquaControlApp extends StatelessWidget {
  const AquaControlApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AquaControl',
      debugShowCheckedModeBanner: false,
      theme: AquaTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}
