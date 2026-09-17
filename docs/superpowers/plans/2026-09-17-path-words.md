# Path Words Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship Path Words — a daily 8×8 word-path puzzle (near–LinkedIn Wend parity) with seeded generation, Flame grid, Bloc-owned play state, undo/hint/reset, and Zip-style score/streak/results.

**Architecture:** Feature `path_words` with `PathWordsBloc` as source of truth; thin `PathWordsGame` (Flame) renders a `PathWordsBoardView` and forwards cell gestures. Domain owns entities, path rules, and seeded generator; data loads a bundled English word list. Reuse `SubmitScore`, `RecordDailyClear`, and `/results`.

**Tech Stack:** Flutter 3 / Dart ^3.12, `flutter_bloc`, `freezed`, `bloc_test`, `mocktail`, `flame`, `go_router`, existing Zip UI chrome (`ZipAtmosphere`, etc.).

## Global Constraints

- Follow spec: `docs/superpowers/specs/2026-09-17-path-words-design.md`
- Feature folder: `lib/features/path_words/`
- Product name in UI: **Path Words** (all copy via `AppStrings`)
- Grid: fixed **8×8**; orthogonal moves only; full cell partition
- Word lengths: **4–10** inclusive
- Hints: **3** per puzzle; undo affects **active path only**
- Timer starts when status becomes **`ready`**; reset does **not** reset timer
- Scoring: `(1000 - elapsedSeconds * 5).clamp(50, 1000)`; modeKey `path_words_<dateId>`
- `GameIds.pathWords = 'path_words'`
- Flame must not own undo/hints/win/score; Bloc may receive gesture cell events (this feature intentionally differs from Zip’s “no per-drag Bloc” rule)
- Analyze with timed `dart analyze <changed files>` — never MCP `analyze_files`
- Run `dart format` on touched Dart files
- Commits only when the user asks (skip commit steps unless explicitly requested)

---

## File structure map

| Path | Responsibility |
|------|----------------|
| `lib/domain/entities/path_words_puzzle.dart` | `PathWordsPuzzle`, `PathWordsTarget` |
| `lib/domain/game_ids.dart` | Add `pathWords` |
| `lib/domain/repositories/word_list_repository.dart` | Load/filter English words |
| `lib/domain/path_words/path_words_rules.dart` | Pure path extend / complete / locked cells |
| `lib/domain/path_words/path_words_generator.dart` | Seeded daily packer |
| `lib/domain/path_words/path_words_scoring.dart` | Points helper |
| `lib/domain/usecases/generate_daily_path_words.dart` | Load words → generate puzzle |
| `lib/data/repositories/word_list_repository_impl.dart` | Asset load + cache |
| `assets/words/en_words.txt` | Bundled lowercase word list |
| `lib/features/path_words/bloc/*` | Events, state, bloc |
| `lib/features/path_words/game/path_words_board_view.dart` | Immutable render model |
| `lib/features/path_words/game/path_words_game.dart` | Flame draw + gestures |
| `lib/features/path_words/view/path_words_screen.dart` | Screen + chrome |
| `lib/features/path_words/view/widgets/*` | Word list, how-to-play |
| `lib/core/strings/app_strings.dart` | Path Words copy |
| `lib/core/router/app_router.dart` | `/path-words` |
| `lib/core/di/app_repositories.dart` | Word list + generate usecase |
| `lib/features/home/view/home_screen.dart` | Entry to Path Words |
| `pubspec.yaml` | Register `assets/words/en_words.txt` (or folder) |
| `test/domain/path_words/*` | Rules + generator tests |
| `test/data/repositories/word_list_repository_impl_test.dart` | Repo test (optional fixture) |
| `test/features/path_words/bloc/path_words_bloc_test.dart` | `bloc_test` suite |

---

### Task 1: Domain entities + GameIds

**Files:**
- Create: `lib/domain/entities/path_words_puzzle.dart`
- Modify: `lib/domain/game_ids.dart`
- Test: `test/domain/path_words/path_words_puzzle_test.dart`

**Interfaces:**
- Produces:
  - `class PathWordsTarget { String id; String word; Cell start; List<Cell> path; int colorIndex; }`
  - `class PathWordsPuzzle { String id; DateTime day; int size; List<String> letters; /* length size*size, row-major */ List<PathWordsTarget> targets; String letterAt(Cell c); }`
  - `GameIds.pathWords == 'path_words'`

