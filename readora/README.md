# Readora

**Read more. Remember more.**

An AI-powered reading companion. Tracking is the entry point, AI is the differentiator,
and your personal knowledge base is what makes it worth keeping.

    Discover → Track → Read → Capture → Understand → Remember → Discover next

> The product name is not final. Every brand string lives in
> `lib/core/config/brand_config.dart` so a rename touches one file plus the two native
> identifiers. The `applicationId` must be settled **before** the first Play Console
> upload — Google does not allow changing it afterwards.

---

## Stack

| Layer | Choice | Why |
|---|---|---|
| App | Flutter (Android + iOS) | One codebase, both stores from day one |
| State | `flutter_bloc` + `bloc_concurrency` | Explicit events, testable with `bloc_test` |
| Navigation | `go_router` (`StatefulShellRoute`) | Five persistent tabs, declarative auth redirects |
| Local DB | Isar | The offline source of truth — the UI reads *only* from here |
| Backend | Supabase (Postgres + Auth + Edge Functions) | Postgres RLS does the security; no server to run |
| AI | OpenAI, called from Edge Functions | The API key never ships in the app |
| Books | Google Books → Open Library fallback | Best search, best ISBN coverage, cached in `public.books` |
| Payments | RevenueCat + store IAP | One SDK for Play Billing and StoreKit |
| DI | `get_it` | Plain, explicit, no code generation |

---

## First-time setup

### 1. Prerequisites

```bash
flutter --version        # stable channel
flutter doctor           # Android toolchain + Xcode must both be green
brew install supabase/tap/supabase   # Supabase CLI
```

### 2. Generate the native projects

This repo ships `lib/`, `supabase/`, docs, and CI — but not the `android/` and `ios/`
folders, which are machine- and version-specific. Create them once, in this directory:

```bash
flutter create --platforms=android,ios --org com.readora --project-name readora .
flutter pub get
```

`flutter create` will not touch existing files. It adds the native folders and nothing else.

### 3. Generate code

Isar models and the localisations are generated:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Re-run this whenever you add or change an `@collection` class or an `.arb` file.
During heavy work, `dart run build_runner watch -d` is less painful.

### 4. Create the Supabase projects

