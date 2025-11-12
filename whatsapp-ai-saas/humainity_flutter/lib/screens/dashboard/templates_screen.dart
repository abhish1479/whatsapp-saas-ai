import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:humainity_flutter/core/providers/templates_provider.dart';
import 'package:humainity_flutter/core/theme/app_colors.dart';
import 'package:humainity_flutter/models/template.dart';
import 'package:humainity_flutter/widgets/ui/app_badge.dart';
import 'package:humainity_flutter/widgets/ui/app_button.dart';
import 'package:humainity_flutter/widgets/ui/app_card.dart';
import 'package:humainity_flutter/widgets/ui/app_dialog.dart';
import 'package:humainity_flutter/widgets/ui/app_dropdown.dart';
import 'package:humainity_flutter/widgets/ui/app_text_field.dart';
import 'package:lucide_icons/lucide_icons.dart';

class TemplatesScreen extends ConsumerWidget {
  const TemplatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(templatesProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Message Templates',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              AppButton(
                text: 'Create Template',
                icon: const Icon(LucideIcons.plus, size: 16),
                onPressed: () {
                  _showTemplateForm(context, ref, null);
                },
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Manage your inbound and outbound message templates.',
            style: TextStyle(color: AppColors.mutedForeground),
          ),
          const SizedBox(height: 12),

          if (state.isLoading && state.inboundTemplates.isEmpty && state.outboundTemplates.isEmpty)
            const Center(child: CircularProgressIndicator()),

          if (state.error != null)
            Container(
              padding: const EdgeInsets.all(12),
              color: AppColors.destructive.withOpacity(0.1),
              child: Text(
                'Error: ${state.error}',
                style: const TextStyle(color: AppColors.destructive),
              ),
            ),

          const SizedBox(height: 12),

          // Inbound List
          _buildTemplateSection(
            context,
            ref,
            title: 'Inbound Templates',
            templates: state.inboundTemplates,
            isLoading: state.isLoading,
          ),

          const SizedBox(height: 24),

          // Outbound List
          _buildTemplateSection(
            context,
            ref,
            title: 'Outbound Templates',
            templates: state.outboundTemplates,
            isLoading: state.isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateSection(
      BuildContext context,
      WidgetRef ref, {
        required String title,
        required List<Template> templates,
        required bool isLoading,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            if (isLoading)
              const Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (templates.isEmpty && !isLoading)
          const AppCard(
            child: Center(
              child: Text(
                'No templates found.',
                style: TextStyle(color: AppColors.mutedForeground),
              ),
            ),
          ),
        if (templates.isNotEmpty)
          ListView.builder(
            itemCount: templates.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return _TemplateCard(template: templates[index]);
            },
          ),
      ],
    );
  }

  void _showTemplateForm(BuildContext context, WidgetRef ref, Template? template) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing on tap-outside
      builder: (context) {
        // Pass ref to the dialog
        return _TemplateFormDialog(template: template, ref: ref);
      },
    );
  }
}

// Card Widget
class _TemplateCard extends ConsumerWidget {
  const _TemplateCard({required this.template});

  final Template template;

