import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_message_model.dart';
import '../services/ai_chat_service.dart';

final aiChatServiceProvider = Provider<AIChatService>((ref) => AIChatService());

// Chat messages state
class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? error;

  const ChatState({
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
      error: error,
    );
  }
}

class ChatNotifier extends Notifier<ChatState> {
  @override
  ChatState build() {
    // Add welcome message on init
    Future.microtask(() {
      state = state.copyWith(messages: [
        ChatMessage(
          id: 'welcome',
          content: 'Hello! I\'m your AI health assistant powered by MediConnect.\n\n'
              'I can help you with:\n'
              '• Symptom checking\n'
              '• General health advice\n'
              '• Medication information\n'
              '• Finding the right doctor\n\n'
              'How can I help you today?',
          isUser: false,
          timestamp: DateTime.now(),
        ),
      ]);
    });
    return const ChatState();
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: text.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isLoading: true,
      error: null,
    );

    try {
      final service = ref.read(aiChatServiceProvider);
      final response = await service.sendMessage(text.trim());
      state = state.copyWith(
        messages: [...state.messages, response],
        isLoading: false,
      );
    } catch (e) {
      final errorMsg = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: 'Sorry, I encountered an error. Please try again.',
        isUser: false,
        timestamp: DateTime.now(),
      );
      state = state.copyWith(
        messages: [...state.messages, errorMsg],
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clearChat() {
    state = const ChatState();
    // Re-add welcome message
    state = state.copyWith(messages: [
      ChatMessage(
        id: 'welcome_${DateTime.now().millisecondsSinceEpoch}',
        content: 'Chat cleared. How can I help you?',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    ]);
  }
}

final chatProvider = NotifierProvider.autoDispose<ChatNotifier, ChatState>(
  ChatNotifier.new,
);
