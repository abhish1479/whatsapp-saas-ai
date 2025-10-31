import 'dart:io';
import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../../theme/business_info_theme.dart';
import '../../helper/ui_helper/custom_widget.dart';
import '../../helper/ui_helper/custom_text_style.dart' show CustomStyle;

class LeadsHubScreen extends StatefulWidget {
  const LeadsHubScreen({super.key});

  @override
  State<LeadsHubScreen> createState() => _LeadsHubScreenState();
}

class _LeadsHubScreenState extends State<LeadsHubScreen> {
  List<Map<String, dynamic>> _leads = [
    {
      'name': 'Rohit Sharma',
      'phone': '+91 9876543210',
      'product': 'AC AMC',
      'pitch': true,
      'workflow': false,
      'status': 'New',
      'lastActivity': '2h ago'
    },
    {
      'name': 'Priya Patel',
      'phone': '+91 9922334455',
      'product': 'Water Purifier',
      'pitch': false,
      'workflow': true,
      'status': 'In Progress',
      'lastActivity': '10m ago'
    },
    {
      'name': 'Arjun Mehta',
      'phone': '+91 9988776655',
      'product': 'Solar Panel',
      'pitch': true,
      'workflow': true,
      'status': 'Converted',
      'lastActivity': '1d ago'
    },
    {
      'name': 'Sneha Gupta',
      'phone': '+91 9090909090',
      'product': 'Home Cleaning',
      'pitch': false,
      'workflow': false,
      'status': 'New',
      'lastActivity': '5h ago'
    },
    {
      'name': 'Vikas Yadav',
      'phone': '+91 8000001234',
      'product': 'AC Repair',
      'pitch': true,
      'workflow': false,
      'status': 'In Progress',
      'lastActivity': '3h ago'
    },
  ];

  String _search = '';

