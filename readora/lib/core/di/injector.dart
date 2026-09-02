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
import 'package:readora/features/ai_companion/data/repositories/ai_chat_repository_impl.dart';
import 'package:readora/features/ai_companion/data/repositories/ai_usage_repository.dart';
import 'package:readora/features/ai_companion/domain/repositories/ai_chat_repository.dart';
import 'package:readora/features/flashcards/data/datasources/flashcards_sync_tables.dart';
import 'package:readora/features/flashcards/data/models/flashcard_models.dart';
import 'package:readora/features/flashcards/data/repositories/flashcards_repository_impl.dart';
import 'package:readora/features/flashcards/domain/repositories/flashcards_repository.dart';
import 'package:readora/features/library/domain/repositories/library_repository.dart';
import 'package:readora/features/notes/data/datasources/notes_sync_tables.dart';
import 'package:readora/features/notes/data/models/note_models.dart';
import 'package:readora/features/notes/data/repositories/notes_repository_impl.dart';
import 'package:readora/features/notes/domain/repositories/notes_repository.dart';
import 'package:readora/features/paywall/data/repositories/billing_repository_impl.dart';
import 'package:readora/features/paywall/domain/repositories/billing_repository.dart';
import 'package:readora/features/quiz/data/datasources/quiz_sync_tables.dart';
import 'package:readora/features/quiz/data/models/quiz_models.dart';
import 'package:readora/features/quiz/data/repositories/quiz_repository_impl.dart';
import 'package:readora/features/quiz/domain/repositories/quiz_repository.dart';
import 'package:readora/features/reading/data/datasources/reading_sync_tables.dart';
import 'package:readora/features/reading/data/models/reading_models.dart';
import 'package:readora/features/reading/data/repositories/reading_repository_impl.dart';
import 'package:readora/features/reading/domain/repositories/reading_repository.dart';
import 'package:readora/features/shelves/data/datasources/shelves_sync_tables.dart';
import 'package:readora/features/shelves/data/models/shelf_models.dart';
import 'package:readora/features/shelves/data/repositories/shelf_repository_impl.dart';
import 'package:readora/features/shelves/domain/repositories/shelf_repository.dart';
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
    ReadingSessionsSyncTable(),
    ReadingDaysSyncTable(),
    GoalsSyncTable(),
    ShelvesSyncTable(),
    ShelfItemsSyncTable(),
    NotesSyncTable(),
    QuizzesSyncTable(),
    QuizQuestionsSyncTable(),
    QuizAttemptsSyncTable(),
    FlashcardsSyncTable(),
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

  sl.registerSingleton<ShelfRepository>(
    ShelfRepositoryImpl(
      isar: isar,
      outbox: sl<Outbox>(),
      syncEngine: sl<SyncEngine>(),
      auth: sl<AuthRepository>(),
    ),
  );

  sl.registerSingleton<ReadingRepository>(
    ReadingRepositoryImpl(
      isar: isar,
      outbox: sl<Outbox>(),
      syncEngine: sl<SyncEngine>(),
      auth: sl<AuthRepository>(),
      prefs: sl<SharedPreferences>(),
    ),
  );

  sl.registerSingleton<AiChatRepository>(
    AiChatRepositoryImpl(sl<SupabaseClient>()),
  );

  sl.registerSingleton<AiUsageRepository>(
    AiUsageRepository(sl<SupabaseClient>()),
  );

  sl.registerSingleton<NotesRepository>(
    NotesRepositoryImpl(
      isar: isar,
      outbox: sl<Outbox>(),
      syncEngine: sl<SyncEngine>(),
      auth: sl<AuthRepository>(),
    ),
  );

  sl.registerSingleton<QuizRepository>(
    QuizRepositoryImpl(
      isar: isar,
      outbox: sl<Outbox>(),
      syncEngine: sl<SyncEngine>(),
      supabase: sl<SupabaseClient>(),
      auth: sl<AuthRepository>(),
    ),
  );

  sl.registerSingleton<FlashcardsRepository>(
    FlashcardsRepositoryImpl(
      isar: isar,
      outbox: sl<Outbox>(),
      syncEngine: sl<SyncEngine>(),
      supabase: sl<SupabaseClient>(),
      auth: sl<AuthRepository>(),
    ),
  );

  // Billing depends only on AuthRepository (to keep identity in sync with
  // RevenueCat) — never the other way around, so no feature needs to know
  // billing exists just to authenticate.
  final billing = BillingRepositoryImpl(auth: sl<AuthRepository>());
  sl.registerSingleton<BillingRepository>(billing);
  await billing.configure();

  await sl<SyncEngine>().start();
}

/// Every Isar collection in the app. Forgetting one here is the most common
/// cause of a "collection not found" crash at runtime.
final List<CollectionSchema<dynamic>> _schemas = [
  OutboxEntrySchema,
  SyncCursorSchema,
  // library
  BookEntitySchema,
  UserBookEntitySchema,
  // reading (M2)
  ReadingSessionEntitySchema,
  ReadingDayEntitySchema,
  GoalEntitySchema,
  // shelves (M2)
  ShelfEntitySchema,
  ShelfItemEntitySchema,
  // notes, quiz, flashcards (M3)
  NoteEntitySchema,
  QuizEntitySchema,
  QuizQuestionEntitySchema,
  QuizAttemptEntitySchema,
  FlashcardEntitySchema,
];