- [ ] **Step 1: Write the failing entity test**

```dart
import 'package:brain_zip/domain/entities/cell.dart';
import 'package:brain_zip/domain/entities/path_words_puzzle.dart';
import 'package:brain_zip/domain/game_ids.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('GameIds.pathWords is path_words', () {
    expect(GameIds.pathWords, 'path_words');
  });

  test('letterAt reads row-major grid', () {
    final puzzle = PathWordsPuzzle(
      id: 'path_words_20260917',
      day: DateTime(2026, 9, 17),
      size: 2,
      letters: const ['a', 'b', 'c', 'd'],
      targets: [
        PathWordsTarget(
          id: 't0',
          word: 'ab',
          start: const Cell(0, 0),
          path: const [Cell(0, 0), Cell(0, 1)],
          colorIndex: 0,
        ),
      ],
    );
    expect(puzzle.letterAt(const Cell(1, 0)), 'c');
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/domain/path_words/path_words_puzzle_test.dart`  
Expected: FAIL (library/type not found)

- [ ] **Step 3: Implement entities + GameIds**

`lib/domain/game_ids.dart`:

```dart
abstract final class GameIds {
  static const zip = 'zip';
  static const pathWords = 'path_words';
}
```

`lib/domain/entities/path_words_puzzle.dart`:

```dart
import 'cell.dart';

class PathWordsTarget {
  const PathWordsTarget({
    required this.id,
    required this.word,
    required this.start,
    required this.path,
    required this.colorIndex,
  });

  final String id;
  final String word;
  final Cell start;
  final List<Cell> path;
  final int colorIndex;
}

class PathWordsPuzzle {
  const PathWordsPuzzle({
    required this.id,
    required this.day,
    required this.size,
    required this.letters,
    required this.targets,
  });

  final String id;
  final DateTime day;
  final int size;
  /// Row-major, length `size * size`, lowercase letters.
  final List<String> letters;
  final List<PathWordsTarget> targets;

  String letterAt(Cell cell) => letters[cell.row * size + cell.col];
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/domain/path_words/path_words_puzzle_test.dart`  
Expected: PASS

- [ ] **Step 5: Commit** (only if user asked)

```bash
git add lib/domain/entities/path_words_puzzle.dart lib/domain/game_ids.dart test/domain/path_words/path_words_puzzle_test.dart
git commit -m "feat(path_words): add puzzle entities and game id"
```

---

### Task 2: Word list repository + asset

**Files:**
- Create: `assets/words/en_words.txt`
- Create: `lib/domain/repositories/word_list_repository.dart`
- Create: `lib/data/repositories/word_list_repository_impl.dart`
- Modify: `pubspec.yaml` (assets)
- Modify: `lib/core/di/app_repositories.dart`
- Test: `test/domain/path_words/word_list_filter_test.dart` (pure filter helper) and/or repo test with `TestWidgetsFlutterBinding` + asset bundle

**Interfaces:**
- Produces:
  - `abstract class WordListRepository { Future<List<String>> loadEnglishWords({int minLen = 4, int maxLen = 10}); }`
  - Impl caches after first load; returns lowercase alphabetic words only in `[minLen, maxLen]`
  - Asset path: `assets/words/en_words.txt` (one word per line)

- [ ] **Step 1: Add a real word list asset**

Create `assets/words/en_words.txt` with **at least 400** common lowercase English words of length 4–10 (enough of each length 4..10 for the generator). Include duplicates-free lines. Example starter lines (expand substantially in the real file):

```text
pump
group
disrupt
cupboard
puppeteer
population
path
words
board
letter
snake
grid
daily
puzzle
...
```

Prefer generating/curating a solid list in-repo rather than downloading at runtime.

- [ ] **Step 2: Register asset in `pubspec.yaml`**

Under `flutter: assets:`, add:

```yaml
    - assets/words/en_words.txt
```

(Keep existing `assets/words/categories/` entry.)

- [ ] **Step 3: Write repository interface + failing load test**

```dart
// lib/domain/repositories/word_list_repository.dart
abstract class WordListRepository {
  Future<List<String>> loadEnglishWords({int minLen = 4, int maxLen = 10});
}
```

Test (`test/data/repositories/word_list_repository_impl_test.dart`):

