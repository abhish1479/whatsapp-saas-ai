import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:humainise_ai/core/routing/app_router.dart';
import 'package:humainise_ai/core/theme/app_theme.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:toastification/toastification.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Supabase first (so any provider that calls Supabase.instance works)
  try {
    await Supabase.initialize(
      url: dotenv.env['VITE_SUPABASE_URL']!,
      anonKey: dotenv.env['VITE_SUPABASE_PUBLISHABLE_KEY']!,
    );
    debugPrint('✅ Supabase initialized');
  } catch (e) {
    debugPrint('⚠️ Supabase init failed: $e');
  }

// ✅ Initialize Firebase
  try {
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyBXal3rxC8vav5BvxJqoHUqHLN_yoeV9Bw",
          authDomain: "whatsapp-saas-3ed90.firebaseapp.com",
          projectId: "whatsapp-saas-3ed90",
          storageBucket: "whatsapp-saas-3ed90.firebasestorage.app",
          messagingSenderId: "734195415255",
          appId: "1:734195415255:web:ca824a4e8a3a97d091d892",
          measurementId: "G-WNVHGN378H",
        ),
      );
    } else {
      await Firebase.initializeApp();
    }
    debugPrint('✅ Firebase initialized');
  } catch (e) {
    debugPrint('⚠️ Firebase init failed: $e');
  }
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return ToastificationWrapper(
      // ✅ Wrap MaterialApp with this
      child: MaterialApp.router(
        title: 'HumAInise.ai',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light, // Set to light as per index.css
        debugShowCheckedModeBanner: false,
        routerConfig: router,
      ),
    );
  }
}
