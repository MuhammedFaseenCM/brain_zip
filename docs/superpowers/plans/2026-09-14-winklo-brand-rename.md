# Winklo Brand Rename Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the whole-app brand (Zip / Brain Zip) with **Winklo** in user-facing strings, Android launcher label, and home hero — without renaming Zip / Word Match / Category Race as games or the `brain_zip` package.

**Architecture:** Centralize brand copy in `AppStrings`, wire `MaterialApp.title` and home hero to `appTitle`, update Android `android:label`, and rename the root widget `BrainZipApp` → `WinkloApp` for code clarity. Zip-game CTAs and feature code stay Zip-named.

**Tech Stack:** Flutter / Dart, existing `AppStrings`, AndroidManifest, `flutter_test`.

## Global Constraints

- Follow spec: `docs/superpowers/specs/2026-09-14-winklo-brand-name-design.md`
- App name: **Winklo**; store/home genre line: **Quick solo mini-games.**
- Do **not** change Zip game copy (`playTodaysZip`, Zip feature paths, Zip level logic)
- Do **not** rename Dart package `brain_zip` or Android applicationId
- Do **not** redesign logo/icon/splash artwork (out of scope)
- All new user-facing copy via `AppStrings` (project rule)
- Analyze with timed `dart analyze <changed files>` — never MCP `analyze_files`
- Commits only when the user asks (skip commit steps unless explicitly requested)

---

## File structure map

| Path | Responsibility |
|------|----------------|
| `lib/core/strings/app_strings.dart` | `appTitle`, home tagline; keep Zip game strings |
| `lib/app.dart` | `WinkloApp` + `MaterialApp.router(title: AppStrings.appTitle)` |
| `lib/main.dart` | Construct `WinkloApp` |
| `lib/features/home/view/home_screen.dart` | Hero brand + tagline from `AppStrings` |
| `android/app/src/main/AndroidManifest.xml` | Launcher label `Winklo` |
| `test/widget_test.dart` | Assert Winklo brand on home |
| `README.md` | Product title / one-line description |

---

### Task 1: AppStrings + MaterialApp + home hero

**Files:**
- Modify: `lib/core/strings/app_strings.dart`
- Modify: `lib/app.dart`
- Modify: `lib/main.dart`
- Modify: `lib/features/home/view/home_screen.dart`
- Modify: `test/widget_test.dart`

**Interfaces:**
- Consumes: none (foundation)
- Produces: `AppStrings.appTitle` (`'Winklo'`), `AppStrings.homeTagline` (`'Quick solo mini-games.'`), widget `WinkloApp`

- [ ] **Step 1: Write the failing test updates**