```dart
import 'package:brain_zip/data/repositories/word_list_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads and filters 4–10 letter words', () async {
    final repo = WordListRepositoryImpl();
    final words = await repo.loadEnglishWords();
    expect(words, isNotEmpty);
    expect(words.every((w) => w.length >= 4 && w.length <= 10), isTrue);
    expect(words.every((w) => w == w.toLowerCase()), isTrue);
  });
}
```

- [ ] **Step 4: Run test — expect FAIL**

Run: `flutter test test/data/repositories/word_list_repository_impl_test.dart`  
Expected: FAIL (impl missing)

- [ ] **Step 5: Implement `WordListRepositoryImpl`**

```dart
import 'package:flutter/services.dart';

import '../../domain/repositories/word_list_repository.dart';

class WordListRepositoryImpl implements WordListRepository {
  WordListRepositoryImpl({this.assetPath = 'assets/words/en_words.txt'});

  final String assetPath;
  List<String>? _cache;

  @override
  Future<List<String>> loadEnglishWords({
    int minLen = 4,
    int maxLen = 10,
  }) async {
    final all = await _loadAll();
    return all
        .where((w) => w.length >= minLen && w.length <= maxLen)
        .toList(growable: false);
  }

  Future<List<String>> _loadAll() async {
    final cached = _cache;
    if (cached != null) return cached;
    final raw = await rootBundle.loadString(assetPath);
    final parsed = raw
        .split(RegExp(r'\r?\n'))
        .map((l) => l.trim().toLowerCase())
        .where((w) => RegExp(r'^[a-z]+$').hasMatch(w))
        .toSet()
        .toList()
      ..sort();
    _cache = parsed;
    return parsed;
  }
}
```

- [ ] **Step 6: Wire DI**

In `lib/core/di/app_repositories.dart`, add providers:

```dart
RepositoryProvider<WordListRepository>(
  create: (_) => WordListRepositoryImpl(),
),
```

(Keep Generate usecase registration for Task 5.)

- [ ] **Step 7: Run test — expect PASS**

Run: `flutter test test/data/repositories/word_list_repository_impl_test.dart`  
Expected: PASS

- [ ] **Step 8: Commit** (only if user asked)

---

### Task 3: Path rules (pure)

**Files:**
- Create: `lib/domain/path_words/path_words_rules.dart`
- Test: `test/domain/path_words/path_words_rules_test.dart`

**Interfaces:**
- Consumes: `PathWordsPuzzle`, `Cell`
- Produces:
  - `Set<Cell> lockedCells(PathWordsPuzzle puzzle, Set<String> completedTargetIds)`
  - `List<Cell>? tryBegin({required PathWordsPuzzle puzzle, required Cell cell, required Set<Cell> locked, required Set<String> completedTargetIds})` — starts if `cell` is start of an unfinished target
  - `List<Cell>? tryExtend({required PathWordsPuzzle puzzle, required List<Cell> path, required Cell candidate, required Set<Cell> locked})` — orthogonal, in-bounds, not locked, not already in path
  - `PathWordsTarget? completedTarget({required PathWordsPuzzle puzzle, required List<Cell> path, required Set<String> completedTargetIds})` — when `path` equals a remaining target’s `path`
  - `Cell? nextHintCell({required PathWordsPuzzle puzzle, required List<Cell> activePath, required Set<String> completedTargetIds})` — first unfinished target in list order; if activePath is a prefix of that target path, return next cell; else return that target’s start
  - `List<Cell> undoActive(List<Cell> path)` — drop last cell (empty stays empty)

- [ ] **Step 1: Write failing rules tests**

