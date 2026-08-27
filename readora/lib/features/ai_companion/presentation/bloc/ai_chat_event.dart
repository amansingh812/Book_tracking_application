part of 'ai_chat_bloc.dart';

sealed class AiChatEvent {
  const AiChatEvent();
}

class SendMessage extends AiChatEvent {
  final String message;

  const SendMessage(this.message);
}

class LoadThread extends AiChatEvent {
  final String? bookId;

  const LoadThread(this.bookId);
}

class ToolSelected extends AiChatEvent {
  final String toolName; // e.g. "Explain", "Quiz"

  const ToolSelected(this.toolName);
}
