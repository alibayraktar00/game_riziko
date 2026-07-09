# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Riziko is a Flutter team-based trivia/quiz game (Turkish/English) built with Riverpod and a
Clean Architecture layering: `core/` (router, theme, localization, shared icon/color mappings),
`domain/` (entities + repository interfaces), `data/` (models + repository implementations),
`presentation/` (screens, widgets, Riverpod providers), `services/` (answer evaluation, audio,
timers, speech-to-text, QR, settings — stateful helpers that aren't full repositories).

## Commands

```bash
flutter pub get                        # install dependencies
flutter run                            # run on a connected device/emulator
flutter analyze                        # static analysis (must be clean before committing)
flutter test                           # run the whole test suite (test/*.dart)
flutter test test/some_test.dart       # run a single test file
flutter test --plain-name "test name"  # run a single test by name
```

Gemini-backed AI question generation requires an API key at run/build time (free key from
https://aistudio.google.com/apikey):
```bash
flutter run --dart-define=GEMINI_API_KEY=xxxxx
```
Without it, `AiQuestionService.generateForSlot` returns `[]` and the app silently falls back to
the static question bank — this is intentional, not an error path to "fix".

To (re)seed the static question bank into the Firestore `questions_pool` collection (idempotent,
keyed by question id):
```bash
flutter run -d chrome -t lib/tools/seed_questions.dart
```

## Architecture notes

### Question sourcing is a 3-tier fallback, and order matters
`QuestionRepositoryImpl.getQuestions()` (`lib/data/repositories/question_repository_impl.dart`)
concatenates three sources in this exact order: **pooled** (Firestore `questions_pool`, backed by
Gemini generation via `QuestionPoolRepositoryImpl`) → **static** (hardcoded `_buildQuestions()` in
the same file) → **custom** (user-authored, persisted in `SharedPreferences` via
`CustomContentService`). `GameNotifier.startGame`/`startGameWithCategories`
(`lib/presentation/providers/game_provider.dart`) then dedups to one question per
`(category, difficulty)` pair, keeping the *first* match — so pooled/AI questions are preferred
over static ones only because of this ordering, not because of any explicit priority field.

`QuestionPoolRepositoryImpl` gates pooled questions behind a `promptVersion` constant and a
`_isCurrentQuality` check (known category name, ≥3 distractors per language). Records that fail
the check are used once and then deleted in the background (`unawaited(_deleteStale(...))`) so
the pool self-heals after a prompt/quality revision — bump `promptVersion` when changing the
Gemini prompt so old rows get invalidated.

### Category name normalization is load-bearing
Category strings reach the app from four independently-cased sources (static bank uses exact
`AiQuestionService.categories` casing like `"Science"`; the AI pool writes that same casing;
custom/legacy Firestore data can be arbitrary user-typed text). Any code that compares or
deduplicates categories **must** normalize with `category.trim().toLowerCase()` first — this has
been the source of real bugs (categories silently vanishing from a filtered list, "ghost"
duplicate entries in pickers) and is not just defensive style. See `_normalizeCategory` in
`game_provider.dart` and the dedup loops in `category_picker_screen.dart` /
`category_selection_screen.dart` for the established pattern. Display labels go through
`AppLocalizations.translate(category.toLowerCase())` — the *translated* label (e.g. `"BİLİM"`) is
never the value stored in `selectedCategories` or compared against; the underlying `category`
field always is.

### Local game vs. multiplayer game share one entity, two very different code paths
`GameSession` (`lib/domain/entities/game_session.dart`) is used both for the single-device local
game (`gameProvider` / `GameNotifier`, pure in-memory Riverpod state, no network) and for
multiplayer sessions synced over **Firebase Realtime Database** (`GameSessionRepository` →
`RealtimeGameSessionRepository`, driven through `MultiplayerService` /
`lib/presentation/providers/multiplayer_provider.dart`). Multiplayer join flow: host creates a
session + QR code in `AdminScreen` → other devices scan it in `QRScanScreen` → `NicknameScreen` →
`WaitingScreen` polls/streams the session until the host starts it. The `/game/:gameCode` route in
`app_router.dart` is still a placeholder ("Coming Soon") — the multiplayer in-game screen isn't
wired up yet.

### Firebase is only really configured for Android
`lib/core/firebase_options.dart` has one real, registered `FirebaseOptions` (Android). The `iOS`
and `web` branches of `currentPlatform` currently reuse the Android options as a placeholder — the
file's own comment flags this. Practically: `flutter run -d chrome` will hang forever at
`Firebase.initializeApp()` in `main()` with no thrown error, because the web app was never
registered with that Firebase project. Don't spend time debugging a blank/black web screen as if
it were an app bug without checking this first; either run on Android or run `flutterfire
configure` to add a real web app.

### Routing
Single flat `go_router` table in `lib/core/router/app_router.dart`. Screens that need
non-primitive data (category name, category+difficulty pair) receive it via `state.extra`, cast
with `as` and no null-check — the router assumes every caller passes the right shape. When adding
a route that takes `extra`, follow the existing unchecked-cast pattern rather than introducing a
new convention.

### Theming and shared widgets
`lib/core/theme/app_theme.dart` defines three `RizikoTheme` presets (`neon`, `royal`, `cyber`) plus
shared design tokens (`AppSpacing`, `AppRadius`, `AppGlass`) — use these tokens instead of literal
padding/radius values so screens don't drift apart. `neon` is the default
(`SettingsService.getThemeMode()`) and the only one actually exercised: `ThemeNotifier.setTheme()`
exists but nothing in the UI currently calls it, so `royal`/`cyber` are reachable only by manually
setting the `theme_mode` preference.

Shared "frosted card" visuals go through `GlassCard` + `CyberHudPainter` (corner-bracket/dot-grid
overlay) rather than being hand-rolled per screen — `CategoryTile`
(`lib/presentation/widgets/category_tile.dart`) is the current reference implementation of that
pattern for a tappable, per-category-colored row. Category → icon/color mapping lives in
`lib/core/category_icons.dart` and is matched by *substring* on the lowercased category name (not
exact match), so new categories should extend those `if` chains carefully to avoid accidental
substring collisions.

### Localization
Custom hand-rolled `AppLocalizations` (`lib/core/localization/app_localizations.dart`), not
`flutter gen-l10n`. `translate(key)` falls back to returning the key itself if the locale or key is
missing — a missing translation shows as a raw key string, not a crash. Default locale is `'tr'`
(`SettingsService.getLocaleCode()`).

### Audio
`AudioService` (`lib/services/audio_service.dart`) plays bundled local assets under
`assets/sounds/` (not remote URLs). Licensing/attribution per file is tracked in
`assets/sounds/NOTICE.md` — check it before swapping or adding a sound asset, since some sources
(e.g. Mixkit's *music* license) explicitly disallow use in games even though their *sound effects*
license allows it.

## Testing patterns

Widget tests that need `questionsProvider` or other Firebase-backed providers should override them
directly at the `ProviderContainer`/`ProviderScope` level rather than exercising real
Firebase/Firestore calls (there's no Firebase emulator or mocking setup in this repo). See
`test/category_picker_screen_test.dart` for the established pattern: `SharedPreferences
.setMockInitialValues({})` + override `sharedPreferencesProvider` and `questionsProvider`, wrap in
`UncontrolledProviderScope`, and give `go_router` real placeholder routes for any screen the test
navigates to (`context.go(...)` throws if the target route isn't registered). Rows inside a
scrollable list may be off-screen at the test surface's default size — call
`tester.ensureVisible(finder)` before `tester.tap(finder)`.
