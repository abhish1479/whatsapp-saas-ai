import 'package:flutter/material.dart';
import '../../theme/business_info_theme.dart';
import '../../helper/ui_helper/custom_widget.dart';
import '../../helper/ui_helper/custom_text_style.dart' show CustomStyle;
import 'campaign_progress_screen.dart';

class CampaignListScreen extends StatefulWidget {
  const CampaignListScreen({super.key});

  @override
  State<CampaignListScreen> createState() => _CampaignListScreenState();
}

class _CampaignListScreenState extends State<CampaignListScreen> {
  final List<Map<String, dynamic>> _campaigns = [
    {
      'name': 'Trial Follow-up',
      'status': 'Scheduled',
      'schedule': '31 Oct, 10:00 AM',
      'audience': 'Tag: trial',
      'template': 'Winback Offer',
      'created': '29 Oct',
    },
    {
      'name': 'AC AMC Renewal',
      'status': 'In Progress',
      'schedule': 'Started today',
      'audience': 'All Leads',
      'template': 'AMC Renewal Reminder',
      'created': '28 Oct',
    },
    {
      'name': 'Festive Offer Blast',
      'status': 'Paused',
      'schedule': 'Scheduled 2 Nov',
      'audience': 'Tag: active',
      'template': 'Festival Discount',
      'created': '26 Oct',
    },
  ];

  String _search = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<BusinessInfoTheme>() ??
        BusinessInfoTheme.light;
    final isMobile = MediaQuery.of(context).size.width < 700;

    final filtered = _campaigns
        .where((c) => c['name'].toLowerCase().contains(_search.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Stack(
        children: [
          Padding(
            padding: theme.screenPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 16),
                Expanded(
                  child: filtered.isEmpty
                      ? _buildEmptyState()
                      : isMobile
                          ? _buildMobileList(filtered)
                          : _buildWebTable(filtered),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
          _buildStickyBottomButtons(context, isMobile),
        ],
      ),
    );
  }

  // ───────────── Header ─────────────
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: "Search campaigns...",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              hintStyle: CustomStyle.textStyleGrey14_500,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            ),
            onChanged: (v) => setState(() => _search = v),
          ),
        ),
      ],
    );
  }

  // ───────────── Campaigns Table (Web) ─────────────
  Widget _buildWebTable(List<Map<String, dynamic>> campaigns) {
    final theme = Theme.of(context).extension<BusinessInfoTheme>() ??
        BusinessInfoTheme.light;

    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: theme.borderRadius),
      child: ClipRRect(
        borderRadius: theme.borderRadius,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(Colors.blue.shade50),
          columns: const [
            DataColumn(label: Text("Campaign Name")),
            DataColumn(label: Text("Status")),
            DataColumn(label: Text("Schedule")),
            DataColumn(label: Text("Audience")),
            DataColumn(label: Text("Template")),
            DataColumn(label: Text("Created")),
            DataColumn(label: Text("Actions")),
          ],
          rows: campaigns.map((c) {
            return DataRow(cells: [
              DataCell(Text(c['name'])),
              DataCell(_buildStatusChip(c['status'])),
              DataCell(Text(c['schedule'])),
              DataCell(Text(c['audience'])),
              DataCell(Text(c['template'])),
              DataCell(Text(c['created'])),
              DataCell(Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.visibility_outlined),
                    tooltip: "View Campaign",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CampaignProgressScreen(
                            campaignName: c['name'],
                            campaignId: c['name']
                                .toLowerCase()
                                .replaceAll(' ', '_'), // dummy id
                          ),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.pause_circle_outline),
                    tooltip: "Pause Campaign",
                    onPressed: () => _showSnack("Campaign paused"),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy_outlined),
                    tooltip: "Duplicate Campaign",
                    onPressed: () => _showSnack("Campaign duplicated"),
                  ),
                ],
              )),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  // ───────────── Campaign Cards (Mobile) ─────────────
  Widget _buildMobileList(List<Map<String, dynamic>> campaigns) {
    final theme = Theme.of(context).extension<BusinessInfoTheme>() ??
        BusinessInfoTheme.light;

    return ListView.builder(
      itemCount: campaigns.length,
      itemBuilder: (ctx, i) {
        final c = campaigns[i];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          elevation: 3,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(borderRadius: theme.borderRadius),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child:
                          Text(c['name'], style: CustomStyle.textStyleBlack16),
                    ),
                    _buildStatusChip(c['status']),
                  ],
                ),
                const SizedBox(height: 6),
                Text("Schedule: ${c['schedule']}",
                    style: CustomStyle.textStyleGrey13),
                Text("Audience: ${c['audience']}",
                    style: CustomStyle.textStyleGrey13),
                Text("Template: ${c['template']}",
                    style: CustomStyle.textStyleGrey13),
                const Divider(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.visibility_outlined),
                      tooltip: "View",
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CampaignProgressScreen(
                              campaignName: c['name'],
                              campaignId: c['name']
                                  .toLowerCase()
                                  .replaceAll(' ', '_'), // dummy id
                            ),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.pause_circle_outline),
                      tooltip: "Pause",
                      onPressed: () => _showSnack("Campaign paused"),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy_outlined),
                      tooltip: "Duplicate",
                      onPressed: () => _showSnack("Campaign duplicated"),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  // ───────────── Bottom Buttons (Sticky) ─────────────
  Widget _buildStickyBottomButtons(BuildContext context, bool isMobile) {
    final spacing =
        SizedBox(width: isMobile ? 0 : 12, height: isMobile ? 12 : 0);

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: isMobile
              ? Column(
                  children: [
                    CustomWidgets.buildCustomButton(
                      onPressed: _exportCampaigns,
                      text: "Export Campaigns",
                      icon: Icons.download,
                      backgroundColor: Colors.white,
                      textColor: Colors.blue[700],
                    ),
                    spacing,
                    CustomWidgets.buildGradientButton(
                      onPressed: () => _showCreateCampaignDrawer(context),
                      text: "Create Campaign",
                      icon: Icons.add,
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: CustomWidgets.buildCustomButton(
                        onPressed: _exportCampaigns,
                        text: "Export Campaigns",
                        icon: Icons.download,
                        backgroundColor: Colors.white,
                        textColor: Colors.blue[700],
                      ),
                    ),
                    spacing,
                    Expanded(
                      child: CustomWidgets.buildGradientButton(
                        onPressed: () => _showCreateCampaignDrawer(context),
                        text: "Create Campaign",
                        icon: Icons.add,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // ───────────── Utility Widgets ─────────────
  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'In Progress':
        color = Colors.blue;
        break;
      case 'Scheduled':
        color = Colors.orange;
        break;
      case 'Paused':
        color = Colors.grey;
        break;
      default:
        color = Colors.green;
    }
    return Chip(
      label: Text(status),
      backgroundColor: color.withOpacity(0.1),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.w600),
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.campaign_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 12),
          Text("No campaigns found", style: CustomStyle.textStyleBlack16),
          const SizedBox(height: 4),
          Text(
            "Create your first campaign to start engaging leads.",
            style: CustomStyle.textStyleGrey14_500,
          ),
        ],
      ),
    );
  }

  // ───────────── Actions ─────────────
  void _showCampaignDetail(Map<String, dynamic> campaign) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(campaign['name']),
        content: Text(
          "Status: ${campaign['status']}\nSchedule: ${campaign['schedule']}\nAudience: ${campaign['audience']}\nTemplate: ${campaign['template']}",
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("Close"))
        ],
      ),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _exportCampaigns() {
    _showSnack("Campaigns exported successfully");
  }

  void _showCreateCampaignDrawer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _CreateCampaignForm(),
    );
  }
}

