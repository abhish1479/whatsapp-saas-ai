// lib/screens/dashboard/customer_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:humainity_flutter/core/providers/customer_detail_provider.dart';
import 'package:humainity_flutter/core/theme/app_colors.dart';
import 'package:humainity_flutter/models/customer.dart';
import 'package:humainity_flutter/widgets/ui/app_button.dart';
import 'package:humainity_flutter/widgets/ui/app_card.dart';
import 'package:humainity_flutter/widgets/ui/app_text_field.dart';
import 'package:lucide_icons/lucide_icons.dart';

class CustomerDetailScreen extends ConsumerStatefulWidget {
  final String customerId;
  const CustomerDetailScreen({Key? key, required this.customerId})
      : super(key: key);

  @override
  _CustomerDetailScreenState createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends ConsumerState<CustomerDetailScreen> {
  bool _isEditing = false;
  late Customer _editedCustomer;
  bool _isInitialized = false;

  @override
  Widget build(BuildContext context) {
    final customerState = ref.watch(customerDetailProvider(widget.customerId));

    // FIX: You cannot use .when() on a custom state object.
    // You must check properties like .isLoading and .error manually.
    if (customerState.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (customerState.error != null) {
      return Scaffold(
          body: Center(child: Text('Error: ${customerState.error}')));
    }

    if (customerState.customer == null) {
      return const Scaffold(body: Center(child: Text('Customer not found.')));
    }

    // Initialize the edited customer once
    if (!_isInitialized) {
      _editedCustomer = customerState.customer!;
      _isInitialized = true;
    }

    final customer = customerState.customer!;

    return Scaffold(
      appBar: AppBar(
        title: Text(customer.name),
        actions: _buildAppBarActions(context, customer),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCustomerInfo(context, customer),
            const SizedBox(height: 24),
            // Other widgets like engagements, payments, etc. would go here
          ],
        ),
      ),
    );
  }

  List<Widget> _buildAppBarActions(BuildContext context, Customer customer) {
    if (_isEditing) {
      return [
        AppButton(
          text: 'Cancel',
          // FIX: Replaced variant: AppButtonVariant.ghost with style: AppButtonStyle.tertiary
          style: AppButtonStyle.tertiary,
          onPressed: () => setState(() {
            _isEditing = false;
            _editedCustomer = customer; // Reset changes
          }),
          icon: const Icon(LucideIcons.x), // FIX: Wrapped in Icon
        ),
        const SizedBox(width: 8),
        AppButton(
          text: 'Save',
          onPressed: () {
            // TODO: Implement save logic with _editedCustomer
            // Example: ref.read(customerDetailProvider(widget.customerId).notifier).updateCustomer(...);
            setState(() => _isEditing = false);
          },
          icon: const Icon(LucideIcons.save), // FIX: Wrapped in Icon
        ),
        const SizedBox(width: 16),
      ];
    }
    return [
      AppButton(
        text: 'Edit Customer',
        onPressed: () => setState(() => _isEditing = true),
        icon: const Icon(LucideIcons.edit), // FIX: Wrapped in Icon
      ),
      const SizedBox(width: 16),
    ];
  }

  Widget _buildCustomerInfo(BuildContext context, Customer customer) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // FIX: .headline6 is obsolete. Use .titleLarge instead
          Text('Customer Details',
              style: Theme.of(context).textTheme.titleLarge),
          const Divider(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildInfoField(
                  'Phone',
                  customer.phone,
                  LucideIcons.phone,
                  isEditing: _isEditing,
                  initialValue: _editedCustomer.phone,
                  onChanged: (val) =>
                      _editedCustomer = _editedCustomer.copyWith(phone: val),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoField(
                  'Email',
                  customer.email ?? 'N/A',
                  LucideIcons.mail,
                  isEditing: _isEditing,
                  initialValue: _editedCustomer.email,
                  onChanged: (val) =>
                      _editedCustomer = _editedCustomer.copyWith(email: val),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInfoField(
                  'Company',
                  customer.company ?? 'N/A',
                  LucideIcons.building2,
                  isEditing: _isEditing,
                  initialValue: _editedCustomer.company,
                  onChanged: (val) =>
                      _editedCustomer = _editedCustomer.copyWith(company: val),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoField(
                  'Assigned To',
                  customer.assignedTo ?? 'Unassigned',
                  LucideIcons.users,
                  isEditing: _isEditing,
                  initialValue: _editedCustomer.assignedTo,
                  onChanged: (val) => _editedCustomer =
                      _editedCustomer.copyWith(assignedTo: val),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoField(
            'Notes',
            customer.notes ?? 'No notes',
            LucideIcons.fileText,
            maxLines: 3,
            isEditing: _isEditing,
            initialValue: _editedCustomer.notes,
            onChanged: (val) =>
                _editedCustomer = _editedCustomer.copyWith(notes: val),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoField(
    String label,
    String displayValue,
    IconData icon, {
    bool isEditing = false,
    int maxLines = 1,
    String? initialValue,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // FIX: AppColors.textSecondary does not exist. Use mutedForeground
            Icon(icon, size: 16, color: AppColors.mutedForeground),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 8),
        if (isEditing)
          AppTextField(
            labelText: label, // FIX: labelText is required
            initialValue: initialValue ?? displayValue,
            onChanged: onChanged,
            maxLines: maxLines,
          )
        else
          Text(displayValue),
      ],
    );
  }
}