```dart
import 'package:brain_zip/domain/entities/cell.dart';
import 'package:brain_zip/domain/entities/path_words_puzzle.dart';
import 'package:brain_zip/domain/path_words/path_words_rules.dart';
import 'package:flutter_test/flutter_test.dart';

PathWordsPuzzle tinyPuzzle() {
  // 2x2: "ab" along row0, "cd" along row1
  return PathWordsPuzzle(
    id: 't',
    day: DateTime(2026, 9, 17),
    size: 2,
    letters: const ['a', 'b', 'c', 'd'],
    targets: [
      PathWordsTarget(
        id: 't0',
        word: 'ab',
        start: const Cell(0, 0),
        path: const [Cell(0, 0), Cell(0, 1)],
        colorIndex: 0,
      ),
      PathWordsTarget(
        id: 't1',
        word: 'cd',
        start: const Cell(1, 0),
        path: const [Cell(1, 0), Cell(1, 1)],
        colorIndex: 1,
      ),
    ],
  );
}

void main() {
  final puzzle = tinyPuzzle();

  test('tryBegin only on unfinished starts', () {
    expect(
      PathWordsRules.tryBegin(
        puzzle: puzzle,
        cell: const Cell(0, 0),
        locked: {},
        completedTargetIds: {},
      ),
      [const Cell(0, 0)],
    );
    expect(
      PathWordsRules.tryBegin(
        puzzle: puzzle,
        cell: const Cell(0, 1),
        locked: {},
        completedTargetIds: {},
      ),
      isNull,
    );
  });

  test('tryExtend rejects diagonal and locked', () {
    final path = [const Cell(0, 0)];
    expect(
      PathWordsRules.tryExtend(
        puzzle: puzzle,
        path: path,
        candidate: const Cell(1, 1),
        locked: {},
      ),
      isNull,
    );
    expect(
      PathWordsRules.tryExtend(
        puzzle: puzzle,
        path: path,
        candidate: const Cell(0, 1),
        locked: {const Cell(0, 1)},
      ),
      isNull,
    );
  });

  test('completedTarget matches full solution path', () {
    final path = [const Cell(0, 0), const Cell(0, 1)];
    expect(
      PathWordsRules.completedTarget(
        puzzle: puzzle,
        path: path,
        completedTargetIds: {},
      )?.id,
      't0',
    );
  });

  test('nextHintCell returns start then next along first unfinished', () {
    expect(
      PathWordsRules.nextHintCell(
        puzzle: puzzle,
        activePath: const [],
        completedTargetIds: {},
      ),
      const Cell(0, 0),
    );
    expect(
      PathWordsRules.nextHintCell(
        puzzle: puzzle,
        activePath: const [Cell(0, 0)],
        completedTargetIds: {},
      ),
      const Cell(0, 1),
    );
  });

  test('undoActive pops last', () {
    expect(
      PathWordsRules.undoActive(const [Cell(0, 0), Cell(0, 1)]),
      [const Cell(0, 0)],
    );
  });
}
```

- [ ] **Step 2: Run tests — expect FAIL**

Run: `flutter test test/domain/path_words/path_words_rules_test.dart`  
Expected: FAIL

- [ ] **Step 3: Implement `PathWordsRules`**

Implement the static methods listed in **Interfaces** in `lib/domain/path_words/path_words_rules.dart`. Orthogonal neighbor: `|dr|+|dc|==1`. Equality of paths: same length and each `Cell` equal in order.

- [ ] **Step 4: Run tests — expect PASS**

Run: `flutter test test/domain/path_words/path_words_rules_test.dart`  
Expected: PASS

- [ ] **Step 5: Commit** (only if user asked)

---

### Task 4: Seeded daily generator + scoring helper

**Files:**
- Create: `lib/domain/path_words/path_words_generator.dart`
- Create: `lib/domain/path_words/path_words_scoring.dart`
- Test: `test/domain/path_words/path_words_generator_test.dart`
- Test: `test/domain/path_words/path_words_scoring_test.dart`

**Interfaces:**
- Produces:
  - `abstract final class PathWordsGenerator { static const generatorVersion = 1; static PathWordsPuzzle generate({required DateTime day, required List<String> words}); }`
  - `abstract final class PathWordsScoring { static int pointsForElapsed(int elapsedSeconds) => (1000 - elapsedSeconds * 5).clamp(50, 1000); }`
  - Puzzle `id`: `path_words_${StreakCalculator.dateId(day)}`
  - `size == 8`, targets cover every cell exactly once, each path spells its word

**Algorithm (required behavior):**

1. Normalize `day` to local Y/M/D; seed `Random(seed)` where `seed = Object.hash(StreakCalculator.dateId(day), generatorVersion)`.
2. Build length buckets from `words` (4–10).
3. Choose a length composition summing to 64 (try preferred patterns first, e.g. `[10,9,8,7,7,6,5,5,4,3]` is invalid because 3 is out of range — use only 4–10). Example preferred: `[10, 9, 8, 7, 6, 6, 5, 5, 4, 4]` (=64). Shuffle order of placing with RNG.
4. For each length, pick a random unused word from that bucket.
5. Place each word as a self-avoiding orthogonal path on empty cells via backtracking (shuffle neighbor order with RNG). On failure, retry whole packing up to N times (e.g. 80), optionally swapping length composition to another list that sums to 64.
6. Emit `PathWordsPuzzle` with `letters` filled from paths; `colorIndex` = index in `targets`.

