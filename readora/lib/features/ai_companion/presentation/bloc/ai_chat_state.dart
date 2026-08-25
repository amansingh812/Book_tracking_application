part of 'ai_chat_bloc.dart';

enum AiMessageRole { user, ai }

class ChatMessage {
  final AiMessageRole role;
  final String content;
  final bool isStreaming;

  const ChatMessage({
    required this.role,
    required this.content,
    this.isStreaming = false,
  });

  ChatMessage copyWith({
    AiMessageRole? role,
    String? content,
    bool? isStreaming,
  }) {
    return ChatMessage(
      role: role ?? this.role,
      content: content ?? this.content,
      isStreaming: isStreaming ?? this.isStreaming,
    );
  }
}

class AiChatState {
  final String? activeBookId;
  final String? activeTool; // e.g. 'Explain', 'Quiz', 'Flashcards', 'Key ideas'
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? error;

  const AiChatState({
    this.activeBookId,
    this.activeTool,
    this.messages = const [],
    this.isLoading = false,
    this.error,
  });

  AiChatState copyWith({
    String? activeBookId,
    String? activeTool,
    List<ChatMessage>? messages,
    bool? isLoading,
    String? error,
    bool clearActiveTool = false,
  }) {
    return AiChatState(
      activeBookId: activeBookId ?? this.activeBookId,
      activeTool: clearActiveTool ? null : (activeTool ?? this.activeTool),
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
