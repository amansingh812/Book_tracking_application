import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/ai_chat_repository.dart';

part 'ai_chat_event.dart';
part 'ai_chat_state.dart';

/// Prompt templates for each AI tool.
/// Kept short and directive so they work well with small models (2–3B params).
const _toolPrompts = {
  'Explain': 'Give me a clear, concise explanation of the key concepts in this book or topic. '
      'Use plain language and short paragraphs.',
  'Quiz': 'Create a 5-question multiple-choice quiz to test understanding. '
      'Format each question as:\n'
      'Q: [question]\n'
      'A) ... B) ... C) ... D) ...\n'
      'Answer: [letter]\n\n'
      'Keep questions focused and educational.',
  'Flashcards': 'Generate 5 study flashcards. Format each exactly as:\n'
      '**Q:** [question]\n'
      '**A:** [answer]\n\n'
      'Make them concise and memorable.',
  'Key ideas': 'List the 5 most important key ideas or takeaways in a numbered list. '
      'For each, give a one-sentence explanation. Be direct and insightful.',
};

class AiChatBloc extends Bloc<AiChatEvent, AiChatState> {
  final AiChatRepository _repository;

  AiChatBloc(this._repository) : super(const AiChatState()) {
    on<LoadThread>(_onLoadThread);
    on<SendMessage>(_onSendMessage);
    on<ToolSelected>(_onToolSelected);
  }

  void _onLoadThread(LoadThread event, Emitter<AiChatState> emit) {
    emit(state.copyWith(
      activeBookId: event.bookId,
      messages: [],
      clearActiveTool: event.bookId == null,
    ));
  }

  void _onToolSelected(ToolSelected event, Emitter<AiChatState> emit) {
    final prompt = _toolPrompts[event.toolName] ??
        'Help me with this book. Tool: ${event.toolName}';

    // Store the active tool name in state so the UI can show the mode pill.
    emit(state.copyWith(
      activeTool: event.toolName,
      messages: [], // fresh conversation per tool
    ));

    add(SendMessage(prompt));
  }

  Future<void> _onSendMessage(SendMessage event, Emitter<AiChatState> emit) async {
    final userMessage = ChatMessage(role: AiMessageRole.user, content: event.message);

    final updatedMessages = List<ChatMessage>.from(state.messages)..add(userMessage);

    // Add empty AI message for streaming
    updatedMessages.add(const ChatMessage(role: AiMessageRole.ai, content: '', isStreaming: true));

    emit(state.copyWith(messages: updatedMessages, isLoading: true, error: null));

    try {
      final previousMessages = state.messages // Use state.messages (which doesn't have the new message yet)
          .where((m) => !m.isStreaming) 
          .map((m) => {
                'role': m.role == AiMessageRole.ai ? 'assistant' : 'user',
                'content': m.content,
              })
          .toList();

      final stream = _repository.sendMessage(
        message: event.message,
        bookId: state.activeBookId,
        previousMessages: previousMessages,
      );

      String accumulatedContent = '';
      await emit.forEach<String>(
        stream,
        onData: (chunk) {
          accumulatedContent += chunk;

          final messages = List<ChatMessage>.from(state.messages);
          // Update the last message (the streaming AI placeholder)
          messages[messages.length - 1] = ChatMessage(
            role: AiMessageRole.ai,
            content: accumulatedContent,
            isStreaming: true,
          );
          return state.copyWith(messages: messages);
        },
        onError: (error, _) {
          return state.copyWith(
            error: error.toString(),
            isLoading: false,
            messages: List<ChatMessage>.from(state.messages)
              ..removeLast(), // remove empty streaming bubble
          );
        },
      );

      // Streaming finished — mark final message as done
      final finalMessages = List<ChatMessage>.from(state.messages);
      if (finalMessages.isNotEmpty) {
        finalMessages[finalMessages.length - 1] = ChatMessage(
          role: AiMessageRole.ai,
          content: accumulatedContent,
          isStreaming: false,
        );
      }

      emit(state.copyWith(messages: finalMessages, isLoading: false));
    } catch (e) {
      // Remove the empty streaming bubble on error
      final cleanMessages = List<ChatMessage>.from(state.messages);
      if (cleanMessages.isNotEmpty && cleanMessages.last.isStreaming) {
        cleanMessages.removeLast();
      }
      emit(state.copyWith(
        error: 'Something went wrong. Please try again.',
        isLoading: false,
        messages: cleanMessages,
      ));
    }
  }
}

