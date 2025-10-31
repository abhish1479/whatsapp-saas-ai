import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../../theme/business_info_theme.dart';
import '../../helper/ui_helper/custom_widget.dart';
import '../../helper/ui_helper/custom_text_style.dart' show CustomStyle;

class CampaignProgressScreen extends StatefulWidget {
  final String campaignName;
  final String campaignId;

  const CampaignProgressScreen({
    super.key,
    required this.campaignName,
    required this.campaignId,
  });

  @override
  State<CampaignProgressScreen> createState() => _CampaignProgressScreenState();
}

class _CampaignProgressScreenState extends State<CampaignProgressScreen> {
  // ---- Mock funnel metrics (you will replace with API data) ----
  int sent = 1200;
  int delivered = 1105;
  int read = 720;
  int replied = 210;
  int converted = 54;
  double credits = 389.0;

  // ---- Sample recipients (you will replace with paged API) ----
  final List<Map<String, dynamic>> _allRecipients = List.generate(35, (i) {
    final states = ['sent', 'delivered', 'read', 'replied', 'converted', 'failed'];
    final s = states[i % states.length];
    return {
      'lead': i % 3 == 0 ? 'Rohit Sharma' : i % 3 == 1 ? 'Priya Patel' : 'Arjun Mehta',
      'phone': '+91 98${70000000 + i}',
      'sentAt': 'Oct ${25 + (i % 5)}, 10:${i % 60} AM',
      'state': s,
      'lastReply': (s == 'replied' || s == 'converted') ? '“Thanks!”' : '-',
      'credits': (i % 2 == 0) ? 1.0 : 1.5,
      'error': s == 'failed' ? '24h window / rate-limit' : '',
    };
  });

  // ---- Filters / pagination ----
  String _stateFilter = 'all';
  String _search = '';
  int _page = 0;
  final int _pageSize = 10;

  bool _isPaused = false;

  List<Map<String, dynamic>> get _filtered {
    final q = _search.toLowerCase();
    final base = _allRecipients.where((r) {
      final matchesState = _stateFilter == 'all' ? true : r['state'] == _stateFilter;
      final matchesText = r['lead'].toLowerCase().contains(q) || r['phone'].contains(_search);
      return matchesState && matchesText;
    }).toList();
    return base;
  }

