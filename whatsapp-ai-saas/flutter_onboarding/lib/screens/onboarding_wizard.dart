import 'package:flutter/material.dart';
import '../api/api.dart';
import 'business_info.dart';
import 'business_type.dart';
import 'info_capture.dart';
import 'workflow_setup.dart';
import 'payment_setup.dart';
import 'review_activate.dart';
import 'auth_screen.dart';
import 'whatsapp_agent_screen.dart';

class OnboardingWizard extends StatefulWidget {
  final Api api;
  OnboardingWizard({required this.api});
  @override
  State<OnboardingWizard> createState() => _OnboardingWizardState();
}

class _OnboardingWizardState extends State<OnboardingWizard> {
  int _step = 0;

  void next() => setState(() => _step = (_step + 1).clamp(0, 5));
  void back() => setState(() => _step = (_step - 1).clamp(0, 5));

  @override
  Widget build(BuildContext context) {
    final steps = [
      SignupScreen(onNext: next),
      BusinessInfoScreen(api: widget.api,  onNext: next),
      BusinessTypeScreen(api: widget.api, onNext: next, onBack: back),
      BusinessInfoCaptureScreen(api: widget.api,  onNext: next, onBack: back),
      WorkflowSetupScreen(api: widget.api, onNext: next, onBack: back),
      // PaymentSetupScreen(api: widget.api,  onNext: next, onBack: back),
      WhatsAppAgentScreen(api: widget.api,  onNext: next, onBack: back),
      ReviewActivateScreen(api: widget.api, onBack: back),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text("Onboarding")),
      body: Column(
        children: [
          LinearProgressIndicator(value: (_step + 1) / steps.length , color: Colors.blue[700],),
          Expanded(child: steps[_step]),
        ],
      ),
    );
  }
}
