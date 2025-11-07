import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:humainity_flutter/core/theme/app_colors.dart';
import 'package:humainity_flutter/core/utils/responsive.dart';
import 'package:humainity_flutter/widgets/ui/app_button.dart';
import 'package:humainity_flutter/widgets/ui/app_card.dart';
import 'package:humainity_flutter/widgets/ui/app_dropdown.dart';
import 'package:humainity_flutter/widgets/ui/app_radio_group.dart';
import 'package:humainity_flutter/widgets/ui/app_switch.dart';
import 'package:humainity_flutter/widgets/ui/app_text_field.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:toggle_switch/toggle_switch.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _llmModel = "google/gemini-2.5-flash";
  String _voiceModel = "eleven_turbo_v2_5";
  String _selectedVoice = "Sarah";
  String _currency = "INR";

  bool _emailNotifications = true;
  bool _campaignAlerts = true;
  bool _lowBalanceAlert = true;
  bool _twoFactor = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Settings',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Manage your account, billing, and preferences',
            style: TextStyle(color: AppColors.mutedForeground),
          ),
          const SizedBox(height: 24),
          _buildAccountSettings(),
          const SizedBox(height: 24),
          _buildBillingPayment(),
          const SizedBox(height: 24),
          _buildAiModelConfig(),
          const SizedBox(height: 24),
          ResponsiveLayout(
            mobile: Column(
              children: [
                _buildNotifications(),
                const SizedBox(height: 16),
                _buildSecurity(),
              ],
            ),
            desktop: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildNotifications()),
                const SizedBox(width: 16),
                Expanded(child: _buildSecurity()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSettings() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(LucideIcons.settings, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text('Account Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 24),
          ResponsiveLayout(
            mobile: Column(
              children: [
                AppTextField(labelText: 'Company Name', controller: TextEditingController(text: 'HumAInity Business')),
                const SizedBox(height: 16),
                AppTextField(labelText: 'Industry', controller: TextEditingController(text: 'Technology')),
              ],
            ),
            desktop: Row(
              children: [
                Expanded(child: AppTextField(labelText: 'Company Name', controller: TextEditingController(text: 'HumAInity Business'))),
                const SizedBox(width: 16),
                Expanded(child: AppTextField(labelText: 'Industry', controller: TextEditingController(text: 'Technology'))),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ResponsiveLayout(
            mobile: Column(
              children: [
                AppTextField(labelText: 'Email Address', controller: TextEditingController(text: 'user@example.com')),
                const SizedBox(height: 16),
                AppTextField(labelText: 'Phone Number', controller: TextEditingController(text: '+91 98765 43210')),
              ],
            ),
            desktop: Row(
              children: [
                Expanded(child: AppTextField(labelText: 'Email Address', controller: TextEditingController(text: 'user@example.com'))),
                const SizedBox(width: 16),
                Expanded(child: AppTextField(labelText: 'Phone Number', controller: TextEditingController(text: '+91 98765 43210'))),
              ],
            ),
          ),
          const SizedBox(height: 24),
          AppButton(text: 'Save Changes', onPressed: () {}),
        ],
      ),
    );
  }

  Widget _buildBillingPayment() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(LucideIcons.creditCard, color: AppColors.primary, size: 20),
                  SizedBox(width: 8),
                  Text('Billing & Payment', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                ],
              ),
              ToggleSwitch(
                minWidth: 60.0,
                initialLabelIndex: _currency == 'INR' ? 0 : 1,
                cornerRadius: 8.0,
                activeFgColor: AppColors.foreground,
                inactiveBgColor: AppColors.muted,
                inactiveFgColor: AppColors.mutedForeground,
                activeBgColor: [AppColors.background],
                totalSwitches: 2,
                labels: const ['INR', 'USD'],
                onToggle: (index) {
                  setState(() => _currency = (index == 0 ? 'INR' : 'USD'));
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Add stat cards...
          const Divider(height: 48),
          AppButton(text: 'Recharge Wallet', onPressed: () {}),
        ],
      ),
    );
  }

  Widget _buildAiModelConfig() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(LucideIcons.bot, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text('AI Model Configuration', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 24),
          AppDropdown<String>(
            labelText: 'LLM Model',
            value: _llmModel,
            onChanged: (val) => setState(() => _llmModel = val!),
            items: const [
              DropdownMenuItem(value: 'google/gemini-2.5-pro', child: Text('Google Gemini 2.5 Pro')),
              DropdownMenuItem(value: 'google/gemini-2.5-flash', child: Text('Google Gemini 2.5 Flash (Recommended)')),
              DropdownMenuItem(value: 'openai/gpt-5', child: Text('OpenAI GPT-5')),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          AppDropdown<String>(
            labelText: 'Voice Model',
            value: _voiceModel,
            onChanged: (val) => setState(() => _voiceModel = val!),
            items: const [
              DropdownMenuItem(value: 'eleven_multilingual_v2', child: Text('Eleven Multilingual v2')),
              DropdownMenuItem(value: 'eleven_turbo_v2_5', child: Text('Eleven Turbo v2.5 (Recommended)')),
            ],
          ),
          const SizedBox(height: 16),
          AppDropdown<String>(
            labelText: 'Voice',
            value: _selectedVoice,
            onChanged: (val) => setState(() => _selectedVoice = val!),
            items: const [
              DropdownMenuItem(value: 'Sarah', child: Text('Sarah - Professional female voice')),
              DropdownMenuItem(value: 'Aria', child: Text('Aria - Warm female voice')),
              DropdownMenuItem(value: 'Roger', child: Text('Roger - Professional male voice')),
            ],
          ),
          const SizedBox(height: 24),
          AppButton(text: 'Save Model Settings', onPressed: () {}),
        ],
      ),
    );
  }

  Widget _buildNotifications() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(LucideIcons.bell, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text('Notifications', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 24),
          _buildSwitchTile(
            title: 'Email Notifications',
            description: 'Receive updates via email',
            value: _emailNotifications,
            onChanged: (val) => setState(() => _emailNotifications = val),
          ),
          const Divider(height: 24),
          _buildSwitchTile(
            title: 'Campaign Alerts',
            description: 'Get notified about campaign status',
            value: _campaignAlerts,
            onChanged: (val) => setState(() => _campaignAlerts = val),
          ),
          const Divider(height: 24),
          _buildSwitchTile(
            title: 'Low Balance Alert',
            description: 'Alert when wallet balance is low',
            value: _lowBalanceAlert,
            onChanged: (val) => setState(() => _lowBalanceAlert = val),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurity() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(LucideIcons.shield, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text('Security', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 24),
          AppTextField(labelText: 'Current Password', obscureText: true),
          const SizedBox(height: 16),
          AppTextField(labelText: 'New Password', obscureText: true),
          const SizedBox(height: 16),
          AppTextField(labelText: 'Confirm New Password', obscureText: true),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: AppButton(text: 'Update Password', onPressed: () {})),
          const Divider(height: 24),
          _buildSwitchTile(
            title: 'Two-Factor Authentication',
            description: 'Add an extra layer of security',
            value: _twoFactor,
            onChanged: (val) => setState(() => _twoFactor = val),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String description,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
              Text(description, style: const TextStyle(color: AppColors.mutedForeground, fontSize: 14)),
            ],
          ),
        ),
        AppSwitch(value: value, onChanged: onChanged),
      ],
    );
  }
}