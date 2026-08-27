import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../library/domain/entities/library_book.dart';
import '../../../library/presentation/bloc/library_bloc.dart';

class BookSelectionModal extends StatelessWidget {
  const BookSelectionModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      // Set a fixed max height so it behaves like a bottom sheet
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: Text(
              'Select a book',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const Divider(),
          Expanded(
            child: BlocBuilder<LibraryBloc, LibraryState>(
              builder: (context, state) {
                if (state.view == LibraryStatusView.loading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.books.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Center(
                      child: Text('Your library is empty. Add some books first!'),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: state.books.length,
                  itemBuilder: (context, index) {
                    final book = state.books[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                      leading: Container(
                        width: 48,
                        height: 72,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(4),
                          image: book.coverUrl != null
                              ? DecorationImage(
                                  image: NetworkImage(book.coverUrl!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: book.coverUrl == null ? const Icon(Icons.book) : null,
                      ),
                      title: Text(
                        book.title,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        book.authorLine,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () {
                        Navigator.of(context).pop(book);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
