import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:humainity_flutter/repositories/chat_repository.dart';

import '../storage/store_user_data.dart';

// 1. Model for a chat message
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

// 2. Model for the chat state
class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? error;

  ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? error,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// 3. StateNotifier for chat logic
class AgentPreviewChatNotifier extends StateNotifier<ChatState> {
  final ChatRepository _chatRepository;
  final StoreUserData storeUserData;

  AgentPreviewChatNotifier(this._chatRepository, this.storeUserData)
      : super(ChatState());

  Future<void> sendMessage(String text) async {
    // Add user message to state
    final userMessage = ChatMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );
    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
      error: null,
    );

    try {
      // Get agent reply from repository
      final tenantId = await storeUserData.getTenantId();
      final replyText = await _chatRepository.testAgent(tenantId!, text);
      final agentMessage = ChatMessage(
        text: replyText,
        isUser: false,
        timestamp: DateTime.now(),
      );
      state = state.copyWith(
        messages: [...state.messages, agentMessage],
        isLoading: false,
      );
    } catch (e) {
      // Show error as a message
      final errorMessage = ChatMessage(
        text: 'Error: Could not get reply. $e',
        isUser: false,
        timestamp: DateTime.now(),
      );
      state = state.copyWith(
        messages: [...state.messages, errorMessage],
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Clear chat history
  void clearChat() {
    state = ChatState();
  }
}

// 4. Provider
// RENAMED provider for clarity
final agentPreviewChatProvider =
StateNotifierProvider<AgentPreviewChatNotifier, ChatState>((ref) {
  final chatRepository = ref.watch(chatRepositoryProvider);
  final storeUserData = ref.watch(storeUserDataProvider);
  return AgentPreviewChatNotifier(chatRepository, storeUserData!);
});