Status: ✅ Done (Task 8)
Changes: Added `PathWordsScreen` with Zip chrome + board/game wiring; added word list + how-to widgets; added Path Words `AppStrings`.
Commits: `dd66943` (Task 8: Path Words screen chrome)
Analyze: `dart analyze lib/features/path_words/view lib/core/strings/app_strings.dart lib/features/path_words/bloc/path_words_bloc.dart` → No issues found
Notes: Screen mirrors `ZipScreen` lifecycle (bloc in `initState`, dispose closes bloc + pauses engine, listener navigates on `PathWordsStatus.navigating`).
Concerns: None; router/home entry intentionally omitted (Task 9).
Report: `.superpowers/sdd/task-8-report.md`

