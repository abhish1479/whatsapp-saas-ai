import 'package:flutter/material.dart';
import '../api.dart';
import 'business_info.dart';
import 'business_type.dart';
import 'info_capture.dart';
import 'workflow_setup.dart';
import 'payment_setup.dart';
import 'review_activate.dart';

class OnboardingWizard extends StatefulWidget {
  final Api api;
  final String tenantId;
  OnboardingWizard({required this.api, required this.tenantId});
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
      BusinessInfoScreen(api: widget.api, tenantId: widget.tenantId, onNext: next),
      BusinessTypeScreen(api: widget.api, tenantId: widget.tenantId, onNext: next, onBack: back),
      InfoCaptureScreen(api: widget.api, tenantId: widget.tenantId, onNext: next, onBack: back),
      WorkflowSetupScreen(api: widget.api, tenantId: widget.tenantId, onNext: next, onBack: back),
      PaymentSetupScreen(api: widget.api, tenantId: widget.tenantId, onNext: next, onBack: back),
      ReviewActivateScreen(api: widget.api, tenantId: widget.tenantId, onBack: back),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text("Onboarding")),
      body: Column(
        children: [
          LinearProgressIndicator(value: (_step + 1) / steps.length),
          Expanded(child: steps[_step]),
        ],
      ),
    );
  }
}
