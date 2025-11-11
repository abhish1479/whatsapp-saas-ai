import 'package:flutter/material.dart';
import 'package:humainity_flutter/core/theme/app_colors.dart';
import 'package:humainity_flutter/widgets/ui/app_badge.dart';
import 'package:humainity_flutter/widgets/ui/app_button.dart';
import 'package:humainity_flutter/widgets/ui/app_card.dart';
import 'package:humainity_flutter/widgets/ui/app_dropdown.dart';
import 'package:humainity_flutter/widgets/ui/app_text_field.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ActionsScreen extends StatelessWidget {
  const ActionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Actions & Automation Workflow',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Three-tier intelligent response system: Defined Actions → Universal API → Fallback Handling',
                    style: TextStyle(color: AppColors.mutedForeground),
                  ),
                ],
              ),
              AppButton(
                text: 'Create Action',
                icon: const Icon(LucideIcons.plus), // FIX: Wrapped in Icon()
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildWorkflowVisualization(),
          const SizedBox(height: 24),
          _buildDefinedActions(),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildApiConfig()),
              const SizedBox(width: 24),
              Expanded(child: _buildFallbackConfig()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWorkflowVisualization() {
    return AppCard(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Response Workflow',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        _buildWorkflowStep(
            '1',
            'Defined Actions',
            'Match user query with pre-configured actions and triggers',
            AppColors.primary),
        const Center(
            child:
                Icon(LucideIcons.arrowDown, color: AppColors.mutedForeground)),
        _buildWorkflowStep(
            '2',
            'Universal API',
            'Query organizational systems for real-time data and answers',
            Colors.blue.shade500),
        const Center(
            child:
                Icon(LucideIcons.arrowDown, color: AppColors.mutedForeground)),
        _buildWorkflowStep(
            '3',
            'Fallback Handling',
            'Switch to human agent or send standard closure message',
            Colors.orange.shade500),
      ],
    ));
  }

  Widget _buildWorkflowStep(
      String step, String title, String description, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(8),
        color: AppColors.background,
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Center(
                child: Text(step,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold))),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(description,
                    style: const TextStyle(
                        color: AppColors.mutedForeground, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefinedActions() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(LucideIcons.zap, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Tier 1: Defined Actions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 16),
          _buildActionItem('Share Brochure', "user asks for 'brochure'",
              'Send PDF Document', 'Active'),
          _buildActionItem('Book Appointment', "intent = 'book_appointment'",
              'Show Appointment Form', 'Active'),
          _buildActionItem('Payment Link', "user says 'pay' or 'payment'",
              'Send Payment Link', 'Active'),
          _buildActionItem('Forward to Agent', "user says 'speak to human'",
              'Transfer to Live Agent', 'Inactive'),
        ],
      ),
    );
  }

  Widget _buildActionItem(
      String name, String trigger, String action, String status) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(LucideIcons.zap, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text('When: $trigger → Then: $action',
                      style: const TextStyle(
                          color: AppColors.mutedForeground, fontSize: 12)),
                ],
              ),
            ],
          ),
          AppBadge(
              text: status,
              color: status == 'Active' ? AppColors.success : AppColors.muted),
        ],
      ),
    );
  }

  Widget _buildApiConfig() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.database, color: Colors.blue.shade500),
              const SizedBox(width: 8),
              const Text('Tier 2: Universal API',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          const Text('Query organizational systems for real-time data.',
              style: TextStyle(color: AppColors.mutedForeground, fontSize: 14)),
          const SizedBox(height: 16),
          AppTextField(
              labelText: 'API Endpoint URL',
              hintText: 'https://api.yourorg.com/query'),
          const SizedBox(height: 16),
          AppTextField(
              labelText: 'API Authentication Key',
              hintText: 'Enter your API key',
              obscureText: true),
          const SizedBox(height: 16),
          AppDropdown(
            labelText: 'Request Method',
            value: 'post',
            onChanged: (val) {},
            items: const [
              DropdownMenuItem(value: 'get', child: Text('GET')),
              DropdownMenuItem(value: 'post', child: Text('POST')),
            ],
          ),
          const SizedBox(height: 16),
          AppButton(
              text: 'Save API Configuration',
              onPressed: () {},
              icon: const Icon(LucideIcons.database)), // FIX: Wrapped in Icon()
        ],
      ),
    );
  }

  // FIX: Completed the truncated file
  Widget _buildFallbackConfig() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.messageSquare, color: Colors.orange.shade500),
              const SizedBox(width: 8),
              const Text('Tier 3: Fallback Handling',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          const Text('Configure what happens when AI cannot handle the query.',
              style: TextStyle(color: AppColors.mutedForeground, fontSize: 14)),
          const SizedBox(height: 16),
          AppDropdown(
            labelText: 'Fallback Action',
            value: 'human',
            onChanged: (val) {},
            items: const [
              DropdownMenuItem(
                  value: 'human', child: Text('Transfer to Live Agent')),
              DropdownMenuItem(
                  value: 'message', child: Text('Send Closure Message')),
              DropdownMenuItem(value: 'form', child: Text('Show Contact Form')),
            ],
          ),
        ],
      ),
    );
  }
}
