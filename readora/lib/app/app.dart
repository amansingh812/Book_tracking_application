import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readora/app/router.dart';
import 'package:readora/core/config/brand_config.dart';
import 'package:readora/core/di/injector.dart';
import 'package:readora/design_system/theme/readora_theme.dart';
import 'package:readora/features/auth/domain/repositories/auth_repository.dart';
import 'package:readora/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:readora/features/library/domain/repositories/library_repository.dart';
import 'package:readora/features/library/presentation/bloc/library_bloc.dart';

/// Blocs that live for the whole session sit here. Feature-scoped blocs are
/// provided at their route instead — a bloc that outlives its screen holds
/// memory and stale state for no reason.
class ReadoraApp extends StatefulWidget {
  const ReadoraApp({super.key});

  @override
  State<ReadoraApp> createState() => _ReadoraAppState();
}

class _ReadoraAppState extends State<ReadoraApp> {
  late final AuthBloc _authBloc = AuthBloc(repository: sl<AuthRepository>());
  late final LibraryBloc _libraryBloc =
      LibraryBloc(repository: sl<LibraryRepository>())..add(const LibraryStarted());
  late final AppRouter _router = AppRouter(_authBloc);

  @override
  void dispose() {
    _authBloc.close();
    _libraryBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _authBloc),
        BlocProvider.value(value: _libraryBloc),
      ],
      child: MaterialApp.router(
        title: BrandConfig.appName,
        debugShowCheckedModeBanner: false,
        theme: ReadoraTheme.light,
        darkTheme: ReadoraTheme.dark,
        themeMode: ThemeMode.system,
        routerConfig: _router.router,
      ),
    );
  }
}
