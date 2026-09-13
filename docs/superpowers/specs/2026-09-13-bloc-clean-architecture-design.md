# Brain Zip — BLoC + Clean Architecture Migration Design

**Date:** 2026-09-13  
**Status:** Approved (design sections §1–§3)  
**Scope:** Full cutover from Riverpod to industrial BLoC architecture, with domain/data layers, core conventions, Cursor rules, and tests. Game-loop performance must not regress.

---

## 1. Goals

1. Replace **Riverpod** with **`flutter_bloc`** as the sole app-level state management.
2. Adopt **official BLoC feature-first** presentation layout plus a **clean-architecture domain/data** split (Approach 2).
3. Pull **unnati / restaurant_app** conventions into `core` (strings, theme, shared widgets, DI bootstrap, Cursor rules).
4. Structure the codebase so **future games, auth, and leaderboards** plug in without rewriting DI or folder conventions.
5. Keep **Flame** responsible for in-game tick/input/render — BLoC must not sit on the frame loop.
6. Ship a **test suite**: usecases, repositories, bloc/cubit (`bloc_test`), keep existing pure-logic tests, update widget smoke tests.

### Non-goals (this pass)

- Implementing real auth or leaderboard product features (folders/contracts may be reserved; no full product UI).
- Rewriting Flame game engines or puzzle algorithms.
- Introducing `get_it` / `injectable` (explicitly rejected in favor of official `RepositoryProvider`).
- Full i18n / `gen-l10n` (use centralized `AppStrings` for now).

---

## 2. Decisions (locked)

| Topic | Choice |
|-------|--------|
| Folder architecture | Feature-first presentation + shared `domain/` + `data/` (Approach 2) |
| Cubit vs Bloc | Cubit for simple load/list screens; Bloc for multi-step play sessions (and future auth/leaderboards) |
| DI | `MultiRepositoryProvider` / `RepositoryProvider` (official BLoC) |
| State/event modeling | **`freezed`** |
| Migration scope | Full Riverpod removal + restructure in one pass |
| Flame ↔ BLoC | Flame owns game loop; BLoC owns screen lifecycle (load, shell, score submit, navigation) |
| Navigation | Keep **`go_router`** |
| Tests | Required: usecase, repo, bloc/cubit, widget smoke; keep logic unit tests |

---

## 3. Target folder tree

```text
lib/
  main.dart
  app.dart
  firebase_options.dart

  core/
    di/                 # helpers to build MultiRepositoryProvider tree
    theme/              # AppTheme (existing, relocated/kept)
    widgets/            # shared UI only if used by 2+ features
    strings/            # AppStrings — centralized user-facing copy
    router/             # go_router
    errors/             # Failure / AppException mapping
    firebase/           # bootstrap
    bloc/               # AppBlocObserver

  domain/               # pure Dart — no Flutter widget imports
    entities/
    repositories/       # abstract interfaces
    usecases/

  data/
    models/             # DTO / JSON → map to entities
    datasources/        # assets, SharedPreferences, Firestore
    clients/            # reserved for future Auth/Leaderboard HTTP or SDK clients
    repositories/       # *RepositoryImpl

  features/
    home/
      cubit/
      view/
      widgets/
    zip/
      bloc/
      view/
      widgets/
      game/             # Flame (performance-critical)
      logic/            # pure validators/generators
    word_match/
      bloc/ | cubit/
      view/
      widgets/
      game/
    category_race/
      bloc/
      view/
      widgets/
    results/
      view/
    # later: auth/, leaderboard/

test/
  domain/usecases/
  data/repositories/
  features/<feature>/(bloc|cubit)/
  features/zip/logic/          # existing path_validator, daily_puzzle_generator
  widget/
```

### Placement rules

