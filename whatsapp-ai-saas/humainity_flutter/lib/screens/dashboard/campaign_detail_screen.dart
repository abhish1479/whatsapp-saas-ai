import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:humainise_ai/core/providers/campaign_detail_provider.dart';
import 'package:humainise_ai/core/theme/app_colors.dart';
import 'package:humainise_ai/core/utils/responsive.dart';
import 'package:humainise_ai/core/utils/status_helpers.dart';
import 'package:humainise_ai/models/campaign.dart';
import 'package:humainise_ai/widgets/ui/app_badge.dart';
import 'package:humainise_ai/widgets/ui/app_button.dart';
import 'package:humainise_ai/widgets/ui/app_card.dart';
import 'package:lucide_icons/lucide_icons.dart';

class CampaignDetailScreen extends ConsumerWidget {
  final String campaignId;

  const CampaignDetailScreen({super.key, required this.campaignId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int? id = int.tryParse(campaignId);
    if (id == null) return const Center(child: Text("Invalid Campaign ID"));

    final state = ref.watch(campaignDetailProvider(id));

    if (state.isLoading)
      return const Center(child: CircularProgressIndicator());
    if (state.error != null || state.campaign == null) {
      return Center(
          child: Text('Error: ${state.error ?? "Campaign not found"}'));
    }

    final campaign = state.campaign!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, ref, campaign),
          const SizedBox(height: 24),
          _buildResponsiveStats(context, campaign),
          const SizedBox(height: 24),
          _buildDescriptionSection(campaign),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, Campaign campaign) {
    Widget buildTitleRow() {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(LucideIcons.arrowLeft),
            onPressed: () => context.pop(),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              campaign.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          AppBadge(
            text: campaign.status,
            color: getStatusColor(campaign.status),
          ),
        ],
      );
    }

    if (Responsive.isMobile(context)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildTitleRow(),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: _buildActionButtons(ref, campaign),
          ),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: buildTitleRow()),
          _buildActionButtons(ref, campaign),
        ],
      );
    }
  }

  Widget _buildActionButtons(WidgetRef ref, Campaign campaign) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (campaign.status == 'Running')
          AppButton(
            text: 'Pause',
            icon: const Icon(LucideIcons.pause),
            style: AppButtonStyle.tertiary,
            onPressed: () => ref
                .read(campaignDetailProvider(campaign.id).notifier)
                .updateStatus('pause'),
          ),
        if (campaign.status == 'Draft' || campaign.status == 'Paused')
          AppButton(
            text: 'Run Campaign',
            icon: const Icon(LucideIcons.play),
            onPressed: () => ref
                .read(campaignDetailProvider(campaign.id).notifier)
                .updateStatus('start'),
          ),
        AppButton(
          text: 'Refresh',
          icon: const Icon(LucideIcons.refreshCw),
          style: AppButtonStyle.tertiary,
          onPressed: () => ref
              .read(campaignDetailProvider(campaign.id).notifier)
              .refreshData(),
        ),
      ],
    );
  }

  Widget _buildResponsiveStats(BuildContext context, Campaign campaign) {
    double cardWidth;
    if (Responsive.isMobile(context)) {
      // (Screen width - padding - spacing) / 2 to show 2 cards per row
      final screenWidth = MediaQuery.of(context).size.width;
      cardWidth = (screenWidth - 32 - 16) / 2;
    } else {
      cardWidth = 200; // Fixed width for larger screens
    }

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _buildStatCard('Total Leads', campaign.totalLeads.toString(),
            width: cardWidth),
        _buildStatCard('New / Pending', campaign.newLeads.toString(),
            width: cardWidth),
        _buildStatCard('Sent', campaign.sent.toString(), width: cardWidth),
        // FIX: Added parameter name 'valueColor:'
        _buildStatCard('Success', campaign.success.toString(),
            valueColor: Colors.green, width: cardWidth),
        _buildStatCard('Failed', campaign.failed.toString(),
            valueColor: Colors.red, width: cardWidth),
      ],
    );
  }

  // FIX: Changed [] to {} for named parameters
  Widget _buildStatCard(String title, String value,
      {Color? valueColor, double? width}) {
    return SizedBox(
      width: width,
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                  color: AppColors.mutedForeground, fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionSection(Campaign campaign) {
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Campaign Configuration",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildDetailRow("Description",
              campaign.description ?? "No description provided."),
          const Divider(height: 24),
          _buildDetailRow(
              "Template", campaign.templateName ?? "No template selected"),
          const Divider(height: 24),
          _buildDetailRow("Channel", campaign.channel),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(
                fontWeight: FontWeight.w500, color: AppColors.mutedForeground),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: AppColors.foreground),
          ),
        ),
      ],
    );
  }
}
