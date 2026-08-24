import 'package:get_it/get_it.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:readora/core/sync/outbox.dart';
import 'package:readora/core/sync/sync_engine.dart';
import 'package:readora/core/sync/sync_models.dart';
import 'package:readora/core/sync/syncable_table.dart';
import 'package:readora/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:readora/features/auth/domain/repositories/auth_repository.dart';
import 'package:readora/features/library/data/datasources/library_sync_tables.dart';
import 'package:readora/features/library/data/models/library_models.dart';
import 'package:readora/features/library/data/repositories/library_repository_impl.dart';
import 'package:readora/features/library/domain/repositories/library_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final sl = GetIt.instance;

/// Wires the object graph. Called once from `bootstrap.dart`.
///
/// Adding a synced feature means: register its [SyncableTable] in the list
/// below, add its Isar schema to [_schemas], and register its repository.
/// Nothing in `core/sync/` changes.
Future<void> configureDependencies() async {
  // --- local database -------------------------------------------------------
  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open(_schemas, directory: dir.path, name: 'readora');
  sl.registerSingleton<Isar>(isar);

  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);

  sl.registerSingleton<SupabaseClient>(Supabase.instance.client);

  // --- sync -----------------------------------------------------------------
  sl.registerSingleton<Outbox>(Outbox(isar));
  sl.registerSingleton<List<SyncableTable>>([
    BooksSyncTable(),
    UserBooksSyncTable(),
    // notes, reading_sessions, goals... register here as each feature lands.
  ]);
  sl.registerSingleton<SyncEngine>(
    SyncEngine(
      isar: isar,
      supabase: sl<SupabaseClient>(),
      outbox: sl<Outbox>(),
      tables: sl<List<SyncableTable>>(),
    ),
  );

  // --- repositories ---------------------------------------------------------
  sl.registerSingleton<AuthRepository>(
    AuthRepositoryImpl(
      supabase: sl<SupabaseClient>(),
      syncEngine: sl<SyncEngine>(),
    ),
  );

  sl.registerSingleton<LibraryRepository>(
    LibraryRepositoryImpl(
      isar: isar,
      outbox: sl<Outbox>(),
      syncEngine: sl<SyncEngine>(),
      supabase: sl<SupabaseClient>(),
      auth: sl<AuthRepository>(),
    ),
  );

  await sl<SyncEngine>().start();
}

/// Every Isar collection in the app. Forgetting one here is the most common
/// cause of a "collection not found" crash at runtime.
final List<CollectionSchema<dynamic>> _schemas = [
  OutboxEntrySchema,
  SyncCursorSchema,
  BookEntitySchema,
  UserBookEntitySchema,
];
