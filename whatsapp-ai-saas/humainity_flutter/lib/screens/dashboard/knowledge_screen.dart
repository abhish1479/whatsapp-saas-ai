import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:humainity_flutter/core/providers/knowledge_provider.dart';
import 'package:humainity_flutter/core/theme/app_colors.dart';
import 'package:humainity_flutter/core/utils/responsive.dart';
import 'package:humainity_flutter/widgets/ui/app_badge.dart';
import 'package:humainity_flutter/widgets/ui/app_button.dart';
import 'package:humainity_flutter/widgets/ui/app_card.dart';
import 'package:humainity_flutter/widgets/ui/app_text_field.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart'; // Import file picker
import 'package:humainity_flutter/models/knowledge_source.dart'; // Import the model

// ConsumerStatefulWidget is needed for controllers and ref
class KnowledgeScreen extends ConsumerStatefulWidget {
  const KnowledgeScreen({super.key});

  @override
  ConsumerState<KnowledgeScreen> createState() => _KnowledgeScreenState();
}

class _KnowledgeScreenState extends ConsumerState<KnowledgeScreen> {
  // Controllers for the text fields
  final _urlController = TextEditingController();
  final _queryController = TextEditingController();

  @override
  void dispose() {
    _urlController.dispose();
    _queryController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null && result.files.first.bytes != null) {
        PlatformFile file = result.files.first;
        await ref.read(knowledgeProvider.notifier).uploadFile(file);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('File ${file.name} uploaded successfully!')),
          );
        }
      } else {
        // User canceled the picker or file is invalid
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File upload failed: $e'), backgroundColor: AppColors.destructive),
        );
      }
    }
  }

  void _addUrl() {
    if (_urlController.text.isNotEmpty) {
      ref.read(knowledgeProvider.notifier).addUrl(_urlController.text);
      _urlController.clear();
    }
  }

  void _runTestQuery() {
    if (_queryController.text.isNotEmpty) {
      ref.read(knowledgeProvider.notifier).testQuery(_queryController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch the provider for state changes
    final state = ref.watch(knowledgeProvider);
    final bool mobile = isMobile(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Knowledge Management',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Train your AI on business documents, FAQs, and media',
            style: TextStyle(color: AppColors.mutedForeground),
          ),
          const SizedBox(height: 12),
          // Show a global loading indicator or error
          if (state.isLoading)
            const Center(child: Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            )),
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

          _buildUploadCard(state),
          const SizedBox(height: 24),
          _buildWebsiteLinksCard(context, state),
          const SizedBox(height: 24),
          _buildKnowledgeTestCard(context, state),
          const SizedBox(height: 24),
          _buildKnowledgeItemsList(context, state),
        ],
      ),
    );
  }

  Widget _buildUploadCard(KnowledgeState state) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(LucideIcons.bookOpen, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text('Upload Knowledge Base', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 16),
          DottedBorder(
            borderType: BorderType.RRect,
            radius: const Radius.circular(8.0),
            color: AppColors.border,
            strokeWidth: 2.0,
            dashPattern: const [6, 3],
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  const Icon(LucideIcons.upload, size: 48, color: AppColors.mutedForeground),
                  const SizedBox(height: 16),
                  const Text('Drop files here or click to upload', style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  const Text(
                    'Supports PDF, DOC, TXT, and media files up to 50MB',
                    style: TextStyle(color: AppColors.mutedForeground, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    text: 'Choose Files',
                    icon: const Icon(LucideIcons.upload),
                    variant: AppButtonVariant.outline,
                    onPressed: _pickAndUploadFile, // Call the upload function
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebsiteLinksCard(BuildContext context, KnowledgeState state) {
    final bool mobile = isMobile(context);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(LucideIcons.link, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text('Business Website Links', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Add website URLs for the AI to crawl and understand your business',
            style: TextStyle(color: AppColors.mutedForeground, fontSize: 14),
          ),
          const SizedBox(height: 16),
          Flex(
            direction: mobile ? Axis.vertical : Axis.horizontal,
            crossAxisAlignment: mobile ? CrossAxisAlignment.stretch : CrossAxisAlignment.center,
            children: [
              // *** FIX: Conditionally wrap in Expanded ***
              !mobile
                  ? Expanded(
                // Desktop: Use Expanded
                child: AppTextField(
                    controller: _urlController, // Use the controller
                    labelText: 'Website URL',
                    hintText: 'https://yourbusiness.com/about'),
              )
                  : AppTextField(
                // Mobile: Do not use Expanded
                  controller: _urlController, // Use the controller
                  labelText: 'Website URL',
                  hintText: 'https://yourbusiness.com/about'),
              SizedBox(width: mobile ? 0 : 8, height: mobile ? 12 : 0),

              // *** FIX: This AppButton was incomplete in your file ***
              AppButton(
                text: 'Add Link',
                icon: const Icon(LucideIcons.plus),
                onPressed: _addUrl, // Call the add URL function
                width: mobile ? double.infinity : null,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Use the dynamic data from the state
          ...state.urlSources.map((link) => _buildLinkItem(context, link)),
        ],
      ),
    );
  }

  Widget _buildLinkItem(BuildContext context, KnowledgeSource link) {
    final bool mobile = isMobile(context);
    final bool isScraped = link.processingStatus == 'TRAINED'; // Use 'TRAINED' as 'Scraped'
    final bool isPending = link.processingStatus == 'PENDING';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: const Icon(LucideIcons.externalLink, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(link.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(link.sourceUri, style: const TextStyle(color: AppColors.mutedForeground, fontSize: 12), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(width: 8),
          AppBadge(
            text: link.processingStatus,
            variant: isScraped ? AppBadgeVariant.primary : (isPending ? AppBadgeVariant.secondary : AppBadgeVariant.destructive),
          ),
          if (mobile)
            IconButton(
              icon: const Icon(LucideIcons.refreshCw, size: 18),
              color: AppColors.mutedForeground,
              tooltip: 'Refresh',
              onPressed: () => ref.read(knowledgeProvider.notifier).loadKnowledge(), // Refresh all
            )
          else
            AppButton(
              text: 'Refresh',
              icon: const Icon(LucideIcons.refreshCw, size: 14),
              variant: AppButtonVariant.ghost,
              onPressed: () => ref.read(knowledgeProvider.notifier).loadKnowledge(), // Refresh all
            ),
        ],
      ),
    );
  }

  Widget _buildKnowledgeTestCard(BuildContext context, KnowledgeState state) {
    final bool mobile = isMobile(context);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(LucideIcons.search, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text('Test Knowledge Base', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 16),
          Flex(
            direction: mobile ? Axis.vertical : Axis.horizontal,
            crossAxisAlignment: mobile ? CrossAxisAlignment.stretch : CrossAxisAlignment.center,
            children: [
              !mobile
                  ? Expanded(
                  child: AppTextField(
                      controller: _queryController,
                      labelText: 'Test Query',
                      hintText: 'Ask a test question...'))
                  : AppTextField(
                  controller: _queryController,
                  labelText: 'Test Query',
                  hintText: 'Ask a test question...'),
              SizedBox(width: mobile ? 0 : 8, height: mobile ? 12 : 0),

              // *** FIX: This AppButton was incomplete in your file ***
              AppButton(
                  text: 'Test Query',
                  onPressed: _runTestQuery, // Call query function
                  width: mobile ? double.infinity : null
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.muted,
              borderRadius: BorderRadius.circular(8.0),
            ),
            // Show the query result from the state
            child: Text(
              state.queryResult ?? "Try asking: \"What are your product prices?\" or \"What's your refund policy?\"",
              style: const TextStyle(color: AppColors.mutedForeground, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKnowledgeItemsList(BuildContext context, KnowledgeState state) {
    final bool mobile = isMobile(context);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flex(
            direction: mobile ? Axis.vertical : Axis.horizontal,
            crossAxisAlignment: mobile ? CrossAxisAlignment.stretch : CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Uploaded Documents', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
              SizedBox(height: mobile ? 12 : 0),
              if (mobile)
                AppButton(
                  text: 'Refresh',
                  icon: const Icon(LucideIcons.refreshCw, size: 14),
                  variant: AppButtonVariant.outline,
                  onPressed: () => ref.read(knowledgeProvider.notifier).loadKnowledge(),
                  width: double.infinity,
                )
              else
                AppButton(
                  text: 'Refresh',
                  icon: const Icon(LucideIcons.refreshCw, size: 14),
                  variant: AppButtonVariant.ghost,
                  onPressed: () => ref.read(knowledgeProvider.notifier).loadKnowledge(),
                ),
            ],
          ),
          const SizedBox(height: 16),
          // Use the dynamic data from the state
          ...state.fileSources.map((item) {
            final bool isTrained = item.processingStatus == 'TRAINED';
            final bool isPending = item.processingStatus == 'PENDING';

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: const Icon(LucideIcons.fileText, color: AppColors.primary),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(
                          // Use the formattedSize getter from the model
                            "FILE • ${item.formattedSize}",
                            style: const TextStyle(color: AppColors.mutedForeground, fontSize: 12)
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      AppBadge(
                        text: item.processingStatus,
                        variant: isTrained ? AppBadgeVariant.primary : (isPending ? AppBadgeVariant.secondary : AppBadgeVariant.destructive),
                      ),
                      const SizedBox(height: 8),
                      if (mobile)
                        SizedBox(
                          width: 120,
                          child: Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            alignment: WrapAlignment.end,
                            children: item.tags
                                .map((tag) => AppBadge(
                              text: tag,
                              variant: AppBadgeVariant.outline,
                              icon: const Icon(LucideIcons.tag, size: 14),
                            ))
                                .toList(),
                          ),
                        )
                      else
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          alignment: WrapAlignment.end,
                          children: item.tags
                              .map((tag) => AppBadge(
                            text: tag,
                            variant: AppBadgeVariant.outline,
                            icon: const Icon(LucideIcons.tag, size: 14),
                          ))
                              .toList(),
                        )
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}