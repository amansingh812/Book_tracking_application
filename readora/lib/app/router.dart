import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:readora/core/di/injector.dart';
import 'package:readora/features/ai_companion/presentation/pages/ai_page.dart';
import 'package:readora/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:readora/features/auth/presentation/pages/sign_in_page.dart';
import 'package:readora/features/auth/presentation/pages/welcome_page.dart';
import 'package:readora/features/discover/presentation/pages/discover_page.dart';
import 'package:readora/features/home/presentation/pages/home_page.dart';
import 'package:readora/features/library/domain/repositories/library_repository.dart';
import 'package:readora/features/library/presentation/pages/library_page.dart';
import 'package:readora/features/profile/presentation/pages/profile_page.dart';
import 'package:readora/features/search_add/presentation/bloc/search_bloc.dart';
import 'package:readora/features/search_add/presentation/pages/add_book_page.dart';

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
    initialLocation: '/home',
    refreshListenable: _BlocRefresh(authBloc.stream),
    redirect: (context, state) {
      final status = authBloc.state.status;
      final atAuth = state.matchedLocation.startsWith('/auth');

      // Still restoring the session: hold wherever we are.
      if (status == AuthStatus.unknown) return null;

      // Unauthenticated users must go to /auth.
      if (status == AuthStatus.unauthenticated) return atAuth ? null : '/auth';

      // Fully-authenticated users are redirected away from the welcome screen
      // only (not sign-in — guests can visit sign-in to upgrade their account).
      if (status == AuthStatus.authenticated && state.matchedLocation == '/auth') {
        return '/home';
      }

      // Guests may visit /auth/sign-in to upgrade to a full account.
      // Once they complete sign-up, status becomes authenticated and they land on /home.
      return null;
    },
    routes: [
      GoRoute(
        path: '/auth',
        builder: (_, __) => const WelcomePage(),
        routes: [
          GoRoute(path: 'sign-in', builder: (_, __) => const SignInPage()),
        ],
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
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/discover', builder: (_, __) => const DiscoverPage())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/ai', builder: (_, __) => const AiPage())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/profile', builder: (_, __) => const ProfilePage())],
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
