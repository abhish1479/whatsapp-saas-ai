import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:humainity_flutter/core/providers/campaigns_provider.dart'; // Import for repo provider
import 'package:humainity_flutter/models/template.dart';
import 'package:humainity_flutter/repositories/templates_repository.dart'; // Import repository

// 1. State (Unchanged)
class TemplatesState {
  final List<MessageTemplate> templates;
  final bool isLoading;
  final String? error;

  TemplatesState({
    this.templates = const [],
    this.isLoading = false,
    this.error,
  });

  TemplatesState copyWith({
    List<MessageTemplate>? templates,
    bool? isLoading,
    String? error,
  }) {
    return TemplatesState(
      templates: templates ?? this.templates,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// 2. Notifier (Refactored to use Repository)
class TemplatesNotifier extends StateNotifier<TemplatesState> {
  // *** REFACTOR ***
  final Ref _ref;

  TemplatesNotifier(this._ref) : super(TemplatesState()) {
    fetchTemplates();
  }

  Future<void> fetchTemplates() async {
    state = state.copyWith(isLoading: true);
    try {
      // *** REFACTOR ***
      // We can re-use the provider defined in campaigns_provider.dart
      final templates =
      await _ref.read(templatesRepositoryProvider).fetchTemplates();
      state = state.copyWith(templates: templates, isLoading: false, error: null);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<MessageTemplate> fetchTemplateById(String id) async {
    try {
      // *** REFACTOR ***
      final template =
      await _ref.read(templatesRepositoryProvider).fetchTemplateById(id);
      return template;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  // *** FIX: Added saveTemplate method ***
  Future<void> saveTemplate(Map<String, dynamic> formData, String? id) async {
    try {
      await _ref.read(templatesRepositoryProvider).saveTemplate(formData, id);
      // Refresh the list
      await fetchTemplates();
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  // *** FIX: Added deleteTemplate method ***
  Future<void> deleteTemplate(String id) async {
    try {
      await _ref.read(templatesRepositoryProvider).deleteTemplate(id);
      // Refresh the list by removing the item locally (faster)
      state = state.copyWith(
          templates: state.templates.where((t) => t.id != id).toList()
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }
}

// 3. Provider (Unchanged)
final templatesProvider =
StateNotifierProvider<TemplatesNotifier, TemplatesState>((ref) {
  return TemplatesNotifier(ref);
});

// Provider for a single template (Unchanged)
final templateProvider =
FutureProvider.autoDispose.family<MessageTemplate, String>((ref, id) async {
  // *** REFACTOR ***
  // We can't use the Notifier's method directly, so we call the repo
  return ref.watch(templatesRepositoryProvider).fetchTemplateById(id);
});