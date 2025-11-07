import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:humainity_flutter/core/theme/app_colors.dart';
import 'package:humainity_flutter/core/utils/responsive.dart';
import 'package:humainity_flutter/widgets/ui/app_button.dart';
import 'package:humainity_flutter/widgets/ui/app_card.dart';
import 'package:humainity_flutter/widgets/ui/app_dropdown.dart';
import 'package:humainity_flutter/widgets/ui/app_switch.dart';
import 'package:humainity_flutter/widgets/ui/app_text_field.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AIAgentScreen extends ConsumerWidget {
  const AIAgentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'AI Agent Setup',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Configure your conversational AI agent\'s personality and settings.',
            style: TextStyle(color: AppColors.mutedForeground),
          ),
          const SizedBox(height: 24),
          // FIX: Using WebContainer (defined in responsive.dart)
          WebContainer(
            child: Column(
              children: [
                _buildAgentDetailsCard(context),
                const SizedBox(height: 24),
                _buildLanguageAndToneCard(context),
                const SizedBox(height: 24),
                _buildAdvancedSettingsCard(),
                const SizedBox(height: 24),
                _buildActionButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgentDetailsCard(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(LucideIcons.bot, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text('Agent Profile', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 16),
          const AppTextField(
            labelText: 'Agent Name',
            hintText: 'e.g., Alex, Sarah',
          ),
          const SizedBox(height: 16),
          const AppTextField(
            labelText: 'Agent Persona/Role',
            hintText: 'e.g., Friendly Customer Support Specialist',
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageAndToneCard(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(LucideIcons.slidersHorizontal, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text('Conversation Settings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AppDropdown<String>(
                  labelText: 'Default Language',
                  // FIX: Changed hintText to hint and provided a Text widget
                  hint: const Text('Select a Language'),
                  items: const [
                    DropdownMenuItem(value: 'en', child: Text('English')),
                    DropdownMenuItem(value: 'es', child: Text('Spanish')),
                  ],
                  onChanged: (val) {},
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppDropdown<String>(
                  labelText: 'Default Tone',
                  // FIX: Changed hintText to hint and provided a Text widget
                  hint: const Text('Select a Tone'),
                  items: const [
                    DropdownMenuItem(value: 'friendly', child: Text('Friendly')),
                    DropdownMenuItem(value: 'formal', child: Text('Formal')),
                  ],
                  onChanged: (val) {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AppDropdown<String>(
                  labelText: 'Default Voice (TTS)',
                  // FIX: Changed hintText to hint and provided a Text widget
                  hint: const Text('Select a Voice'),
                  items: const [
                    DropdownMenuItem(value: 'male', child: Text('Male - Charon')),
                    DropdownMenuItem(value: 'female', child: Text('Female - Kore')),
                  ],
                  onChanged: (val) {},
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppDropdown<String>(
                  labelText: 'Accent Preference',
                  // FIX: Changed hintText to hint and provided a Text widget
                  hint: const Text('Select an Accent'),
                  items: const [
                    DropdownMenuItem(value: 'general', child: Text('General American')),
                    DropdownMenuItem(value: 'british', child: Text('British English')),
                  ],
                  onChanged: (val) {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedSettingsCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(LucideIcons.settings, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text('Advanced Behavior', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 16),
          _buildSettingRow(
            'Enable Fallback to Human',
            'If the AI cannot answer a question, automatically transfer to a human agent.',
            const AppSwitch(value: true, onChanged: null),
          ),
          _buildDivider(),
          _buildSettingRow(
            'Proactive Engagement',
            'Allow the AI to initiate conversation based on customer behavior (e.g., prolonged idle time).',
            const AppSwitch(value: false, onChanged: null),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingRow(String title, String description, Widget control) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(description, style: const TextStyle(color: AppColors.mutedForeground, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          control,
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Divider(color: AppColors.border, height: 1),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        AppButton(
          text: 'Save Changes',
          onPressed: () {},
        ),
      ],
    );
  }
}