# Architecture

## The shape of the app

```
                         presentation (Bloc, pages, widgets)
                                    │  events ↓   states ↑
                         domain (entities, repository interfaces)
                                    │
                         data (repository impls, Isar, Supabase)
                                    │
                    ┌───────────────┴────────────────┐
                Isar (local)                   Supabase (remote)
                    │                                │
                    └──────────  SyncEngine  ────────┘
```

Three layers per feature, one direction of dependency: `presentation → domain → data`.
`domain` imports nothing from Flutter or Supabase. `presentation` never imports
`supabase_flutter`, `isar`, or `dio`.

## The rule everything else follows

> **The local database is the source of truth for the UI.
> Nothing in `presentation/` ever awaits the network.**

Every write follows the same four steps:

1. write to Isar
2. enqueue the change on the outbox
3. return
4. nudge the sync engine, fire-and-forget

`LibraryRepositoryImpl` is the reference implementation. Copy its shape.

The consequence is that the app is fully functional offline — add books, update
progress, write notes, run the timer — and that no screen ever shows a spinner
because a server is slow. The only online-only actions in V1 are catalogue search
and the AI features, and both fail with a clear message rather than a dead screen.

---

## Sync

### Push: field-level patches

An outbox entry carries **only the fields that changed**, serialised as JSON. The
engine sends it as a PostgREST `PATCH`, which becomes a partial `UPDATE`. Two devices
that edited different fields of the same note therefore both keep their edit — we get
field-level last-write-wins without storing a timestamp per column.

Consecutive updates to the same row are merged in the outbox before sending, so
dragging a progress slider queues one request, not forty.

### Pull: cursor + tombstones

Per table, we ask for `updated_at > cursor`, ordered ascending. `updated_at` is stamped
by a Postgres trigger, never by the device, so a phone with a wrong clock cannot skip
rows. Rows with a non-null `deleted_at` are tombstones: they delete the local copy.

Push always runs before pull. That way our own writes come back in the same cycle with
a server timestamp, the cursor advances past them, and we never re-download our own edit.

### Failure handling

A failed entry gets exponential backoff (2s → 30 min) and the queue keeps moving — one
poisoned row must never block everything behind it. The user sees `synced | syncing |
offline | failed` in the `SyncBadge`, and the copy for `offline` reassures rather than
warns.

### Adding a synced table

1. Add the Isar collection (`@collection`, with a unique `uuid` index).
2. Implement `SyncableTable` for it.
3. Register it in `lib/core/di/injector.dart` — both in the `SyncableTable` list and in
   `_schemas`.
4. Add the table to `0009_rls.sql`'s `owned` array so it gets policies automatically.

No changes to `SyncEngine` are ever needed. If you find yourself editing it for a
feature, the feature is fighting the design.

### Guest to account

Guest rows are written with `userId = 'local'`. On sign-up we re-stamp them with the
real uid, reset the sync cursors, and let the outbox upload everything. A guest who
creates an account never loses a book — which is the whole reason guest mode is
offered as an equal option on the welcome screen.

---

## State management

- One Bloc per screen-sized concern. Feature Blocs are provided at their route;
  `AuthBloc` and `LibraryBloc` are app-scoped because the router and Home both need them.
- Events are past tense for facts (`LibraryBooksUpdated`) and imperative for intents
  (`LibraryProgressUpdated`). Sealed classes, `Equatable` props on everything.
- Use `bloc_concurrency` transformers deliberately: `restartable()` for anything that
  opens a subscription, `sequential()` for writes, `droppable()` for
  submit-button handlers.
- A Bloc never catches a raw SDK exception. Repositories throw `Failure`s
  (via `guard()` in `core/error/error_mapper.dart`) and the Bloc puts them in state.

## Errors

`core/error/failure.dart` defines the only error types the UI knows about:
`NetworkFailure`, `AuthFailure`, `QuotaFailure`, `ValidationFailure`, `ServerFailure`,
`CacheFailure`. Each carries a message that is already safe to show a reader. If you
cannot write such a message, what you have is a bug, not a `Failure`.

`QuotaFailure` is special: the UI turns it into the paywall, not an error snackbar.

## Design tokens

`design_system/tokens/` holds every colour, size, radius, blur, and text style in the
app. **No widget may write `Color(0x...)`, `Colors.something`, a raw padding number, or
its own `TextStyle`.** If a token is missing, add it.

The current token values are placeholders. Replacing them with the real Glass palette
from the Claude Design export (`colors_and_type.css`) should require editing only
`readora_colors.dart` and `readora_typography.dart` — if it requires touching a widget,
that widget has a hardcoded value that needs removing first.

Performance note on the Glass look: each `GlassCard` costs a backdrop-filter pass. Use
`GlassCard.flat` in lists; keep blurred surfaces to two or three per screen.

## AI and copyright

The AI context is assembled in `supabase/functions/_shared/context.ts` from exactly two
things: public bibliographic metadata, and the reader's own notes, highlights, rating
and progress. Readora does not source, store, or send book text it is not authorised to
hold. If a feature seems to need the book's actual text, the answer is to ask the reader
to paste the passage in front of them — never to fetch it.

The system prompt also forbids spoiling content past the reader's current page. That is
a product decision as much as a safety one.

## Security

- RLS is on for every table, forced, with policies generated from a list in
  `0009_rls.sql` so a new table cannot be forgotten.
- `subscriptions` and `ai_usage` are readable by their owner and writable by nobody but
  the service role. A user cannot grant themselves Plus or reset their AI meter.
- `books` is readable by all authenticated users and writable only by the `book-search`
  function.
- The `service_role` key exists only as a Supabase secret. It is never in the app,
  never in `env/*.json`, never in git.

## Testing strategy

| Layer | Tool | What must be proven |
|---|---|---|
| Domain entities | plain `test` | Every number a reader sees is right at the edges |
| Repositories | in-memory Isar + `mocktail` | Local write happens; outbox entry is queued; network is not awaited |
| Blocs | `bloc_test` | Happy path, failure path, offline path |
| Widgets | `flutter_test` | Empty, loading, and error states render |
| Sync | integration | Airplane-mode round trip, and a two-device field conflict |
| RLS | integration | User B gets zero rows of user A's data |

## Known risks

**Isar maintenance.** Upstream `isar` 3.1.x is stale against recent AGP and Xcode. If
the build breaks, switch to the `isar_community` fork — the pin lives in one place in
`pubspec.yaml`, and repositories talk to Isar through a narrow surface, so the swap is
contained.

**No crash reporting.** Shipping without Firebase and Sentry means production crashes
are only visible through the local ring buffer in `AppLogger`, flushed to
`public.client_errors`. This is fine for a private beta and not fine for a public
launch — see ROADMAP → release prep.

**Backdrop filters on low-end Android.** The Glass look is the most likely source of
jank on ₹10–15k devices, which is a meaningful slice of the India-first audience.
Profile on a real budget device before M4, and be willing to drop to the flat variant
by default there.
