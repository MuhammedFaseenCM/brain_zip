# Winklo Project Rename Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rename the Dart package, docs/IDE labels, GitHub repo, and local folder from `brain_zip` / BrainZip to `winklo` / Winklo while leaving app IDs and Zip-game names untouched.

**Architecture:** Mechanical in-place rename. Update `pubspec.yaml` name, bulk-replace `package:brain_zip/` imports, fix project identity strings in guides/IDE, rename the GitHub remote with `gh`, retarget `origin`, then rename the on-disk folder last so the workspace can be reopened at the new path.

**Tech Stack:** Flutter / Dart package layout, `gh` for GitHub repo rename, git remotes, macOS filesystem.

## Global Constraints

- Follow spec: `docs/superpowers/specs/2026-09-23-winklo-project-rename-design.md`
- Target Dart package name: `winklo`
- Target GitHub repo: `MuhammedFaseenCM/winklo`
- Target local folder: `/Users/muhammedfaseencm/winklo`
- Do **not** change Android `applicationId` / namespace (`com.winklo.faseencm`)
- Do **not** change Zip / Word Match / Category Race game feature names or Zip-specific `AppStrings`
- Do **not** edit `android/app/google-services.json` Firebase `package_name` (Firebase IDs out of scope; note any stale value in the PR/summary only)
- Do **not** rewrite git history
- Analyze with timed `dart analyze <paths>` / `flutter test` — never MCP `analyze_files`
- Commits only when the user asks (skip commit steps unless explicitly requested)

---

## File structure map

| Path | Responsibility |
|------|----------------|
| `pubspec.yaml` | Package `name: winklo` |
| `lib/**/*.dart`, `test/**/*.dart` | All `package:brain_zip/` → `package:winklo/` (~63 files, ~222 import lines) |
| `.vscode/launch.json` | Launch config display names |
| `CLAUDE.md` | Project guide title |
| `.cursor/rules/bloc-architecture.mdc` | Rule title BrainZip → Winklo |
| `docs/superpowers/**` | Hardcoded `…/brain_zip` paths and “BrainZip” *project* titles in plans/specs where they mean the repo (not historical brand-discussion context that must stay accurate) |
| `docs/privacy/index.html` | GitHub issues URL after repo rename |
| `play/app_content_answers.txt` | Privacy / Pages URL after repo rename |
| GitHub `MuhammedFaseenCM/brain_zip` | Rename to `winklo`; update local `origin` |
| `/Users/muhammedfaseencm/brain_zip` | Rename directory to `winklo` (last step) |

---

### Task 1: Dart package name + imports

**Files:**
- Modify: `pubspec.yaml` (line with `name: brain_zip`)
- Modify: every Dart file under `lib/` and `test/` that imports `package:brain_zip/` (list via `rg -l 'package:brain_zip/' lib test`)

**Interfaces:**
- Consumes: none
- Produces: package identity `winklo`; all app/test imports use `package:winklo/...`

- [ ] **Step 1: Change pubspec package name**

In `pubspec.yaml`, set:

```yaml
name: winklo
```

Leave `description`, `version`, and dependencies unchanged.

- [ ] **Step 2: Bulk-replace Dart imports**

From repo root:

```bash
rg -l 'package:brain_zip/' lib test --glob '*.dart' | while IFS= read -r f; do
  sed -i '' 's|package:brain_zip/|package:winklo/|g' "$f"
done
```

- [ ] **Step 3: Confirm no Dart package imports remain**

```bash
rg 'package:brain_zip/' lib test --glob '*.dart'
```

Expected: no matches.

- [ ] **Step 4: Refresh packages and verify**

```bash
flutter pub get
dart analyze lib test
flutter test
```

Expected: `pub get` succeeds; analyze clean (or only pre-existing unrelated issues); tests pass.

- [ ] **Step 5: Commit** (only if user requested commits)

```bash
git add pubspec.yaml pubspec.lock lib test
git commit -m "$(cat <<'EOF'
chore: rename Dart package brain_zip to winklo

EOF
)"
```

---

### Task 2: IDE, project guides, and docs identity

**Files:**
- Modify: `.vscode/launch.json`
- Modify: `CLAUDE.md`
- Modify: `.cursor/rules/bloc-architecture.mdc`
- Modify: docs that still treat the **project** as BrainZip / path `brain_zip` for operator instructions:
  - Prefer updating titles/paths in active guides; keep historical “we renamed brand but left package `brain_zip`” sentences accurate by noting the package was later renamed (one clarifying line) or update the deferred-scope sentence in `docs/superpowers/specs/2026-09-14-winklo-brand-name-design.md` to say package rename is covered by `2026-09-23-winklo-project-rename-design.md`
  - Replace hardcoded `/Users/muhammedfaseencm/brain_zip` command paths in plans with `/Users/muhammedfaseencm/winklo` (or `$REPO_ROOT`) where they are copy-paste run instructions

**Interfaces:**
- Consumes: Task 1 package name `winklo`
- Produces: human-facing project identity aligned with Winklo

- [ ] **Step 1: Update launch.json names**

Replace configuration `"name"` values:

```json
"name": "winklo"
```

```json
"name": "winklo (profile mode)"
```

```json
"name": "winklo (release mode)"
```

- [ ] **Step 2: Update CLAUDE.md title**

Change the first heading from:

```markdown
## BrainZip — Project guide (BLoC + domain/data)
```

to:

```markdown
## Winklo — Project guide (BLoC + domain/data)
```

- [ ] **Step 3: Update bloc-architecture rule title**

