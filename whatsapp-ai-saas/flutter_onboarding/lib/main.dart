// lib/main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'api/api.dart';
import 'controller/catalog_controller.dart';
import 'controller/onboarding_controller.dart';
// Import your new check screen and home screen
import 'screens/check_auth_screen.dart'; // Create this
// import 'screens/home_screen.dart'; // Create this later

String resolveApiBase() {
  const fromDefine = String.fromEnvironment('API_BASE');
  if (fromDefine.isNotEmpty) return fromDefine;
  return 'https://depictive-expiringly-jazmin.ngrok-free.dev'; // Ensure no trailing space
  // return 'https://0b0d30716cca.ngrok-free.app'; // Ensure no trailing space
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final api = Api(resolveApiBase());
    return GetMaterialApp(
      title: 'WhatsApp AI Onboarding',
      theme: ThemeData(useMaterial3: true),
      // Change the home to the new check screen
      home: CheckAuthScreen(api: api),
      initialBinding: BindingsBuilder(() {
        Get.put(api);
        Get.put(OnboardingController(api));
        Get.put(CatalogController(api));
      }),
    );
  }
}