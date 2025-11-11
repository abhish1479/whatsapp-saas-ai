import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:humainity_flutter/core/providers/campaign_detail_provider.dart';
import 'package:humainity_flutter/core/theme/app_colors.dart';
import 'package:humainity_flutter/core/utils/status_helpers.dart';
import 'package:humainity_flutter/models/campaign.dart';
import 'package:humainity_flutter/models/campaign_log.dart';
import 'package:humainity_flutter/widgets/ui/app_badge.dart';
import 'package:humainity_flutter/widgets/ui/app_button.dart';
import 'package:humainity_flutter/widgets/ui/app_card.dart';
import 'package:lucide_icons/lucide_icons.dart';

class CampaignDetailScreen extends ConsumerWidget {
  final String campaignId;

  const CampaignDetailScreen({super.key, required this.campaignId});

  @override
  Widget build(BuildContext c, WidgetRef ref) {
    // <-- The context is 'c'
    final state = ref.watch(campaignDetailProvider(campaignId));

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

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
          _buildHeader(c, ref, campaign), // *** FIX: Was 'context', now 'c' ***
          const SizedBox(height: 24),
          _buildStats(campaign),
          const SizedBox(height: 24),
          _buildLogs(state.logs),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, Campaign campaign) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(LucideIcons.arrowLeft),
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    campaign.name,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 12),
                  AppBadge(
                    text: campaign.status,
                    color: getStatusColor(campaign.status),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 52), // Align with title
                child: Text(
                  'Manage and review your ${campaign.channel} campaign.',
                  style: const TextStyle(color: AppColors.mutedForeground),
                ),
              ),
            ],
          ),
        ),
        _buildActionButtons(ref, campaign),
      ],
    );
  }

  Widget _buildActionButtons(WidgetRef ref, Campaign campaign) {
    return Row(
      children: [
        if (campaign.status == 'running')
          AppButton(
            text: 'Pause',
            icon: const Icon(LucideIcons.pause),
            // FIX: Replaced variant: AppButtonVariant.outline with style: AppButtonStyle.tertiary
            style: AppButtonStyle.tertiary,
            // *** FIX: Call correct notifier method ***
            onPressed: () => ref
                .read(campaignDetailProvider(campaign.id).notifier)
                .updateStatus('paused'),
          ),
        if (campaign.status == 'draft' || campaign.status == 'paused')
          AppButton(
            text: 'Run Campaign',
            icon: const Icon(LucideIcons.play),
            // *** FIX: Call correct notifier method ***
            onPressed: () => ref
                .read(campaignDetailProvider(campaign.id).notifier)
                .updateStatus('running'),
          ),
        const SizedBox(width: 8),
        AppButton(
          text: 'Refresh Data',
          icon: const Icon(LucideIcons.refreshCw),
          // FIX: Replaced variant: AppButtonVariant.ghost with style: AppButtonStyle.tertiary
          style: AppButtonStyle.tertiary,
          // *** FIX: Call correct notifier method ***
          onPressed: () => ref
              .read(campaignDetailProvider(campaign.id).notifier)
              .refreshData(),
        ),
      ],
    );
  }

  Widget _buildStats(Campaign campaign) {
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 2.5,
      ),
      children: [
        _buildStatCard('Total Contacts', campaign.totalContacts.toString()),
        _buildStatCard('Contacts Reached', campaign.contactsReached.toString()),
        _buildStatCard('Successful', campaign.successfulDeliveries.toString(),
            Colors.green),
        _buildStatCard(
            'Failed', campaign.failedDeliveries.toString(), Colors.red),
        // *** FIX: Use getter 'engagementRate' from fixed model ***
        _buildStatCard('Engagement Rate',
            '${campaign.engagementRate.toStringAsFixed(1)}%'),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, [Color? valueColor]) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: AppColors.mutedForeground, fontSize: 14)),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogs(List<CampaignLog> logs) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Campaign Logs',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          if (logs.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text('No logs yet. Run the campaign to see activity.',
                    style: TextStyle(color: AppColors.mutedForeground)),
              ),
            )
          else
            SizedBox(
              height: 400, // Fixed height for scrollable list
              child: ListView.builder(
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  final log = logs[index];
                  return ListTile(
                    leading: Icon(
                      log.status == 'success'
                          ? LucideIcons.checkCircle2
                          : LucideIcons.xCircle,
                      color:
                          log.status == 'success' ? Colors.green : Colors.red,
                    ),
                    // *** FIX: Use 'message' field from fixed model ***
                    title: Text(log.message),
                    // *** FIX: Use 'contactIdentifier' from fixed model ***
                    subtitle:
                        Text('Contact: ${log.contactIdentifier ?? "N/A"}'),
                    trailing: Text(
                      '${log.createdAt.toLocal().hour}:${log.createdAt.toLocal().minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                          color: AppColors.mutedForeground, fontSize: 12),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