  @override
  Widget build(BuildContext context) {
    final theme =
        Theme.of(context).extension<BusinessInfoTheme>() ?? BusinessInfoTheme.light;
    final isMobile = MediaQuery.of(context).size.width < 700;
    final filteredLeads = _leads
        .where((lead) =>
            lead['name'].toLowerCase().contains(_search.toLowerCase()) ||
            lead['phone'].contains(_search))
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
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: filteredLeads.isEmpty
                        ? _buildEmptyState()
                        : isMobile
                            ? _buildMobileList(filteredLeads)
                            : _buildWebTable(filteredLeads),
                  ),
                ),
                const SizedBox(height: 80), // Space for sticky buttons
              ],
            ),
          ),

          // Sticky Bottom Buttons
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                child: _buildBottomButtons(context, isMobile),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────── Header ───────────────
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: "Search leads...",
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
            onChanged: (val) => setState(() => _search = val),
          ),
        ),
      ],
    );
  }

  // ─────────────── Bottom Buttons (Sticky) ───────────────
  Widget _buildBottomButtons(BuildContext context, bool isMobile) {
    final spacing = SizedBox(width: isMobile ? 0 : 12, height: isMobile ? 12 : 0);

    return isMobile
        ? Column(
            children: [
              CustomWidgets.buildCustomButton(
                onPressed: () => _showImportModal(context),
                text: "Import CSV",
                icon: Icons.upload_file,
                backgroundColor: Colors.white,
                textColor: Colors.blue[700],
              ),
              spacing,
              CustomWidgets.buildCustomButton(
                onPressed: _exportLeads,
                text: "Export Leads",
                icon: Icons.download,
                backgroundColor: Colors.white,
                textColor: Colors.blue[700],
              ),
              spacing,
              CustomWidgets.buildGradientButton(
                onPressed: () => _showAddLeadDrawer(context),
                text: "Add Lead",
                icon: Icons.add,
              ),
            ],
          )
        : Row(
            children: [
              Expanded(
                child: CustomWidgets.buildCustomButton(
                  onPressed: () => _showImportModal(context),
                  text: "Import CSV",
                  icon: Icons.upload_file,
                  backgroundColor: Colors.white,
                  textColor: Colors.blue[700],
                ),
              ),
              spacing,
              Expanded(
                child: CustomWidgets.buildCustomButton(
                  onPressed: _exportLeads,
                  text: "Export Leads",
                  icon: Icons.download,
                  backgroundColor: Colors.white,
                  textColor: Colors.blue[700],
                ),
              ),
              spacing,
              Expanded(
                child: CustomWidgets.buildGradientButton(
                  onPressed: () => _showAddLeadDrawer(context),
                  text: "Add Lead",
                  icon: Icons.add,
                ),
              ),
            ],
          );
  }

  // ─────────────── Lead List (Mobile) ───────────────
  Widget _buildMobileList(List<Map<String, dynamic>> leads) {
    final theme =
        Theme.of(context).extension<BusinessInfoTheme>() ?? BusinessInfoTheme.light;

    return ListView.builder(
      itemCount: leads.length,
      itemBuilder: (context, i) {
        final lead = leads[i];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          elevation: 3,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(borderRadius: theme.borderRadius),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue.shade50,
              child: const Icon(Icons.person, color: Colors.blue),
            ),
            title: Text(lead['name'], style: CustomStyle.textStyleBlack16),
            subtitle: Text("${lead['phone']} • ${lead['product']}",
                style: CustomStyle.textStyleGrey14_500),
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStatusChip(lead['status']),
                Text(lead['lastActivity'], style: CustomStyle.textStyleGrey12),
              ],
            ),
            onTap: () => _showLeadDetail(context, lead),
          ),
        );
      },
    );
  }

  // ─────────────── Lead Table (Web) ───────────────
  Widget _buildWebTable(List<Map<String, dynamic>> leads) {
    final theme =
        Theme.of(context).extension<BusinessInfoTheme>() ?? BusinessInfoTheme.light;

    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: theme.borderRadius),
      child: ClipRRect(
        borderRadius: theme.borderRadius,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(Colors.blue.shade50),
          columns: const [
            DataColumn(label: Text("Name")),
            DataColumn(label: Text("Phone")),
            DataColumn(label: Text("Product/Service")),
            DataColumn(label: Text("Pitch")),
            DataColumn(label: Text("Workflow")),
            DataColumn(label: Text("Status")),
            DataColumn(label: Text("Last Activity")),
            DataColumn(label: Text("Actions")),
          ],
          rows: leads.map((lead) {
            return DataRow(cells: [
              DataCell(Text(lead['name'])),
              DataCell(Text(lead['phone'])),
              DataCell(Text(lead['product'])),
              DataCell(Icon(
                lead['pitch'] ? Icons.check_circle : Icons.cancel,
                color: lead['pitch'] ? Colors.green : Colors.redAccent,
              )),
              DataCell(Icon(
                lead['workflow'] ? Icons.check_circle : Icons.cancel,
                color: lead['workflow'] ? Colors.green : Colors.redAccent,
              )),
              DataCell(_buildStatusChip(lead['status'])),
              DataCell(Text(lead['lastActivity'])),
              DataCell(Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.visibility_outlined),
                    tooltip: "View Lead",
                    onPressed: () => _showLeadDetail(context, lead),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chat_bubble_outline),
                    tooltip: "Start Conversation",
                    onPressed: () =>
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content:
                          Text("Starting conversation with ${lead['name']}"),
                    )),
                  ),
                ],
              )),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  // ─────────────── Helpers ───────────────
  Widget _buildStatusChip(String status) {
    final color = status == 'New'
        ? Colors.green
        : status == 'In Progress'
            ? Colors.orange
            : Colors.blueGrey;
    return Chip(
      label: Text(status),
      backgroundColor: color.withOpacity(0.1),
      labelStyle: TextStyle(color: color.shade700, fontWeight: FontWeight.w600),
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.people_outline, size: 64, color: Colors.grey),
          const SizedBox(height: 12),
          Text("No leads found", style: CustomStyle.textStyleBlack16),
          const SizedBox(height: 4),
          Text(
            "Add a lead manually or import from CSV to get started.",
            style: CustomStyle.textStyleGrey14_500,
          ),
        ],
      ),
    );
  }

  // ─────────────── CSV Import / Add Lead / Export ───────────────
  void _showImportModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _CsvImportModal(),
    );
  }

  void _showAddLeadDrawer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _AddLeadForm(),
    );
  }

  void _showLeadDetail(BuildContext context, Map<String, dynamic> lead) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(lead['name']),
        content: Text(
          "Phone: ${lead['phone']}\nProduct: ${lead['product']}\nStatus: ${lead['status']}",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  Future<void> _exportLeads() async {
    if (_leads.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("No leads to export.")));
      return;
    }

    List<List<dynamic>> csvData = [
      [
        'Name',
        'Phone',
        'Product',
        'Pitch',
        'Workflow',
        'Status',
        'Last Activity'
      ],
      ..._leads.map((lead) => [
            lead['name'],
            lead['phone'],
            lead['product'],
            lead['pitch'] ? 'Yes' : 'No',
            lead['workflow'] ? 'Yes' : 'No',
            lead['status'],
            lead['lastActivity'],
          ]),
    ];

    String csv = const ListToCsvConverter().convert(csvData);
    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/leads_export.csv");
    await file.writeAsString(csv);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Leads exported to ${file.path}"),
      duration: const Duration(seconds: 3),
    ));
  }
}

// ─────────────── CSV Import Modal ───────────────
class _CsvImportModal extends StatefulWidget {
  const _CsvImportModal();

  @override
  State<_CsvImportModal> createState() => _CsvImportModalState();
}

class _CsvImportModalState extends State<_CsvImportModal> {
  File? _csvFile;
  List<List<dynamic>>? _csvData;
  bool _isLoading = false;
  String? _error;