  AppBadgeVariant _getStatusVariant(TemplateStatus status) {
    switch (status) {
      case TemplateStatus.ACTIVATED:
      case TemplateStatus.SUBMITTED:
        return AppBadgeVariant.success;
      case TemplateStatus.DRAFT:
      case TemplateStatus.DEACTIVATED: // Handle new status
        return AppBadgeVariant.secondary;
      default:
        return AppBadgeVariant.destructive;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Name and Menu
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        template.name,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ),
                    _buildMenu(context, ref),
                  ],
                ),
                const SizedBox(height: 4),

                // Body Preview
                Text(
                  template.body,
                  style: const TextStyle(color: AppColors.mutedForeground),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),

                // Bottom Tags
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: [
                    AppBadge(
                      text: template.language.toUpperCase(),
                      variant: AppBadgeVariant.outline,
                      icon: const Icon(LucideIcons.globe2, size: 14),
                    ),
                    AppBadge(
                      text: template.category,
                      variant: AppBadgeVariant.outline,
                      icon: const Icon(LucideIcons.tag, size: 14),
                    ),
                  ],
                )
              ],
            ),
          ),

          // Status Badge
          Positioned(
            top: 16,
            right: 48, // Adjust to be left of the menu
            child: AppBadge(
              text: template.status.displayName, // Use displayName
              variant: _getStatusVariant(template.status),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenu(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      icon: const Icon(LucideIcons.moreVertical, color: AppColors.mutedForeground),
      onSelected: (value) {
        if (value == 'edit') {
          _showTemplateForm(context, ref, template);
        } else if (value == 'delete') {
          _showDeleteConfirm(context, ref);
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'edit',
          child: Row(
            children: [
              Icon(LucideIcons.edit, size: 16, color: AppColors.mutedForeground),
              SizedBox(width: 8),
              Text('Edit'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: [
              Icon(LucideIcons.trash2, size: 16, color: AppColors.destructive),
              const SizedBox(width: 8),
              const Text('Delete', style: TextStyle(color: AppColors.destructive)),
            ],
          ),
        ),
      ],
    );
  }

  void _showTemplateForm(BuildContext context, WidgetRef ref, Template? template) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return _TemplateFormDialog(template: template, ref: ref);
      },
    );
  }

  void _showDeleteConfirm(BuildContext context, WidgetRef ref) {
    showAppDialog(
      context: context,
      title: 'Delete Template?',
      content: Text('Are you sure you want to delete "${template.name}"? This action cannot be undone.'),
      actions: [
        AppButton(
          text: 'Cancel',
          style: AppButtonStyle.tertiary,
          onPressed: () => Navigator.pop(context),
        ),
        AppButton(
          text: 'Delete',
          style: AppButtonStyle.destructive,
          onPressed: () {
            ref.read(templatesProvider.notifier).removeTemplate(template.id);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}


// Form Dialog Widget
class _TemplateFormDialog extends StatefulWidget {
  final Template? template;
  final WidgetRef ref; // Pass ref

  const _TemplateFormDialog({this.template, required this.ref});

  @override
  State<_TemplateFormDialog> createState() => _TemplateFormDialogState();
}

class _TemplateFormDialogState extends State<_TemplateFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _bodyController;
  late TemplateType _selectedType;
  late String _selectedLanguage;
  late String _selectedCategory;

  bool _isSaving = false;
  final List<String> _languages = ['en', 'es', 'fr', 'de'];
  final List<String> _categories = ['MARKETING', 'UTILITY', 'AUTHENTICATION'];

  @override
  void initState() {
    super.initState();
    final t = widget.template;
    _nameController = TextEditingController(text: t?.name ?? '');
    _bodyController = TextEditingController(text: t?.body ?? '');
    _selectedType = t?.type ?? TemplateType.OUTBOUND;
    _selectedLanguage = t?.language ?? _languages.first;
    _selectedCategory = t?.category ?? _categories.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _getFormData(TemplateStatus status) {
    return {
      'name': _nameController.text,
      'body': _bodyController.text,
      'type': _selectedType.toJson(),
      'language': _selectedLanguage,
      'category': _selectedCategory,
      'status': status.toJson(),
    };
  }

  Future<void> _onSave(TemplateStatus status) async {
    if (!_formKey.currentState!.validate()) {
      return; // Validation failed
    }

    setState(() { _isSaving = true; });

    final data = _getFormData(status);
    bool success;

    if (widget.template == null) {
      // Create
      success = await widget.ref.read(templatesProvider.notifier).addTemplate(data);
    } else {
      // Update
      success = await widget.ref.read(templatesProvider.notifier).editTemplate(widget.template!.id, data);
    }

    if (mounted) {
      setState(() { _isSaving = false; });
      if (success) {
        Navigator.pop(context); // Close form
      }
      // If not success, error is already shown by the provider
    }
  }

  void _onClose() {
    // Check if form has changes
    bool hasChanges = _nameController.text != (widget.template?.name ?? '') ||
        _bodyController.text != (widget.template?.body ?? '') ||
        _selectedType != (widget.template?.type ?? TemplateType.OUTBOUND);

    if (hasChanges) {
      showAppDialog(
        context: context,
        title: 'Save as Draft?',
        content: const Text('You have unsaved changes. Would you like to save this as a draft?'),
        actions: [
          AppButton(
            text: 'Discard',
            style: AppButtonStyle.tertiary,
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close form
            },
          ),
          AppButton(
            text: 'Save as Draft',
            onPressed: () {
              Navigator.pop(context); // Close dialog
              _onSave(TemplateStatus.DRAFT); // Save as draft
            },
          ),
        ],
      );
    } else {
      Navigator.pop(context); // No changes, just close
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.template == null ? 'Create Template' : 'Edit Template',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          IconButton(
            icon: const Icon(LucideIcons.x),
            onPressed: _isSaving ? null : _onClose,
            color: AppColors.mutedForeground,
          ),
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.5, // 50% of screen width
        child: _isSaving
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTextField(
                  controller: _nameController,
                  labelText: 'Template Name',
                  hintText: 'e.g., "Welcome Message"',
                  validator: (val) => val == null || val.isEmpty ? 'Name is required' : null,
                ),
                const SizedBox(height: 16),
                AppDropdown<TemplateType>(
                  labelText: 'Type',
                  value: _selectedType,
                  items: TemplateType.values
                      .where((t) => t != TemplateType.UNKNOWN)
                      .map((t) => DropdownMenuItem(value: t, child: Text(t.displayName))) // Use displayName
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedType = val);
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: AppDropdown<String>(
                        labelText: 'Language',
                        value: _selectedLanguage,
                        items: _languages
                            .map((l) => DropdownMenuItem(value: l, child: Text(l.toUpperCase())))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedLanguage = val);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: AppDropdown<String>(
                        labelText: 'Category',
                        value: _selectedCategory,
                        items: _categories
                            .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedCategory = val);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _bodyController,
                  labelText: 'Template Body',
                  hintText: 'Enter your message body here... Use {{variable}} for placeholders.',
                  maxLines: 6,
                  validator: (val) => val == null || val.isEmpty ? 'Body is required' : null,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: _isSaving
          ? []
          : [
        AppButton(
          text: 'Save Template',
          onPressed: () => _onSave(TemplateStatus.SUBMITTED),
        ),
      ],
    );
  }
}