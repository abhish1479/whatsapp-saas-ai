// lib/main.dart
import 'package:flutter/material.dart';
import '/api.dart';
import '/screens/onboarding_wizard.dart';

String resolveApiBase() {
  const fromDefine = String.fromEnvironment('API_BASE');
  if (fromDefine.isNotEmpty) return fromDefine;
  // sensible defaults for dev
  // return 'http://localhost:8000';
  return 'https://0b0d30716cca.ngrok-free.app';
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
    return MaterialApp(
      title: 'WhatsApp AI Onboarding',
      theme: ThemeData(useMaterial3: true),
      home: OnboardingWizard(api: api),
    );
  }
}
