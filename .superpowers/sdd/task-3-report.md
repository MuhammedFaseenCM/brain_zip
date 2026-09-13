## Task 3 — Domain repository interfaces + score usecases (TDD)

### Status
- **Done**: Domain repository interfaces + thin usecases implemented.
- **Out of scope (per brief)**: No data-layer implementations added.

### TDD evidence (RED → GREEN)
- **RED**: `flutter test test/domain/usecases/submit_score_test.dart`
  - Fails to compile because domain types don’t exist yet:
    - `Error when reading 'lib/domain/repositories/score_repository.dart': No such file or directory`
    - `Error when reading 'lib/domain/usecases/submit_score.dart': No such file or directory`
- **GREEN**: same command after implementation
  - `All tests passed!`

### What was added
#### Repository interfaces (domain)
- `lib/domain/repositories/score_repository.dart`
- `lib/domain/repositories/zip_level_repository.dart`
- `lib/domain/repositories/word_match_repository.dart`
- `lib/domain/repositories/category_repository.dart`

#### Usecases (thin forwarding)
- Score:
  - `lib/domain/usecases/submit_score.dart`
  - `lib/domain/usecases/get_best_points.dart`
  - `lib/domain/usecases/get_best_time_seconds.dart`
- Content:
  - `lib/domain/usecases/fetch_zip_levels.dart`
  - `lib/domain/usecases/fetch_word_match_decks.dart`
  - `lib/domain/usecases/fetch_categories.dart`

#### Tests
- `test/domain/usecases/submit_score_test.dart`

### Notes / constraints
- `flutter test` (full suite) currently fails in this repo due to missing dependency `flutter_riverpod` referenced by app/widget code. This is unrelated to Task 3 and the targeted RED/GREEN test is passing.

