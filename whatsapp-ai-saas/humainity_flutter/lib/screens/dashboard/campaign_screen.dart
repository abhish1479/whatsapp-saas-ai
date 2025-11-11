import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:humainity_flutter/core/providers/campaigns_provider.dart';
import 'package:humainity_flutter/core/theme/app_colors.dart';
import 'package:humainity_flutter/core/utils/status_helpers.dart';
import 'package:humainity_flutter/models/campaign.dart';
import 'package:humainity_flutter/models/template.dart';
import 'package:humainity_flutter/widgets/ui/app_badge.dart';
import 'package:humainity_flutter/widgets/ui/app_button.dart';
import 'package:humainity_flutter/widgets/ui/app_card.dart';
import 'package:humainity_flutter/widgets/ui/app_dialog.dart';
import 'package:humainity_flutter/widgets/ui/app_dropdown.dart';
import 'package:humainity_flutter/widgets/ui/app_radio_group.dart';
import 'package:humainity_flutter/widgets/ui/app_text_field.dart';
import 'package:lucide_icons/lucide_icons.dart';

class CampaignScreen extends ConsumerStatefulWidget {
  const CampaignScreen({super.key});

  @override
  ConsumerState<CampaignScreen> createState() => _CampaignScreenState();
}

class _CampaignScreenState extends ConsumerState<CampaignScreen> {
  String _selectedTab = 'whatsapp';

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(campaignsProvider);
    final whatsappCampaigns = ref.watch(whatsappCampaignsProvider);
    final voiceCampaigns = ref.watch(voiceCampaignsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, ref),
          const SizedBox(height: 24),
          _buildTabs(context),
          const SizedBox(height: 16),
          if (state.isLoading)
            const Center(child: CircularProgressIndicator())
          else
            _selectedTab == 'whatsapp'
                ? _buildCampaignList(whatsappCampaigns)
                : _buildCampaignList(voiceCampaigns),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Campaigns',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                'Manage your outbound voice and WhatsApp campaigns.',
                style: TextStyle(color: AppColors.mutedForeground),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        AppButton(
          text: "Create Campaign",
          icon: const Icon(LucideIcons.plus),
          onPressed: () => _showCreateCampaignDialog(context, ref),
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
              text: 'WhatsApp',
              icon: const Icon(LucideIcons.messageCircle),
              // FIX: Replaced 'variant' with 'style' and used ternary logic with AppButtonStyle.tertiary for ghost
              style: _selectedTab == 'whatsapp'
                  ? AppButtonStyle.primary
                  : AppButtonStyle.tertiary,
              onPressed: () => setState(() => _selectedTab = 'whatsapp'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: AppButton(
              text: 'Voice',
              icon: const Icon(LucideIcons.phone),
              // FIX: Replaced 'variant' with 'style' and used ternary logic with AppButtonStyle.tertiary for ghost
              style: _selectedTab == 'voice'
                  ? AppButtonStyle.primary
                  : AppButtonStyle.tertiary,
              onPressed: () => setState(() => _selectedTab = 'voice'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCampaignList(List<Campaign> campaigns) {
    if (campaigns.isEmpty) {
      return const AppCard(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: Text('No campaigns found for this channel.'),
          ),
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: campaigns.length,
      itemBuilder: (context, index) {
        final campaign = campaigns[index];
        return AppCard(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => context.push('/dashboard/campaigns/${campaign.id}'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(campaign.name,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600)),
                    AppBadge(
                      text: campaign.status,
                      color: getStatusColor(campaign.status),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // *** FIX: Use 'description' field from fixed model ***
                Text(campaign.description ?? 'No description',
                    style: const TextStyle(color: AppColors.mutedForeground)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStat(
                        LucideIcons.users, 'Total', campaign.totalContacts),
                    _buildStat(
                        LucideIcons.send, 'Reached', campaign.contactsReached),
                    _buildStat(LucideIcons.check, 'Successful',
                        campaign.successfulDeliveries),
                    _buildStat(
                        LucideIcons.x, 'Failed', campaign.failedDeliveries),
                    // *** FIX: Use 'engagementRate' getter from fixed model ***
                    _buildStat(LucideIcons.activity, 'Engagement',
                        campaign.engagementRate,
                        isPercent: true),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStat(IconData icon, String label, num value,
      {bool isPercent = false}) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.mutedForeground),
        const SizedBox(width: 4),
        Text(
          '$label: ${isPercent ? '${value.toStringAsFixed(1)}%' : value}',
          style:
              const TextStyle(fontSize: 12, color: AppColors.mutedForeground),
        ),
      ],
    );
  }

  void _showCreateCampaignDialog(BuildContext context, WidgetRef ref) {
    showAppDialog(
      context: context,
      title: 'Create New Campaign',
      description: const Text('Set up a new WhatsApp or Voice campaign.'),
      content: CampaignForm(
        onSubmit: () => Navigator.of(context).pop(),
      ),
    );
  }
}

class CampaignForm extends ConsumerStatefulWidget {
  final VoidCallback onSubmit;
  const CampaignForm({required this.onSubmit, super.key});

  @override
  ConsumerState<CampaignForm> createState() => _CampaignFormState();
}

class _CampaignFormState extends ConsumerState<CampaignForm> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _description = '';
  String _channel = 'whatsapp';
  String _status = 'draft';
  String? _templateId;

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final formData = {
      'name': _name,
      'description': _description,
      'channel': _channel,
      'status': _status,
      'template_id': _templateId,
      'ai_agent_id': null, // TODO: Add agent selection
      'customer_list_id': null, // TODO: Add list selection
    };

    try {
      await ref.read(campaignsProvider.notifier).createCampaign(formData);
      widget.onSubmit();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Campaign created successfully')),
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
    // *** FIX: Get templates from the main campaignsProvider state ***
    final templates = ref.watch(campaignsProvider).templates;

    final templateItems = templates
        .map((t) => DropdownMenuItem(value: t.id, child: Text(t.name)))
        .toList();

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment:
            CrossAxisAlignment.start, // Align labels to the left
        children: [
          AppTextField(
            labelText: 'Campaign Name',
            onSaved: (val) => _name = val!,
            validator: (val) => val!.isEmpty ? 'Name is required' : null,
          ),
          const SizedBox(height: 16),
          AppTextField(
            labelText: 'Description',
            maxLines: 3,
            onSaved: (val) => _description = val!,
          ),
          const SizedBox(height: 16),
          // *** FIX: Removed 'labelText' and wrapped in a Column ***
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Channel',
                  style: TextStyle(
                      fontSize: 12, color: AppColors.mutedForeground)),
              const SizedBox(height: 8),
              AppRadioGroup<String>(
                groupValue: _channel,
                onChanged: (val) => setState(() => _channel = val!),
                // *** FIX: Must be a List<AppRadioItem> ***
                items: const [
                  AppRadioItem(value: 'whatsapp', label: Text('WhatsApp')),
                  AppRadioItem(value: 'voice', label: Text('Voice')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          AppDropdown<String>(
            labelText: 'Message Template',
            hint: const Text('Select a template'),
            value: _templateId,
            onChanged: (val) => setState(() => _templateId = val),
            items: templateItems,
            validator: (val) => val == null ? 'Template is required' : null,
          ),
          const SizedBox(height: 16),
          AppDropdown<String>(
            labelText: 'Initial Status',
            value: _status,
            onChanged: (val) => setState(() => _status = val!),
            items: const [
              DropdownMenuItem(value: 'draft', child: Text('Draft')),
              DropdownMenuItem(
                  value: 'running', child: Text('Run Immediately')),
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
                text: 'Create Campaign',
                onPressed: _handleSubmit,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