In `.cursor/rules/bloc-architecture.mdc`, change:

```markdown
# BLoC architecture (BrainZip)
```

to:

```markdown
# BLoC architecture (Winklo)
```

- [ ] **Step 4: Patch docs paths / deferred-scope note**

1. In `docs/superpowers/specs/2026-09-14-winklo-brand-name-design.md`, replace the out-of-scope bullet that says Dart package `brain_zip` is deferred with a pointer that package/folder/GitHub rename is specified in `2026-09-23-winklo-project-rename-design.md`.
2. Run:

```bash
rg -n '/Users/muhammedfaseencm/brain_zip|BrainZip|brain_zip' docs/superpowers CLAUDE.md .cursor .vscode
```

Update remaining **instructional** paths and project titles; do not rewrite Zip-game content; do not invent new product copy.

- [ ] **Step 5: Spot-check**

```bash
rg 'package:brain_zip/' lib test --glob '*.dart'
rg 'name: brain_zip' pubspec.yaml
```

Expected: no matches.

- [ ] **Step 6: Commit** (only if user requested commits)

```bash
git add .vscode/launch.json CLAUDE.md .cursor/rules/bloc-architecture.mdc docs
git commit -m "$(cat <<'EOF'
docs: align project guides and IDE labels with Winklo

EOF
)"
```

---

### Task 3: GitHub repo rename + link updates

**Files:**
- Modify (remote): GitHub repository name via `gh`
- Modify: local git `origin` URL
- Modify: `docs/privacy/index.html` (GitHub issues href)
- Modify: `play/app_content_answers.txt` (GitHub Pages privacy URL)

**Interfaces:**
- Consumes: Task 2 docs awareness
- Produces: `https://github.com/MuhammedFaseenCM/winklo`; updated privacy/issues links

- [ ] **Step 1: Rename GitHub repository**

```bash
gh repo rename winklo --yes
```

Expected: repo becomes `MuhammedFaseenCM/winklo`. GitHub redirects old `brain_zip` URLs.

- [ ] **Step 2: Point local origin at the new URL**

```bash
git remote set-url origin https://github.com/MuhammedFaseenCM/winklo.git
git remote -v
```

Expected: fetch/push both show `…/winklo.git`.

- [ ] **Step 3: Update privacy / Play content links**

In `docs/privacy/index.html`, change the issues link host path from `/brain_zip/issues` to `/winklo/issues`.

In `play/app_content_answers.txt`, change:

```text
https://muhammedfaseencm.github.io/brain_zip/privacy/
```

to:

```text
https://muhammedfaseencm.github.io/winklo/privacy/
```

(If GitHub Pages is enabled for this repo, redeploy/settings may be needed after rename — verify Pages URL in GitHub Settings → Pages; if Pages still serves under the old path temporarily, keep the working URL until Pages settles, then update.)

- [ ] **Step 4: Verify remote**

```bash
gh repo view --json name,url,nameWithOwner
```

Expected: `"name":"winklo"`, `nameWithOwner` `MuhammedFaseenCM/winklo`.

- [ ] **Step 5: Commit link updates** (only if user requested commits)

```bash
git add docs/privacy/index.html play/app_content_answers.txt
git commit -m "$(cat <<'EOF'
chore: update GitHub links after winklo repo rename

EOF
)"
```

Do **not** `git push` unless the user explicitly asks.

---

### Task 4: Local folder rename + final verification

**Files:**
- Filesystem: `/Users/muhammedfaseencm/brain_zip` → `/Users/muhammedfaseencm/winklo`
- No source edits required if Tasks 1–3 are done

**Interfaces:**
- Consumes: Tasks 1–3 complete; working tree preferably clean or intentional
- Produces: workspace lives at `…/winklo`

- [ ] **Step 1: Close or pause IDE binding if needed**

Cursor may still have the old folder open. Prefer completing git/status checks from a shell first, then rename.

- [ ] **Step 2: Rename the directory**

From parent:

```bash
cd /Users/muhammedfaseencm
mv brain_zip winklo
cd winklo
pwd
```

Expected: `/Users/muhammedfaseencm/winklo`.

- [ ] **Step 3: Final verification from new path**

```bash
flutter pub get
rg 'package:brain_zip/' lib test --glob '*.dart'
rg 'name: brain_zip' pubspec.yaml
git remote -v
gh repo view --json nameWithOwner
flutter test
```

Expected: package name `winklo`, no `package:brain_zip/` imports, remote and GitHub name are winklo, tests pass.

- [ ] **Step 4: Reopen workspace**

Open `/Users/muhammedfaseencm/winklo` in Cursor (File → Open Folder). Old `brain_zip` path should no longer be used.

---

## Self-review (plan vs spec)

| Spec requirement | Task |
|------------------|------|
| Dart package `winklo` + imports | Task 1 |
| IDE / CLAUDE / cursor rules / docs paths | Task 2 |
| GitHub rename + origin | Task 3 |
| Privacy / Pages link updates | Task 3 |
| Folder rename | Task 4 |
| Leave Android applicationId | Global Constraints |
| Leave Zip game names | Global Constraints |
| Leave Firebase IDs / `google-services.json` | Global Constraints |
| Verification commands | Tasks 1 and 4 |

**Placeholder scan:** none intentional.  
**Known leftover:** `android/app/google-services.json` may still list `"package_name": "com.brainzip.brain_zip"` while Gradle uses `com.winklo.faseencm` — out of scope; mention in summary only, do not “fix” as part of this plan.
