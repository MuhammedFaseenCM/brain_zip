# Winklo — project / package / folder rename

**Date:** 2026-09-23  
**Status:** Approved  
**Related:** [2026-09-14-winklo-brand-name-design.md](./2026-09-14-winklo-brand-name-design.md) (brand locked; package path was deferred)

## Goal

Align repository identity with the product name **Winklo**: Dart package, local folder, docs/IDE labels, and GitHub remote — without changing store IDs or game feature names.

## Current vs target

| Layer | Current | Target |
|-------|---------|--------|
| Product / UI title | Winklo (already) | unchanged |
| Dart package (`pubspec.yaml` `name`) | `brain_zip` | `winklo` |
| Import prefix | `package:brain_zip/...` | `package:winklo/...` |
| Local folder | `…/brain_zip` | `…/winklo` |
| GitHub repo | `MuhammedFaseenCM/brain_zip` | `MuhammedFaseenCM/winklo` |
| Android `applicationId` / namespace | `com.winklo.faseencm` | unchanged |
| Zip / Word Match / Category Race feature IDs & copy | as today | unchanged |

## Approach

**Mechanical rename in place** (preserve git history; one focused change set):

1. Rename Dart package and rewrite all `package:brain_zip/` imports to `package:winklo/`.
2. Update IDE/docs/rules that still say BrainZip / `brain_zip` where they mean the project (not historical commit messages or unrelated Zip-game copy).
3. Rename GitHub repository via `gh`, then update local `origin` URL.
4. Rename the on-disk project folder last; reopen the workspace from the new path.

## In scope

- `pubspec.yaml` package name
- All Dart/test imports using `package:brain_zip/`
- `.vscode/launch.json` configuration names
- Project guides and Cursor rules that title or refer to the repo as BrainZip / `brain_zip` (e.g. `CLAUDE.md`, `.cursor/rules`)
- Hardcoded local paths in docs under `docs/superpowers/` that point at `/Users/.../brain_zip` (update to `winklo` where they are instructions to run commands)
- GitHub repo rename + `git remote set-url origin`
- Filesystem folder rename `brain_zip` → `winklo`

## Out of scope

- App display name / `AppStrings.appTitle` (already Winklo)
- Android `applicationId`, Kotlin/Java package directories if already under winklo
- Firebase project IDs, Play Console listing, deep links
- Rewriting git history or old commit messages
- Renaming the Zip **game** feature, assets, or Zip-specific strings
- Creating a new empty repo and migrating by copy

## Risks & mitigations

| Risk | Mitigation |
|------|------------|
| Missed imports break analyze/tests | Repo-wide replace of `package:brain_zip/`; run `flutter pub get` + targeted analyze/tests |
| Cursor / IDE still open on old folder path | Rename folder after code + remote; user reopens `…/winklo` |
| Broken clone URLs for anyone with old remote | GitHub rename leaves redirects from old URL; update `origin` locally |
| Over-renaming “Zip” game mentions | Only change project/package/BrainZip identity; leave Zip game strings alone |

## Verification

- `flutter pub get` succeeds with package name `winklo`
- No remaining `package:brain_zip/` imports in `lib/` or `test/`
- `dart analyze` / `flutter test` on a representative set (or full suite if fast enough)
- `git remote -v` shows `…/winklo.git`
- Working directory is `…/winklo`

## Success criteria

Clone path, Dart package, docs title, and GitHub name all say **winklo** / **Winklo**; Android app ID and in-app game names unchanged.
