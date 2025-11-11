import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:humainity_flutter/core/providers/templates_provider.dart';
import 'package:humainity_flutter/core/theme/app_colors.dart';
import 'package:humainity_flutter/models/template.dart';
import 'package:humainity_flutter/widgets/ui/app_button.dart';
import 'package:humainity_flutter/widgets/ui/app_card.dart';
import 'package:humainity_flutter/widgets/ui/app_dialog.dart';
import 'package:humainity_flutter/widgets/ui/app_dropdown.dart';
import 'package:humainity_flutter/widgets/ui/app_radio_group.dart';
import 'package:humainity_flutter/widgets/ui/app_text_field.dart';
import 'package:lucide_icons/lucide_icons.dart';

class TemplatesScreen extends ConsumerStatefulWidget {
  const TemplatesScreen({super.key});

  @override
  ConsumerState<TemplatesScreen> createState() => _TemplatesScreenState();
}

class _TemplatesScreenState extends ConsumerState<TemplatesScreen> {
  String _selectedTab = 'inbound';

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(templatesProvider);

    // *** FIX: Filter the list of templates from the main provider ***
    final allTemplates = state.templates;
    final inboundTemplates =
        allTemplates.where((t) => t.type == 'inbound').toList();
    final outboundTemplates =
        allTemplates.where((t) => t.type == 'outbound').toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 24),
          _buildTabs(context),
          const SizedBox(height: 16),
          if (state.isLoading)
            const Center(child: CircularProgressIndicator())
          else
            _selectedTab == 'inbound'
                ? _buildTemplateList(inboundTemplates)
                : _buildTemplateList(outboundTemplates),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Message Templates',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                'Manage inbound (agent) and outbound (campaign) templates.',
                style: TextStyle(color: AppColors.mutedForeground),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        AppButton(
          text: "Create Template",
          icon: const Icon(LucideIcons.plus),
          onPressed: () => _showTemplateDialog(context),
        ),
      ],
    );
  }

  Widget _buildTabs(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: AppButton(
              text: 'Inbound (AI Agent)',
              icon: const Icon(LucideIcons.arrowDownToLine),
              // FIX: Replaced 'variant' with 'style' and used tertiary for ghost
              style: _selectedTab == 'inbound'
                  ? AppButtonStyle.primary
                  : AppButtonStyle.tertiary,
              onPressed: () => setState(() => _selectedTab = 'inbound'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: AppButton(
              text: 'Outbound (Campaigns)',
              icon: const Icon(LucideIcons.arrowUpFromLine),
              // FIX: Replaced 'variant' with 'style' and used tertiary for ghost
              style: _selectedTab == 'outbound'
                  ? AppButtonStyle.primary
                  : AppButtonStyle.tertiary,
              onPressed: () => setState(() => _selectedTab = 'outbound'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateList(List<MessageTemplate> templates) {
    if (templates.isEmpty) {
      return const AppCard(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: Text('No templates found for this type.'),
          ),
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: templates.length,
      itemBuilder: (context, index) {
        final template = templates[index];
        return AppCard(
          margin: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(template.name,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600)),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(LucideIcons.edit, size: 18),
                        onPressed: () =>
                            _showTemplateDialog(context, template: template),
                      ),
                      IconButton(
                        icon: const Icon(LucideIcons.trash2,
                            size: 18, color: AppColors.destructive),
                        onPressed: () =>
                            _showDeleteConfirmation(context, template),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(template.messageText,
                  style: const TextStyle(color: AppColors.mutedForeground)),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, MessageTemplate template) {
    showAppDialog(
      context: context,
      title: 'Delete Template',
      description: Text(
          'Are you sure you want to delete "${template.name}"? This action cannot be undone.'),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          AppButton(
            text: 'Cancel',
            // FIX: Replaced variant: AppButtonVariant.outline with style: AppButtonStyle.tertiary
            style: AppButtonStyle.tertiary,
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 8),
          AppButton(
            text: 'Delete',
            // FIX: Replaced variant: AppButtonVariant.destructive with setting the destructive color
            color: AppColors.destructive,
            onPressed: () {
              // *** FIX: Call correct notifier method ***
              ref.read(templatesProvider.notifier).deleteTemplate(template.id);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  void _showTemplateDialog(BuildContext context, {MessageTemplate? template}) {
    showAppDialog(
      context: context,
      title: template == null ? 'Create New Template' : 'Edit Template',
      description: const Text('Enter the details for your message template.'),
      content: TemplateForm(
        template: template,
        onSubmit: () => Navigator.of(context).pop(),
      ),
    );
  }
}

class TemplateForm extends ConsumerStatefulWidget {
  final MessageTemplate? template;
  final VoidCallback onSubmit;
  const TemplateForm({this.template, required this.onSubmit, super.key});

  @override
  ConsumerState<TemplateForm> createState() => _TemplateFormState();
}

class _TemplateFormState extends ConsumerState<TemplateForm> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _messageText;
  late String _type;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _name = widget.template?.name ?? '';
    _messageText = widget.template?.messageText ?? '';
    _type = widget.template?.type ?? 'inbound';
    _isActive = widget.template?.isActive ?? true;
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final formData = {
      'name': _name,
      'message_text': _messageText,
      'type': _type,
      'is_active': _isActive,
      'tags': [], // TODO: Add tag support
    };

    try {
      // *** FIX: Call correct notifier method ***
      await ref
          .read(templatesProvider.notifier)
          .saveTemplate(formData, widget.template?.id);
      widget.onSubmit();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Template ${widget.template == null ? 'created' : 'updated'} successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error: $e'), backgroundColor: AppColors.destructive),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment:
            CrossAxisAlignment.start, // Align labels to the left
        children: [
          AppTextField(
            labelText: 'Template Name',
            initialValue: _name,
            onSaved: (val) => _name = val!,
            validator: (val) => val!.isEmpty ? 'Name is required' : null,
          ),
          const SizedBox(height: 16),
          AppTextField(
            labelText: 'Message Text',
            initialValue: _messageText,
            maxLines: 5,
            onSaved: (val) => _messageText = val!,
            validator: (val) =>
                val!.isEmpty ? 'Message text is required' : null,
          ),
          const SizedBox(height: 16),
          // *** FIX: Removed 'labelText' and wrapped in a Column ***
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Template Type',
                  style: TextStyle(
                      fontSize: 12, color: AppColors.mutedForeground)),
              const SizedBox(height: 8),
              AppRadioGroup<String>(
                groupValue: _type,
                onChanged: (val) => setState(() => _type = val!),
                // *** FIX: Must be a List<AppRadioItem> ***
                items: const [
                  AppRadioItem(
                      value: 'inbound', label: Text('Inbound (For AI Agent)')),
                  AppRadioItem(
                      value: 'outbound',
                      label: Text('Outbound (For Campaigns)')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AppButton(
                text: 'Cancel',
                // FIX: Replaced variant: AppButtonVariant.outline with style: AppButtonStyle.tertiary
                style: AppButtonStyle.tertiary,
                onPressed: () => Navigator.of(context).pop(),
              ),
              const SizedBox(width: 8),
              AppButton(
                text: 'Save Template',
                onPressed: _handleSubmit,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
