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
import 'package:humainity_flutter/core/utils/responsive.dart';
import 'package:humainity_flutter/core/providers/auth_provider.dart';

class TemplatesScreen extends ConsumerStatefulWidget {
  const TemplatesScreen({super.key});

  @override
  ConsumerState<TemplatesScreen> createState() => _TemplatesScreenState();
}

class _TemplatesScreenState extends ConsumerState<TemplatesScreen> {
  bool _showOutbound = true;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(templatesProvider);
    final templates =
    _showOutbound ? state.outboundTemplates : state.inboundTemplates;
    final bool isMobileScreen = isMobile(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16.0),
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
              SizedBox(height: isMobileScreen ? 16 : 0),
              AppButton(
                text: 'Create Template',
                icon: const Icon(LucideIcons.plus, size: 16),
                onPressed: () {
                  _showTemplateForm(context, ref, null);
                },
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
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(4.0),
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
      barrierDismissible: false,
      builder: (context) {
        return _TemplateFormDialog(template: template, ref: ref);
      },
    );
  }
}

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

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 350.0,
        mainAxisSpacing: 16.0,
        crossAxisSpacing: 16.0,
        mainAxisExtent: 340, // Increased height for media
      ),
      itemCount: templates.length,
      itemBuilder: (context, index) {
        return _TemplateCard(template: templates[index]);
      },
    );
  }
}

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

  IconData _getMediaIcon(MediaType type) {
    switch (type) {
      case MediaType.VIDEO:
        return LucideIcons.video;
      case MediaType.DOCUMENT:
        return LucideIcons.fileText;
      case MediaType.IMAGE:
        return LucideIcons.image;
      default:
        return LucideIcons.link;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool hasMedia =
        template.mediaType != MediaType.TEXT && template.mediaLink != null;

    return AppCard(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
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

          Text(
            template.name,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  template.body,
                  style: const TextStyle(
                      color: AppColors.mutedForeground, fontSize: 14),
                  maxLines: hasMedia ? 3 : 5,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),

                if (hasMedia)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.muted.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: AppColors.border.withOpacity(0.5)),
                    ),
                    child: Row(
                      children: [
                        // Show Image Preview if type is IMAGE
                        if (template.mediaType == MediaType.IMAGE)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.network(
                              template.mediaLink!,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(LucideIcons.imageOff,
                                    size: 20, color: AppColors.destructive);
                              },
                            ),
                          )
                        else
                          Icon(
                            _getMediaIcon(template.mediaType),
                            size: 20,
                            color: AppColors.primary,
                          ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                template.mediaType.displayName,
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.foreground),
                              ),
                              Text(
                                template.mediaLink!,
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.mutedForeground),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

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

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
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

class _TemplateFormDialog extends StatefulWidget {
  final Template? template;
  final WidgetRef ref;

  const _TemplateFormDialog({this.template, required this.ref});

  @override
  State<_TemplateFormDialog> createState() => _TemplateFormDialogState();
}

