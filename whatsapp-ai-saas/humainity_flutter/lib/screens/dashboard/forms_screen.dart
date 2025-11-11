import 'package:flutter/material.dart';
import 'package:humainity_flutter/core/theme/app_colors.dart';
import 'package:humainity_flutter/widgets/ui/app_badge.dart';
import 'package:humainity_flutter/widgets/ui/app_button.dart';
import 'package:humainity_flutter/widgets/ui/app_card.dart';
import 'package:humainity_flutter/widgets/ui/app_text_field.dart';
import 'package:lucide_icons/lucide_icons.dart';

class FormsScreen extends StatelessWidget {
  const FormsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 24),
          _buildFormTemplatesSection(context),
          const SizedBox(height: 32),
          _buildFormBuilderSection(context),
          const SizedBox(height: 32),
          _buildFormPreviewSection(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Form & Flow Builder',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 4),
        Text(
          'Design custom forms to feed data directly into your agents or CRM.',
          style: TextStyle(color: AppColors.mutedForeground),
        ),
      ],
    );
  }

  // FIX: Added BuildContext context argument
  Widget _buildFormTemplatesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // FIX: context is now available
            Text('Form Templates',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w600)),
            AppButton(
                text: 'Create New Form',
                icon: const Icon(LucideIcons.plus),
                onPressed: () {}),
          ],
        ),
        const SizedBox(height: 16),
        // Placeholder for GridView of forms
        Wrap(
          spacing: 16.0,
          runSpacing: 16.0,
          children: [
            _buildTemplateCard(context, 'Customer Enquiry',
                'Collect customer information and inquiries.', true),
            _buildTemplateCard(context, 'Service Request',
                'For tracking support and service issues.', false),
            _buildTemplateCard(context, 'Feedback Form',
                'Gather feedback on recent interactions.', false),
          ],
        ),
      ],
    );
  }

  Widget _buildTemplateCard(
      BuildContext context, String title, String subtitle, bool isActive) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: 300,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
                AppBadge(
                    text: isActive ? 'Active' : 'Draft',
                    variant: isActive
                        ? AppBadgeVariant.primary
                        : AppBadgeVariant.secondary),
              ],
            ),
            const SizedBox(height: 4),
            Text(subtitle,
                style: const TextStyle(
                    color: AppColors.mutedForeground, fontSize: 14)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // FIX: Replaced variant: AppButtonVariant.outline with style: AppButtonStyle.tertiary
                AppButton(
                    text: 'Edit',
                    style: AppButtonStyle.tertiary,
                    onPressed: () {}),
                const SizedBox(width: 8),
                AppButton(text: 'Preview', onPressed: () {}),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // FIX: Added BuildContext context argument
  Widget _buildFormBuilderSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // FIX: context is now available
        Text('Form Builder',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppTextField(
                  labelText: 'Form Title', hintText: 'e.g., Contact Us Form'),
              const SizedBox(height: 16),
              const AppTextField(
                  labelText: 'Form Description',
                  hintText: 'A brief description...',
                  maxLines: 3),
              const SizedBox(height: 24),
              const Text('Form Fields (Drag & Drop Coming Soon)',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              _buildFormFieldsList(),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // FIX: Replaced variant: AppButtonVariant.outline with style: AppButtonStyle.tertiary
                  AppButton(
                      text: 'Add Field',
                      style: AppButtonStyle.tertiary,
                      icon: const Icon(LucideIcons.plus),
                      onPressed: () {}),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppButton(text: 'Save Form', onPressed: () {}),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFormFieldsList() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FormFieldItem(label: 'Name', type: 'Text Input', isRequired: true),
          Divider(color: AppColors.border),
          _FormFieldItem(label: 'Email', type: 'Email Input', isRequired: true),
          Divider(color: AppColors.border),
          _FormFieldItem(
              label: 'Phone', type: 'Phone Input', isRequired: false),
          Divider(color: AppColors.border),
          _FormFieldItem(label: 'Message', type: 'Textarea', isRequired: true),
        ],
      ),
    );
  }

  // FIX: Added BuildContext context argument
  Widget _buildFormPreviewSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // FIX: context is now available
        Text('Form Preview',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // FIX: context is now available
                      Text('Customer Enquiry Form',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600)),
                      const Text('Collect customer information and inquiries.',
                          style: TextStyle(color: AppColors.mutedForeground)),
                    ],
                  ),
                  const AppBadge(
                      text: 'Active',
                      color: AppColors.success,
                      textColor: AppColors.successForeground),
                ],
              ),
              const SizedBox(height: 24),
              const AppTextField(
                  labelText: 'Name *', hintText: 'Enter your name'),
              const SizedBox(height: 16),
              const AppTextField(
                  labelText: 'Email *', hintText: 'Enter your email'),
              const SizedBox(height: 16),
              const AppTextField(labelText: 'Phone', hintText: 'Optional'),
              const SizedBox(height: 16),
              const AppTextField(
                  labelText: 'Message *',
                  hintText: 'How can we help?',
                  maxLines: 5),
              const SizedBox(height: 24),
              AppButton(text: 'Submit Inquiry', onPressed: () {}),
            ],
          ),
        ),
      ],
    );
  }
}

class _FormFieldItem extends StatelessWidget {
  final String label;
  final String type;
  final bool isRequired;

  const _FormFieldItem({
    required this.label,
    required this.type,
    required this.isRequired,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
              if (isRequired)
                const Padding(
                  padding: EdgeInsets.only(left: 4.0),
                  child:
                      Text('*', style: TextStyle(color: AppColors.destructive)),
                ),
            ],
          ),
          Text(type, style: const TextStyle(color: AppColors.mutedForeground)),
          Row(
            children: [
              IconButton(
                icon: const Icon(LucideIcons.pencil,
                    size: 16, color: AppColors.mutedForeground),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(LucideIcons.trash2,
                    size: 16, color: AppColors.destructive),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}