In `test/widget_test.dart`, replace `BrainZipApp` with `WinkloApp` and expect the new brand:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:brain_zip/app.dart';
import 'package:brain_zip/core/di/app_repositories.dart';
import 'package:brain_zip/core/strings/app_strings.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  testWidgets('Home shows Winklo brand and daily Zip CTA', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: buildRepositoryProviders(prefs: prefs),
        child: const WinkloApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));

    expect(find.text(AppStrings.appTitle), findsOneWidget);
    expect(find.text(AppStrings.homeTagline), findsOneWidget);
    expect(find.text(AppStrings.playTodaysZip), findsOneWidget);
    expect(find.text(AppStrings.today), findsOneWidget);
    expect(find.text('Choose a puzzle'), findsNothing);
    expect(find.text(AppStrings.wordMatch), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/widget_test.dart`

Expected: FAIL — `WinkloApp` / `AppStrings.homeTagline` undefined, or brand text still `ZIP`.

- [ ] **Step 3: Update `AppStrings`**

Replace the branding section of `lib/core/strings/app_strings.dart` with:

```dart
abstract final class AppStrings {
  static const appTitle = 'Winklo';

  // Home
  static const homeTagline = 'Quick solo mini-games.';
  static const playTodaysZip = "Play today's Zip";
  static const today = 'TODAY';
  static const wordMatch = 'Word Match';
  static const categoryRace = 'Category Race';

  // Zip game branding (feature, not app title)
  static const zipBrand = 'ZIP';

  // Add more as screens migrate
}
```

- [ ] **Step 4: Rename root app widget and wire title**

In `lib/app.dart`:

```dart
import 'package:flutter/material.dart';

import 'core/router/app_router.dart';
import 'core/strings/app_strings.dart';
import 'core/theme/app_theme.dart';

class WinkloApp extends StatefulWidget {
  const WinkloApp({super.key});

  @override
  State<WinkloApp> createState() => _WinkloAppState();
}

class _WinkloAppState extends State<WinkloApp> {
  late final _router = buildRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppStrings.appTitle,
      theme: buildAppTheme(),
      themeMode: ThemeMode.dark,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
```

In `lib/main.dart`, change `BrainZipApp` → `WinkloApp` (keep import of `app.dart`).

- [ ] **Step 5: Update home hero copy**

In `lib/features/home/view/home_screen.dart`:

- Change `AppStrings.zipBrand` → `AppStrings.appTitle` on the hero `Text`
- Change hardcoded `'One fresh puzzle every day.'` → `AppStrings.homeTagline`

Leave `AppStrings.playTodaysZip` and Zip CTA behavior unchanged.

- [ ] **Step 6: Run test to verify it passes**

Run: `flutter test test/widget_test.dart`

Expected: PASS

- [ ] **Step 7: Analyze changed Dart files**

Run: `dart analyze lib/core/strings/app_strings.dart lib/app.dart lib/main.dart lib/features/home/view/home_screen.dart test/widget_test.dart`

Expected: No issues

- [ ] **Step 8: Commit** (only if user asked)

```bash
git add lib/core/strings/app_strings.dart lib/app.dart lib/main.dart \
  lib/features/home/view/home_screen.dart test/widget_test.dart
git commit -m "$(cat <<'EOF'
feat: show Winklo as the whole-app brand on home

EOF
)"
```

---

### Task 2: Android launcher label + README

**Files:**
- Modify: `android/app/src/main/AndroidManifest.xml`
- Modify: `README.md`

**Interfaces:**
- Consumes: brand name `Winklo` from Task 1 / spec
- Produces: launcher label + README title aligned with store-facing name

- [ ] **Step 1: Update Android application label**

In `android/app/src/main/AndroidManifest.xml`, change:

```xml
android:label="Winklo"
```

(was `"Zip"`). Do not change `android:name`, icon, or activity config.

- [ ] **Step 2: Update README product title**

Replace the top of `README.md` with:

```markdown
# Winklo

Solo Android mini-games built with Flutter + Flame:

1. **Zip** — drag a path through numbered cells (1→N), avoid walls, fill the grid  
2. **Word Match** — drag words onto their pairs  
3. **Category Race** — timed category + letter typing race  

Content loads from **Firebase Firestore** when configured, otherwise from local seed assets. High scores use `shared_preferences`.
```

Keep the rest of the README (Run / Firebase / Project layout) unchanged.

- [ ] **Step 3: Smoke-check for leftover app-title Zip**

Run: `rg -n "title: 'Zip'|android:label=\"Zip\"|AppStrings\\.appTitle = 'Zip'|BrainZipApp" lib android test README.md`

Expected: no matches (Zip game strings like `playTodaysZip` / `zipBrand` may still appear — that is correct).

- [ ] **Step 4: Commit** (only if user asked)

```bash
git add android/app/src/main/AndroidManifest.xml README.md
git commit -m "$(cat <<'EOF'
chore: set Android launcher label and README to Winklo

EOF
)"
```

---

## Spec coverage check

| Spec item | Task |
|-----------|------|
| App name Winklo | Task 1 (`appTitle`), Task 2 (manifest/README) |
| Store subtitle / genre line | Task 1 (`homeTagline`) |
| Replace Zip-as-app-title | Task 1 (home + MaterialApp) |
| Android launcher label | Task 2 |
| Keep Zip / Word Match / Category Race game names | Task 1 (explicit non-changes) |
| No `brain_zip` package rename | Global Constraints |
| No logo/icon redesign | Global Constraints / out of scope |

## Placeholder scan

No TBD / “implement later” / vague steps remaining.