class _TemplateFormDialogState extends State<_TemplateFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _bodyController;
  late TextEditingController _mediaLinkController;
  late TemplateType _selectedType;
  late String _selectedLanguage;
  late String _selectedCategory;
  late MediaType _selectedMediaType;

  bool _isSaving = false;
  String? _previewImageUrl;
  final List<String> _languages = ['en', 'es', 'fr', 'de'];
  final List<String> _categories = ['MARKETING', 'UTILITY', 'AUTHENTICATION'];

  @override
  void initState() {
    super.initState();
    final t = widget.template;
    _nameController = TextEditingController(text: t?.name ?? '');
    _bodyController = TextEditingController(text: t?.body ?? '');
    _mediaLinkController = TextEditingController(text: t?.mediaLink ?? '');
    _selectedType = t?.type ?? TemplateType.OUTBOUND;
    _selectedLanguage = t?.language ?? _languages.first;
    _selectedCategory = t?.category ?? _categories.first;
    _selectedMediaType = t?.mediaType ?? MediaType.TEXT;

    // Set initial preview image if applicable
    if (_selectedMediaType == MediaType.IMAGE &&
        _mediaLinkController.text.isNotEmpty) {
      _previewImageUrl = _mediaLinkController.text;
    }

    // Add listener to update preview on change
    _mediaLinkController.addListener(() {
      if (_selectedMediaType == MediaType.IMAGE) {
        setState(() {
          _previewImageUrl = _mediaLinkController.text.isNotEmpty
              ? _mediaLinkController.text
              : null;
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bodyController.dispose();
    _mediaLinkController.dispose();
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
      'media_type': _selectedMediaType.toJson(),
      'media_link': _mediaLinkController.text.isNotEmpty
          ? _mediaLinkController.text
          : null,
    };
  }

  Future<void> _onSave(TemplateStatus status) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final data = _getFormData(status);
    bool success;

    if (widget.template == null) {
      success =
      await widget.ref.read(templatesProvider.notifier).addTemplate(data);
    } else {
      success = await widget.ref
          .read(templatesProvider.notifier)
          .editTemplate(widget.template!.id, data);
    }

    if (mounted) {
      setState(() {
        _isSaving = false;
      });
      if (success) {
        Navigator.pop(context);
        await widget.ref
            .read(authNotifierProvider.notifier)
            .maybeFetchOnboardingStatus();
      }
    }
  }

  void _onClose() {
    if (widget.template == null) {
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
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
            AppButton(
              text: 'Save as Draft',
              onPressed: () {
                Navigator.pop(context);
                _onSave(TemplateStatus.DRAFT);
              },
            ),
          ],
        );
      } else {
        Navigator.pop(context);
      }
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
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
      content: SizedBox(
        width: isMobileScreen ? screenWidth * 0.9 : screenWidth * 0.5,
        // Use a ConstrainedBox to ensure the dialog doesn't grow too large
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
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
                  AppDropdown<MediaType>(
                    labelText: 'Media Type',
                    value: _selectedMediaType,
                    items: [
                      MediaType.TEXT,
                      MediaType.VIDEO,
                      MediaType.DOCUMENT,
                      MediaType.IMAGE
                    ]
                        .map((t) => DropdownMenuItem(
                        value: t, child: Text(t.displayName)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedMediaType = val;
                          if (val == MediaType.TEXT) {
                            _mediaLinkController.clear();
                            _previewImageUrl = null;
                          } else if (val == MediaType.IMAGE &&
                              _mediaLinkController.text.isNotEmpty) {
                            _previewImageUrl = _mediaLinkController.text;
                          } else {
                            _previewImageUrl = null;
                          }
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  if (_selectedMediaType != MediaType.TEXT) ...[
                    AppTextField(
                      controller: _mediaLinkController,
                      labelText: 'Media Link',
                      hintText: 'e.g., https://example.com/image.png',
                      prefixIcon: const Icon(LucideIcons.link, size: 16),
                      validator: (val) {
                        if (_selectedMediaType != MediaType.TEXT &&
                            (val == null || val.isEmpty)) {
                          return 'Media Link is required for ${_selectedMediaType.displayName}';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Image Preview Section
                    if (_selectedMediaType == MediaType.IMAGE &&
                        _previewImageUrl != null)
                      Container(
                        height: 150,
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            _previewImageUrl!,
                            fit: BoxFit.cover,
                            loadingBuilder: (BuildContext context,
                                Widget child,
                                ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress
                                      .expectedTotalBytes !=
                                      null
                                      ? loadingProgress
                                      .cumulativeBytesLoaded /
                                      loadingProgress
                                          .expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Column(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: [
                                    Icon(LucideIcons.imageOff,
                                        size: 32,
                                        color: AppColors.destructive),
                                    SizedBox(height: 8),
                                    Text(
                                        'Failed to load image preview.',
                                        style: TextStyle(
                                            color: AppColors
                                                .mutedForeground)),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                  ],
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
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.all(16.0),
      actions: _isSaving
          ? []
          : [
        AppButton(
          text: 'Submit',
          onPressed: () => _onSave(TemplateStatus.SUBMITTED),
          width: isMobileScreen ? double.infinity : null,
        ),
      ],
    );
  }
}