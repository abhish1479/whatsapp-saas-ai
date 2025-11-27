import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';
import 'package:humainity_flutter/core/storage/store_user_data.dart';
import 'package:humainity_flutter/core/theme/app_colors.dart';
import 'package:humainity_flutter/core/utils/responsive.dart';
import 'package:humainity_flutter/widgets/ui/app_button.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'sidebar_content.dart'; // for onboardingStatusProvider

class AppHeader extends ConsumerWidget implements PreferredSizeWidget {
  final VoidCallback? onMenuPressed;

  const AppHeader({this.onMenuPressed, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingAsync = ref.watch(onboardingStatusProvider);

    bool goLiveEnabled = false;

    onboardingAsync.whenData((status) {
      final stepsMap =
          Map<String, dynamic>.from(status['onboarding_steps'] ?? {});
      final step1 = stepsMap['AI_Agent_Configuration'] == true;
      final step2 = stepsMap['Knowledge_Base_Ingestion'] == true;
      final step3 = stepsMap['template_Messages_Setup'] == true;
      goLiveEnabled = step1 && step2 && step3;
    });

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.95),
        border: const Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (isMobile(context))
            IconButton(
              icon: const Icon(LucideIcons.menu),
              onPressed: onMenuPressed,
            ),
          const Spacer(),
          SizedBox(
            height: 44,
            child: AppButton(
              text: 'Go Live',
              // onPressed:
              //     goLiveEnabled ? () => _showGoLiveDialog(context) : null,
                  onPressed: goLiveEnabled ? () => _showGoLiveDialog(context, ref) : null,

            ),
          ),
        ],
      ),
    );
  }

void _showGoLiveDialog(BuildContext context, WidgetRef ref) {
  final controller = TextEditingController();
  final formKey = GlobalKey<FormState>();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text(
          "Go Live – Enter WhatsApp Number",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Please enter your WhatsApp Business number to activate your agent.",
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: controller,
                keyboardType: TextInputType.phone,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: const InputDecoration(
                  labelText: "WhatsApp Number",
                  border: OutlineInputBorder(),
                  prefixText: "+",
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Number is required";
                  }

                  final trimmed = value.trim();

                  if (!RegExp(r'^[0-9]+$').hasMatch(trimmed)) {
                    return "Only digits allowed";
                  }

                  if (trimmed.length < 10 || trimmed.length > 12) {
                    return "Enter a valid 10–12 digit number";
                  }

                  return null; // VALID
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),

          ElevatedButton(
            child: const Text("Save"),
            onPressed: () async {
              if (!formKey.currentState!.validate()) {
                return; 
              }

              final number = controller.text.trim();

              // === REAL API CALL OPTION ===
              // final repo = ref.read(authRepositoryProvider);
              // await repo.saveWhatsappNumber(number);

              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("WhatsApp number saved successfully!"),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
        ],
      );
    },
  );
}

  @override
  Size get preferredSize => const Size.fromHeight(64.0);
}
