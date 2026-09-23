# BLoC + Clean Architecture Migration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fully replace Riverpod with industrial `flutter_bloc` + domain/data layers, core conventions, Cursor rules, and tests—without putting Flame’s game loop through BLoC.

**Architecture:** Feature-first presentation (`features/*/cubit|bloc/view/game`) over shared `domain/` (entities, repository interfaces, usecases) and `data/` (impls, datasources, future clients). DI via official `MultiRepositoryProvider`. States/events via `freezed`. Flame keeps tick/input; screens dispatch one-shot Bloc events on load/complete/score.

**Tech Stack:** Flutter 3 / Dart ^3.12, `flutter_bloc`, `bloc`, `freezed`, `bloc_test`, `mocktail`, `go_router`, `flame`, `shared_preferences`, Firebase (existing).

## Global Constraints

- Follow spec: `docs/superpowers/specs/2026-09-13-bloc-clean-architecture-design.md`
- Approach 2: feature-first presentation + shared `domain/` + `data/`
- Cubit for simple load/list; Bloc for play sessions (and future auth/leaderboards)
- DI: `RepositoryProvider` / `MultiRepositoryProvider` only — no `get_it`, no Riverpod after cutover
- State/events: `freezed`
- Flame owns game loop; BLoC must not receive per-frame / per-drag updates
- User-facing copy via `AppStrings` as screens are migrated
- Promote widgets to `core/widgets` only when used by 2+ features
- Analyze with timed `dart analyze <changed files>` — never MCP `analyze_files`
- Do not rewrite Zip/Word Match Flame engines beyond thin callback wiring
- Keep existing `path_validator` / `daily_puzzle_generator` tests green
- Commits only when the user asks (skip commit steps unless user explicitly requests commits)

---

## File structure map (create / move)

| Path | Responsibility |
|------|----------------|
| `lib/domain/entities/*` | Pure domain types (migrate from `lib/data/models/*`) |
| `lib/domain/repositories/*.dart` | Abstract repo contracts |
| `lib/domain/usecases/*.dart` | Thin application services |
| `lib/domain/failures.dart` | Shared failure type |
| `lib/data/datasources/*` | Asset / prefs / firestore access |
| `lib/data/repositories/*_impl.dart` | Contract implementations |
| `lib/data/clients/` | Empty placeholder + `.gitkeep` for future auth/leaderboard |
| `lib/core/di/app_repositories.dart` | `MultiRepositoryProvider` list builder |
| `lib/core/strings/app_strings.dart` | Centralized copy |
| `lib/core/bloc/app_bloc_observer.dart` | Debug observer |
| `lib/core/errors/` | Optional mapping helpers |
| `lib/features/home/cubit/*` | Home scores cubit + freezed state |
| `lib/features/zip/bloc/*` | Zip session bloc |
| `lib/features/word_match/cubit/*` | Deck select cubit |
| `lib/features/word_match/bloc/*` | Play session bloc |
| `lib/features/category_race/bloc/*` | Race session bloc |
| `lib/features/results/results_args.dart` | Typed results payload |
| `.cursor/rules/*.mdc` | Architecture + style rules |
| `CLAUDE.md` | Agent layout doc |
| `test/domain/usecases/*` | Usecase unit tests |
| `test/data/repositories/*` | Repo unit tests |
| `test/features/**/cubit|bloc/*` | `bloc_test` suites |
| `test/widget/home_screen_test.dart` | Replaces Riverpod widget test |

**Delete after migration:** `lib/core/providers.dart`, all `flutter_riverpod` imports, orphan `ZipLevelSelectScreen` (unrouted / broken path)—do not port it.

**Flame boundary (explicit):** Keep `onWin` / `onProgress` / `onStatsChanged` callbacks. HUD mirrors (matched count, path length) may use rare callbacks + local `setState` or `ValueNotifier` on the screen—**never** stream every drag cell into Bloc.

---

### Task 1: Packages and codegen setup

**Files:**
- Modify: `pubspec.yaml`
- Create: `analysis_options.yaml` note only if needed (keep existing)
- Test: `flutter pub get` succeeds

**Interfaces:**
- Produces: dependencies available for later tasks

- [ ] **Step 1: Update `pubspec.yaml` dependencies**