If packing still fails, throw `StateError('PathWordsGenerator failed for $dateId')` — tests over a date range must pass so tune word list / retries until green.

- [ ] **Step 1: Write scoring + generator tests**

```dart
// scoring
expect(PathWordsScoring.pointsForElapsed(0), 1000);
expect(PathWordsScoring.pointsForElapsed(12), 940);
expect(PathWordsScoring.pointsForElapsed(10000), 50);

// generator
final words = /* in-memory list with many 4–10 letter words — can load from asset in test with binding, or duplicate a const list of 200+ words */;

test('same day is deterministic', () {
  final a = PathWordsGenerator.generate(day: DateTime(2026, 9, 17), words: words);
  final b = PathWordsGenerator.generate(day: DateTime(2026, 9, 17), words: words);
  expect(a.letters, b.letters);
  expect(a.targets.map((t) => t.word).toList(), b.targets.map((t) => t.word).toList());
});

test('covers 8x8 exactly once and paths spell words', () {
  final p = PathWordsGenerator.generate(day: DateTime(2026, 1, 1), words: words);
  expect(p.size, 8);
  expect(p.letters.length, 64);
  final seen = <Cell>{};
  for (final t in p.targets) {
    expect(t.path.first, t.start);
    expect(t.path.length, t.word.length);
    for (var i = 0; i < t.path.length; i++) {
      final c = t.path[i];
      expect(seen.add(c), isTrue);
      expect(p.letterAt(c), t.word[i]);
    }
  }
  expect(seen.length, 64);
});

test('generates for 30 consecutive days', () {
  final start = DateTime(2026, 9, 1);
  for (var i = 0; i < 30; i++) {
    final day = start.add(Duration(days: i));
    expect(() => PathWordsGenerator.generate(day: day, words: words), returnsNormally);
  }
});
```

- [ ] **Step 2: Run tests — expect FAIL**

Run: `flutter test test/domain/path_words/path_words_generator_test.dart test/domain/path_words/path_words_scoring_test.dart`  
Expected: FAIL

- [ ] **Step 3: Implement generator + scoring**

Implement as specified. Keep generator pure Dart (no Flutter imports).

- [ ] **Step 4: Run tests — expect PASS**

Run: same command  
Expected: all PASS (if 30-day test flakes, increase retries / enrich word list before moving on)

- [ ] **Step 5: Commit** (only if user asked)

---

### Task 5: `GenerateDailyPathWords` usecase + DI

**Files:**
- Create: `lib/domain/usecases/generate_daily_path_words.dart`
- Modify: `lib/core/di/app_repositories.dart`
- Test: `test/domain/usecases/generate_daily_path_words_test.dart`

**Interfaces:**
- Consumes: `WordListRepository`, `PathWordsGenerator`
- Produces:
  - `class GenerateDailyPathWords { Future<PathWordsPuzzle> call({required DateTime day}); }`

- [ ] **Step 1: Write failing usecase test with mocktail**

```dart
class _MockWords extends Mock implements WordListRepository {}

bloc-less unit test:
when(() => repo.loadEnglishWords(minLen: 4, maxLen: 10))
  .thenAnswer((_) async => fixtureWords);
final puzzle = await GenerateDailyPathWords(repo)(day: DateTime(2026, 9, 17));
expect(puzzle.id, 'path_words_20260917');
expect(puzzle.size, 8);
```

- [ ] **Step 2: Implement usecase**

```dart
class GenerateDailyPathWords {
  GenerateDailyPathWords(this._words);
  final WordListRepository _words;

  Future<PathWordsPuzzle> call({required DateTime day}) async {
    final list = await _words.loadEnglishWords(minLen: 4, maxLen: 10);
    return PathWordsGenerator.generate(day: day, words: list);
  }
}
```

Register:

```dart
RepositoryProvider<GenerateDailyPathWords>(
  create: (context) =>
      GenerateDailyPathWords(context.read<WordListRepository>()),
),
```

- [ ] **Step 3: Run test — PASS**

