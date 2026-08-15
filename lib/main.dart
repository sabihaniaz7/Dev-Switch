import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_colors.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  // Enables edge-to-edge rendering on modern Android devices
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Ensures gradient flows underneath
      systemStatusBarContrastEnforced:
          false, // Disables Android's grey contrast line
      statusBarIconBrightness:
          Brightness.dark, // Android icon color (dark/light)
      statusBarBrightness:
          Brightness.light, // iOS status bar content brightness
    ),
  );
  runApp(const DevSwitchApp());
}

class DevSwitchApp extends StatelessWidget {
  const DevSwitchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dev Switch',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'Roboto',
      ),
      home: const HomeScreen(),
    );
  }
}