Create **two** projects at [supabase.com](https://supabase.com) — `readora-dev` and
`readora-prod`, region `ap-south-1` (Mumbai). Then apply the schema:

```bash
supabase link --project-ref <your-dev-ref>
supabase db push            # applies supabase/migrations/*.sql in order
```

Or run the whole stack locally instead (needs Docker):

```bash
supabase start
supabase db reset           # migrations + seed.sql
```

### 5. Configure environments

```bash
cp env/dev.example.json  env/dev.json
cp env/prod.example.json env/prod.json
```

Fill in the Supabase URL and **anon** key for each project.
`env/*.json` is gitignored — only the `.example.json` files are committed.

> The `service_role` key and the OpenAI key never go in these files. They are Edge
> Function secrets and belong only on the server.

### 6. Set the server-side secrets

```bash
supabase secrets set \
  OPENAI_API_KEY=sk-... \
  GOOGLE_BOOKS_API_KEY=... \
  REVENUECAT_WEBHOOK_SECRET=$(openssl rand -hex 32) \
  AI_FREE_MONTHLY_LIMIT=5
```

### 7. Deploy the Edge Functions

```bash
supabase functions deploy book-search
supabase functions deploy ai-chat
supabase functions deploy ai-generate
supabase functions deploy revenuecat-webhook --no-verify-jwt
```

`revenuecat-webhook` is the one function deployed without JWT verification — RevenueCat
cannot present a Supabase token, so it authenticates with the shared secret above.

### 8. Wire up the flavors

**Android** — in `android/app/build.gradle.kts`, inside `android { }`:

```kotlin
flavorDimensions += "env"
productFlavors {
    create("dev") {
        dimension = "env"
        applicationIdSuffix = ".dev"
        resValue("string", "app_name", "Readora Dev")
    }
    create("prod") {
        dimension = "env"
        resValue("string", "app_name", "Readora")
    }
}
```

Then set `android:label="@string/app_name"` in `android/app/src/main/AndroidManifest.xml`.

**iOS** — in Xcode: duplicate the Debug/Release/Profile configurations into
`Debug-dev`, `Release-dev`, `Debug-prod`, `Release-prod`; create `dev` and `prod`
schemes; set `PRODUCT_BUNDLE_IDENTIFIER` to `com.readora.app.dev` for the dev
configurations. Add the URL scheme `readora` under Info → URL Types so the auth
callback returns to the app.

---

## Running

```bash
# dev
flutter run --flavor dev -t lib/main_dev.dart --dart-define-from-file=env/dev.json

# prod
flutter run --flavor prod -t lib/main_prod.dart --dart-define-from-file=env/prod.json

# release bundle
flutter build appbundle --flavor prod -t lib/main_prod.dart \
  --dart-define-from-file=env/prod.json
```

Both flavors install side by side on one device and point at different Supabase projects,
so testing a migration can never touch real user data.

---

## Testing

```bash
flutter test                      # unit + bloc + widget
flutter test --coverage
flutter analyze --fatal-infos
dart format lib test
```

What must be covered before a feature is considered done:

- every Bloc, via `bloc_test` (happy path, failure path, and the offline path)
- every repository, against an in-memory Isar instance
- any calculation a reader will see as a number — progress, streaks, reading speed
- an RLS test per new table: user A must get zero rows from user B

---

## Project structure

```
lib/
  app/                  MaterialApp, router, shell
  core/
    config/             Env (dart-defines), Flavor, BrandConfig
    di/                 get_it wiring — the whole object graph in one file
    error/              Failure types + the single SDK-exception mapper
    sync/               Outbox, SyncEngine, cursors  ← read this first
    logging/
  design_system/
    tokens/             colours, type, spacing, radii, blur  ← the only literals
    theme/              ThemeData built from tokens
    widgets/            GlassCard, ProgressRing, BookCover, SyncBadge
  features/<feature>/
    data/               Isar models, datasources, repository implementations
    domain/             entities, repository interfaces, usecases
    presentation/       bloc, pages, widgets
supabase/
  migrations/           numbered SQL, applied in order, never edited once pushed
  functions/            Deno Edge Functions (_shared/ holds auth, quota, OpenAI)
docs/                   ARCHITECTURE, DATA_MODEL, ROADMAP
```

Full conventions are in [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md), the schema in
[`docs/DATA_MODEL.md`](docs/DATA_MODEL.md), and the build order in
[`docs/ROADMAP.md`](docs/ROADMAP.md).

---

## The one rule that shapes everything

**The local database is the source of truth for the UI. Nothing in `presentation/` ever
awaits the network.**

A repository writes to Isar, queues the change on the outbox, and returns. The sync
engine drains the queue whenever a connection exists. People read on planes and in
basements — being offline is a normal state in Readora, not an error.

---

## Troubleshooting

| Symptom | Fix |
|---|---|
| `Missing dart-define values: SUPABASE_URL` | You forgot `--dart-define-from-file=env/dev.json` |
| `IsarError: collection not found` | New `@collection` isn't in `_schemas` in `lib/core/di/injector.dart` |
| Isar build fails on newer AGP/Xcode | Swap to the `isar_community` fork — see ARCHITECTURE → Risks |
| `flutter pub get` cannot resolve | `flutter pub upgrade --major-versions`, then commit `pubspec.lock` |
| RLS "permission denied" on a new table | You added the table but not its policies in `0009_rls.sql` |
| Edge Function 401 in the app | The session expired, or the function was deployed with the wrong `verify_jwt` |
| Covers don't load on iOS | The URL is `http:` — the book-search function rewrites Google's to `https:` |

---

## Security notes

- The `service_role` key must never appear in the Flutter app, in `env/*.json`, or in git.
- Entitlements come only from the RevenueCat webhook. The client can read
  `subscriptions` and never write it — a user cannot PATCH themselves into Plus.
- The AI layer only ever sees public book metadata and the reader's own notes and
  highlights. Readora does not source or store book text it isn't authorised to hold.