- [ ] **Step 4: Commit** (only if user asked)

---

### Task 6: PathWordsBloc (play + score)

**Files:**
- Create: `lib/features/path_words/bloc/path_words_event.dart`
- Create: `lib/features/path_words/bloc/path_words_state.dart`
- Create: `lib/features/path_words/bloc/path_words_bloc.dart`
- Generate: `*.freezed.dart` via build_runner
- Test: `test/features/path_words/bloc/path_words_bloc_test.dart`

**Interfaces:**
- Events: `started({DateTime? date})`, `pointerDown(Cell)`, `pointerEnter(Cell)`, `pointerUp()`, `undo()`, `hint()`, `reset()`
- Status enum: `loading`, `ready`, `playing`, `submitting`, `navigating`, `failed`
- State: `day`, `puzzle?`, `status`, `activePath`, `completedTargetIds`, `hintsRemaining` (default 3), `startedAt?`, `hintFlashCell?`, `errorMessage?`, `finished`, `points?`, `timeSeconds?`, `improved?`, `resultsExtra?`
- On `started`: status loading → load puzzle via `GenerateDailyPathWords` → ready, set `startedAt = DateTime.now()`, hints=3, clear paths
- Gestures: use `PathWordsRules`; on complete word add id; if all done → compute points from `DateTime.now().difference(startedAt!).inSeconds`, submit score + streak, navigating
- `modeKey`: `'path_words_${StreakCalculator.dateId(day)}'`
- `undo`: `activePath = PathWordsRules.undoActive(activePath)`
- `hint`: if hintsRemaining>0 and not finished, set `hintFlashCell = nextHintCell(...)`, decrement hints
- `reset`: clear active + completed, hints=3, clear hintFlash; **do not** change `startedAt` or puzzle

- [ ] **Step 1: Define freezed event/state files** (mirror Zip style)

```dart
@freezed
sealed class PathWordsEvent with _$PathWordsEvent {
  const factory PathWordsEvent.started({DateTime? date}) = PathWordsStarted;
  const factory PathWordsEvent.pointerDown(Cell cell) = PathWordsPointerDown;
  const factory PathWordsEvent.pointerEnter(Cell cell) = PathWordsPointerEnter;
  const factory PathWordsEvent.pointerUp() = PathWordsPointerUp;
  const factory PathWordsEvent.undo() = PathWordsUndo;
  const factory PathWordsEvent.hint() = PathWordsHint;
  const factory PathWordsEvent.reset() = PathWordsReset;
}
```

State similarly with `PathWordsStatus` enum in the same file or adjacent.

- [ ] **Step 2: Run build_runner**

Run: `dart run build_runner build --delete-conflicting-outputs`  
Expected: generates `path_words_event.freezed.dart`, `path_words_state.freezed.dart`

- [ ] **Step 3: Write `bloc_test` cases (failing until bloc exists)**

Cover at minimum:
1. `started` → `ready` with puzzle id for date  
2. Completing all target paths (drive `pointerDown`/`pointerEnter` along each solution) → `submitting` then `navigating` with streak fields  
3. `undo` shortens active path  
4. `hint` decrements and sets `hintFlashCell`  
5. `reset` clears progress but keeps `startedAt`

Use mocks for `GenerateDailyPathWords`, `SubmitScore`, `RecordDailyClear`. For play tests, inject a **fixed tiny puzzle** by making `GenerateDailyPathWords` mock return `tinyPuzzle()` from Task 3 (bump to cover-all if needed) OR add an optional `PathWordsPuzzle? puzzleOverride` only in tests via constructor `PathWordsBloc(..., {PathWordsPuzzle Function(DateTime day)? puzzleForTest})` — prefer mock usecase returning a fixture 2×2 or full 8×8 fixture constant in the test file.

For win test on 2×2 fixture, temporarily allow non-8 size in bloc (bloc should not hardcode 8; generator does).

- [ ] **Step 4: Implement `PathWordsBloc`**

Wire handlers; guard against input when `finished` or not `ready`/`playing`; set `playing` on first successful path mutation.

On win:

```dart
final elapsed = DateTime.now().difference(state.startedAt!).inSeconds;
final points = PathWordsScoring.pointsForElapsed(elapsed);
// submitScore modeKey path_words_<dateId>
// recordDailyClear gameId: GameIds.pathWords
// ResultsArgs title from AppStrings.pathWordsClearedTitle, replayDaily: true
```

