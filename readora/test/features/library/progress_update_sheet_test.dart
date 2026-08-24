import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:readora/features/library/data/models/library_models.dart';
import 'package:readora/features/library/domain/entities/library_book.dart';
import 'package:readora/features/library/presentation/bloc/library_bloc.dart';
import 'package:readora/features/library/presentation/widgets/progress_update_sheet.dart';

class MockLibraryBloc extends MockBloc<LibraryEvent, LibraryState>
    implements LibraryBloc {}

void main() {
  late MockLibraryBloc mockLibraryBloc;

  setUpAll(() {
    registerFallbackValue(const LibraryStarted());
    registerFallbackValue(
      const LibraryProgressUpdated(userBookId: '1', page: 1),
    );
    registerFallbackValue(
      const LibraryStatusChanged(
        userBookId: '1',
        status: ReadingStatus.reading,
      ),
    );
  });

  setUp(() {
    mockLibraryBloc = MockLibraryBloc();
    when(() => mockLibraryBloc.state).thenReturn(const LibraryState());
  });

  LibraryBook testBook({
    int currentPage = 50,
    int? pageCount = 200,
    ReadingStatus status = ReadingStatus.reading,
  }) {
    return LibraryBook(
      id: 'ub-123',
      bookId: 'b-123',
      title: 'Designing Data-Intensive Applications',
      authors: const ['Martin Kleppmann'],
      status: status,
      currentPage: currentPage,
      pageCount: pageCount,
    );
  }

  Widget createSubject(LibraryBook book) {
    return MaterialApp(
      home: Scaffold(
        body: BlocProvider<LibraryBloc>.value(
          value: mockLibraryBloc,
          child: ProgressUpdateSheet(book: book),
        ),
      ),
    );
  }

  group('ProgressUpdateSheet', () {
    testWidgets('renders book title, current page, and total pages',
        (tester) async {
      final book = testBook();
      await tester.pumpWidget(createSubject(book));

      expect(
        find.textContaining('Designing Data-Intensive Applications'),
        findsWidgets,
      );
      expect(find.text('Martin Kleppmann'), findsOneWidget);
      expect(find.byKey(const Key('progress_stat_text')), findsOneWidget);
      final statWidget = tester.widget<Text>(
        find.byKey(const Key('progress_stat_text')),
      );
      expect(statWidget.data, '50');
      expect(find.text('/ 200 pages'), findsOneWidget);
      expect(find.text('25%'), findsOneWidget);
    });

    testWidgets('stepping +1 increments current page and updates percentage',
        (tester) async {
      final book = testBook();
      await tester.pumpWidget(createSubject(book));

      await tester.tap(find.text('+1'));
      await tester.pumpAndSettle();

      final statWidget = tester.widget<Text>(
        find.byKey(const Key('progress_stat_text')),
      );
      expect(statWidget.data, '51');
      expect(find.byKey(const Key('progress_delta_text')), findsOneWidget);
      final deltaWidget = tester.widget<Text>(
        find.byKey(const Key('progress_delta_text')),
      );
      expect(deltaWidget.data, '+1 pages this log');
    });

    testWidgets('stepping +5 increments current page by 5', (tester) async {
      final book = testBook();
      await tester.pumpWidget(createSubject(book));

      await tester.tap(find.text('+5'));
      await tester.pumpAndSettle();

      final statWidget = tester.widget<Text>(
        find.byKey(const Key('progress_stat_text')),
      );
      expect(statWidget.data, '55');
      expect(find.text('28%'), findsOneWidget);
      final deltaWidget = tester.widget<Text>(
        find.byKey(const Key('progress_delta_text')),
      );
      expect(deltaWidget.data, '+5 pages this log');
    });

    testWidgets('stepping -10 decrements current page by 10', (tester) async {
      final book = testBook();
      await tester.pumpWidget(createSubject(book));

      await tester.tap(find.text('-10'));
      await tester.pumpAndSettle();

      final statWidget = tester.widget<Text>(
        find.byKey(const Key('progress_stat_text')),
      );
      expect(statWidget.data, '40');
      final deltaWidget = tester.widget<Text>(
        find.byKey(const Key('progress_delta_text')),
      );
      expect(deltaWidget.data, '-10 pages this log');
    });

    testWidgets('entering exact page number in text field updates page',
        (tester) async {
      final book = testBook();
      await tester.pumpWidget(createSubject(book));

      final textField = find.byKey(const Key('progress_page_textfield'));
      expect(textField, findsOneWidget);

      await tester.enterText(textField, '100');
      await tester.pumpAndSettle();

      final statWidget = tester.widget<Text>(
        find.byKey(const Key('progress_stat_text')),
      );
      expect(statWidget.data, '100');
      expect(find.text('50%'), findsOneWidget);
      final deltaWidget = tester.widget<Text>(
        find.byKey(const Key('progress_delta_text')),
      );
      expect(deltaWidget.data, '+50 pages this log');
    });

    testWidgets('tapping Save Progress dispatches LibraryProgressUpdated',
        (tester) async {
      final book = testBook();
      await tester.pumpWidget(createSubject(book));

      await tester.tap(find.text('+5'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('progress_save_button')));
      await tester.pump();

      verify(
        () => mockLibraryBloc.add(
          const LibraryProgressUpdated(
            userBookId: 'ub-123',
            page: 55,
          ),
        ),
      ).called(1);
    });

    testWidgets(
        'changing status dispatches both progress and status change events',
        (tester) async {
      final book = testBook();
      await tester.pumpWidget(createSubject(book));

      await tester.tap(find.text('Paused'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('progress_save_button')));
      await tester.pump();

      verify(
        () => mockLibraryBloc.add(
          const LibraryStatusChanged(
            userBookId: 'ub-123',
            status: ReadingStatus.paused,
          ),
        ),
      ).called(1);
    });
  });
}