  List<Map<String, dynamic>> get _paged {
    final start = _page * _pageSize;
    final end = (start + _pageSize).clamp(0, _filtered.length);
    if (start >= _filtered.length) return [];
    return _filtered.sublist(start, end);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<BusinessInfoTheme>() ?? BusinessInfoTheme.light;
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(widget.campaignName),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          Padding(
            padding: theme.screenPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFunnel(context, isMobile),
                const SizedBox(height: 16),
                _buildToolbar(context),
                const SizedBox(height: 12),
                Expanded(
                  child: _paged.isEmpty
                      ? _buildEmpty()
                      : (isMobile ? _buildMobileList(_paged) : _buildWebTable(_paged)),
                ),
                const SizedBox(height: 12),
                _buildPagination(context),
                const SizedBox(height: 84), // space for sticky buttons
              ],
            ),
          ),
          _buildStickyActions(context, isMobile),
        ],
      ),
    );
  }

  // ---------------- Funnel metrics ----------------
  Widget _buildFunnel(BuildContext context, bool isMobile) {
    final cards = [
      _metricCard('Sent', sent, Icons.send),
      _metricCard('Delivered', delivered, Icons.mark_email_read_outlined),
      _metricCard('Read', read, Icons.visibility_outlined),
      _metricCard('Replied', replied, Icons.reply_outlined),
      _metricCard('Converted', converted, Icons.check_circle_outline),
      _metricCard('Credits', credits, Icons.local_atm_outlined, isCurrency: true),
    ];

    if (isMobile) {
      return Column(
        children: [
          Row(children: cards.sublist(0, 2).map((w) => Expanded(child: w)).toList()),
          const SizedBox(height: 8),
          Row(children: cards.sublist(2, 4).map((w) => Expanded(child: w)).toList()),
          const SizedBox(height: 8),
          Row(children: cards.sublist(4, 6).map((w) => Expanded(child: w)).toList()),
        ],
      );
    }

    return Row(
      children: cards.map((w) => Expanded(child: w)).toList(),
    );
  }

  Widget _metricCard(String label, num value, IconData icon, {bool isCurrency = false}) {
    final theme = Theme.of(context).extension<BusinessInfoTheme>() ?? BusinessInfoTheme.light;
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: theme.borderRadius,
        boxShadow: [theme.cardShadow],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.blue.shade50,
            child: Icon(icon, color: Colors.blue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: CustomStyle.textStyleGrey12),
                const SizedBox(height: 4),
                Text(
                  isCurrency ? value.toStringAsFixed(2) : value.toString(),
                  style: CustomStyle.textStyleBlack18,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- Toolbar (search + filters) ----------------
  Widget _buildToolbar(BuildContext context) {
    final chips = [
      _chip('All', 'all'),
      _chip('Sent', 'sent'),
      _chip('Delivered', 'delivered'),
      _chip('Read', 'read'),
      _chip('Replied', 'replied'),
      _chip('Converted', 'converted'),
      _chip('Failed', 'failed'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // search
        TextField(
          decoration: InputDecoration(
            hintText: "Search lead/phone...",
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: Colors.white,
            hintStyle: CustomStyle.textStyleGrey14_500,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          ),
          onChanged: (v) => setState(() {
            _search = v;
            _page = 0;
          }),
        ),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: chips),
      ],
    );
  }

  Widget _chip(String label, String value) {
    final selected = _stateFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() {
        _stateFilter = value;
        _page = 0;
      }),
    );
  }

  // ---------------- Recipients: Web Table ----------------
  Widget _buildWebTable(List<Map<String, dynamic>> rows) {
    final theme = Theme.of(context).extension<BusinessInfoTheme>() ?? BusinessInfoTheme.light;

    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: theme.borderRadius),
      child: ClipRRect(
        borderRadius: theme.borderRadius,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(Colors.blue.shade50),
          columns: const [
            DataColumn(label: Text("Lead")),
            DataColumn(label: Text("Phone")),
            DataColumn(label: Text("Sent At")),
            DataColumn(label: Text("State")),
            DataColumn(label: Text("Last Reply")),
            DataColumn(label: Text("Credits")),
            DataColumn(label: Text("Actions")),
          ],
          rows: rows.map((r) {
            return DataRow(cells: [
              DataCell(Text(r['lead'])),
              DataCell(Text(r['phone'])),
              DataCell(Text(r['sentAt'])),
              DataCell(_statePill(r['state'])),
              DataCell(Text(r['lastReply'])),
              DataCell(Text(r['credits'].toString())),
              DataCell(Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.forum_outlined),
                    tooltip: "Open conversation",
                    onPressed: () => _openConversation(r),
                  ),
                  if (r['state'] == 'failed' || r['state'] == 'sent' || r['state'] == 'delivered')
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      tooltip: "Retry/Resume",
                      onPressed: () => _retryRecipient(r),
                    ),
                ],
              )),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  // ---------------- Recipients: Mobile Cards ----------------
  Widget _buildMobileList(List<Map<String, dynamic>> rows) {
    final theme = Theme.of(context).extension<BusinessInfoTheme>() ?? BusinessInfoTheme.light;

    return ListView.builder(
      itemCount: rows.length,
      itemBuilder: (ctx, i) {
        final r = rows[i];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          elevation: 3,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(borderRadius: theme.borderRadius),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(child: Text(r['lead'], style: CustomStyle.textStyleBlack16)),
                  _statePill(r['state']),
                ]),
                const SizedBox(height: 6),
                Text(r['phone'], style: CustomStyle.textStyleGrey13),
                Text("Sent: ${r['sentAt']}", style: CustomStyle.textStyleGrey13),
                Text("Last reply: ${r['lastReply']}", style: CustomStyle.textStyleGrey13),
                const Divider(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.forum_outlined),
                      tooltip: "Open conversation",
                      onPressed: () => _openConversation(r),
                    ),
                    if (r['state'] == 'failed' || r['state'] == 'sent' || r['state'] == 'delivered')
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        tooltip: "Retry/Resume",
                        onPressed: () => _retryRecipient(r),
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

  // ---------------- Small helpers ----------------
  Widget _statePill(String state) {
    Color c;
    switch (state) {
      case 'sent':
        c = Colors.blueGrey;
        break;
      case 'delivered':
        c = Colors.blue;
        break;
      case 'read':
        c = Colors.indigo;
        break;
      case 'replied':
        c = Colors.green;
        break;
      case 'converted':
        c = Colors.teal;
        break;
      case 'failed':
        c = Colors.red;
        break;
      default:
        c = Colors.grey;
    }
    return Chip(
      label: Text(state[0].toUpperCase() + state.substring(1)),
      backgroundColor: c.withOpacity(0.12),
      labelStyle: TextStyle(color: c, fontWeight: FontWeight.w600),
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.people_outline, size: 64, color: Colors.grey),
          const SizedBox(height: 12),
          Text("No recipients match the filters", style: CustomStyle.textStyleBlack16),
          const SizedBox(height: 4),
          Text("Try changing state/filter or search.", style: CustomStyle.textStyleGrey14_500),
        ],
      ),
    );
  }

  // ---------------- Pagination (dummy) ----------------
  Widget _buildPagination(BuildContext context) {
    final pageCount = (_filtered.length / _pageSize).ceil();
    if (pageCount <= 1) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text("Page ${_page + 1} of $pageCount", style: CustomStyle.textStyleGrey13),
        const SizedBox(width: 12),
        IconButton(
          onPressed: _page > 0
              ? () => setState(() => _page--)
              : null,
          icon: const Icon(Icons.chevron_left),
        ),
        IconButton(
          onPressed: (_page + 1) < pageCount
              ? () => setState(() => _page++)
              : null,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }

  // ---------------- Sticky bottom actions ----------------
  Widget _buildStickyActions(BuildContext context, bool isMobile) {
    final spacing = SizedBox(width: isMobile ? 0 : 12, height: isMobile ? 12 : 0);

    return Positioned(
      left: 0, right: 0, bottom: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, -2))],
        ),
        child: SafeArea(
          top: false,
          child: isMobile
              ? Column(
                  children: [
                    CustomWidgets.buildCustomButton(
                      onPressed: _exportCSV,
                      text: "Export CSV",
                      icon: Icons.download,
                      backgroundColor: Colors.white,
                      textColor: Colors.blue[700],
                    ),
                    spacing,
                    CustomWidgets.buildCustomButton(
                      onPressed: () => _duplicateCampaign(),
                      text: "Duplicate",
                      icon: Icons.copy_outlined,
                      backgroundColor: Colors.white,
                      textColor: Colors.blue[700],
                    ),
                    spacing,
                    CustomWidgets.buildGradientButton(
                      onPressed: _togglePause,
                      text: _isPaused ? "Resume" : "Pause",
                      icon: _isPaused ? Icons.play_arrow : Icons.pause,
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: CustomWidgets.buildCustomButton(
                        onPressed: _exportCSV,
                        text: "Export CSV",
                        icon: Icons.download,
                        backgroundColor: Colors.white,
                        textColor: Colors.blue[700],
                      ),
                    ),
                    spacing,
                    Expanded(
                      child: CustomWidgets.buildCustomButton(
                        onPressed: () => _duplicateCampaign(),
                        text: "Duplicate",
                        icon: Icons.copy_outlined,
                        backgroundColor: Colors.white,
                        textColor: Colors.blue[700],
                      ),
                    ),
                    spacing,
                    Expanded(
                      child: CustomWidgets.buildGradientButton(
                        onPressed: _togglePause,
                        text: _isPaused ? "Resume" : "Pause",
                        icon: _isPaused ? Icons.play_arrow : Icons.pause,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // ---------------- Actions ----------------
  void _openConversation(Map<String, dynamic> r) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Open conversation with ${r['lead']}')),
    );
    // TODO: navigate to conversation detail when wired to your routes.
  }

  void _retryRecipient(Map<String, dynamic> r) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Queued retry for ${r['phone']}')),
    );
    // TODO: call retry endpoint and refresh row
  }

  void _togglePause() {
    setState(() => _isPaused = !_isPaused);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_isPaused ? 'Campaign paused' : 'Campaign resumed')),
    );
    // TODO: call /campaigns/{id}/pause|resume
  }

  void _duplicateCampaign() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Campaign duplicated')),
    );
    // TODO: call duplicate endpoint
  }

  Future<void> _exportCSV() async {
    final data = [
      ['Lead', 'Phone', 'Sent At', 'State', 'Last Reply', 'Credits'],
      ..._filtered.map((r) => [
            r['lead'],
            r['phone'],
            r['sentAt'],
            r['state'],
            r['lastReply'],
            r['credits'].toString()
          ])
    ];
    final csv = const ListToCsvConverter().convert(data);
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/${widget.campaignId}_recipients.csv');
    await file.writeAsString(csv);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Exported to ${file.path}')),
    );
  }
}
