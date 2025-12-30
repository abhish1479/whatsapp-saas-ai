import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:humainise_ai/core/storage/store_user_data.dart';
import 'package:humainise_ai/models/knowledge_source.dart';
import 'package:humainise_ai/repositories/knowledge_repository.dart';

// 1. State Class
class KnowledgeState {
  final List<KnowledgeSource> fileSources;
  final List<KnowledgeSource> urlSources;
  final String? queryResult;
  final bool isLoading;
  final String? error;

  KnowledgeState({
    this.fileSources = const [],
    this.urlSources = const [],
    this.queryResult,
    this.isLoading = false,
    this.error,
  });

  KnowledgeState copyWith({
    List<KnowledgeSource>? fileSources,
    List<KnowledgeSource>? urlSources,
    String? queryResult,
    bool? isLoading,
    String? error,
  }) {
    return KnowledgeState(
      fileSources: fileSources ?? this.fileSources,
      urlSources: urlSources ?? this.urlSources,
      queryResult: queryResult ?? this.queryResult,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// 2. Notifier Class
class KnowledgeNotifier extends StateNotifier<KnowledgeState> {
  final KnowledgeRepository _repository;
  final StoreUserData storeUserData;

  KnowledgeNotifier(this._repository, this.storeUserData)
      : super(KnowledgeState()) {
    loadKnowledge(); // Load initial data
  }

  Future<void> loadKnowledge() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final tenantId = await storeUserData.getTenantId();
      final sources = await _repository.getKnowledgeSources(tenantId!);

      // Separate sources by type as requested
      final files = sources.where((s) => s.sourceType == "FILE").toList();
      final urls = sources.where((s) => s.sourceType == "URL").toList();

      state = state.copyWith(
        fileSources: files,
        urlSources: urls,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> uploadFile(PlatformFile file) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final tenantId = await storeUserData.getTenantId();
      final newSource = await _repository.uploadFile(tenantId!, file);

      // Add the new file to the state
      state = state.copyWith(
        fileSources: [...state.fileSources, newSource],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addUrl(String url) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final tenantId = await storeUserData.getTenantId();
      final newSource = await _repository.webCrawl(tenantId!, url);

      // Add the new URL to the state
      state = state.copyWith(
        urlSources: [...state.urlSources, newSource],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> testQuery(String query) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final tenantId = await storeUserData.getTenantId();
      final result = await _repository.queryRAG(tenantId!, query);

      state = state.copyWith(
        queryResult: result,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

// 3. Provider Definition
final knowledgeProvider =
    StateNotifierProvider<KnowledgeNotifier, KnowledgeState>((ref) {
  final repository = ref.watch(knowledgeRepositoryProvider);
  final storeUserData = ref.watch(storeUserDataProvider);
  return KnowledgeNotifier(repository, storeUserData!);
});
