# Path Words — Design Spec

**Date:** 2026-09-17  
**Status:** Approved (design sections §1–§3)  
**Working product name:** Path Words (BrainZip-original; rename later without changing feature folder if desired)  
**Scope:** Near–LinkedIn Wend parity daily word-path puzzle: Flame grid, listed words, undo/hint/reset, how-to-play, seeded daily generator from a bundled English word list, score + streak via existing usecases.

---

## 1. Goals

1. Ship a new daily game **Path Words**: find listed words by tracing orthogonal paths on an **8×8** letter grid that is fully partitioned by the solution.
2. Match **near–LinkedIn Wend** UX: start-cell markers, colored completed paths with direction arrows, word list with checkmarks, Undo, Hint, Reset, collapsible How to play.
3. Use a **seeded daily generator** over a **bundled English word list** so each calendar day has a deterministic puzzle.
4. Follow BrainZip architecture: feature-first UI + BLoC, pure domain rules, Flame as **thin renderer/input** only (Bloc owns play state).
5. Reuse **SubmitScore**, **RecordDailyClear**, results screen, and home/routing patterns from Zip.

### Non-goals (v1)

- Multiplayer, cloud-authored puzzles, or live dictionary updates.
- Thematic word packs (single bundled English list only).
- Diagonals, overlapping letters, or partial-board puzzles.
- Deep settings beyond reset; no separate settings product surface required.
- Renaming to a final brand name (placeholder **Path Words** is fine).

---

## 2. Decisions (locked)

| Topic | Choice |
|-------|--------|
| v1 scope | Near–LinkedIn parity (undo, hint, daily, score/streak, how-to-play, markers/arrows) |
| Puzzle source | Seeded daily generator (calendar day) |
| Word source | Bundled English word list asset, filtered by length |
| Grid rendering / input | Flame (like Zip), but **Bloc owns play state** |
| Feature folder | `lib/features/path_words/` |
| Product name | Path Words (placeholder) |
| Grid size | Fixed 8×8 (64 cells; word lengths sum to 64) |
| Movement | Orthogonal only (up/down/left/right) |
| Hints | 3 per puzzle; reveal next correct cell for current unfinished target |
| Scoring | Zip-shaped: `(1000 - elapsedSeconds * 5).clamp(50, 1000)` |
| State modeling | `freezed` events/states |
| Copy | All user-facing strings via `AppStrings` |

---

## 3. Architecture

### 3.1 Feature layout

```text
lib/features/path_words/
  bloc/           # PathWordsBloc + freezed events/states
  view/           # PathWordsScreen + chrome widgets (word list, how-to-play)
  game/           # PathWordsGame — draw + forward cell gestures only
```

Optional `logic/` only for UI-adjacent helpers that are not worth domain placement. Prefer domain for path validation and generation.

### 3.2 Domain

- **Entities**
  - `PathWordsPuzzle`: `id` / date, `size` (8), `letters` (row-major or 2D), `targets`
  - `PathWordsTarget`: `id`, `word`, `start: Cell`, `path: List<Cell>`, `colorIndex`
  - Reuse existing `Cell` (`row`, `col`)
- **Game id:** `GameIds.pathWords`
- **Generator:** pure Dart, deterministic for `(dateId, wordListVersion)` — place non-overlapping snake paths covering every cell; letters come from placed words
- **Path rules:** pure helpers/usecase-level functions: try extend active path, detect completed target, occupancy (completed cells cannot be reused)
- **Word list access:** repository interface e.g. `WordListRepository` → `Future<List<String>> loadEnglishWords({int minLen, int maxLen})`

### 3.3 Data

- Asset: e.g. `assets/words/en_words.txt` (one word per line, lowercase ASCII)
- `WordListRepositoryImpl` loads once (cache in memory), filters length (v1: **4–10** inclusive to match Wend-like lengths)
- No network dependency for v1 puzzles

### 3.4 Integration

- Router: `/path-words` (optional `date` query/extra for replay, matching Zip if present)
- Home: new card/entry beside Zip
- On win: `SubmitScore(modeKey: 'path_words_<dateId>', ...)` + `RecordDailyClear(gameId: GameIds.pathWords, ...)` → push `/results` with `ResultsArgs` (`replayDaily: true`)

### 3.5 Flame ↔ Bloc contract

- **Source of truth:** Bloc state (puzzle, completed target ids + paths, active path, hints remaining, timer start, status).
- **Flame responsibilities:** layout cells; paint letters, start checks, completed path fills/arrows, active path highlight, optional hint flash cell; map pointer → `Cell`; emit gesture callbacks upward.
- **Flame must not:** own undo stack, hint counts, win submission, or word-list state.
- Screen passes a **render snapshot** into the game when state changes (or game reads an immutable view model updated by the screen). Prefer replacing/updating a single `PathWordsBoardView` object rather than putting Bloc inside Flame.

---

## 4. Gameplay rules

