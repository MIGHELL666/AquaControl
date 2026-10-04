import 'dart:ui' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/role_selection_screen.dart';
import 'theme/aqua_theme.dart';
import 'theme/aqua_colors.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AquaColors.iceBlue,
      systemNavigationBarIconBrightness: Brightness.dark,
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
      theme: AquaTheme.lightTheme,
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        physics: const BouncingScrollPhysics(),
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
          PointerDeviceKind.trackpad,
          PointerDeviceKind.stylus,
        },
      ),
      home: const RoleSelectionScreen(),
    );
  }
}