- **Domain** never imports Flutter UI, Flame, or `data/`.
- **Presentation** (features) depends on **usecases** (preferred) or domain repository interfaces — never datasources/clients directly.
- **Data** implements domain repository contracts; maps models → entities.
- Feature-local widgets stay under `features/<f>/widgets/`. Promote to `core/widgets` only when used by **2+** features.
- User-facing strings go through `core/strings` (`AppStrings`), not ad-hoc literals in new/migrated UI (migrate existing copy as screens are touched).

---

## 4. Packages

### Add

- `flutter_bloc`, `bloc`
- `freezed_annotation`
- `equatable` (optional companion; freezed often sufficient alone — use freezed equality)
- Dev: `build_runner`, `freezed`, `bloc_test`, `mocktail`

### Remove

- `flutter_riverpod` (and delete `lib/core/providers.dart`)

### Keep

- `go_router`, `flame`, `shared_preferences`, `firebase_core`, `cloud_firestore`, `google_fonts`, `flutter_animate`, `cupertino_icons`

---

## 5. Dependency injection & bootstrap

```text
main()
  → WidgetsFlutterBinding
  → FirebaseBootstrap
  → SharedPreferences.getInstance()
  → runApp(
       MultiRepositoryProvider(
         providers: [
           RepositoryProvider<SharedPreferences>.value(value: prefs),
           RepositoryProvider<ScoreRepository>(create: … ScoreRepositoryImpl …),
           RepositoryProvider<ZipLevelRepository>(…),
           RepositoryProvider<WordMatchRepository>(…),
           RepositoryProvider<CategoryRepository>(…),
           // UseCases as RepositoryProvider<UseCase> OR constructed in BlocProvider
           …
         ],
         child: BlocProvider optional globals,
         child: BrainZipApp (MaterialApp.router),
       ),
     )
```

- Provide **domain interfaces** as the `RepositoryProvider` types; create **impl** instances.
- Feature pages create `BlocProvider` / `Cubit` in the page (or router `builder`), reading deps via `context.read<T>()`.
- Register `Bloc.observer = AppBlocObserver()` in debug/profile as needed.
- **No** `ProviderScope`, **no** `get_it`.

### Future auth / leaderboards

Add `AuthRepository` / `LeaderboardRepository` (+ clients under `data/clients/`) to the same `MultiRepositoryProvider` tree and new feature folders — no DI paradigm change.

---

## 6. Data flow

```text
UI / Flame completion callback
  → bloc.add(Event) or cubit.method()
  → UseCase(params)
  → Repository (abstract)
  → Datasource / Client
  → Entity
  → freezed State emit
  → BlocBuilder / BlocListener / BlocConsumer
```

**Error handling:** map failures in data/usecase layer to domain `Failure` (or typed results). States carry error via freezed variants. Screens own snackbars/dialogs (`BuildContext`), matching restaurant_app controller/screen split adapted to BLoC.

---

## 7. Feature → Cubit/Bloc mapping

| Feature | Type | Responsibility |
|---------|------|----------------|
| Home | Cubit | High scores / home CTAs load |
| Zip level select (if retained) | Cubit | Levels list load |
| Zip play | Bloc | Load daily/level, session shell, submit score, navigate results |
| Word Match select | Cubit | Decks + scores load |
| Word Match play | Bloc | Load deck, submit score |
| Category Race | Bloc | Load categories, submit score |
| Results | View-only (route `extra`) for now | Optional Cubit later |
| Auth / Leaderboard (future) | Bloc | Session, ranks, submit remote |

### Flame boundary (non-negotiable)

- Flame engines remain under `features/*/game/`.
- BLoC/Cubit must **not** receive per-frame or per-drag updates.
- On win/lose/complete, the screen (or a thin adapter) dispatches a **one-shot** event to Bloc/Cubit.
- Existing pure logic (`path_validator`, `daily_puzzle_generator`) stays outside BLoC and remains unit-tested.

---

## 8. Freezed conventions

