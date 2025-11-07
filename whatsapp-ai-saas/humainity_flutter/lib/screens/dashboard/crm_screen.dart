import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:humainity_flutter/core/providers/crm_provider.dart';
import 'package:humainity_flutter/core/theme/app_colors.dart';
import 'package:humainity_flutter/core/utils/responsive.dart'; // FIX: Added import
import 'package:humainity_flutter/core/utils/status_helpers.dart';
import 'package:humainity_flutter/models/customer.dart';
import 'package:humainity_flutter/models/engagement.dart';
import 'package:humainity_flutter/models/payment.dart'; // FIX: Added import
import 'package:humainity_flutter/widgets/ui/app_badge.dart';
import 'package:humainity_flutter/widgets/ui/app_button.dart';
import 'package:humainity_flutter/widgets/ui/app_card.dart';
import 'package:humainity_flutter/widgets/ui/app_dialog.dart';
import 'package:humainity_flutter/widgets/ui/app_dropdown.dart';
import 'package:humainity_flutter/widgets/ui/app_text_field.dart';
import 'package:lucide_icons/lucide_icons.dart';

// FIX: Created a provider to compute status counts
final customerStatusCountsProvider = Provider<Map<String, int>>((ref) {
  final customers = ref.watch(crmProvider).customers;
  final Map<String, int> counts = {
    'all': customers.length,
    'new': 0,
    'contacted': 0,
    'qualified': 0,
    'negotiating': 0,
    'converted': 0,
    'lost': 0,
  };
  for (var customer in customers) {
    if (counts.containsKey(customer.status)) {
      counts[customer.status] = counts[customer.status]! + 1;
    }
  }
  return counts;
});


class CRMScreen extends ConsumerStatefulWidget {
  const CRMScreen({super.key});

  @override
  ConsumerState<CRMScreen> createState() => _CRMScreenState();
}

class _CRMScreenState extends ConsumerState<CRMScreen> {
  String _sourceFilter = "all";
  String _statusFilter = "all";
  String _campaignFilter = "all";
  Customer? _selectedCustomer;
  Customer? _previewCustomer;

