import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:readora/core/di/injector.dart';
import 'package:readora/features/ai_companion/domain/repositories/ai_chat_repository.dart';
import 'package:readora/features/ai_companion/presentation/bloc/ai_chat_bloc.dart';
import 'package:readora/features/ai_companion/presentation/pages/ai_page.dart';
import 'package:readora/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:readora/features/auth/presentation/pages/sign_in_page.dart';
import 'package:readora/features/auth/presentation/pages/welcome_page.dart';
import 'package:readora/features/discover/presentation/pages/discover_page.dart';
import 'package:readora/features/flashcards/domain/repositories/flashcards_repository.dart';
import 'package:readora/features/flashcards/presentation/bloc/flashcards_bloc.dart';
import 'package:readora/features/flashcards/presentation/pages/flashcards_review_page.dart';
import 'package:readora/features/home/presentation/pages/home_page.dart';
import 'package:readora/features/library/domain/entities/library_book.dart';
import 'package:readora/features/library/domain/repositories/library_repository.dart';
import 'package:readora/features/library/presentation/book_detail/bloc/book_detail_bloc.dart';
import 'package:readora/features/library/presentation/book_detail/book_detail_page.dart';
import 'package:readora/features/library/presentation/pages/library_page.dart';
import 'package:readora/features/notes/domain/repositories/notes_repository.dart';
import 'package:readora/features/notes/presentation/bloc/notes_bloc.dart';
import 'package:readora/features/notes/presentation/pages/notes_page.dart';
import 'package:readora/features/paywall/domain/repositories/billing_repository.dart';
import 'package:readora/features/paywall/presentation/bloc/paywall_bloc.dart';
import 'package:readora/features/paywall/presentation/pages/paywall_page.dart';
import 'package:readora/features/profile/presentation/pages/profile_page.dart';
import 'package:readora/features/quiz/domain/entities/quiz.dart';
import 'package:readora/features/quiz/domain/repositories/quiz_repository.dart';
import 'package:readora/features/quiz/presentation/bloc/quiz_bloc.dart';
import 'package:readora/features/quiz/presentation/pages/quiz_list_page.dart';
import 'package:readora/features/quiz/presentation/pages/quiz_take_page.dart';
import 'package:readora/features/reading/domain/repositories/reading_repository.dart';
import 'package:readora/features/reading/presentation/bloc/reading_session_bloc.dart';
import 'package:readora/features/reading/presentation/pages/reading_session_page.dart';
import 'package:readora/features/search_add/presentation/bloc/search_bloc.dart';
import 'package:readora/features/search_add/presentation/pages/add_book_page.dart';
import 'package:readora/features/search_add/presentation/pages/isbn_scan_page.dart';
import 'package:readora/features/shelves/domain/repositories/shelf_repository.dart';
import 'package:readora/features/shelves/presentation/bloc/shelves_bloc.dart';
import 'package:readora/features/shelves/presentation/pages/shelf_detail_page.dart';
import 'package:readora/features/shelves/presentation/pages/shelves_page.dart';
import 'package:readora/features/splash/presentation/pages/splash_page.dart';
import 'package:readora/features/stats/presentation/pages/stats_page.dart';

/// Five destinations, no more. Every V1 feature reaches the user through one of
/// these tabs; anything that needs a sixth tab is a sign the feature belongs
/// inside an existing one.
class AppRouter {
  AppRouter(this.authBloc);

  final AuthBloc authBloc;

  /// Allows full-screen routes to cover the bottom navigation bar.
  static final rootNavigatorKey = GlobalKey<NavigatorState>();

