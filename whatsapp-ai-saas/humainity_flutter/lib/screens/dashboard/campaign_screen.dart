import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:humainity_flutter/core/providers/campaigns_provider.dart';
import 'package:humainity_flutter/core/providers/templates_provider.dart';
import 'package:humainity_flutter/core/theme/app_colors.dart';
import 'package:humainity_flutter/core/utils/status_helpers.dart';
import 'package:humainity_flutter/models/campaign.dart';
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
  String _selectedTab = 'WHATSAPP';

  @override
  Widget build(BuildContext context) {
    final campaignsAsync = ref.watch(campaignsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, ref),
          const SizedBox(height: 24),
          _buildTabs(context),
          const SizedBox(height: 16),
          campaignsAsync.when(
            data: (campaigns) {
              final filtered = campaigns
                  .where((c) => c.channel.toUpperCase() == _selectedTab)
                  .toList();
              return _buildCampaignList(filtered, ref);
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
          ),
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
              style: _selectedTab == 'WHATSAPP'
                  ? AppButtonStyle.primary
                  : AppButtonStyle.tertiary,
              onPressed: () => setState(() => _selectedTab = 'WHATSAPP'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: AppButton(
              text: 'Voice',
              icon: const Icon(LucideIcons.phone),
              style: _selectedTab == 'VOICE'
                  ? AppButtonStyle.primary
                  : AppButtonStyle.tertiary,
              onPressed: () => setState(() => _selectedTab = 'VOICE'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCampaignList(List<Campaign> campaigns, WidgetRef ref) {
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
                    Expanded(
                      child: Text(campaign.name,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600)),
                    ),
                    Row(
                      children: [
                        if (campaign.status == 'Running')
                          IconButton(
                            icon: const Icon(LucideIcons.pauseCircle,
                                color: Colors.orange),
                            onPressed: () => ref
                                .read(campaignsProvider.notifier)
                                .updateStatus(campaign.id, 'pause'),
                          )
                        else if (campaign.status != 'Completed')
                          IconButton(
                            icon: const Icon(LucideIcons.playCircle,
                                color: Colors.green),
                            onPressed: () => ref
                                .read(campaignsProvider.notifier)
                                .updateStatus(campaign.id, 'start'),
                          ),
                        const SizedBox(width: 8),
                        AppBadge(
                          text: campaign.status,
                          color: getStatusColor(campaign.status),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(campaign.description ?? 'No description',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.mutedForeground)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStat(LucideIcons.users, 'Total', campaign.totalLeads),
                    _buildStat(LucideIcons.send, 'Sent', campaign.sent),
                    _buildStat(LucideIcons.check, 'Success', campaign.success),
                    _buildStat(LucideIcons.x, 'Failed', campaign.failed),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStat(IconData icon, String label, num value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.mutedForeground),
        const SizedBox(width: 4),
        Text(
          '$label: $value',
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
        onSubmit: () {},
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
  String _channel = 'WHATSAPP';
  String? _templateId;
  bool _runImmediate = false;
  PlatformFile? _selectedFile;
  bool _isUploading = false;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null) {
      setState(() {
        _selectedFile = result.files.first;
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload a CSV file')),
      );
      return;
    }
    _formKey.currentState!.save();

    setState(() => _isUploading = true);

    try {
      await ref.read(campaignsProvider.notifier).createCampaign(
        name: _name,
        description: _description,
        channel: _channel,
        templateId: _templateId != null ? int.parse(_templateId!) : null,
        runImmediate: _runImmediate,
        file: _selectedFile!,
      );
      widget.onSubmit();
      if (!mounted) return;

      // 6. Close the Dialog explicitly using CURRENT context
      // This ensures we close the dialog, not the screen behind it
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Campaign created successfully')),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error: $e'), backgroundColor: AppColors.destructive),
      );
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final templatesState = ref.watch(templatesProvider);
    final templates = templatesState.outboundTemplates;

    final templateItems = templates
        .map((t) => DropdownMenuItem(
        value: t.id.toString(), child: Text(t.name)))
        .toList();

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTextField(
            labelText: 'Campaign Name',
            onSaved: (val) => _name = val!,
            validator: (val) => val!.isEmpty ? 'Name is required' : null,
          ),
          const SizedBox(height: 16),
          // FIX: Fixed height of 4 lines to prevent dialog resizing
          AppTextField(
            labelText: 'Description (Default Pitch)',
            keyboardType: TextInputType.multiline,
            maxLines: 4,
            onSaved: (val) => _description = val!,
          ),
          const SizedBox(height: 16),
          const Text('Channel',
              style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
          const SizedBox(height: 8),
          AppRadioGroup<String>(
            groupValue: _channel,
            onChanged: (val) => setState(() => _channel = val!),
            items: const [
              AppRadioItem(value: 'WHATSAPP', label: Text('WhatsApp')),
              AppRadioItem(value: 'VOICE', label: Text('Voice')),
            ],
          ),
          const SizedBox(height: 16),
          AppDropdown<String>(
            labelText: 'Message Template',
            hint: const Text('Select a template'),
            value: _templateId,
            onChanged: (val) => setState(() => _templateId = val),
            items: templateItems,
          ),
          const SizedBox(height: 16),
          const Text('Recipients (CSV)',
              style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
          const SizedBox(height: 8),
          InkWell(
            onTap: _pickFile,
            child: DottedBorder(
              color: AppColors.mutedForeground.withOpacity(0.5),
              strokeWidth: 1,
              dashPattern: const [6, 3],
              borderType: BorderType.RRect,
              radius: const Radius.circular(8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    Icon(LucideIcons.uploadCloud,
                        size: 32, color: AppColors.primary),
                    const SizedBox(height: 8),
                    Text(
                      _selectedFile != null
                          ? _selectedFile!.name
                          : 'Click to upload CSV',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    if (_selectedFile == null)
                      const Text(
                        'Columns: name, phone, email, pitch',
                        style: TextStyle(
                            fontSize: 10, color: AppColors.mutedForeground),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Run Immediately?',
                  style: TextStyle(fontWeight: FontWeight.w500)),
              Switch(
                value: _runImmediate,
                onChanged: (val) => setState(() => _runImmediate = val),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AppButton(
                text: 'Cancel',
                style: AppButtonStyle.tertiary,
                onPressed: () => Navigator.of(context).pop(),
              ),
              const SizedBox(width: 8),
              if (_isUploading)
                const CircularProgressIndicator()
              else
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