- Events and states are `@freezed` sealed unions.
- Prefer explicit variants: `initial`, `loading`, `success(...)`, `failure(...)` (names may vary per feature but pattern is consistent).
- Run `dart run build_runner build --delete-conflicting-outputs` after model changes.
- Generated `*.freezed.dart` are committed (or follow repo preference; default: commit generated files for simpler CI on this app).

---

## 9. Testing strategy

| Layer | Tooling | What |
|-------|---------|------|
| Use cases | `mocktail` + `flutter_test` | Success/failure paths with mocked repos |
| Repository impls | `flutter_test` + fake prefs/assets where practical | Score submit improve/not; list loads |
| Cubit/Bloc | `bloc_test` | Load success/failure; submit score |
| Pure game logic | existing tests | Keep `path_validator_test`, `daily_puzzle_generator_test` |
| Widget smoke | `flutter_test` | Home (and optionally one shell) under `MultiRepositoryProvider` + fakes |
| Flame frame loops | **Out of scope** | Too brittle; cover via logic + Bloc edges |

Replace Riverpod overrides in `test/widget_test.dart` with repository fakes.

---

## 10. Cursor rules & agent docs

Create under `.cursor/rules/`:

1. **`bloc-architecture.mdc`** (always apply or `lib/**`) — feature-first + domain/data; no UI in domain; Cubit vs Bloc guidance; Flame boundary; RepositoryProvider DI; freezed; usecases between UI and repos.
2. **`code-style.mdc`** — ported from unnati (formatting, naming, small functions, import grouping, no dead code).
3. **`dart-style.mdc`** — `final`/`const`, prefer named params, extract widgets not Widget-returning helpers, avoid bang, await futures.
4. **`app-strings.mdc`** — user-facing copy via `AppStrings`.
5. **`shared-widgets.mdc`** — promote to `core/widgets` only when used by 2+ features.

Also add a short root **`CLAUDE.md`** (restaurant_app style) documenting the `lib/` layout and state-management conventions for future agents.

Keep existing global rule: timed `dart analyze` on changed files; never hang on MCP `analyze_files`.

---

## 11. Migration plan (high level)

1. Add packages; configure `freezed` / `build_runner`.
2. Introduce `domain` entities, repository interfaces, usecases (thin wrappers over current repo methods first).
3. Move/adapt current repos into `data/repositories/*Impl` + datasources; map models → entities.
4. Add `core/strings`, `core/errors`, `core/di`, `AppBlocObserver`; relocate theme/widgets as needed.
5. Wire `MultiRepositoryProvider` in `main`/`app`; remove Riverpod.
6. Migrate features one by one: Home Cubit → Zip → Word Match → Category Race → Results; update router providers.
7. Add/adjust tests per layer; fix widget smoke.
8. Add Cursor rules + `CLAUDE.md`.
9. Verify: `flutter test`, scoped `dart analyze` on touched paths.

Behavior and visuals of existing games should remain equivalent; this is an architecture migration, not a UX redesign.

---

## 12. Risks & mitigations

| Risk | Mitigation |
|------|------------|
| Freezed/codegen friction | Document build_runner command; commit generated files |
| Over-abstraction (usecases too thin) | Allow 1:1 usecases initially; merge only if noise becomes clear later — do not skip domain contracts |
| Accidental BLoC-on-frame-loop | Cursor rule + code review; Flame callbacks only on completion |
| Large PR | Single cutover still preferred while app is small; commit in logical chunks during implementation |

---

## 13. Success criteria

- [ ] No `flutter_riverpod` dependency or imports remain.
- [ ] Folder tree matches §3; domain has no Flutter UI imports.
- [ ] All current screens work via Cubit/Bloc + RepositoryProvider.
- [ ] Flame games feel unchanged (no tick-through-BLoC).
- [ ] `bloc_test` coverage for primary Cubits/Blocs; usecase + repo tests for scores/lists; widget Home smoke green.
- [ ] Cursor rules + `CLAUDE.md` present and accurate.
- [ ] `flutter test` passes; scoped analyze clean on changed files.