  late final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: _BlocRefresh(authBloc.stream),
    redirect: (context, state) {
      final status = authBloc.state.status;
      final atAuth = state.matchedLocation.startsWith('/auth');
      final atSplash = state.matchedLocation == '/';

      // Still restoring the session from disk: hold on the splash screen,
      // not wherever go_router happened to start (e.g. a deep link — those
      // aren't preserved through the splash gate today, a known gap).
      if (status == AuthStatus.unknown) return atSplash ? null : '/';

      // Session resolved: nobody should still be sitting on the splash.
      if (atSplash) return status == AuthStatus.unauthenticated ? '/auth' : '/home';

      // Unauthenticated users must go to /auth.
      if (status == AuthStatus.unauthenticated) return atAuth ? null : '/auth';

      // Fully-authenticated users are redirected away from the welcome screen
      // only (not sign-in — guests can visit sign-in to upgrade their account).
      if (status == AuthStatus.authenticated && atAuth) return '/home';

      // Guests may visit /auth/sign-in to upgrade to a full account.
      // Once they complete sign-up, status becomes authenticated and they land on /home.
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, __) => const SplashPage(),
      ),
      GoRoute(
        path: '/auth',
        builder: (_, __) => const WelcomePage(),
        routes: [
          GoRoute(path: 'sign-in', builder: (_, __) => const SignInPage()),
        ],
      ),
      GoRoute(
        path: '/paywall',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, __) => BlocProvider(
          create: (_) => PaywallBloc(sl<BillingRepository>())..add(const PaywallStarted()),
          child: const PaywallPage(),
        ),
      ),
      GoRoute(
        path: '/quiz/:quizId/take',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, state) => QuizTakePage(quiz: state.extra as Quiz),
      ),
      StatefulShellRoute.indexedStack(
        builder: (_, __, shell) => _AppShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [GoRoute(path: '/home', builder: (_, __) => const HomePage())],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/library',
                builder: (_, __) => const LibraryPage(),
                routes: [
                  GoRoute(
                    path: 'add',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (_, __) => BlocProvider(
                      create: (_) => SearchBloc(repository: sl<LibraryRepository>())
                        ..add(const SearchStarted()),
                      child: const AddBookPage(),
                    ),
                    routes: [
                      GoRoute(
                        path: 'scan',
                        parentNavigatorKey: rootNavigatorKey,
                        builder: (_, __) => const IsbnScanPage(),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'shelves',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (_, __) => BlocProvider(
                      create: (_) => ShelvesBloc(sl<ShelfRepository>())
                        ..add(const ShelvesStarted()),
                      child: const ShelvesPage(),
                    ),
                    routes: [
                      GoRoute(
                        path: ':shelfId',
                        parentNavigatorKey: rootNavigatorKey,
                        builder: (_, state) {
                          final shelfId = state.pathParameters['shelfId']!;
                          final shelfName = state.extra as String? ?? 'Shelf';
                          return MultiBlocProvider(
                            providers: [
                              BlocProvider(
                                create: (_) => ShelvesBloc(sl<ShelfRepository>())
                                  ..add(const ShelvesStarted()),
                              ),
                              BlocProvider(
                                create: (_) => ShelfDetailBloc(sl<ShelfRepository>())
                                  ..add(ShelfDetailStarted(shelfId)),
                              ),
                            ],
                            child: ShelfDetailPage(
                              shelfId: shelfId,
                              shelfName: shelfName,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  GoRoute(
                    path: ':userBookId',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (_, state) => BlocProvider(
                      create: (_) => BookDetailBloc(sl<LibraryRepository>())
                        ..add(BookDetailStarted(
                            state.pathParameters['userBookId']!)),
                      child: const BookDetailPage(),
                    ),
                    routes: [
                      GoRoute(
                        path: 'read',
                        parentNavigatorKey: rootNavigatorKey,
                        builder: (_, state) {
                          final book = state.extra as LibraryBook;
                          return BlocProvider(
                            create: (_) => ReadingSessionBloc(sl<ReadingRepository>()),
                            child: ReadingSessionPage(book: book),
                          );
                        },
                      ),
                      GoRoute(
                        path: 'notes',
                        parentNavigatorKey: rootNavigatorKey,
                        builder: (_, state) {
                          final book = state.extra as LibraryBook;
                          return BlocProvider(
                            create: (_) => NotesBloc(sl<NotesRepository>())
                              ..add(NotesStarted(book.id)),
                            child: NotesPage(bookTitle: book.title),
                          );
                        },
                      ),
                      GoRoute(
                        path: 'quiz',
                        parentNavigatorKey: rootNavigatorKey,
                        builder: (_, state) {
                          final book = state.extra as LibraryBook;
                          return BlocProvider(
                            create: (_) => QuizBloc(sl<QuizRepository>())
                              ..add(QuizStarted(book.id)),
                            child: QuizListPage(bookTitle: book.title),
                          );
                        },
                      ),
                      GoRoute(
                        path: 'flashcards',
                        parentNavigatorKey: rootNavigatorKey,
                        builder: (_, state) {
                          final book = state.extra as LibraryBook;
                          return BlocProvider(
                            create: (_) => FlashcardsBloc(
                              sl<FlashcardsRepository>(),
                              userBookId: book.id,
                            ),
                            child: FlashcardsReviewPage(bookTitle: book.title),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/discover', builder: (_, __) => const DiscoverPage())],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/ai',
                builder: (_, __) => BlocProvider(
                  create: (_) => AiChatBloc(sl<AiChatRepository>()),
                  child: const AiPage(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (_, __) => const ProfilePage(),
                routes: [
                  GoRoute(
                    path: 'stats',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (_, __) => const StatsPage(),
                  ),
                  GoRoute(
                    path: 'study',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (_, __) => BlocProvider(
                      create: (_) => FlashcardsBloc(sl<FlashcardsRepository>()),
                      child: const FlashcardsReviewPage(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

class _AppShell extends StatelessWidget {
  const _AppShell({required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_stories_outlined),
            selectedIcon: Icon(Icons.auto_stories),
            label: 'Library',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Discover',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome),
            label: 'AI',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

/// Bridges a Bloc stream to go_router's Listenable-based refresh.
class _BlocRefresh extends ChangeNotifier {
  _BlocRefresh(Stream<dynamic> stream) {
    notifyListeners();
    _sub = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
