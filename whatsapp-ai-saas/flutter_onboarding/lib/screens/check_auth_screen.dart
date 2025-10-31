// lib/screens/check_auth_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../api/api.dart';
import '../helper/utils/shared_preference.dart';
import 'leads/leads_list_screen.dart';
import 'onboarding_wizard.dart'; // Assuming SignupScreen is part of this
import 'auth_screen.dart'; // Import your auth screen (SignupScreen)
import 'dashboard_root.dart';
class CheckAuthScreen extends StatefulWidget {
  final Api api;

  const CheckAuthScreen({Key? key, required this.api}) : super(key: key);

  @override
  State<CheckAuthScreen> createState() => _CheckAuthScreenState();
}

class _CheckAuthScreenState extends State<CheckAuthScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  void _checkAuthStatus() async {
    // Wait for the widget to be mounted before navigating
    await Future.delayed(Duration.zero);

    // Use your StoreUserData class to check login status
    bool isLoggedIn = await StoreUserData().isLoggedIn();
    String userStatus = await StoreUserData().getUserStatus(); // Check onboarding status

    if (isLoggedIn) {
      // User is logged in, check onboarding status
      if (userStatus.toLowerCase() == 'completed') {
        // Navigate to Home Screen
        if (mounted) {
          Get.offAll(() =>
              // DashboardRoot());
              LeadsListScreen());
        }
      } else {
        // User is logged in but onboarding is not complete, go to onboarding
        if (mounted) {
          Get.offAll(() => OnboardingWizard(api: widget.api));
        }
      }
    } else {
      // User is not logged in, go to Auth Screen (SignupScreen)
      if (mounted) {
        Get.offAll(() => SignupScreen( api: widget.api));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // A simple splash screen UI while checking
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(
          valueColor:
              AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
        ),
      ),
    );
  }
}