Replace Riverpod with BLoC stack:

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  flame: ^1.38.2
  flutter_bloc: ^9.1.1
  bloc: ^9.0.0
  freezed_annotation: ^3.0.0
  go_router: ^18.0.1
  shared_preferences: ^2.5.5
  firebase_core: ^4.14.0
  cloud_firestore: ^6.9.0
  google_fonts: ^8.2.1
  flutter_animate: ^4.5.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
  build_runner: ^2.4.15
  freezed: ^3.0.0
  bloc_test: ^10.0.0
  mocktail: ^1.0.4
```

Remove `flutter_riverpod` entirely. If resolver complains about versions, run `flutter pub add flutter_bloc bloc freezed_annotation` and `flutter pub add --dev build_runner freezed bloc_test mocktail` then delete riverpod.

- [ ] **Step 2: Fetch packages**

Run: `cd /Users/muhammedfaseencm/winklo && flutter pub get`  
Expected: exit 0; lockfile updated; no riverpod.

- [ ] **Step 3: Sanity — existing pure tests still pass**

Run: `flutter test test/path_validator_test.dart test/daily_puzzle_generator_test.dart`  
Expected: all PASS (no DI changes yet).

---

### Task 2: Domain failures + entities

**Files:**
- Create: `lib/domain/failures.dart`
- Create: `lib/domain/entities/cell.dart`, `wall.dart`, `zip_level.dart`, `word_pair.dart`, `word_match_deck.dart`, `word_category.dart`, `high_score.dart` (move content from `lib/data/models/`)
- Modify: update imports in logic/game files after move
- Delete: old `lib/data/models/*` once imports updated (or keep temporary export shims one commit—prefer hard move)

**Interfaces:**
- Produces: entity types used by domain repos/usecases

- [ ] **Step 1: Add failure type**

```dart
// lib/domain/failures.dart
class Failure {
  const Failure(this.message, {this.cause});
  final String message;
  final Object? cause;

  @override
  String toString() => 'Failure($message)';
}
```

- [ ] **Step 2: Move models → entities**

Move each class from `lib/data/models/` into `lib/domain/entities/` keeping APIs identical (`ZipLevel`, `Cell`, `Wall`, `WordPair`, `WordMatchDeck`, `WordCategory`, `HighScore`). Update package imports across `lib/` and `test/`.

- [ ] **Step 3: Run pure tests**

Run: `flutter test test/path_validator_test.dart test/daily_puzzle_generator_test.dart`  
Expected: PASS with updated entity import paths.

---

### Task 3: Domain repository interfaces + score usecases (TDD)

**Files:**
- Create: `lib/domain/repositories/score_repository.dart`
- Create: `lib/domain/repositories/zip_level_repository.dart`
- Create: `lib/domain/repositories/word_match_repository.dart`
- Create: `lib/domain/repositories/category_repository.dart`
- Create: `lib/domain/usecases/get_best_points.dart`, `get_best_time_seconds.dart`, `submit_score.dart`
- Test: `test/domain/usecases/submit_score_test.dart`

**Interfaces:**
- Produces:

```dart
abstract class ScoreRepository {
  int getBestPoints(String modeKey);
  int? getBestTimeSeconds(String modeKey);
  Future<bool> submitScore({
    required String modeKey,
    required int points,
    int? timeSeconds,
  });
}

abstract class ZipLevelRepository {
  Future<List<ZipLevel>> fetchLevels();
}

abstract class WordMatchRepository {
  Future<List<WordMatchDeck>> fetchDecks();
}

abstract class CategoryRepository {
  Future<List<WordCategory>> fetchCategories();
}

class SubmitScore {
  SubmitScore(this._repo);
  final ScoreRepository _repo;
  Future<bool> call({
    required String modeKey,
    required int points,
    int? timeSeconds,
  }) =>
      _repo.submitScore(
        modeKey: modeKey,
        points: points,
        timeSeconds: timeSeconds,
      );
}
```

Same thin pattern for `GetBestPoints` / `GetBestTimeSeconds`.

- [ ] **Step 1: Write failing usecase test**

```dart
// test/domain/usecases/submit_score_test.dart
import 'package:winklo/domain/repositories/score_repository.dart';
import 'package:winklo/domain/usecases/submit_score.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockScoreRepository extends Mock implements ScoreRepository {}

void main() {
  late _MockScoreRepository repo;
  late SubmitScore usecase;

  setUp(() {
    repo = _MockScoreRepository();
    usecase = SubmitScore(repo);
  });

  test('forwards params and returns repository result', () async {
    when(
      () => repo.submitScore(
        modeKey: 'zip_daily',
        points: 900,
        timeSeconds: 12,
      ),
    ).thenAnswer((_) async => true);

    final improved = await usecase(
      modeKey: 'zip_daily',
      points: 900,
      timeSeconds: 12,
    );

    expect(improved, isTrue);
    verify(
      () => repo.submitScore(
        modeKey: 'zip_daily',
        points: 900,
        timeSeconds: 12,
      ),
    ).called(1);
  });
}
```

- [ ] **Step 2: Run test — expect FAIL (missing types)**

Run: `flutter test test/domain/usecases/submit_score_test.dart`  
Expected: FAIL compilation / missing library.

- [ ] **Step 3: Implement interfaces + usecases**

Add the four abstract repos and three score usecases as specified above. Add content usecases:

```dart
// lib/domain/usecases/fetch_zip_levels.dart
class FetchZipLevels {
  FetchZipLevels(this._repo);
  final ZipLevelRepository _repo;
  Future<List<ZipLevel>> call() => _repo.fetchLevels();
}
```

Mirror for `FetchWordMatchDecks`, `FetchCategories`.

- [ ] **Step 4: Run usecase test — expect PASS**

Run: `flutter test test/domain/usecases/submit_score_test.dart`  
Expected: PASS.

---

### Task 4: Data layer — ScoreRepositoryImpl (TDD)

**Files:**
- Create: `lib/data/repositories/score_repository_impl.dart`
- Create: `lib/data/datasources/score_local_datasource.dart` (optional thin wrap; OK to keep prefs inside impl if tiny)
- Move/adapt: existing `lib/data/repositories/score_repository.dart` → impl implementing domain interface
- Test: `test/data/repositories/score_repository_impl_test.dart`

**Interfaces:**
- Consumes: `domain/repositories/score_repository.dart`
- Produces: `ScoreRepositoryImpl implements ScoreRepository`

- [ ] **Step 1: Write failing repo test**

```dart
// test/data/repositories/score_repository_impl_test.dart
import 'package:winklo/data/repositories/score_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('submitScore improves points and time', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final repo = ScoreRepositoryImpl(prefs);

    expect(repo.getBestPoints('zip_x'), 0);
    expect(repo.getBestTimeSeconds('zip_x'), isNull);

    final improved = await repo.submitScore(
      modeKey: 'zip_x',
      points: 100,
      timeSeconds: 20,
    );
    expect(improved, isTrue);
    expect(repo.getBestPoints('zip_x'), 100);
    expect(repo.getBestTimeSeconds('zip_x'), 20);

    final notImproved = await repo.submitScore(
      modeKey: 'zip_x',
      points: 50,
      timeSeconds: 25,
    );
    expect(notImproved, isFalse);
  });
}
```

- [ ] **Step 2: Run — expect FAIL**

Run: `flutter test test/data/repositories/score_repository_impl_test.dart`  
Expected: FAIL missing impl.

- [ ] **Step 3: Implement `ScoreRepositoryImpl`**

Copy logic from current `ScoreRepository` into `ScoreRepositoryImpl implements ScoreRepository`. Delete or re-export old class name only via typedef if needed briefly—prefer delete old concrete class once all call sites use interface/impl.

- [ ] **Step 4: Run — expect PASS**

Run: `flutter test test/data/repositories/score_repository_impl_test.dart`  
Expected: PASS.

---

### Task 5: Data layer — content repositories

**Files:**
- Create: `lib/data/datasources/zip_level_remote_datasource.dart`, `zip_level_asset_datasource.dart` (or one combined datasource per feature if small)
- Create: `lib/data/repositories/zip_level_repository_impl.dart`, `word_match_repository_impl.dart`, `category_repository_impl.dart`
- Adapt existing fetch/Firestore/asset logic into impls implementing domain interfaces
- Create: `lib/data/clients/.gitkeep`
- Test: at least one smoke test that asset fallback works with `firestore: null` / Firebase not ready — e.g. `test/data/repositories/zip_level_repository_impl_test.dart` loading assets (may need `TestWidgetsFlutterBinding` + asset bundle). If asset tests are flaky in unit env, document and test with a injectable `AssetBundle` seam; minimum: constructor accepts optional `FirebaseFirestore?` and private load method unit-tested via package asset load like today.

**Interfaces:**
- Produces: `ZipLevelRepositoryImpl`, `WordMatchRepositoryImpl`, `CategoryRepositoryImpl`

- [ ] **Step 1: Port ZipLevelRepository → Impl**

Keep public behavior of `fetchLevels()` identical. Class must `implements ZipLevelRepository`.

- [ ] **Step 2: Port WordMatch + Category the same way**

- [ ] **Step 3: Add placeholder clients dir**

```bash
mkdir -p lib/data/clients && touch lib/data/clients/.gitkeep
```

- [ ] **Step 4: Quick analyze on new data files**

Run: `dart analyze lib/domain lib/data`  
Expected: no errors (warnings OK if pre-existing unrelated).

---

### Task 6: Core — strings, DI, BlocObserver, app bootstrap (no Riverpod)

**Files:**
- Create: `lib/core/strings/app_strings.dart`
- Create: `lib/core/di/app_repositories.dart`
- Create: `lib/core/bloc/app_bloc_observer.dart`
- Modify: `lib/main.dart`, `lib/app.dart`
- Delete: `lib/core/providers.dart` **after** features no longer import it (if still imported, defer delete to Task 12; prefer creating DI now and migrating features next)

**Interfaces:**
- Produces: `List<SingleChildWidget> buildRepositoryProviders({required SharedPreferences prefs})`

- [ ] **Step 1: Add AppStrings (seed with home/results copy)**

```dart
// lib/core/strings/app_strings.dart
abstract final class AppStrings {
  static const appTitle = 'Zip';
  static const playTodaysZip = "Play today's Zip";
  static const today = 'TODAY';
  static const wordMatch = 'Word Match';
  static const categoryRace = 'Category Race';
  static const zipBrand = 'ZIP';
  // Add more as screens migrate
}
```

- [ ] **Step 2: DI helper**

```dart
// lib/core/di/app_repositories.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
// imports for impls + usecases...

List<RepositoryProvider> buildRepositoryProviders({
  required SharedPreferences prefs,
}) {
  return [
    RepositoryProvider<SharedPreferences>.value(value: prefs),
    RepositoryProvider<ScoreRepository>(
      create: (context) => ScoreRepositoryImpl(context.read<SharedPreferences>()),
    ),
    RepositoryProvider<ZipLevelRepository>(
      create: (_) => ZipLevelRepositoryImpl(),
    ),
    RepositoryProvider<WordMatchRepository>(
      create: (_) => WordMatchRepositoryImpl(),
    ),
    RepositoryProvider<CategoryRepository>(
      create: (_) => CategoryRepositoryImpl(),
    ),
    RepositoryProvider<SubmitScore>(
      create: (context) => SubmitScore(context.read<ScoreRepository>()),
    ),
    RepositoryProvider<GetBestPoints>(
      create: (context) => GetBestPoints(context.read<ScoreRepository>()),
    ),
    RepositoryProvider<GetBestTimeSeconds>(
      create: (context) => GetBestTimeSeconds(context.read<ScoreRepository>()),
    ),
    RepositoryProvider<FetchZipLevels>(
      create: (context) => FetchZipLevels(context.read<ZipLevelRepository>()),
    ),
    RepositoryProvider<FetchWordMatchDecks>(
      create: (context) =>
          FetchWordMatchDecks(context.read<WordMatchRepository>()),
    ),
    RepositoryProvider<FetchCategories>(
      create: (context) => FetchCategories(context.read<CategoryRepository>()),
    ),
  ];
}
```

- [ ] **Step 3: BlocObserver**

```dart
// lib/core/bloc/app_bloc_observer.dart
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';

class AppBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    if (kDebugMode) {
      debugPrint('${bloc.runtimeType} $change');
    }
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    if (kDebugMode) {
      debugPrint('${bloc.runtimeType} $error');
    }
    super.onError(bloc, error, stackTrace);
  }
}
```

- [ ] **Step 4: Rewrite `main.dart` / `app.dart`**

```dart
// main.dart (concept)
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = AppBlocObserver();
  await FirebaseBootstrap.init();
  final prefs = await SharedPreferences.getInstance();
  runApp(
    MultiRepositoryProvider(
      providers: buildRepositoryProviders(prefs: prefs),
      child: const BrainZipApp(),
    ),
  );
}
```

`BrainZipApp` becomes a plain `StatefulWidget` (or `StatelessWidget` holding router) — **not** `ConsumerStatefulWidget`. Keep `MaterialApp.router` + `buildAppTheme()` + `buildRouter()`.

> If features still use Riverpod at this moment, temporarily keep both DI trees only if unavoidable—prefer migrating Home in the same session as bootstrap so the app compiles. Practical order: implement Home Cubit (Task 7) immediately after this bootstrap in the same working tree before running the app.

---

### Task 7: Home Cubit + screen migration (TDD)

**Files:**
- Create: `lib/features/home/cubit/home_state.dart`, `home_cubit.dart`
- Modify: `lib/features/home/home_screen.dart` → `view/home_screen.dart` (move path)
- Update: `lib/core/router/app_router.dart` imports
- Test: `test/features/home/cubit/home_cubit_test.dart`
- Modify: `test/widget_test.dart` → use `MultiRepositoryProvider`

**Interfaces:**
- Consumes: `GetBestPoints`, `GetBestTimeSeconds`, `DailyPuzzleGenerator`
- Produces: `HomeCubit` / `HomeState`

- [ ] **Step 1: Define freezed state + write failing cubit test**

```dart
// lib/features/home/cubit/home_state.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:winklo/domain/entities/zip_level.dart';

part 'home_state.freezed.dart';

@freezed
class HomeState with _$HomeState {
  const factory HomeState({
    required ZipLevel dailyLevel,
    required String dateId,
    @Default(0) int bestPoints,
    int? bestTimeSeconds,
  }) = _HomeState;
}
```

```dart
// test/features/home/cubit/home_cubit_test.dart
import 'package:bloc_test/bloc_test.dart';
import 'package:winklo/domain/usecases/get_best_points.dart';
import 'package:winklo/domain/usecases/get_best_time_seconds.dart';
import 'package:winklo/features/home/cubit/home_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetBestPoints extends Mock implements GetBestPoints {}
class _MockGetBestTime extends Mock implements GetBestTimeSeconds {}

void main() {
  // Use a fixed DateTime in cubit constructor for determinism.
  blocTest<HomeCubit, HomeState>(
    'loads bests for daily mode key',
    build: () {
      final pts = _MockGetBestPoints();
      final time = _MockGetBestTime();
      when(() => pts(any())).thenReturn(42);
      when(() => time(any())).thenReturn(11);
      return HomeCubit(
        getBestPoints: pts,
        getBestTimeSeconds: time,
        now: DateTime.utc(2026, 9, 13),
      );
    },
    act: (c) => c.load(),
    expect: () => [
      isA<HomeState>()
          .having((s) => s.bestPoints, 'pts', 42)
          .having((s) => s.bestTimeSeconds, 'time', 11),
    ],
  );
}
```

- [ ] **Step 2: Run build_runner for freezed**

Run: `dart run build_runner build --delete-conflicting-outputs`  
Expected: `home_state.freezed.dart` generated.

- [ ] **Step 3: Implement `HomeCubit`**

```dart
class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required GetBestPoints getBestPoints,
    required GetBestTimeSeconds getBestTimeSeconds,
    DateTime? now,
  })  : _getBestPoints = getBestPoints,
        _getBestTimeSeconds = getBestTimeSeconds,
        _now = now ?? DateTime.now(),
        super(_initial(now ?? DateTime.now()));

  final GetBestPoints _getBestPoints;
  final GetBestTimeSeconds _getBestTimeSeconds;
  final DateTime _now;

  static HomeState _initial(DateTime now) {
    final day = DateTime(now.year, now.month, now.day);
    final level = DailyPuzzleGenerator.forDate(day);
    return HomeState(dailyLevel: level, dateId: DailyPuzzleGenerator.dateId(day));
  }

  void load() {
    final key = 'zip_${state.dailyLevel.id}';
    emit(state.copyWith(
      bestPoints: _getBestPoints(key),
      bestTimeSeconds: _getBestTimeSeconds(key),
    ));
  }
}
```

- [ ] **Step 4: Migrate `HomeScreen`**

- Use `BlocProvider(create: (c) => HomeCubit(...context.read...)..load(), child: …)`
- Replace `ConsumerWidget` with `StatelessWidget` + `BlocBuilder`
- Replace hardcoded user strings with `AppStrings` where matching
- Provide cubit in router builder or screen `build` top-level

- [ ] **Step 5: Fix widget test**

```dart
await tester.pumpWidget(
  MultiRepositoryProvider(
    providers: buildRepositoryProviders(prefs: prefs),
    child: const BrainZipApp(),
  ),
);
```

Assert same texts via `AppStrings` constants.

- [ ] **Step 6: Run tests**

Run: `flutter test test/features/home/cubit/home_cubit_test.dart test/widget_test.dart`  
Expected: PASS.

---

### Task 8: Zip play Bloc + screen (Flame callbacks preserved)

**Files:**
- Create: `lib/features/zip/bloc/zip_event.dart`, `zip_state.dart`, `zip_bloc.dart`
- Modify: `lib/features/zip/zip_screen.dart` → `view/zip_screen.dart`
- Keep: `game/zip_game.dart`, `logic/*` unchanged except imports
- Test: `test/features/zip/bloc/zip_bloc_test.dart`
- Delete: `zip_level_select_screen.dart` (orphan)

**Interfaces:**
- Events: `ZipStarted`, `ZipCompleted(points, timeSeconds)` (and optional `ZipResetUi` if needed)
- State: `level`, `finished`, `status` (initial/ready/submitting/navigating), `improved?`
- Consumes: `SubmitScore`
- Flame: still constructed in the view; `onWin: (p,t) => context.read<ZipBloc>().add(ZipCompleted(...))`

- [ ] **Step 1: Write `blocTest` for complete → submit**

Mock `SubmitScore`; on `ZipCompleted` expect state with `improved: true` and status ready for navigation. Use `BlocListener` in UI for `pushReplacement`.

- [ ] **Step 2: generate freezed + implement ZipBloc**

Load daily level in `ZipStarted` / constructor (same `DailyPuzzleGenerator` as today). Do **not** put path cells in state.

- [ ] **Step 3: Migrate ZipScreen**

- `BlocProvider` at page
- Local UI only for FlameWidget + undo/clear calling `_game` methods
- Empty `setState` after undo/clear is acceptable for button enablement OR read `path.isNotEmpty` via a tiny `ValueNotifier` on the game—do not add path to Bloc
- On listener navigation, pass typed `ResultsArgs` if Task 11 done; else keep map temporarily

- [ ] **Step 4: Delete orphan level select screen + fix any imports**

- [ ] **Step 5: Run**

Run: `flutter test test/features/zip/bloc/zip_bloc_test.dart test/path_validator_test.dart`  
Expected: PASS.

---

### Task 9: Word Match — select Cubit + play Bloc

**Files:**
- Create: `features/word_match/cubit/word_match_select_*.dart`
- Create: `features/word_match/bloc/word_match_*.dart`
- Move views under `view/`
- Keep `game/word_match_game.dart`
- Tests: select cubit + play bloc

**Rules:**
- Select Cubit: `FetchWordMatchDecks` + best points per deck
- Play Bloc: load deck by id via usecase/repo; own **countdown timer** with cancellable subscription in `close()` (replace screen `async while`); on Flame `onWin` → submit score; on timeout → fail navigation without submit (preserve current behavior)
- Progress HUD (`matched/total`) may stay as local state from `onProgress` callback

- [ ] **Step 1: TDD select cubit load success/failure**
- [ ] **Step 2: Implement select cubit + migrate select screen**
- [ ] **Step 3: TDD play bloc timer tick + complete submit**
- [ ] **Step 4: Implement play bloc; migrate play screen; wire Flame `onWin` only into bloc**
- [ ] **Step 5: `flutter test` for both new test files**

---

### Task 10: Category Race Bloc

**Files:**
- Create: `features/category_race/bloc/*`
- Move: `category_race_screen.dart` → `view/`
- Test: `test/features/category_race/bloc/category_race_bloc_test.dart`

**Rules:**
- Bloc loads categories (`FetchCategories`), picks category/letter (inject `Random` for tests)
- Timer subscription in bloc (cancel on close)
- Answer validation can live in bloc events `AnswerSubmitted(String)` emitting feedback—**this is not Flame**; OK in Bloc
- Finish → `SubmitScore` with `modeKey: 'race_${id}'`

- [ ] **Step 1: Write bloc tests for valid/invalid answer + finish improved**
- [ ] **Step 2: Implement bloc + migrate screen to `BlocBuilder`/`BlocListener`
- [ ] **Step 3: Run category race bloc tests

---

### Task 11: Typed ResultsArgs + Results view

**Files:**
- Create: `lib/features/results/results_args.dart`
- Modify: `results_screen.dart`, router, all navigators from Zip/WordMatch/CategoryRace

```dart
class ResultsArgs {
  const ResultsArgs({
    required this.title,
    required this.subtitle,
    required this.timeSeconds,
    required this.improved,
    this.points,
    this.replayDaily = false,
    this.replayLevelId,
    this.nextLevelId,
  });

  final String title;
  final String subtitle;
  final int timeSeconds;
  final bool improved;
  final int? points;
  final bool replayDaily;
  final String? replayLevelId;
  final String? nextLevelId;
}
```

Router: `extra is ResultsArgs ? extra : fallback`.

- [ ] **Step 1: Add ResultsArgs + update ResultsScreen**
- [ ] **Step 2: Update all `pushReplacement('/results', extra: …)` call sites
- [ ] **Step 3: Manual compile check / analyze results + callers

---

### Task 12: Remove Riverpod + dead code + import sweep

**Files:**
- Delete: `lib/core/providers.dart`
- Modify: `pubspec.yaml` ensure no riverpod
- Grep purge: `flutter_riverpod`, `ConsumerWidget`, `ref.watch`, `ProviderScope`

- [ ] **Step 1: `rg "riverpod|ConsumerWidget|ProviderScope|ref\\.watch|ref\\.read" lib test`**

Expected: no matches (except maybe comments—remove those too).

- [ ] **Step 2: `flutter pub get && dart analyze lib`**

Expected: no errors related to missing providers.

- [ ] **Step 3: Full test run**

Run: `flutter test`  
Expected: all PASS.

---

### Task 13: Cursor rules + CLAUDE.md

**Files:**
- Create: `.cursor/rules/bloc-architecture.mdc`
- Create: `.cursor/rules/code-style.mdc` (from unnati)
- Create: `.cursor/rules/dart-style.mdc` (from unnati)
- Create: `.cursor/rules/app-strings.mdc`
- Create: `.cursor/rules/shared-widgets.mdc`
- Create: `CLAUDE.md` (restaurant_app-style layout doc pointing at domain/data/features + Flame rule)

- [ ] **Step 1: Write `bloc-architecture.mdc`** covering: feature-first; domain no Flutter UI; Cubit vs Bloc; RepositoryProvider; freezed; usecases; Flame one-shot callbacks only; tests with bloc_test/mocktail
- [ ] **Step 2: Port code-style + dart-style from unnati (adapt paths)
- [ ] **Step 3: strings + shared-widgets rules
- [ ] **Step 4: Write `CLAUDE.md` tree matching final `lib/`

---

### Task 14: Final verification

- [ ] **Step 1: `flutter test`**
- [ ] **Step 2: `dart analyze lib test`** (timed shell; scoped if slow)
- [ ] **Step 3: Smoke-run app (home → zip → results) manually or via existing launch config
- [ ] **Step 4: Confirm success criteria from design §13**

Checklist:
- [ ] No `flutter_riverpod`
- [ ] Domain has no Flutter widget imports (`rg "package:flutter/" lib/domain` → empty)
- [ ] Flame games unchanged in tick/input ownership
- [ ] Tests: usecases, score repo, home cubit, zip/word_match/category blocs, widget home, logic tests
- [ ] Rules + `CLAUDE.md` present

---

## Self-review (plan vs spec)

| Spec requirement | Task coverage |
|------------------|---------------|
| Approach 2 domain/data/features | Tasks 2–5, 7–10 |
| RepositoryProvider DI | Task 6 |
| freezed | Tasks 7–10 |
| Cubit vs Bloc mapping | Tasks 7–10 |
| Full Riverpod cutover | Tasks 6–12 |
| Flame performance boundary | Tasks 8–9 notes + Global Constraints |
| AppStrings / core conventions | Tasks 6, 13 |
| Cursor rules + CLAUDE.md | Task 13 |
| Tests (usecase/repo/bloc/widget) | Tasks 3–4, 7–10, 14 |
| Future auth/leaderboards ready | `data/clients/`, domain repo pattern, MultiRepositoryProvider extension |

No TBD placeholders. Commit steps omitted unless user requests commits (global constraint).
