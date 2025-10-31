// lib/main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:leadbot_client/controller/campaign_controller.dart';
import 'package:leadbot_client/controller/monitoring_controller.dart';
import 'api/api.dart';
import 'controller/catalog_controller.dart';
import 'controller/leads_controller.dart';
import 'controller/onboarding_controller.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/check_auth_screen.dart';
import 'package:flutter/foundation.dart';

// String resolveApiBase() {
//   const fromDefine = String.fromEnvironment('API_BASE');
//   if (fromDefine.isNotEmpty) return fromDefine;
//   // return 'https://diglottic-nondisingenuously-gordon.ngrok-free.dev'; // Azim URL
//   return 'https://depictive-expiringly-jazmin.ngrok-free.dev'; // Salman URL
//   // return 'https://0b0d30716cca.ngrok-free.app'; // Ensure no trailing space
// }

String resolveApiBase() {
  // Detect if running on web
  if (kIsWeb) {
    // Use build-time environment vars if available
    const host = String.fromEnvironment('API_HOST', defaultValue: '');
    const port = int.fromEnvironment('API_PORT', defaultValue: 8000);

    // If host not defined, use current browser host
    final uri = Uri.base;
    final baseUri = Uri(
      scheme: uri.scheme,
      host: host.isNotEmpty ? host : uri.host,
      port: port,
    );
    return baseUri.toString();
  } else {
    // Native (mobile or desktop)
    if (kDebugMode) {
      return 'http://localhost:8000';
    } else {
      const apiBase = String.fromEnvironment(
        'API_BASE',
        defaultValue: 'https://api.whatsapp-saas.ai',
      );
      return apiBase;
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyBXal3rxC8vav5BvxJqoHUqHLN_yoeV9Bw",
            authDomain: "whatsapp-saas-3ed90.firebaseapp.com",
            projectId: "whatsapp-saas-3ed90",
            storageBucket: "whatsapp-saas-3ed90.firebasestorage.app",
            messagingSenderId: "734195415255",
            appId: "1:734195415255:web:ca824a4e8a3a97d091d892",
            measurementId: "G-WNVHGN378H"));
  }
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
        Get.put(LeadsController(api));
        Get.put(CampaignController(api));
        Get.put(MonitoringController(api));
      }),
    );
  }
}
