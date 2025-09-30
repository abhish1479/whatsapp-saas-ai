// lib/main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'api/api.dart';
import 'controller/onboarding_controller.dart';
import 'screens/onboarding_wizard.dart';

String resolveApiBase() {
  const fromDefine = String.fromEnvironment('API_BASE');
  if (fromDefine.isNotEmpty) return fromDefine;
  return 'https://0b0d30716cca.ngrok-free.app'; // ✅ No trailing space
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
      home: OnboardingWizard(api: api),
      initialBinding: BindingsBuilder(() {
        Get.put(api);
        Get.put(OnboardingController(api)); // ✅ Pass api to controller
      }),
    );
  }
}