1. Target words are shown in a list; each has a unique color and a marked **start cell**.
2. Player drags a continuous orthogonal path of letters. Path may start only on an unused start cell of an unfinished word, or continue from the current active tip (product rule: starting on a listed start letter begins that word’s attempt).
3. Letters on completed words are locked and cannot be reused.
4. When the active path’s letter sequence equals a target word **and** the path equals that target’s solution path (or, equivalently, matches the unique solution path for that word on this puzzle), the word is marked found and painted.
5. **Undo:** pops the last path action (shrink active path; if active empty, undo last completed word only if we define undo that way — **v1: undo only affects the active incomplete path**; completed words stay locked unless **Reset**).
6. **Hint:** if hints remain and puzzle incomplete, pick the first unfinished target in list order; reveal the next cell along its solution path after the longest correct prefix currently matching the active path (if active path empty or on another word, reveal that target’s start). Decrement hints. Flash/highlight that cell briefly.
7. **Reset:** clear active path, completed words, restore hints to 3, keep same daily puzzle and timer policy (**v1: reset does not reset elapsed timer** — timer keeps running from first start).
8. **Win:** all targets found → compute points from elapsed seconds → submit → results.

### Clarified path matching

Because the generator places a single covering partition, each target has one solution path. Acceptance = active path equals that target’s `path` (cells in order). Letter spelling alone is insufficient if a wrong route somehow spelled the same string (should not occur if letters only appear on solution paths, but still validate by cell path).

---

## 5. Daily generator

**Inputs:** calendar `DateTime` day (local), word list (filtered 4–10).  
**Output:** `PathWordsPuzzle` with full cover.

**Algorithm sketch (implementation may refine, behavior must hold):**

1. Seed RNG from `dateId` (and a constant `generatorVersion` int for future invalidation).
2. Sample a multiset of word lengths that sum to **64** (e.g. prefer a mix similar to Wend: several mid-length words).
3. For each length, pick a random unused word of that length from the list.
4. Place words as self-avoiding orthogonal paths on empty cells until the grid is full; backtrack/retry with the seeded RNG on failure; bounded attempts then fall back to a simpler length composition and retry.
5. Write letters from placed words onto the grid; record each `PathWordsTarget`.

**Invariants (tested):**

- Same `(dateId, generatorVersion, word list file hash/version)` → identical puzzle
- Every cell belongs to exactly one target path
- Each target path spells `word`
- Start cell is `path.first`

---

## 6. UI

- Visual language: existing Zip / Winklo dark atmosphere (`ZipAtmosphere`, shared chrome where it fits); Path Words–specific path colors (palette of ≥6 distinct colors).
- Top bar: back, title, reset, optional settings stub (omit settings gear if app has no settings route — prefer omit over dead control).
- Grid: Flame `GameWidget` in a square aspect region.
- Word list: color chip + word + check when found.
- Bottom: Undo, Hint (show remaining hints on label or badge).
- How to play: expandable section with short rules from `AppStrings`.
- Finished: disable Undo/Hint; navigate to results after score submit (mirror Zip listeners).

---

## 7. Bloc sketch

**Status:** `loading` → `ready` → `playing` → `submitting` → `navigating` (and `failed` if word list/generation fails).

**Events:**

- `started({DateTime? date})`
- `pointerDown(Cell cell)` / `pointerEnter(Cell cell)` / `pointerUp`
- `undo`
- `hint`
- `reset`
- Internal completion path triggers score submit (or explicit `completed` after last word)

**State fields:** day, puzzle, status, activePath, completedTargetIds, hintsRemaining, startedAt / elapsed, points?, improved?, resultsExtra?, errorMessage?, hintFlashCell?

Timer: start on first successful path interaction (or on `ready` — **v1: start when status becomes `ready`**, consistent and simple).

---

## 8. Scoring & streaks

- Points: `(1000 - elapsedSeconds * 5).clamp(50, 1000)` (same as Zip).
- `modeKey`: `path_words_${dateId}`
- `GameIds.pathWords` for streak repository.
- Results copy via `AppStrings` / `ResultsArgs` (title like puzzle cleared).

---

## 9. Testing

| Layer | Coverage |
|-------|----------|
| Generator | Determinism; full cover; path spells word; length sum 64 |
| Path rules | Extend neighbor; reject diagonal/reuse/out-of-bounds; complete; undo active |
| Hint | Decrements; reveals expected next cell; no-op at 0 |
| Bloc | `bloc_test` for start → play → complete word → win submit; undo; reset |
| Widget | Optional smoke: screen builds in `ready` with fake puzzle |

Use `mocktail` for repositories/usecases where needed.

---

## 10. Risks & mitigations

| Risk | Mitigation |
|------|------------|
| Generator fails to pack some seeds | Bounded retries + fallback length patterns; ship a unit test over N consecutive days |
| Large word list load jank | Load async on `started`; cache; show loading status |
| Flame/Bloc sync bugs | Single immutable board view model; game does not mutate puzzle |
| Legal/branding | Original name Path Words; do not use LinkedIn/Wend trademarks in store copy |

---

## 11. Implementation order (high level)

1. Domain entities + word list repo + generator + path rules + tests  
2. Bloc + tests  
3. Flame board + screen chrome  
4. Home + router + GameIds + AppStrings  
5. Score/streak/results wiring  
6. Polish: arrows, hint flash, how-to-play  

Detailed task breakdown follows in `docs/superpowers/plans/` after this spec is accepted.