// ───────────── Create Campaign Drawer ─────────────
class _CreateCampaignForm extends StatefulWidget {
  const _CreateCampaignForm();

  @override
  State<_CreateCampaignForm> createState() => _CreateCampaignFormState();
}

class _CreateCampaignFormState extends State<_CreateCampaignForm> {
  final _nameCtrl = TextEditingController();
  String? _selectedAudience;
  String? _selectedTemplate;
  String? _scheduleType = 'Now';

  final _audiences = [
    'All Leads',
    'Tag: trial',
    'Tag: active',
    'Segment: warm leads'
  ];
  final _templates = ['Welcome Offer', 'AMC Renewal Reminder', 'Winback Offer'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<BusinessInfoTheme>() ??
        BusinessInfoTheme.light;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 24,
        left: 16,
        right: 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Create Campaign",
                style: CustomStyle.textStyleBlack18
                    .copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            CustomWidgets.buildTextField2(
              context: context,
              controller: _nameCtrl,
              label: "Campaign Name",
              hint: "Enter campaign name",
              iconColor: Colors.blue,
            ),
            const SizedBox(height: 12),
            CustomWidgets.buildDropdown<String>(
              value: _selectedAudience,
              label: "Audience",
              icon: Icons.people_alt_outlined,
              items: _audiences
                  .map((a) => DropdownMenuItem(value: a, child: Text(a)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedAudience = v),
            ),
            const SizedBox(height: 12),
            CustomWidgets.buildDropdown<String>(
              value: _selectedTemplate,
              label: "Message Template",
              icon: Icons.message_outlined,
              items: _templates
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedTemplate = v),
            ),
            const SizedBox(height: 12),
            Text("Schedule",
                style: CustomStyle.textStyleBlack16
                    .copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 10,
              children: ['Now', 'Later', 'Auto']
                  .map((opt) => ChoiceChip(
                        label: Text(opt),
                        selected: _scheduleType == opt,
                        onSelected: (_) => setState(() => _scheduleType = opt),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerRight,
              child: CustomWidgets.buildGradientButton(
                onPressed: () {
                  if (_nameCtrl.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Campaign name required")));
                    return;
                  }
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Campaign created successfully")));
                },
                text: "Create Campaign",
                icon: Icons.check_circle_outline,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