  Future<void> _pickCsvFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null) {
        setState(() => _isLoading = true);
        final file = File(result.files.single.path!);
        final content = await file.readAsString();
        final parsed = const CsvToListConverter().convert(content);

        if (parsed.isEmpty) {
          setState(() => _error = "CSV file is empty.");
        } else {
          setState(() {
            _csvFile = file;
            _csvData = parsed;
          });
        }
      }
    } catch (e) {
      setState(() => _error = "Error reading CSV: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _importLeads() {
    if (_csvData == null || _csvData!.length <= 1) {
      setState(() => _error = "No data found to import.");
      return;
    }
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Leads imported successfully")));
  }

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
          children: [
            Text("Import Leads from CSV",
                style: CustomStyle.textStyleBlack18
                    .copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: theme.borderRadius,
                boxShadow: [theme.cardShadow],
              ),
              child: Column(
                children: [
                  const Icon(Icons.upload_file, size: 50, color: Colors.blue),
                  const SizedBox(height: 12),
                  Text(
                    _csvFile == null
                        ? "Select your CSV file"
                        : _csvFile!.path.split('/').last,
                    style: CustomStyle.textStyleGrey14_600,
                  ),
                  const SizedBox(height: 16),
                  CustomWidgets.buildGradientButton(
                    onPressed: _pickCsvFile,
                    text: _csvFile == null ? "Choose File" : "Change File",
                    icon: Icons.upload_file,
                    isLoading: _isLoading,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            if (_csvData != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: theme.borderRadius,
                  boxShadow: [theme.cardShadow],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Preview", style: CustomStyle.textStyleBlack16),
                    const SizedBox(height: 10),
                    Container(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: ListView.builder(
                        itemCount: _csvData!.length.clamp(0, 6),
                        itemBuilder: (ctx, i) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              children: _csvData![i]
                                  .map((cell) => Expanded(
                                        child: Text(cell.toString(),
                                            overflow: TextOverflow.ellipsis,
                                            style: i == 0
                                                ? CustomStyle.textStyleBlack14
                                                : CustomStyle
                                                    .textStyleGrey14_500),
                                      ))
                                  .toList(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerRight,
                      child: CustomWidgets.buildGradientButton(
                        onPressed: _importLeads,
                        text: "Import Leads",
                        icon: Icons.check_circle_outline,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ─────────────── Add Lead Form ───────────────
class _AddLeadForm extends StatefulWidget {
  const _AddLeadForm();

  @override
  State<_AddLeadForm> createState() => _AddLeadFormState();
}

class _AddLeadFormState extends State<_AddLeadForm> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _tagsCtrl = TextEditingController();
  final _pitchCtrl = TextEditingController();

  String? _selectedProduct;
  String? _selectedWorkflow;

  final List<String> _productOptions = [
    'AC AMC',
    'Water Purifier',
    'Solar Panel',
    'Home Service',
  ];

  final List<String> _workflowOptions = [
    'Default – Services',
    'Follow-up Reminder',
    'Demo Scheduling',
  ];

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
            Text("Add New Lead",
                style: CustomStyle.textStyleBlack18
                    .copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            CustomWidgets.buildTextField2(
              context: context,
              controller: _nameCtrl,
              label: "Name",
              hint: "Enter lead name",
              iconColor: Colors.blue,
            ),
            const SizedBox(height: 12),
            CustomWidgets.buildTextField2(
              context: context,
              controller: _phoneCtrl,
              label: "Phone *",
              hint: "+91...",
              keyboardType: TextInputType.phone,
              iconColor: Colors.blue,
            ),
            const SizedBox(height: 12),
            CustomWidgets.buildTextField2(
              context: context,
              controller: _emailCtrl,
              label: "Email",
              hint: "example@mail.com",
              keyboardType: TextInputType.emailAddress,
              iconColor: Colors.blue,
            ),
            const SizedBox(height: 12),
            CustomWidgets.buildTextField2(
              context: context,
              controller: _tagsCtrl,
              label: "Tags",
              hint: "e.g. hot | trial | dnd",
              iconColor: Colors.blue,
            ),
            const SizedBox(height: 12),
            CustomWidgets.buildDropdown<String>(
              value: _selectedProduct,
              label: "Product / Service",
              icon: Icons.category_outlined,
              items: _productOptions
                  .map((item) =>
                      DropdownMenuItem(value: item, child: Text(item)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedProduct = v),
            ),
            const SizedBox(height: 12),
            CustomWidgets.buildTextField2(
              context: context,
              controller: _pitchCtrl,
              label: "Lead Pitch",
              hint: "Type custom pitch or leave blank to use default...",
              maxLines: 3,
              iconColor: Colors.blue,
            ),
            const SizedBox(height: 12),
            CustomWidgets.buildDropdown<String>(
              value: _selectedWorkflow,
              label: "Conversation Workflow",
              icon: Icons.work_outline,
              items: _workflowOptions
                  .map((item) =>
                      DropdownMenuItem(value: item, child: Text(item)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedWorkflow = v),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: CustomWidgets.buildGradientButton(
                onPressed: () {
                  if (_phoneCtrl.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Phone is required")),
                    );
                    return;
                  }
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Lead added successfully")),
                  );
                },
                text: "Save Lead",
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
