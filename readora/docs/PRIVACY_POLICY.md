# Readora Privacy Policy

**Last updated: August 30, 2026**

> **Draft notice:** This is a first draft written directly from Readora's actual
> data model and third-party integrations, not boilerplate. It has **not** been
> reviewed by a lawyer. Have it reviewed before linking it from a public App
> Store / Play Store listing — in particular, confirm the governing-law
> section, the age minimum, and whether India's DPDP Act (2023) requires
> anything further once you have real users.

Readora ("we", "us") is a reading-tracking and AI reading-companion app. This
policy explains what we collect, why, who we share it with, and how you can
get it deleted.

## What we collect

**Account information.** Your email address and password (Supabase Auth
stores your password as a salted hash — we never see or store it in plain
text), and an optional display name. If you use Readora without creating an
account ("guest mode"), we still create an anonymous account behind the
scenes so your library can sync and back up, but no email or password is
attached to it.

**Your library and reading activity.** Books you add, their status (want to
read / reading / finished), ratings and reviews, reading sessions (start/end
time, pages read), daily reading streaks, and goals you set.

**Notes and highlights.** Anything you write or paste into Readora as a note
or highlight, including which page or chapter it's attached to and any tags
you add.

**AI Companion usage.** When you use the AI Companion, quiz generator, or
flashcard generator, we send your own notes and highlights for the relevant
book (never the book's copyrighted text) to OpenAI to generate a response.
We also keep a monthly count of how many AI interactions you've used, to
enforce the free-tier limit.

**Subscription status.** If you subscribe to Readora Plus, RevenueCat (our
subscription-management provider) tells us your entitlement status via a
webhook. We do not receive or store your payment card details — those are
handled entirely by the Apple App Store or Google Play.

**Device and diagnostic information.** Basic device information (OS version,
device model) and crash/error reports, so we can fix bugs. Camera access is
requested only when you use the barcode scanner to add a book by ISBN, and
the camera feed is never stored or transmitted — it's used live, on-device,
to read the barcode.

**What we do not collect.** We do not access your contacts, photos (outside
the ISBN scanner's live camera use), location, or browsing history, and we
do not sell your data to anyone.

## Why we collect it

- To provide the core app: syncing your library and notes across your
  devices, offline and online.
- To power the AI Companion, quiz, and flashcard features you choose to use.
- To enforce the free-tier AI usage limit and to unlock Readora Plus features
  once you subscribe.
- To send you optional local reminders (e.g. a daily reading streak nudge) —
  these are scheduled entirely on your device and never involve us seeing
  when you get them.
- To diagnose crashes and bugs.

## Who we share it with

We use a small number of service providers (subprocessors) to run Readora.
None of them may use your data for their own purposes.

| Provider | What it handles |
|---|---|
| Supabase | Database, authentication, and backend hosting for all of the above |
| OpenAI | Generates AI Companion replies, quizzes, and flashcards from your notes |
| RevenueCat | Manages subscription entitlements (Readora Plus) |
| Google Books / Open Library | Public book metadata (title, cover, author) when you search for or add a book — no personal data is sent to them |
| Apple App Store / Google Play | Processes payment for Readora Plus; we never see your payment details |

## How long we keep it

Your data stays until you delete it. Deleting a note, book, or shelf in the
app removes it (this is a "soft delete" for up to 30 days to protect against
accidental deletion, then it's permanently purged). Deleting your account
(Settings → Profile → Delete account) permanently and immediately removes
your account and everything tied to it — library, notes, quizzes, flashcards,
reading history, and subscription record — across every system we control.
This cannot be undone.

## Your rights

You can access, export (on request, email us), correct, or delete your data
at any time. Account deletion is self-service, in-app, and immediate — you
don't need to email us to exercise that right, though you're welcome to.

## Children's privacy

Readora is not directed at children under 13 (or the minimum age required by
your country's law, if higher), and we do not knowingly collect data from
children under that age. If you believe a child has created an account,
contact us and we'll delete it.

## Changes to this policy

If we make a material change to this policy, we'll update the "Last updated"
date above and, where required by law, notify you in-app.

## Contact

Questions about this policy or your data: **hello@readora.app**
