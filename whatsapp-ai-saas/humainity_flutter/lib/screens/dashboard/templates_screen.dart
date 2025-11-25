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
import 'package:humainity_flutter/core/utils/responsive.dart'; // <-- 1. Import responsive util
import 'package:humainity_flutter/core/providers/auth_provider.dart';

// Convert back to StatefulWidget to manage the tab state
class TemplatesScreen extends ConsumerStatefulWidget {
  const TemplatesScreen({super.key});

  @override
  ConsumerState<TemplatesScreen> createState() => _TemplatesScreenState();
}

class _TemplatesScreenState extends ConsumerState<TemplatesScreen> {
  // true = Outbound, false = Inbound
  bool _showOutbound = true;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(templatesProvider);
    final templates =
        _showOutbound ? state.outboundTemplates : state.inboundTemplates;

    // 2. Check for mobile screen size
    final bool isMobileScreen = isMobile(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16.0),
          // 2. Use Flex for responsive header
          child: Flex(
            direction: isMobileScreen ? Axis.vertical : Axis.horizontal,
            crossAxisAlignment: isMobileScreen
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Templates',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Manage and create your inbound and outbound message templates.',
                      style: TextStyle(color: AppColors.mutedForeground),
                    ),
                  ],
                ),
              ),
              // 2. Add spacing for mobile stack
              SizedBox(height: isMobileScreen ? 16 : 0),
              AppButton(
                text: 'Create Template',
                icon: const Icon(LucideIcons.plus, size: 16),
                onPressed: () {
                  _showTemplateForm(context, ref, null);
                },
                // 2. Make button full width on mobile
                width: isMobileScreen ? double.infinity : null,
              ),
            ],
          ),
        ),

        // Error Message
        if (state.error != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              padding: const EdgeInsets.all(12),
              color: AppColors.destructive.withOpacity(0.1),
              child: Text(
                'Error: ${state.error}',
                style: const TextStyle(color: AppColors.destructive),
              ),
            ),
          ),

        // Custom Tab Buttons
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
          // 3. Remove MainAxisAlignment.start
          child: Row(
            children: [
              // 3. Let container expand
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(4.0),
                  // 3. Remove fixed max-width on mobile, keep it for web
                  constraints: isMobileScreen
                      ? null
                      : const BoxConstraints(maxWidth: 350),
                  decoration: BoxDecoration(
                    color: AppColors.muted,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          text: 'Outbound',
                          icon: const Icon(LucideIcons.arrowUpRight, size: 16),
                          onPressed: () => setState(() => _showOutbound = true),
                          style: _showOutbound
                              ? AppButtonStyle.primary
                              : AppButtonStyle.tertiary,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: AppButton(
                          text: 'Inbound',
                          icon: const Icon(LucideIcons.arrowDownLeft, size: 16),
                          onPressed: () =>
                              setState(() => _showOutbound = false),
                          style: !_showOutbound
                              ? AppButtonStyle.primary
                              : AppButtonStyle.tertiary,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // TabBarView
        Expanded(
          child: _TemplateList(
            templates: templates,
            isLoading: state.isLoading,
          ),
        ),
      ],
    );
  }

  void _showTemplateForm(
      BuildContext context, WidgetRef ref, Template? template) {
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

// Helper widget for the grid view inside tabs
class _TemplateList extends StatelessWidget {
  final List<Template> templates;
  final bool isLoading;

  const _TemplateList({required this.templates, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    if (isLoading && templates.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (templates.isEmpty) {
      return const Center(
        child: Text(
          'No templates found.',
          style: TextStyle(color: AppColors.mutedForeground),
        ),
      );
    }

    // Use GridView.builder for a responsive grid
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 350.0, // Max width of each item
        mainAxisSpacing: 16.0, // Spacing between rows
        crossAxisSpacing: 16.0, // Spacing between columns
        // 1. REMOVE childAspectRatio to let cards size themselves
        // childAspectRatio: 0.85,

        // 1. ADD mainAxisExtent to ensure a minimum height for smaller content
        mainAxisExtent: 280, // You can adjust this value
      ),
      itemCount: templates.length,
      itemBuilder: (context, index) {
        return _TemplateCard(template: templates[index]);
      },
    );
  }
}

// 1. Convert back to ConsumerWidget
class _TemplateCard extends ConsumerWidget {
  const _TemplateCard({required this.template});

  final Template template;

  AppBadgeVariant _getStatusVariant(TemplateStatus status) {
    switch (status) {
      case TemplateStatus.ACTIVATED:
      case TemplateStatus.SUBMITTED:
        return AppBadgeVariant.success;
      case TemplateStatus.DRAFT:
      case TemplateStatus.DEACTIVATED:
        return AppBadgeVariant.secondary;
      default:
        return AppBadgeVariant.destructive;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppCard(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        // 2. Set mainAxisSize to MainAxisSize.min
        mainAxisSize:
            MainAxisSize.min, // Allow column to be as short as its content
        children: [
          // Top Row: Icon & Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(LucideIcons.messageSquare,
                  color: AppColors.primary, size: 24),
              AppBadge(
                text: template.status.displayName,
                variant: _getStatusVariant(template.status),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Template Name
          Text(
            template.name,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),

          // Body Preview
          // 2. Wrap Body and Tags in Expanded to push buttons down
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  template.body,
                  style: const TextStyle(
                      color: AppColors.mutedForeground, fontSize: 14),
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),

                // Tags
                Row(
                  children: [
                    const Icon(LucideIcons.globe2,
                        size: 14, color: AppColors.mutedForeground),
                    const SizedBox(width: 4),
                    Text(
                      template.language.toUpperCase(),
                      style: const TextStyle(
                          color: AppColors.mutedForeground, fontSize: 12),
                    ),
                    const SizedBox(width: 16),
                    const Icon(LucideIcons.tag,
                        size: 14, color: AppColors.mutedForeground),
                    const SizedBox(width: 4),
                    Text(
                      template.category,
                      style: const TextStyle(
                          color: AppColors.mutedForeground, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 2. REMOVE Spacer
          // const Spacer(),

          // Footer: Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.end, // 1. Align all to the end
            children: [
              // 1. Remove Expand/Collapse button

              // Edit Button
              TextButton.icon(
                onPressed: () => _showTemplateForm(context, ref, template),
                icon: const Icon(LucideIcons.edit,
                    size: 14, color: AppColors.primary),
                label: const Text('Edit',
                    style: TextStyle(color: AppColors.primary)),
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Delete Button
              TextButton.icon(
                onPressed: () => _showDeleteConfirm(context, ref),
                icon: const Icon(LucideIcons.trash2,
                    size: 14, color: AppColors.destructive),
                label: const Text('Delete',
                    style: TextStyle(color: AppColors.destructive)),
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  void _showTemplateForm(
      BuildContext context, WidgetRef ref, Template? template) {
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
      content: Text(
          'Are you sure you want to delete "${template.name}"? This action cannot be undone.'),
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

    setState(() {
      _isSaving = true;
    });

    final data = _getFormData(status);
    bool success;

    if (widget.template == null) {
      // Create
      success =
          await widget.ref.read(templatesProvider.notifier).addTemplate(data);
    } else {
      // Update
      success = await widget.ref
          .read(templatesProvider.notifier)
          .editTemplate(widget.template!.id, data);
    }

    if (mounted) {
      setState(() {
        _isSaving = false;
      });
      if (success) {
        Navigator.pop(context); // Close form
        await widget.ref
            .read(authNotifierProvider.notifier)
            .maybeFetchOnboardingStatus();
      }
      // If not success, error is already shown by the provider
    }
  }

  // 2. Simplify _onClose
  void _onClose() {
    // Check if we are in CREATE mode (template is null)
    if (widget.template == null) {
      // Check if required fields are filled
      bool requiredDataFilled =
          _nameController.text.isNotEmpty && _bodyController.text.isNotEmpty;

      if (requiredDataFilled) {
        showAppDialog(
          context: context,
          title: 'Save as Draft?',
          content: const Text(
              'You have unsaved changes. Would you like to save this as a draft?'),
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
        // In CREATE mode, but no data, so just close
        Navigator.pop(context);
      }
    } else {
      // In EDIT mode, just close
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 2. Get screen width for responsive dialog
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isMobileScreen = screenWidth < 600;

    return AlertDialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.template == null
                    ? 'Create new template'
                    : 'Edit Template',
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
              ),
              IconButton(
                icon: const Icon(LucideIcons.x),
                onPressed: _isSaving ? null : _onClose,
                color: AppColors.mutedForeground,
              ),
            ],
          ),
          const Text(
            'Fill in the details to create a new message template.',
            style: TextStyle(
                color: AppColors.mutedForeground,
                fontSize: 14,
                fontWeight: FontWeight.normal),
          ),
        ],
      ),
      // 2. Make dialog width responsive
      content: SizedBox(
        width: isMobileScreen
            ? screenWidth * 0.9
            : screenWidth * 0.5, // 90% on mobile, 50% on web
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
                        validator: (val) => val == null || val.isEmpty
                            ? 'Name is required'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      // 2. Use Flex for responsive dropdowns
                      Flex(
                        direction:
                            isMobileScreen ? Axis.vertical : Axis.horizontal,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: AppDropdown<TemplateType>(
                              labelText: 'Type',
                              value: _selectedType,
                              items: TemplateType.values
                                  .where((t) => t != TemplateType.UNKNOWN)
                                  .map((t) => DropdownMenuItem(
                                      value: t, child: Text(t.displayName)))
                                  .toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _selectedType = val);
                                }
                              },
                            ),
                          ),
                          SizedBox(
                              width: isMobileScreen ? 0 : 16,
                              height: isMobileScreen ? 16 : 0),
                          Expanded(
                            child: AppDropdown<String>(
                              labelText: 'Language',
                              value: _selectedLanguage,
                              items: _languages
                                  .map((l) => DropdownMenuItem(
                                      value: l, child: Text(l.toUpperCase())))
                                  .toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _selectedLanguage = val);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      AppDropdown<String>(
                        labelText: 'Category',
                        value: _selectedCategory,
                        items: _categories
                            .map((c) =>
                                DropdownMenuItem(value: c, child: Text(c)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedCategory = val);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _bodyController,
                        labelText: 'Template Body',
                        hintText:
                            'Enter your message body here... Use {{variable}} for placeholders.',
                        maxLines: 6,
                        validator: (val) => val == null || val.isEmpty
                            ? 'Body is required'
                            : null,
                      ),
                      const SizedBox(
                          height: 16), // 2. Add some padding at the bottom
                    ],
                  ),
                ),
              ),
      ),
      actionsPadding: const EdgeInsets.all(16.0),
      actions: _isSaving
          ? []
          : [
              // Only show the "Submit" button as the main action
              AppButton(
                text: 'Submit',
                onPressed: () => _onSave(TemplateStatus.SUBMITTED),
                // 2. Make button full width on mobile
                width: isMobileScreen ? double.infinity : null,
              ),
            ],
    );
  }
}