Note: importing `AppStrings` into bloc couples presentation copy into feature bloc (Zip currently hardcodes `'Puzzle cleared!'`). **Match Zip:** hardcode results title string in bloc OR use `AppStrings` — prefer `AppStrings.pathWordsClearedTitle` for consistency with app-strings rule.

- [ ] **Step 5: Run tests — PASS**

Run: `flutter test test/features/path_words/bloc/path_words_bloc_test.dart`  
Expected: PASS

- [ ] **Step 6: Commit** (only if user asked)

---

### Task 7: Board view model + Flame game

**Files:**
- Create: `lib/features/path_words/game/path_words_board_view.dart`
- Create: `lib/features/path_words/game/path_words_game.dart`

**Interfaces:**
- Produces:
  - `class PathWordsBoardView { PathWordsPuzzle puzzle; List<Cell> activePath; Map<String, List<Cell>> completedPathsByTargetId; Cell? hintFlashCell; bool inputEnabled; }`
  - `class PathWordsGame extends FlameGame with DragCallbacks { PathWordsBoardView view; void Function(Cell) onPointerDown; void Function(Cell) onPointerEnter; void Function() onPointerUp; void applyView(PathWordsBoardView view); }`

- [ ] **Step 1: Implement `PathWordsBoardView`** as immutable data class (const constructor + fields above).

- [ ] **Step 2: Implement `PathWordsGame`**

Behavior:
- On load / resize: compute `_cellSize`, `_origin` for square board inset (mirror `ZipGame` layout math).
- `applyView`: replace `view`, call `refresh()` / mark dirty.
- `onDragStart` / `onDragUpdate` / `onDragEnd`: map global/local position → `Cell?`; if non-null and `inputEnabled`, invoke callbacks. Deduplicate `onPointerEnter` if same cell as last.
- `render`: for each cell draw letter; for completed paths fill with color from a fixed palette `List<Color> pathColors` (≥6); draw small check on unfinished starts; draw active path highlight; draw arrows between consecutive cells of completed (+ active) paths; pulse/highlight `hintFlashCell`.
- `backgroundColor`: transparent like Zip.

Do **not** import Bloc into the game file.

- [ ] **Step 3: Manual sanity** — `dart analyze lib/features/path_words/game/`  
Expected: no issues

- [ ] **Step 4: Commit** (only if user asked)

---

### Task 8: Screen chrome + AppStrings

**Files:**
- Create: `lib/features/path_words/view/path_words_screen.dart`
- Create: `lib/features/path_words/view/widgets/path_words_word_list.dart`
- Create: `lib/features/path_words/view/widgets/path_words_how_to_play.dart`
- Modify: `lib/core/strings/app_strings.dart`

**Interfaces:**
- Screen reads `GenerateDailyPathWords`, `SubmitScore`, `RecordDailyClear` from context; creates `PathWordsBloc`..`add(started)`
- Builds `PathWordsGame` once puzzle ready; on each state change `game.applyView(...)`
- Gesture callbacks → bloc events
- Listener: `status == navigating` → `context.pushReplacement('/results', extra: state.resultsExtra)`
- UI: `ZipAtmosphere` scaffold; AppBar with back, title `AppStrings.pathWordsTitle`, reset `Icons.refresh`; body column: aspect-ratio board, word list, Undo/Hint row, how-to-play
- Disable Undo when `activePath.isEmpty` or finished; disable Hint when `hintsRemaining==0` or finished

- [ ] **Step 1: Add AppStrings**

```dart
static const pathWordsTitle = 'Path Words';
static const pathWordsTagline = 'Trace every word across the grid.';
static const playTodaysPathWords = "Play today's Path Words";
static const pathWordsUndo = 'Undo';
static const pathWordsHint = 'Hint';
static String pathWordsHintWithCount(int n) => 'Hint ($n)';
static const pathWordsHowToPlayTitle = 'How to play';
static const pathWordsHowToPlayBody =
    'Drag a path from each marked start letter. Paths move up, down, left, or right—not diagonally. Find every listed word to clear the board. Undo backs up your current path. Hint reveals the next correct cell.';
static const pathWordsClearedTitle = 'Puzzle cleared!';
static const pathWordsLoading = 'Building today’s puzzle…';
static const pathWordsFailed = 'Could not load today’s puzzle.';
```

