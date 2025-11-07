import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:humainity_flutter/core/providers/supabase_provider.dart';
// FIX: Removed unused Supabase import
// import 'package:supabase_flutter/supabase_flutter.dart';

class ChatMessage {
  final String role;
  final String content;
  final DateTime timestamp;

  ChatMessage({required this.role, required this.content, required this.timestamp});
}

class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? error;

  ChatState({
    required this.messages,
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

class ChatNotifier extends StateNotifier<ChatState> {
  final Ref _ref;

  ChatNotifier(this._ref)
      : super(ChatState(messages: [
    ChatMessage(
      role: 'assistant',
      content: "Hi! Let's train together. Ask me questions or give me scenarios to practice.",
      timestamp: DateTime.now(),
    )
  ]));

  Future<void> sendMessage(String text) async {
    final userMessage = ChatMessage(role: 'user', content: text, timestamp: DateTime.now());

    // Add user message to state immediately
    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
      error: null,
    );

    try {
      // Prepare message history for the API
      final apiMessages = state.messages.map((msg) => {
        'role': msg.role,
        'content': msg.content
      }).toList();

      // Call the Supabase Edge Function
      final response = await _ref.read(supabaseClientProvider).functions.invoke(
        'chat',
        body: {'messages': apiMessages},
      );

      // FIX: Correct error handling for FunctionResponse
      if (response.data == null || response.data['error'] != null) {
        throw Exception(response.data?['error'] ?? 'Unknown function error');
      }

      final assistantMessage = ChatMessage(
        role: 'assistant',
        content: response.data['response'] ?? "Sorry, I couldn't process that.",
        timestamp: DateTime.now(),
      );

      // Add assistant response to state
      state = state.copyWith(
        messages: [...state.messages, assistantMessage],
        isLoading: false,
      );
    } catch (e) {
      final errorMessage = ChatMessage(
        role: 'assistant',
        content: "Error: ${e.toString()}",
        timestamp: DateTime.now(),
      );
      state = state.copyWith(
        messages: [...state.messages, errorMessage],
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clearChat() {
    state = state.copyWith(
      messages: [
        ChatMessage(
          role: 'assistant',
          content: "Hi! Let's train together. Ask me questions or give me scenarios to practice.",
          timestamp: DateTime.now(),
        )
      ],
      isLoading: false,
      error: null,
    );
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier(ref);
});