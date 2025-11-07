// humainity_saas/lib/screens/dashboard/knowledge_screen.dart

import 'package:flutter/material.dart';
import 'package:humainity_flutter/core/theme/app_colors.dart';
import 'package:humainity_flutter/widgets/ui/app_badge.dart';
import 'package:humainity_flutter/widgets/ui/app_button.dart';
import 'package:humainity_flutter/widgets/ui/app_card.dart';
import 'package:humainity_flutter/widgets/ui/app_text_field.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:dotted_border/dotted_border.dart';

const knowledgeItems = [
  {"name": "Product Catalog 2024.pdf", "type": "PDF", "size": "2.4 MB", "tags": ["Product", "Pricing"], "status": "Trained"},
  {"name": "Customer FAQs", "type": "Document", "size": "156 KB", "tags": ["Support", "FAQ"], "status": "Trained"},
  {"name": "Service Policies", "type": "Document", "size": "89 KB", "tags": ["Policy"], "status": "Training"},
];

const businessLinks = [
  {"url": "https://example.com/about", "title": "About Us Page", "status": "Scraped", "pages": 1},
  {"url": "https://example.com/services", "title": "Services Overview", "status": "Scraped", "pages": 3},
  {"url": "https://example.com/blog", "title": "Company Blog", "status": "Pending", "pages": 0},
];

class KnowledgeScreen extends StatelessWidget {
  const KnowledgeScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
          const SizedBox(height: 24),
          _buildUploadCard(),
          const SizedBox(height: 24),
          _buildWebsiteLinksCard(),
          const SizedBox(height: 24),
          _buildKnowledgeTestCard(),
          const SizedBox(height: 24),
          _buildKnowledgeItemsList(),
        ],
      ),
    );
  }

  Widget _buildUploadCard() {
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
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    text: 'Choose Files',
                    icon: const Icon(LucideIcons.upload),
                    variant: AppButtonVariant.outline,
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebsiteLinksCard() {
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
          Row(
            children: [
              // FIX: Add required labelText
              const Expanded(child: AppTextField(labelText: 'Website URL', hintText: 'https://yourbusiness.com/about')),
              const SizedBox(width: 8),
              AppButton(text: 'Add Link', icon: const Icon(LucideIcons.plus), onPressed: () {}),
            ],
          ),
          const SizedBox(height: 16),
          ...businessLinks.map((link) => _buildLinkItem(link)),
        ],
      ),
    );
  }

  Widget _buildLinkItem(Map<String, dynamic> link) {
    final bool isScraped = link['status'] == 'Scraped';
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
                Text(link['title'] as String, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(link['url'] as String, style: const TextStyle(color: AppColors.mutedForeground, fontSize: 12), overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                AppBadge(
                  text: link['status'] as String,
                  variant: isScraped ? AppBadgeVariant.primary : AppBadgeVariant.secondary,
                ),
              ],
            ),
          ),
          AppButton(text: 'Refresh', variant: AppButtonVariant.ghost, onPressed: () {}),
        ],
      ),
    );
  }

  Widget _buildKnowledgeTestCard() {
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
          Row(
            children: [
              // FIX: Add required labelText
              const Expanded(child: AppTextField(labelText: 'Test Query', hintText: 'Ask a test question...')),
              const SizedBox(width: 8),
              AppButton(text: 'Test Query', onPressed: () {}),
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
            child: const Text(
              "Try asking: \"What are your product prices?\" or \"What's your refund policy?\"",
              style: TextStyle(color: AppColors.mutedForeground, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKnowledgeItemsList() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Uploaded Documents', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
              AppButton(text: 'Re-train All', variant: AppButtonVariant.outline, onPressed: () {}),
            ],
          ),
          const SizedBox(height: 16),
          // FIX: Corrected map syntax to ensure it returns a valid Iterable<Widget> for the spread operator.
          ...knowledgeItems.map((item) {
            final bool isTrained = item['status'] == 'Trained';
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
                    child: const Icon(LucideIcons.fileText, color: AppColors.primary),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['name'] as String, style: const TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text("${item['type']} • ${item['size']}", style: const TextStyle(color: AppColors.mutedForeground, fontSize: 12)),
                            const SizedBox(width: 8),
                            AppBadge(
                              text: item['status'] as String,
                              variant: isTrained ? AppBadgeVariant.primary : AppBadgeVariant.secondary,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Wrap(
                    spacing: 8,
                    children: (item['tags'] as List<String>).map((tag) => AppBadge(text: tag, variant: AppBadgeVariant.outline, icon: const Icon(LucideIcons.tag))).toList(),
                  ),
                ],
              ),
            );
          }).toList(), // Map's result needs to be a list/iterable, and the original code structure suggests a missing return or incorrect lambda syntax
        ],
      ),
    );
  }
}