import 'dart:convert'; // For formatting query result
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:humainise_ai/core/providers/knowledge_provider.dart';
import 'package:humainise_ai/core/theme/app_colors.dart';
import 'package:humainise_ai/core/utils/responsive.dart';
import 'package:humainise_ai/widgets/ui/app_badge.dart';
import 'package:humainise_ai/widgets/ui/app_button.dart';
import 'package:humainise_ai/widgets/ui/app_card.dart';
import 'package:humainise_ai/widgets/ui/app_text_field.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:humainise_ai/models/knowledge_source.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:humainise_ai/core/providers/auth_provider.dart';

class KnowledgeScreen extends ConsumerStatefulWidget {
  const KnowledgeScreen({super.key});

  @override
  ConsumerState<KnowledgeScreen> createState() => _KnowledgeScreenState();
}

class _KnowledgeScreenState extends ConsumerState<KnowledgeScreen> {
  final _urlController = TextEditingController();
  final _queryController = TextEditingController();
  final Map<int, bool> _expandedUrls = {};
  final Map<int, bool> _expandedFiles = {};
  bool _showQueryResult = false;
  PlatformFile? _selectedFile;

  @override
  void dispose() {
    _urlController.dispose();
    _queryController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    setState(() {
      _showQueryResult = false;
    });
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null && result.files.first.bytes != null) {
        setState(() {
          _selectedFile = result.files.first;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('File selection failed: $e'),
              backgroundColor: AppColors.destructive),
        );
      }
    }
  }

  // ADDED: Upload the selected file
  Future<void> _uploadSelectedFile() async {
    if (_selectedFile == null) return;

    try {
      await ref.read(knowledgeProvider.notifier).uploadFile(_selectedFile!);
      if (mounted) {
        await ref
            .read(authNotifierProvider.notifier)
            .maybeFetchOnboardingStatus();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('File ${_selectedFile!.name} uploaded successfully!')),
        );
        setState(() {
          _selectedFile = null; // Reset selection
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('File upload failed: $e'),
              backgroundColor: AppColors.destructive),
        );
      }
    }
  }

  // ADDED: Cancel selection
  void _cancelSelection() {
    setState(() {
      _selectedFile = null;
    });
  }

  Future<void> _addUrl() async {
    setState(() {
      _showQueryResult = false;
    });
    if (_urlController.text.isNotEmpty) {
      ref.read(knowledgeProvider.notifier).addUrl(_urlController.text);
      await ref
          .read(authNotifierProvider.notifier)
          .maybeFetchOnboardingStatus();

      _urlController.clear();
    }
  }

  void _runTestQuery() {
    if (_queryController.text.isNotEmpty) {
      ref.read(knowledgeProvider.notifier).testQuery(_queryController.text);
      setState(() {
        _showQueryResult = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(knowledgeProvider);
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
          if (state.isLoading)
            const Center(
                child: Padding(
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
              Text('Upload Knowledge Base',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 16),

          // MODIFIED: Interactive Dotted Border Area
          DottedBorder(
            borderType: BorderType.RRect,
            radius: const Radius.circular(8.0),
            color: AppColors.border,
            strokeWidth: 2.0,
            dashPattern: const [6, 3],
            child: Material(
              // Added Material for InkWell
              color: Colors.transparent,
              child: InkWell(
                onTap: _selectedFile == null
                    ? _pickFile
                    : null, // Click to pick if nothing selected
                borderRadius: BorderRadius.circular(8.0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32.0),
                  child: _selectedFile == null
                      ? _buildDropZoneContent() // Show "Drop files here"
                      : _buildSelectedFileContent(), // Show selected file + Upload button
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ADDED: Extracted drop zone content
  Widget _buildDropZoneContent() {
    return Column(
      children: [
        const Icon(LucideIcons.upload,
            size: 48, color: AppColors.mutedForeground),
        const SizedBox(height: 16),
        const Text('Click to upload or drag files here',
            style: TextStyle(fontWeight: FontWeight.w500)),
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
            onPressed: _pickFile, // Trigger pick
            style: AppButtonStyle.tertiary),
      ],
    );
  }

  // ADDED: Content when a file is selected but not uploaded
  Widget _buildSelectedFileContent() {
    return Column(
      children: [
        const Icon(LucideIcons.fileText, size: 48, color: AppColors.primary),
        const SizedBox(height: 16),
        Text(
          _selectedFile!.name,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          textAlign: TextAlign.center,
        ),
        Text(
          '${(_selectedFile!.size / 1024).toStringAsFixed(2)} KB',
          style:
              const TextStyle(color: AppColors.mutedForeground, fontSize: 12),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppButton(
              text: 'Cancel',
              style: AppButtonStyle.destructive, // Or secondary/outline
              onPressed: _cancelSelection,
            ),
            const SizedBox(width: 16),
            AppButton(
              text: 'Upload Now',
              icon: const Icon(LucideIcons.uploadCloud),
              style: AppButtonStyle.primary,
              onPressed: _uploadSelectedFile,
            ),
          ],
        ),
      ],
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
              Text('Business Website Links',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
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
            crossAxisAlignment:
                mobile ? CrossAxisAlignment.stretch : CrossAxisAlignment.center,
            children: [
              !mobile
                  ? Expanded(
                      child: AppTextField(
                          controller: _urlController,
                          labelText: 'Website URL',
                          hintText: 'https://yourbusiness.com/about'),
                    )
                  : AppTextField(
                      controller: _urlController,
                      labelText: 'Website URL',
                      hintText: 'https://yourbusiness.com/about'),
              SizedBox(width: mobile ? 0 : 8, height: mobile ? 12 : 0),
              AppButton(
                text: 'Add Link',
                icon: const Icon(LucideIcons.plus),
                onPressed: _addUrl,
                width: mobile ? double.infinity : null,
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...state.urlSources.map((link) => _buildLinkItem(context, link)),
        ],
      ),
    );
  }

  // <-- 1. UPDATED WIDGET: _buildLinkItem
  Widget _buildLinkItem(BuildContext context, KnowledgeSource link) {
    final bool mobile = isMobile(context);
    final bool isScraped = link.processingStatus == 'Completed';
    final bool isPending = link.processingStatus == 'Pending';
    final bool isExpanded = _expandedUrls[link.id] ?? false;
    final bool hasSummary = link.summary != null && link.summary!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: const Icon(LucideIcons.externalLink,
                      color: AppColors.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(link.name,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      // Use Wrap for the URL and button to be responsive
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8.0,
                        runSpacing: 4.0,
                        children: [
                          Text(
                            link.sourceUri,
                            style: const TextStyle(
                                color: AppColors.mutedForeground, fontSize: 12),
                          ),
                          if (hasSummary)
                            // Smaller, styled TextButton
                            TextButton.icon(
                              onPressed: () => setState(() {
                                _expandedUrls[link.id] = !isExpanded;
                              }),
                              icon: Icon(
                                isExpanded
                                    ? LucideIcons.chevronUp
                                    : LucideIcons.chevronDown,
                                size: 14,
                                color: AppColors.primary,
                              ),
                              label: const Text(
                                'Summary',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary),
                              ),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4)),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    AppBadge(
                      text: link.processingStatus,
                      variant: isScraped
                          ? AppBadgeVariant.success
                          : (isPending
                              ? AppBadgeVariant.secondary
                              : AppBadgeVariant.destructive),
                    ),
                    const SizedBox(height: 8),
                    //if (mobile)
                    IconButton(
                      icon: const Icon(LucideIcons.refreshCw, size: 18),
                      color: AppColors.mutedForeground,
                      tooltip: 'Refresh',
                      onPressed: () =>
                          ref.read(knowledgeProvider.notifier).loadKnowledge(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    )
                    // else
                    //   AppButton(
                    //     text: 'Refresh',
                    //     icon: const Icon(LucideIcons.refreshCw, size: 14),
                    //     onPressed: () => ref.read(knowledgeProvider.notifier).loadKnowledge(),
                    //     style: AppButtonStyle.tertiary,
                    //   ),
                  ],
                ),
              ],
            ),
          ),
          Visibility(
            visible: isExpanded && hasSummary,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: AppColors.border))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  const Text('Summary',
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(
                    link.summary ?? "No summary available.",
                    style: const TextStyle(
                        color: AppColors.mutedForeground, fontSize: 14),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildKnowledgeTestCard(BuildContext context, KnowledgeState state) {
    final bool mobile = Responsive.isMobile(context);

    // Helper widget to render the result as Markdown
    Widget _buildQueryResult() {
      if (state.queryResult == null) {
        return const Text(
          "Try asking: \"What are your product prices?\" or \"What's your refund policy?\"",
          style: TextStyle(color: AppColors.mutedForeground, fontSize: 14),
        );
      }

      // Render the result as Markdown
      return MarkdownBody(
        data: state.queryResult!,
        selectable: true,
        onTapLink: (text, href, title) {
          if (href != null) {
            try {
              launchUrl(Uri.parse(href));
            } catch (e) {
              print('Could not launch $href: $e');
            }
          }
        },
        imageBuilder: (uri, title, alt) {
          // Re-using the responsive image logic from chat_message_bubble
          final bool isMobile = Responsive.isMobile(context);
          final double maxImageWidth = isMobile ? 250.0 : 350.0;
          const double maxImageHeight = 400.0;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: maxImageWidth,
                maxHeight: maxImageHeight,
              ),
              child: Image.network(
                uri.toString(),
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Text(
                    '[Failed to load image: $alt]\n(Check console for CORS errors)',
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  );
                },
              ),
            ),
          );
        },
      );
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(LucideIcons.search, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text('Test Knowledge Base',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 16),
          Flex(
            direction: mobile ? Axis.vertical : Axis.horizontal,
            crossAxisAlignment:
                mobile ? CrossAxisAlignment.stretch : CrossAxisAlignment.center,
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
              AppButton(
                  text: 'Test Query',
                  onPressed: _runTestQuery,
                  width: mobile ? double.infinity : null),
            ],
          ),
          const SizedBox(height: 12),
          Visibility(
            visible: _showQueryResult &&
                (state.queryResult != null && state.queryResult!.isNotEmpty),
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: AppColors.muted,
                      borderRadius: BorderRadius.circular(8.0)),
                  child:
                      _buildQueryResult(), // <-- Use the new Markdown renderer
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: IconButton(
                    icon: const Icon(LucideIcons.x,
                        size: 16, color: AppColors.mutedForeground),
                    onPressed: () => setState(() {
                      _showQueryResult = false;
                    }),
                    tooltip: 'Close result',
                  ),
                ),
              ],
            ),
          ),
          Visibility(
            visible: !_showQueryResult ||
                (state.queryResult == null || state.queryResult!.isEmpty),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: AppColors.muted,
                  borderRadius: BorderRadius.circular(8.0)),
              child: const Text(
                "Try asking: \"What are your product prices?\" or \"What's your refund policy?\"",
                style:
                    TextStyle(color: AppColors.mutedForeground, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // <-- 2. UPDATED WIDGET: _buildKnowledgeItemsList
  Widget _buildKnowledgeItemsList(BuildContext context, KnowledgeState state) {
    final bool mobile = isMobile(context);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flex(
            direction: mobile ? Axis.vertical : Axis.horizontal,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Uploaded Documents',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
              SizedBox(height: mobile ? 12 : 0),
              AppButton(
                text: 'Refresh',
                icon: const Icon(LucideIcons.refreshCw, size: 14),
                onPressed: () =>
                    ref.read(knowledgeProvider.notifier).loadKnowledge(),
                style:
                    mobile ? AppButtonStyle.primary : AppButtonStyle.tertiary,
                width: mobile ? double.infinity : null,
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...state.fileSources.map((item) {
            final bool isTrained = item.processingStatus == 'Completed';
            final bool isPending = item.processingStatus == 'Pending';
            final bool isExpanded = _expandedFiles[item.id] ?? false;
            final bool hasSummary =
                item.summary != null && item.summary!.isNotEmpty;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8.0)),
                          child: const Icon(LucideIcons.fileText,
                              color: AppColors.primary),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              // Use Wrap for the file info and button
                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 8.0,
                                runSpacing: 4.0,
                                children: [
                                  Text(
                                    "FILE • ${item.formattedSize}",
                                    style: const TextStyle(
                                        color: AppColors.mutedForeground,
                                        fontSize: 12),
                                  ),
                                  if (hasSummary)
                                    // Smaller, styled TextButton
                                    TextButton.icon(
                                      onPressed: () => setState(() {
                                        _expandedFiles[item.id] = !isExpanded;
                                      }),
                                      icon: Icon(
                                        isExpanded
                                            ? LucideIcons.chevronUp
                                            : LucideIcons.chevronDown,
                                        size: 14,
                                        color: AppColors.primary,
                                      ),
                                      label: const Text(
                                        'Summary',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.primary),
                                      ),
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        minimumSize: Size.zero,
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(4)),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            AppBadge(
                              text: item.processingStatus,
                              variant: isTrained
                                  ? AppBadgeVariant.success
                                  : (isPending
                                      ? AppBadgeVariant.secondary
                                      : AppBadgeVariant.destructive),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 4,
                              runSpacing: 4,
                              alignment: WrapAlignment.end,
                              direction:
                                  mobile ? Axis.vertical : Axis.horizontal,
                              children: item.tags
                                  .map((tag) => AppBadge(
                                      text: tag,
                                      variant: AppBadgeVariant.outline,
                                      icon: const Icon(LucideIcons.tag,
                                          size: 14)))
                                  .toList(),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: isExpanded && hasSummary,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      decoration: const BoxDecoration(
                          border:
                              Border(top: BorderSide(color: AppColors.border))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 12),
                          const Text('Summary',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 14)),
                          const SizedBox(height: 4),
                          Text(item.summary ?? "No summary available.",
                              style: const TextStyle(
                                  color: AppColors.mutedForeground,
                                  fontSize: 14)),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