  @override
  Widget build(BuildContext context) {
    final crmState = ref.watch(crmProvider);
    final statusCounts = ref.watch(customerStatusCountsProvider); // FIX: Used new provider
    final filteredCustomers = _filterCustomers(crmState.customers);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildStatusCards(statusCounts),
          const SizedBox(height: 16),
          _buildFilterBar(),
          const SizedBox(height: 16),
          _buildCrmContent(crmState, filteredCustomers),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'B2C Customer CRM',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                'Track customers, campaigns, products, services, and payment history',
                style: TextStyle(color: AppColors.mutedForeground),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        AppButton(
          text: "Add Customer",
          icon: const Icon(LucideIcons.plus), // FIX: Wrapped in Icon()
          onPressed: () => _showAddCustomerDialog(),
        ),
      ],
    );
  }

  Widget _buildStatusCards(Map<String, int> counts) {
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile(context) ? 2 : 7, // FIX: isMobile defined
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: isMobile(context) ? 2.5 : 2, // FIX: isMobile defined
      ),
      children: [
        _buildStatusCard('Total', counts['all']!, 'all'),
        _buildStatusCard('New', counts['new']!, 'new'),
        _buildStatusCard('Contacted', counts['contacted']!, 'contacted'),
        _buildStatusCard('Qualified', counts['qualified']!, 'qualified'),
        _buildStatusCard('Negotiating', counts['negotiating']!, 'negotiating'),
        _buildStatusCard('Converted', counts['converted']!, 'converted'),
        _buildStatusCard('Lost', counts['lost']!, 'lost'),
      ],
    );
  }

  Widget _buildStatusCard(String title, int count, String statusKey) {
    final bool isSelected = _statusFilter == statusKey;
    final Color color = getStatusColor(statusKey == 'all' ? null : statusKey);

    return InkWell(
      onTap: () => setState(() => _statusFilter = statusKey),
      child: AppCard(
        padding: const EdgeInsets.all(12),
        borderColor: isSelected ? color : AppColors.border,
        // FIX: Removed borderWidth
        color: isSelected ? color.withOpacity(0.05) : AppColors.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: AppColors.mutedForeground, fontSize: 12)),
            const SizedBox(height: 4),
            Row(
              children: [
                if (statusKey != 'all') ...[
                  Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                ],
                Text('$count', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: AppDropdown<String>(
              labelText: 'Source',
              value: _sourceFilter,
              onChanged: (val) => setState(() => _sourceFilter = val!),
              items: const [
                DropdownMenuItem(value: 'all', child: Text('All Sources')),
                DropdownMenuItem(value: 'inbound', child: Text('Inbound')),
                DropdownMenuItem(value: 'outbound', child: Text('Outbound')),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: AppDropdown<String>(
              labelText: 'Status',
              value: _statusFilter,
              onChanged: (val) => setState(() => _statusFilter = val!),
              items: const [
                DropdownMenuItem(value: 'all', child: Text('All Statuses')),
                DropdownMenuItem(value: 'new', child: Text('New')),
                DropdownMenuItem(value: 'contacted', child: Text('Contacted')),
                DropdownMenuItem(value: 'qualified', child: Text('Qualified')),
                DropdownMenuItem(value: 'negotiating', child: Text('Negotiating')),
                DropdownMenuItem(value: 'converted', child: Text('Converted')),
                DropdownMenuItem(value: 'lost', child: Text('Lost')),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: AppDropdown<String>(
              labelText: 'Campaign Participation',
              value: _campaignFilter,
              onChanged: (val) => setState(() => _campaignFilter = val!),
              items: const [
                DropdownMenuItem(value: 'all', child: Text('All Customers')),
                DropdownMenuItem(value: 'has_campaigns', child: Text('In Campaigns')),
                DropdownMenuItem(value: 'no_campaigns', child: Text('Not in Campaigns')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCrmContent(CrmState crmState, List<Customer> filteredCustomers) {
    if (crmState.isLoading && crmState.customers.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    bool showPreview = _previewCustomer != null && !isMobile(context); // FIX: isMobile defined

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: showPreview ? 320 : MediaQuery.of(context).size.width - 32, // Adjust width
          child: _buildCustomerList(filteredCustomers),
        ),
        if (showPreview) ...[
          const SizedBox(width: 16),
          Expanded(
            child: _buildCustomerPreview(
                _previewCustomer!,
                crmState.previewEngagements[_previewCustomer!.id] ?? [], // FIX: Used previewEngagements
                crmState.previewPayments[_previewCustomer!.id] ?? [] // FIX: Used previewPayments
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCustomerList(List<Customer> filteredCustomers) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Customers (${filteredCustomers.length})', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Container(
          height: 600, // Fixed height for scrollable list
          child: ListView.builder(
            itemCount: filteredCustomers.length,
            itemBuilder: (context, index) {
              final customer = filteredCustomers[index];
              final bool isSelected = _previewCustomer?.id == customer.id;
              return AppCard(
                margin: const EdgeInsets.only(bottom: 8.0),
                padding: const EdgeInsets.all(12.0),
                borderColor: isSelected ? AppColors.primary : AppColors.border,
                // FIX: Removed borderWidth
                color: isSelected ? AppColors.primary.withOpacity(0.05) : AppColors.card,
                child: InkWell(
                  onTap: () {
                    setState(() => _previewCustomer = customer);
                    // FIX: Renamed provider method
                    ref.read(crmProvider.notifier).fetchCustomerPreviewDetails(customer.id);
                  },
                  onDoubleTap: () => context.push('/dashboard/crm/${customer.id}'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(customer.source == 'inbound' ? LucideIcons.arrowDownToLine : LucideIcons.arrowUpFromLine, size: 14, color: customer.source == 'inbound' ? Colors.blue : Colors.purple),
                              const SizedBox(width: 8),
                              Text(customer.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                            ],
                          ),
                          AppBadge(text: customer.status, color: getStatusColor(customer.status)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (customer.company != null && customer.company!.isNotEmpty) ...[
                        Row(
                          children: [
                            const Icon(LucideIcons.building, size: 12, color: AppColors.mutedForeground),
                            const SizedBox(width: 4),
                            Text(customer.company!, style: const TextStyle(color: AppColors.mutedForeground, fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 4),
                      ],
                      Row(
                        children: [
                          const Icon(LucideIcons.phone, size: 12, color: AppColors.mutedForeground),
                          const SizedBox(width: 4),
                          Text(customer.phone, style: const TextStyle(color: AppColors.mutedForeground, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerPreview(Customer customer, List<Engagement> engagements, List<Payment> payments) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(customer.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      AppBadge(text: customer.status, color: getStatusColor(customer.status)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(customer.phone, style: const TextStyle(color: AppColors.mutedForeground)),
                ],
              ),
              IconButton(
                icon: const Icon(LucideIcons.x),
                onPressed: () => setState(() => _previewCustomer = null),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AppButton(
            text: 'View Full Details',
            icon: const Icon(LucideIcons.externalLink), // FIX: Wrapped in Icon()
            variant: AppButtonVariant.outline,
            onPressed: () => context.push('/dashboard/crm/${customer.id}'),
          ),
          const SizedBox(height: 16),
          // Simplified tab view
          Text('Activity (${engagements.length})', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Container(
            height: 300,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: engagements.length,
              itemBuilder: (context, index) {
                final engagement = engagements[index];
                return AppCard(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(getEngagementIcon(engagement.engagementType), size: 14),
                          const SizedBox(width: 8),
                          Text(engagement.engagementType.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(engagement.content, style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddCustomerDialog() {
    showAppDialog(
      context: context,
      title: 'Add New Customer',
      description: const Text('Enter customer information to start tracking'),
      content: AddCustomerForm(
        onSubmit: () => Navigator.of(context).pop(),
      ),
    );
  }

  List<Customer> _filterCustomers(List<Customer> customers) {
    return customers.where((c) {
      if (_sourceFilter != "all" && c.source != _sourceFilter) return false;
      if (_statusFilter != "all" && c.status != _statusFilter) return false;
      if (_campaignFilter != "all") {
        if (_campaignFilter == "has_campaigns" && (c.campaignCount == null || c.campaignCount == 0)) return false;
        if (_campaignFilter == "no_campaigns" && c.campaignCount != null && c.campaignCount! > 0) return false;
      }
      return true;
    }).toList();
  }
}

class AddCustomerForm extends ConsumerStatefulWidget {
  final VoidCallback onSubmit;
  const AddCustomerForm({required this.onSubmit, super.key});

  @override
  ConsumerState<AddCustomerForm> createState() => _AddCustomerFormState();
}

class _AddCustomerFormState extends ConsumerState<AddCustomerForm> {
  final _formKey = GlobalKey<FormState>();
  // FIX: Added controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _companyController = TextEditingController();
  final _notesController = TextEditingController();

  String _source = "inbound";
  String _status = "new";

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _companyController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    // FIX: No longer need _formKey.currentState!.save()

    final formData = {
      'name': _nameController.text,
      'email': _emailController.text.isEmpty ? null : _emailController.text,
      'phone': _phoneController.text,
      'company': _companyController.text.isEmpty ? null : _companyController.text,
      'source': _source,
      'status': _status,
      'notes': _notesController.text.isEmpty ? null : _notesController.text,
      'total_interactions': 0,
    };

    try {
      await ref.read(crmProvider.notifier).addCustomer(formData);
      widget.onSubmit();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Customer added successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.destructive),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppTextField(
            labelText: 'Name',
            controller: _nameController, // FIX: Added controller
            validator: (val) => val!.isEmpty ? 'Name is required' : null,
            // FIX: Removed onSaved
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: AppTextField(labelText: 'Email', controller: _emailController)), // FIX: Added controller
              const SizedBox(width: 16),
              Expanded(child: AppTextField(labelText: 'Phone', controller: _phoneController, validator: (val) => val!.isEmpty ? 'Phone is required' : null)), // FIX: Added controller
            ],
          ),
          const SizedBox(height: 16),
          AppTextField(labelText: 'Company', controller: _companyController), // FIX: Added controller
          const SizedBox(height: 16),
          AppDropdown<String>(
            labelText: 'Source',
            value: _source,
            onChanged: (val) => setState(() => _source = val!),
            items: const [
              DropdownMenuItem(value: 'inbound', child: Text('Inbound')),
              DropdownMenuItem(value: 'outbound', child: Text('Outbound')),
            ],
          ),
          const SizedBox(height: 16),
          AppTextField(labelText: 'Notes', maxLines: 3, controller: _notesController), // FIX: Added controller
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AppButton(
                text: 'Cancel',
                variant: AppButtonVariant.outline,
                onPressed: () => Navigator.of(context).pop(),
              ),
              const SizedBox(width: 8),
              AppButton(
                text: 'Add Customer',
                onPressed: _handleSubmit,
              ),
            ],
          ),
        ],
      ),
    );
  }
}