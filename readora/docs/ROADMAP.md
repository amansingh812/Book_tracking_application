# Roadmap

The strategy in one line: **tracking is the entry point, AI is the differentiator,
personal knowledge is the moat.** Build in that order, and do not build the moat before
anyone has arrived.

The metric that decides whether this works is not downloads. It is:

> Do weekly active readers keep coming back to Readora to track their reading?

A valuable user adds books → reads → tracks progress → saves notes → uses AI → returns.
Everything below is sequenced to reach that loop as fast as possible.

---

## M1 — Walking skeleton ✅ done

One thin slice through every layer, so the architecture is proven before it carries
weight.

- [x] Repo, flavors, CI, analysis rules
- [x] Supabase schema, RLS, `book-search` / `ai-chat` / `ai-generate` functions
- [x] Offline-first core: Isar, outbox, sync engine, cursors, sync badge
- [x] Design token layer + theme + Glass surfaces
- [x] Email/password + guest auth, router with the five tabs
- [x] Library list, status filter, progress model
- [x] Add-book flow wired to `book-search` (search → tap → in library)
- [x] Progress update sheet writing through the outbox

**Done when:** in airplane mode you can add a book, set progress, kill the app, reopen
it, reconnect, and see the row appear in Supabase. ✅

---

## M2 — Library and reading core ✅ done

The tracker people actually came for.

- [x] Book detail screen: status, rating, review, page count override
- [x] TBR with priority ordering and shelves
- [x] ISBN barcode scanner (`mobile_scanner`) and manual entry
- [x] Reading timer → `reading_sessions`, with pages read and reading speed
- [x] `reading_days` maintenance + streak display from `reading_streak()`
- [x] Daily/yearly goals
- [x] Local notifications for streak reminders (`flutter_local_notifications`)
- [x] Basic statistics: books, pages, time, streak

**Done when:** someone could use Readora as their only book tracker for a month and not
miss anything. ✅

---

## M3 — Capture and AI ✅ code complete, needs build + config

The reason to pay.

- [x] Notes and highlights: create, tag, favourite, per-book list (Isar + outbox synced)
- [x] AI Companion chat (streaming) grounded in the reader's own notes
- [x] "Save to notes" / "Make flashcard" wired from the AI chat into real repositories
- [x] Quiz generation (`ai-generate` task=quiz) + attempt scoring + knowledge history
- [x] Flashcards with SM-2-lite review scheduling, due-queue and per-book generation
- [x] `ai_usage` quota surfaced honestly in the UI (`_LiveUsageMeter`, replaces the old
      hardcoded 3/300 placeholder)
- [x] RevenueCat integration + paywall page + entitlement gating (`BillingRepository`)
- [x] Search/filter across notes (text search + kind/favourite filters, client-side)
- [ ] Practical actions ("turn this book into actions") — backend (`ai-generate`
      task=actions) exists; no client UI yet

**Done when:** a reader who has saved ten notes can be quizzed on them and the questions
are actually about what they wrote. Functionally done as of this pass — **blocked on the
build step below before it runs**:

1. `flutter pub get`
2. `dart run build_runner build --delete-conflicting-outputs` — generates the missing
   `.g.dart` files for the five new Isar collections (`NoteEntity`, `QuizEntity`,
   `QuizQuestionEntity`, `QuizAttemptEntity`, `FlashcardEntity`). Nothing in this pass
   compiles until this runs once.
3. `dart run flutter_launcher_icons` + `dart run flutter_native_splash:create` —
   generates the native icon/splash assets from `assets/icons/` per the config in
   `pubspec.yaml`.
4. `flutter analyze --fatal-infos` and `flutter test`
5. RevenueCat dashboard configuration (entitlement `plus`, offering, store products —
   see below) before the paywall can actually sell anything.

---

## Store readiness (TestFlight / Play internal testing)

Added on top of M3 for the first real device build, not gated behind a milestone:

- [x] Native splash screen + app icon, generated from a placeholder mark built
      directly off the design tokens (`tool/generate_brand_marks.py`) — swap
      the four PNGs in `assets/icons/` for real art whenever it's ready, the
      config doesn't change.
- [x] Auth-gate splash screen (`/`) — closes the cold-start flash of Home
      before session restore resolves.
- [x] Self-service account deletion (`Settings → Profile → Delete account`),
      backed by the `delete-account` edge function. Required by Apple/Google
      policy before any public listing; every per-user table already cascades
      from `auth.users`, so the function is one call.
- [x] Privacy Policy + Terms of Service — drafted, published, and linked from
      Settings. **Not yet lawyer-reviewed** — see the draft notice on the page
      itself before this goes in front of the public store listings.
- [ ] Apple Developer Program enrollment + App Store Connect app record
      (needed for TestFlight)
- [ ] Play Console developer account + app record (needed for internal
      testing track)

---

## M4 — Discover, analytics, and launch

- [ ] Personalised recommendations, each with a plain-English *why*
- [ ] Mood-based discovery and "I have 30 minutes"
- [ ] Analytics: speed, genres, trends, consistency (beyond the M2 basic stats page)
- [ ] Onboarding polish and empty states across the app
- [ ] Store listings, screenshots, privacy policy, data-deletion flow
- [ ] Replace the ring-buffer error sink with a real crash reporter
- [ ] Performance pass on a budget Android device (the Glass blur is the suspect)

**Done when:** it is in both stores and a stranger can get from install to first tracked
book without help.

---

## M5 — V2, the moat

Only after real retention data.

- [ ] Concept extraction from notes + embeddings pipeline
- [ ] My Knowledge: concepts with related notes, highlights, and books
- [ ] Cross-book connections (supports / contradicts / extends)
- [ ] Ask My Library (RAG over the reader's own notes) — Plus only
- [ ] Book comparison
- [ ] Reading Wrapped (and the shareable card, which is also a growth channel)
- [ ] Advanced recommendations and AI reading insights
- [ ] Home-screen widgets, Goodreads/StoryGraph import

---

## V3 — Social, much later

Profiles, friends, buddy reads, book clubs, challenges, community discovery.
Only after meaningful traction, and only because users ask for it.

---

## Explicitly not building

Writing this down matters more than the roadmap itself, because each of these is a
plausible-sounding request that would cost months before the core is proven:

- social feed, followers, messaging
- a full ebook reader or a Kindle replacement
- audiobook playback
- a book marketplace or any selling
- author profiles
- elaborate gamification (badges, levels, leaderboards)

---

## Monetisation

Free tier stays genuinely useful — the whole library, tracker, timer, goals, streaks,
notes, highlights, ratings, basic discovery and stats, plus **5 AI interactions a month**.
Those features build habit and data, and charging for them would kill both.

Plus sells intelligence and personalisation: AI Companion, quizzes, flashcards,
practical actions, My Knowledge, cross-book connections, Ask My Library, advanced
recommendations and analytics, Reading Wrapped, cloud sync across devices, widgets,
premium themes.

**Pricing is a hypothesis, not a decision.** Starting point to test in India:
₹199–₹299/month, ₹1,999/year. A lifetime tier (₹4,999–₹7,999) only once churn is
understood. Validate with real users before treating any of it as fixed.

---

## Competitive position

| App | Strongest at |
|---|---|
| Goodreads | Community, social, ecosystem |
| StoryGraph | Statistics, mood discovery |
| Bookly | Timer, habits, progress |
| Bookmory | Reading journal, aesthetics |
| **Readora** | **Understanding and remembering what you read** |

Do not try to beat everyone at everything. The last row is the only one worth defending.
