import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:humainity_flutter/models/template.dart';
import 'package:humainity_flutter/repositories/templates_repository.dart';
import 'package:humainity_flutter/core/storage/store_user_data.dart'; // Import storage service

// 1. Define the State
class TemplatesState {
  final bool isLoading;
  final String? error;
  final List<Template> inboundTemplates;
  final List<Template> outboundTemplates;

  TemplatesState({
    this.isLoading = false,
    this.error,
    this.inboundTemplates = const [],
    this.outboundTemplates = const [],
  });

  TemplatesState copyWith({
    bool? isLoading,
    String? error,
    List<Template>? inboundTemplates,
    List<Template>? outboundTemplates,
  }) {
    return TemplatesState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      inboundTemplates: inboundTemplates ?? this.inboundTemplates,
      outboundTemplates: outboundTemplates ?? this.outboundTemplates,
    );
  }
}

// 2. Create the Notifier
class TemplatesNotifier extends StateNotifier<TemplatesState> {
  final TemplatesRepository _repository;
  final StoreUserData _storage; // Add storage service

  TemplatesNotifier(this._repository, this._storage) : super(TemplatesState()) {
    loadTemplates(); // Load templates on initialization
  }

  // Helper to get tenantId or set error
  Future<String?> _getTenantId() async {
    final tenantId = await _storage.getTenantId();
    if (tenantId == null) {
      state = state.copyWith(isLoading: false, error: 'User not logged in. Tenant ID missing.');
      return null;
    }
    return tenantId;
  }

  Future<void> loadTemplates() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final tenantId = await _getTenantId();
      if (tenantId == null) return; // Error already set

      final allTemplates = await _repository.getTemplates(tenantId);

      final inbound = allTemplates
          .where((t) => t.type == TemplateType.INBOUND)
          .toList();
      final outbound = allTemplates
          .where((t) => t.type == TemplateType.OUTBOUND)
          .toList();

      state = state.copyWith(
        isLoading: false,
        inboundTemplates: inbound,
        outboundTemplates: outbound,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> addTemplate(Map<String, dynamic> data) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final tenantId = await _getTenantId();
      if (tenantId == null) return false; // Error already set

      await _repository.createTemplate(tenantId, data);
      await loadTemplates(); // Refresh the list
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> editTemplate(int templateId, Map<String, dynamic> data) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      // No tenantId needed for update, but we can keep the loading state
      await _repository.updateTemplate(templateId, data);
      await loadTemplates(); // Refresh the list
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> removeTemplate(int templateId) async {
    try {
      // Optimistic update: remove from UI first
      state = state.copyWith(
        inboundTemplates: state.inboundTemplates.where((t) => t.id != templateId).toList(),
        outboundTemplates: state.outboundTemplates.where((t) => t.id != templateId).toList(),
        error: null,
      );
      // No tenantId needed for delete
      await _repository.deleteTemplate(templateId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      // If delete failed, reload to get the item back
      await loadTemplates();
    }
  }
}

// 3. Define the Provider
final templatesProvider = StateNotifierProvider<TemplatesNotifier, TemplatesState>((ref) {
  final repository = ref.watch(templatesRepositoryProvider);
  final storage = StoreUserData(); // Get storage service
  return TemplatesNotifier(repository, storage);
});