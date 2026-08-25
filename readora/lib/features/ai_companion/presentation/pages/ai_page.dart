import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/ai_chat_bloc.dart';
import '../widgets/ai_chat_bubble.dart';
import '../widgets/tool_chips_row.dart';
import '../widgets/usage_meter.dart';
import '../widgets/book_selection_modal.dart';
import '../../../library/presentation/bloc/library_bloc.dart';
import '../../../library/domain/entities/library_book.dart';

class AiPage extends StatelessWidget {
  const AiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AiChatBloc, AiChatState>(
      builder: (context, state) {
        if (state.activeBookId == null && state.activeTool == null && state.messages.isEmpty) {
          return const _AiHomeView();
        } else {
          return const _AiChatView();
        }
      },
    );
  }
}

class BookSelectorCard extends StatelessWidget {
  const BookSelectorCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AiChatBloc, AiChatState>(
      builder: (context, chatState) {
        return BlocBuilder<LibraryBloc, LibraryState>(
          builder: (context, libraryState) {
            LibraryBook? selectedBook;
            if (chatState.activeBookId != null) {
              try {
                selectedBook = libraryState.books.firstWhere((b) => b.bookId == chatState.activeBookId);
              } catch (_) {}
            }

            return InkWell(
              onTap: () async {
                final selected = await showModalBottomSheet<LibraryBook>(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => const BookSelectionModal(),
                );
                
                if (selected != null && context.mounted) {
                  context.read<AiChatBloc>().add(LoadThread(selected.bookId));
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(4),
                        image: selectedBook?.coverUrl != null
                            ? DecorationImage(
                                image: NetworkImage(selectedBook!.coverUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: selectedBook?.coverUrl == null ? const Icon(Icons.book) : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selectedBook?.title ?? 'Select a book',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            selectedBook != null ? 'Ask anything about what you\'re reading.' : 'Tap to choose a book from your library.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.unfold_more, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _AiHomeView extends StatelessWidget {
  const _AiHomeView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Companion'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: BookSelectorCard(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'How can I help you today?',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          ToolChipsRow(
            onToolSelected: (tool) {
              context.read<AiChatBloc>().add(ToolSelected(tool));
            },
          ),
          const Spacer(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: UsageMeter(
              used: 3,
              total: 300,
              description: '3 of 300 this month',
            ),
          ),
          const _ChatInputArea(),
        ],
      ),
    );
  }
}

class _AiChatView extends StatelessWidget {
  const _AiChatView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<AiChatBloc, AiChatState>(
          builder: (context, state) {
            if (state.activeTool != null) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.auto_awesome, size: 20),
                  const SizedBox(width: 8),
                  Text('${state.activeTool} Mode', style: const TextStyle(fontSize: 16)),
                ],
              );
            }
            return const Text('AI Companion');
          },
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            context.read<AiChatBloc>().add(const LoadThread(null));
          },
        ),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
            child: BookSelectorCard(),
          ),
          Expanded(
            child: BlocConsumer<AiChatBloc, AiChatState>(
              listenWhen: (previous, current) => previous.error != current.error && current.error != null,
              listener: (context, state) {
                if (state.error != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.error!), backgroundColor: Colors.red),
                  );
                }
              },
              builder: (context, state) {
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: state.messages.length,
                  itemBuilder: (context, index) {
                    final message = state.messages[index];
                    if (message.role == AiMessageRole.user) {
                      return UserChatBubble(message: message);
                    } else {
                      return AiChatBubble(message: message);
                    }
                  },
                );
              },
            ),
          ),
          const _ChatInputArea(),
        ],
      ),
    );
  }
}

class _ChatInputArea extends StatefulWidget {
  const _ChatInputArea();

  @override
  State<_ChatInputArea> createState() => _ChatInputAreaState();
}

class _ChatInputAreaState extends State<_ChatInputArea> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      context.read<AiChatBloc>().add(SendMessage(text));
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0).copyWith(
        bottom: 16.0 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Ask anything...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceVariant,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _sendMessage,
            icon: const Icon(Icons.send),
            color: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }
}