- [ ] **Step 2: Implement word list + how-to-play widgets** (feature-local)

Word list: for each target, color dot, uppercase word, check icon if completed.

How to play: `ExpansionTile` or similar with title/body from AppStrings.

- [ ] **Step 3: Implement `PathWordsScreen`**

Mirror lifecycle patterns from `ZipScreen` (create bloc in `initState`, dispose/pause engine, `BlocProvider.value`, multi listeners). Map state → `PathWordsBoardView`.

- [ ] **Step 4: Analyze screen files**

Run: `dart analyze lib/features/path_words lib/core/strings/app_strings.dart`  
Expected: clean

- [ ] **Step 5: Commit** (only if user asked)

---

### Task 9: Router + home entry

**Files:**
- Modify: `lib/core/router/app_router.dart`
- Modify: `lib/features/home/view/home_screen.dart`
- Optionally: `lib/features/home/cubit/home_cubit.dart` / state if showing Path Words streak/best — **v1 YAGNI:** add a second CTA button that simply `context.push('/path-words')` without home stats for Path Words unless quick to mirror Zip. Prefer a clear home button/card labeled `AppStrings.playTodaysPathWords`.

- [ ] **Step 1: Add route**

```dart
GoRoute(
  path: '/path-words',
  builder: (context, state) => const PathWordsScreen(),
),
```

- [ ] **Step 2: Add home navigation**

Place a primary or secondary button near Zip’s daily card:

```dart
ZipPrimaryButton(
  label: AppStrings.playTodaysPathWords,
  icon: Icons.grid_on_rounded,
  onPressed: () => context.push('/path-words'),
),
```

(Adjust layout so Zip remains primary if desired; Path Words can sit just below Zip CTA.)

- [ ] **Step 3: Run app smoke**

Run: `flutter run` (or IDE), open Path Words, confirm loading → grid → word list visible.

- [ ] **Step 4: Commit** (only if user asked)

---

### Task 10: End-to-end polish checklist

**Files:** touch-up under `lib/features/path_words/game/path_words_game.dart` and view widgets as needed.

- [ ] **Step 1: Visual parity checklist**

Verify manually:
- [ ] Start-cell checkmarks on unfinished targets only  
- [ ] Completed path fill colors + direction arrows  
- [ ] Active drag highlight  
- [ ] Hint flash visible then cleared on next gesture (bloc may clear `hintFlashCell` on pointerDown)  
- [ ] Undo / Hint disabled states  
- [ ] Reset clears progress, same letters  
- [ ] Win → results with streak  
- [ ] How to play expands  

- [ ] **Step 2: Clear hint on interaction**

In bloc `pointerDown` handler: `hintFlashCell: null` when applying new path logic.

- [ ] **Step 3: Full automated suite for Path Words**

Run:

```bash
flutter test test/domain/path_words test/features/path_words test/data/repositories/word_list_repository_impl_test.dart
dart analyze lib/features/path_words lib/domain/path_words lib/domain/entities/path_words_puzzle.dart lib/domain/usecases/generate_daily_path_words.dart lib/data/repositories/word_list_repository_impl.dart
```

Expected: all tests PASS; analyze clean

- [ ] **Step 4: Commit** (only if user asked)

```bash
git add assets/words/en_words.txt pubspec.yaml lib test
git commit -m "feat: add Path Words daily word-path puzzle"
```

---

## Spec coverage self-review

| Spec requirement | Task |
|------------------|------|
| Near-Wend UX (markers, colors, arrows, word list, undo, hint, reset, how-to-play) | 7, 8, 10 |
| Seeded daily generator + bundled English list | 2, 4, 5 |
| Flame thin + Bloc-owned play state | 6, 7, 8 |
| 8×8 full partition, orthogonal | 3, 4 |
| Score/streak/results like Zip | 6, 9 |
| AppStrings | 8 |
| Home + route | 9 |
| Tests: generator, rules, hint, bloc | 3, 4, 6 |
| No LinkedIn/Wend trademark in product name | AppStrings = Path Words |

**Placeholder scan:** none intentional — word list must be concretely authored in Task 2.  
**Type consistency:** `PathWordsPuzzle.letters` row-major; `GameIds.pathWords`; modeKey `path_words_<dateId>`; hints default 3; undo active-only; timer from `ready` / `startedAt`.
