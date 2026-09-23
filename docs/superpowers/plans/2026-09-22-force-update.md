# Force Update (version + build) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Soft-prompt or force-update Winklo from Home when the install is behind Firebase Remote Config minimum version and/or build number.

**Architecture:** Pure domain compare + `CheckAppUpdate` usecase; `AppUpdateRepository` reads Remote Config + `PackageInfo` and opens the store; `HomeCubit` owns `none|soft|forced` UI state; Home shows a non-dismissible banner or a Home-only blocking overlay. No app-wide root gate.

**Tech Stack:** Flutter / Dart ^3.12, `flutter_bloc`, `freezed`, `bloc_test`, `mocktail`, `firebase_remote_config`, `package_info_plus`, `url_launcher`.

## Global Constraints

- Follow spec: `docs/superpowers/specs/2026-09-22-force-update-design.md`
- All user-facing copy via `AppStrings`
- Domain must not import Flutter/`package_info_plus`/`url_launcher`/`firebase_*`
- Fail open: RC/Firebase/URL missing → `AppUpdateStatus.none`
- Soft banner is not dismissible; force overlay is Home-only
- Escalation controlled by RC `forceUpdate` boolean
- Android store URL only for launch (`playStoreUrl`); `appStoreUrl` key reserved
- Analyze with timed `dart analyze <changed files>` — never MCP `analyze_files`
- Run `dart format` on touched Dart files
- Commits only when the user asks (skip commit steps unless explicitly requested)

---

## File structure map

| Path | Responsibility |
|------|----------------|
| `lib/domain/app_version.dart` | Pure version/build comparison helpers |
| `lib/domain/entities/app_update_decision.dart` | Status enum + decision value |
| `lib/domain/repositories/app_update_repository.dart` | Policy + install info + openStore |
| `lib/domain/usecases/check_app_update.dart` | Orchestrate compare → decision |
| `lib/data/clients/remote_config_client.dart` | Firebase RC init/refresh/getters |
| `lib/data/repositories/app_update_repository_impl.dart` | PackageInfo + RC + url_launcher |
| `lib/core/firebase/firebase_bootstrap.dart` | Init RC after Firebase ready |
| `lib/core/di/app_repositories.dart` | Register repo + usecase |
| `lib/core/strings/app_strings.dart` | Update copy |
| `lib/features/home/cubit/home_state.dart` | Add update fields |
| `lib/features/home/cubit/home_cubit.dart` | Check on load; openStore |
| `lib/features/home/view/home_screen.dart` | Banner/overlay + resume recheck |
| `lib/features/home/view/widgets/home_update_banner.dart` | Soft banner |
| `lib/features/home/view/widgets/home_force_update_overlay.dart` | Forced dialog overlay |
| `pubspec.yaml` | New deps |
| `android/app/src/main/AndroidManifest.xml` | `https` queries for url_launcher |
| `FIREBASE.md` | RC ops docs |
| `test/domain/app_version_test.dart` | Compare matrix |
| `test/domain/usecases/check_app_update_test.dart` | Usecase |
| `test/features/home/cubit/home_cubit_test.dart` | Extend for update status |
| `test/features/home/view/home_update_widgets_test.dart` | Soft/forced UI |

---

### Task 1: Pure version/build comparison

**Files:**
- Create: `lib/domain/app_version.dart`
- Test: `test/domain/app_version_test.dart`

**Interfaces:**
- Produces:
  - `int compareAppVersions(String a, String b)` — `<0` if a&lt;b, `0` equal, `>0` if a&gt;b
  - `bool isAppUpdateRequired({required String currentVersion, required int currentBuild, required String minVersion, required int minBuild})`

- [ ] **Step 1: Write the failing test**

```dart
import 'package:winklo/domain/app_version.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('compareAppVersions', () {
    test('detects lower patch / minor / major', () {
      expect(compareAppVersions('1.0.0', '1.0.1'), lessThan(0));
      expect(compareAppVersions('1.0.8', '1.1.0'), lessThan(0));
      expect(compareAppVersions('1.9.0', '2.0.0'), lessThan(0));
    });

    test('equal or higher', () {
      expect(compareAppVersions('1.0.8', '1.0.8'), 0);
      expect(compareAppVersions('1.0.9', '1.0.8'), greaterThan(0));
    });

    test('pads missing segments as zero', () {
      expect(compareAppVersions('1.0', '1.0.1'), lessThan(0));
      expect(compareAppVersions('1.0.0', '1.0'), 0);
    });
  });

  group('isAppUpdateRequired', () {
    test('version behind', () {
      expect(
        isAppUpdateRequired(
          currentVersion: '1.0.0',
          currentBuild: 99,
          minVersion: '1.0.1',
          minBuild: 0,
        ),
        isTrue,
      );
    });

    test('same version, build behind', () {
      expect(
        isAppUpdateRequired(
          currentVersion: '1.0.0',
          currentBuild: 2,
          minVersion: '1.0.0',
          minBuild: 3,
        ),
        isTrue,
      );
    });

    test('same version, build ok', () {
      expect(
        isAppUpdateRequired(
          currentVersion: '1.0.0',
          currentBuild: 3,
          minVersion: '1.0.0',
          minBuild: 3,
        ),
        isFalse,
      );
    });

    test('current version higher ignores build', () {
      expect(
        isAppUpdateRequired(
          currentVersion: '1.1.0',
          currentBuild: 1,
          minVersion: '1.0.0',
          minBuild: 99,
        ),
        isFalse,
      );
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/domain/app_version_test.dart`  
Expected: FAIL (library not found)

- [ ] **Step 3: Implement**

```dart
/// Pure dotted-version helpers for force-update checks.
int compareAppVersions(String a, String b) {
  final aParts = a.split('.').map((e) => int.tryParse(e) ?? 0).toList();
  final bParts = b.split('.').map((e) => int.tryParse(e) ?? 0).toList();
  final maxLength = aParts.length > bParts.length ? aParts.length : bParts.length;
  for (var i = 0; i < maxLength; i++) {
    final partA = i < aParts.length ? aParts[i] : 0;
    final partB = i < bParts.length ? bParts[i] : 0;
    if (partA < partB) return -1;
    if (partA > partB) return 1;
  }
  return 0;
}

bool isAppUpdateRequired({
  required String currentVersion,
  required int currentBuild,
  required String minVersion,
  required int minBuild,
}) {
  final cmp = compareAppVersions(currentVersion, minVersion);
  if (cmp < 0) return true;
  if (cmp > 0) return false;
  return currentBuild < minBuild;
}
```

- [ ] **Step 4: Run tests — expect PASS**

Run: `flutter test test/domain/app_version_test.dart`  
Then: `dart format lib/domain/app_version.dart test/domain/app_version_test.dart`

---

### Task 2: Decision entity + repository interface

**Files:**
- Create: `lib/domain/entities/app_update_decision.dart`
- Create: `lib/domain/repositories/app_update_repository.dart`
- Test: `test/domain/entities/app_update_decision_test.dart`

**Interfaces:**
- Produces:
  - `enum AppUpdateStatus { none, soft, forced }`
  - `class AppUpdateDecision { AppUpdateStatus status; String storeUrl; String currentLabel; String requiredLabel; }` with `AppUpdateDecision.none` factory
  - `class AppUpdatePolicy { String minVersion; int minBuildNumber; bool forceUpdate; String playStoreUrl; }`
  - `class AppInstallInfo { String version; int buildNumber; }`
  - `abstract class AppUpdateRepository { Future<AppUpdatePolicy> getPolicy(); Future<AppInstallInfo> getInstallInfo(); Future<bool> openStore(String storeUrl); }`

- [ ] **Step 1: Write the failing test**

```dart
import 'package:winklo/domain/entities/app_update_decision.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('none factory has empty labels and none status', () {
    const d = AppUpdateDecision.none;
    expect(d.status, AppUpdateStatus.none);
    expect(d.storeUrl, isEmpty);
    expect(d.currentLabel, isEmpty);
    expect(d.requiredLabel, isEmpty);
  });
}
```

- [ ] **Step 2: Run — expect FAIL**

- [ ] **Step 3: Implement entity + repository**

```dart
// lib/domain/entities/app_update_decision.dart
enum AppUpdateStatus { none, soft, forced }

class AppUpdateDecision {
  const AppUpdateDecision({
    required this.status,
    this.storeUrl = '',
    this.currentLabel = '',
    this.requiredLabel = '',
  });

  static const none = AppUpdateDecision(status: AppUpdateStatus.none);

  final AppUpdateStatus status;
  final String storeUrl;
  final String currentLabel;
  final String requiredLabel;
}

class AppUpdatePolicy {
  const AppUpdatePolicy({
    required this.minVersion,
    required this.minBuildNumber,
    required this.forceUpdate,
    required this.playStoreUrl,
  });

  final String minVersion;
  final int minBuildNumber;
  final bool forceUpdate;
  final String playStoreUrl;
}

class AppInstallInfo {
  const AppInstallInfo({
    required this.version,
    required this.buildNumber,
  });

  final String version;
  final int buildNumber;
}
```

```dart
// lib/domain/repositories/app_update_repository.dart
import '../entities/app_update_decision.dart';

abstract class AppUpdateRepository {
  Future<AppUpdatePolicy> getPolicy();
  Future<AppInstallInfo> getInstallInfo();
  Future<bool> openStore(String storeUrl);
}
```

- [ ] **Step 4: Run tests — expect PASS; format**

---

### Task 3: CheckAppUpdate usecase

**Files:**
- Create: `lib/domain/usecases/check_app_update.dart`
- Test: `test/domain/usecases/check_app_update_test.dart`

**Interfaces:**
- Consumes: `AppUpdateRepository`, `isAppUpdateRequired`, `AppUpdateDecision`
- Produces: `class CheckAppUpdate { Future<AppUpdateDecision> call(); }`

- [ ] **Step 1: Write failing usecase tests**

```dart
import 'package:winklo/domain/entities/app_update_decision.dart';
import 'package:winklo/domain/repositories/app_update_repository.dart';
import 'package:winklo/domain/usecases/check_app_update.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAppUpdateRepository extends Mock implements AppUpdateRepository {}

void main() {
  late _MockAppUpdateRepository repo;
  late CheckAppUpdate check;

  setUp(() {
    repo = _MockAppUpdateRepository();
    check = CheckAppUpdate(repo);
  });

  test('returns none when minVersion is 0.0.0', () async {
    when(() => repo.getPolicy()).thenAnswer(
      (_) async => const AppUpdatePolicy(
        minVersion: '0.0.0',
        minBuildNumber: 5,
        forceUpdate: true,
        playStoreUrl: 'https://play.google.com/store/apps/details?id=com.winklo.faseencm',
      ),
    );
    when(() => repo.getInstallInfo()).thenAnswer(
      (_) async => const AppInstallInfo(version: '1.0.0', buildNumber: 1),
    );

    final result = await check();
    expect(result.status, AppUpdateStatus.none);
  });

  test('returns soft when behind and forceUpdate false', () async {
    when(() => repo.getPolicy()).thenAnswer(
      (_) async => const AppUpdatePolicy(
        minVersion: '1.0.0',
        minBuildNumber: 2,
        forceUpdate: false,
        playStoreUrl: 'https://play.google.com/store/apps/details?id=com.winklo.faseencm',
      ),
    );
    when(() => repo.getInstallInfo()).thenAnswer(
      (_) async => const AppInstallInfo(version: '1.0.0', buildNumber: 1),
    );

    final result = await check();
    expect(result.status, AppUpdateStatus.soft);
    expect(result.currentLabel, '1.0.0+1');
    expect(result.requiredLabel, '1.0.0+2');
    expect(result.storeUrl, contains('com.winklo.faseencm'));
  });

  test('returns forced when behind and forceUpdate true', () async {
    when(() => repo.getPolicy()).thenAnswer(
      (_) async => const AppUpdatePolicy(
        minVersion: '2.0.0',
        minBuildNumber: 0,
        forceUpdate: true,
        playStoreUrl: 'https://play.google.com/store/apps/details?id=com.winklo.faseencm',
      ),
    );
    when(() => repo.getInstallInfo()).thenAnswer(
      (_) async => const AppInstallInfo(version: '1.0.0', buildNumber: 10),
    );

    final result = await check();
    expect(result.status, AppUpdateStatus.forced);
  });

  test('returns none when playStoreUrl empty', () async {
    when(() => repo.getPolicy()).thenAnswer(
      (_) async => const AppUpdatePolicy(
        minVersion: '9.0.0',
        minBuildNumber: 0,
        forceUpdate: true,
        playStoreUrl: '',
      ),
    );
    when(() => repo.getInstallInfo()).thenAnswer(
      (_) async => const AppInstallInfo(version: '1.0.0', buildNumber: 1),
    );

    final result = await check();
    expect(result.status, AppUpdateStatus.none);
  });

  test('returns none when repository throws', () async {
    when(() => repo.getPolicy()).thenThrow(Exception('offline'));
    final result = await check();
    expect(result.status, AppUpdateStatus.none);
  });
}
```

- [ ] **Step 2: Run — expect FAIL**

- [ ] **Step 3: Implement usecase**

```dart
import '../app_version.dart';
import '../entities/app_update_decision.dart';
import '../repositories/app_update_repository.dart';

class CheckAppUpdate {
  CheckAppUpdate(this._repo);

  final AppUpdateRepository _repo;

  Future<AppUpdateDecision> call() async {
    try {
      final policy = await _repo.getPolicy();
      final install = await _repo.getInstallInfo();

      final minVersion = policy.minVersion.trim();
      if (minVersion.isEmpty || minVersion == '0.0.0') {
        return AppUpdateDecision.none;
      }

      final storeUrl = policy.playStoreUrl.trim();
      if (storeUrl.isEmpty) {
        return AppUpdateDecision.none;
      }

      final needed = isAppUpdateRequired(
        currentVersion: install.version,
        currentBuild: install.buildNumber,
        minVersion: minVersion,
        minBuild: policy.minBuildNumber,
      );
      if (!needed) return AppUpdateDecision.none;

      return AppUpdateDecision(
        status: policy.forceUpdate
            ? AppUpdateStatus.forced
            : AppUpdateStatus.soft,
        storeUrl: storeUrl,
        currentLabel: '${install.version}+${install.buildNumber}',
        requiredLabel: '$minVersion+${policy.minBuildNumber}',
      );
    } catch (_) {
      return AppUpdateDecision.none;
    }
  }
}
```

- [ ] **Step 4: Run tests — expect PASS; format**

---

### Task 4: Remote Config client + repository impl + deps

**Files:**
- Modify: `pubspec.yaml` — add `firebase_remote_config`, `package_info_plus`, `url_launcher`
- Create: `lib/data/clients/remote_config_client.dart`
- Create: `lib/data/repositories/app_update_repository_impl.dart`
- Modify: `lib/core/firebase/firebase_bootstrap.dart` — call RC init when Firebase ready
- Modify: `android/app/src/main/AndroidManifest.xml` — add HTTPS intent queries for store URLs
- Test: `test/data/repositories/app_update_repository_impl_test.dart` (optional light test with fake; prefer mocking at usecase — if hard to unit without plugins, skip and rely on Task 3 + manual RC check)

**Interfaces:**
- Consumes: `FirebaseBootstrap.isReady`, `FirebaseRemoteConfig`
- Produces:
  - `RemoteConfigClient.instance.initialize()` / `refresh()` / getters
  - Keys: `appVersion`, `minBuildNumber`, `forceUpdate`, `playStoreUrl`, `appStoreUrl`
  - Defaults: `appVersion: '0.0.0'`, `minBuildNumber: 0`, `forceUpdate: false`, play URL for `com.winklo.faseencm`, `appStoreUrl: ''`
  - `AppUpdateRepositoryImpl implements AppUpdateRepository`

- [ ] **Step 1: Add dependencies**

```bash
cd /Users/muhammedfaseencm/winklo
flutter pub add firebase_remote_config package_info_plus url_launcher
```

- [ ] **Step 2: Implement `RemoteConfigClient`**

Mirror Urbania’s client, scoped to update keys only:

```dart
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

class RemoteConfigClient {
  RemoteConfigClient._();
  static final instance = RemoteConfigClient._();

  bool _initialized = false;
  Map<String, dynamic> _defaults = const {};

  bool get isInitialized => _initialized;

  static const kAppVersionKey = 'appVersion';
  static const kMinBuildNumberKey = 'minBuildNumber';
  static const kForceUpdateKey = 'forceUpdate';
  static const kAppStoreUrlKey = 'appStoreUrl';
  static const kPlayStoreUrlKey = 'playStoreUrl';

  static const defaultPlayStoreUrl =
      'https://play.google.com/store/apps/details?id=com.winklo.faseencm';

  static Map<String, dynamic> defaultValues() => {
        kAppVersionKey: '0.0.0',
        kMinBuildNumberKey: 0,
        kForceUpdateKey: false,
        kAppStoreUrlKey: '',
        kPlayStoreUrlKey: defaultPlayStoreUrl,
      };

  Future<void> initialize({
    Map<String, dynamic>? defaults,
    Duration fetchTimeout = const Duration(seconds: 10),
    Duration minimumFetchInterval = Duration.zero,
  }) async {
    if (_initialized) return;
    _initialized = true;
    _defaults = defaults ?? defaultValues();
    try {
      final remoteConfig = FirebaseRemoteConfig.instance;
      await remoteConfig.setDefaults(_defaults);
      await remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: fetchTimeout,
          minimumFetchInterval: minimumFetchInterval,
        ),
      );
      await remoteConfig.fetchAndActivate();
    } catch (e) {
      debugPrint('RemoteConfigClient: init failed — $e');
    }
  }

  Future<bool> refresh() async {
    if (!_initialized) return false;
    try {
      return await FirebaseRemoteConfig.instance.fetchAndActivate();
    } catch (e) {
      debugPrint('RemoteConfigClient: refresh failed — $e');
      return false;
    }
  }

  String getString(String key) { /* trim; fallback to _defaults */ }
  bool getBool(String key) { /* … */ }
  int getInt(String key) { /* … */ }

  String get appVersion => getString(kAppVersionKey);
  int get minBuildNumber => getInt(kMinBuildNumberKey);
  bool get forceUpdate => getBool(kForceUpdateKey);
  String get playStoreUrl => getString(kPlayStoreUrlKey);
  String get appStoreUrl => getString(kAppStoreUrlKey);
}
```

Fill getters with the same fail-safe pattern as Urbania (`_defaults` when not initialized / on throw).

- [ ] **Step 3: Implement `AppUpdateRepositoryImpl`**

```dart
class AppUpdateRepositoryImpl implements AppUpdateRepository {
  AppUpdateRepositoryImpl({RemoteConfigClient? remoteConfig})
      : _remoteConfig = remoteConfig ?? RemoteConfigClient.instance;

  final RemoteConfigClient _remoteConfig;

  @override
  Future<AppUpdatePolicy> getPolicy() async {
    await _remoteConfig.refresh();
    return AppUpdatePolicy(
      minVersion: _remoteConfig.appVersion,
      minBuildNumber: _remoteConfig.minBuildNumber,
      forceUpdate: _remoteConfig.forceUpdate,
      playStoreUrl: _remoteConfig.playStoreUrl,
    );
  }

  @override
  Future<AppInstallInfo> getInstallInfo() async {
    final info = await PackageInfo.fromPlatform();
    return AppInstallInfo(
      version: info.version,
      buildNumber: int.tryParse(info.buildNumber) ?? 0,
    );
  }

  @override
  Future<bool> openStore(String storeUrl) async {
    try {
      final uri = Uri.parse(storeUrl);
      if (!await canLaunchUrl(uri)) return false;
      return launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}
```

- [ ] **Step 4: Hook bootstrap**

In `FirebaseBootstrap.init()`, after `isReady = true`, call:

```dart
await RemoteConfigClient.instance.initialize(
  defaults: RemoteConfigClient.defaultValues(),
  minimumFetchInterval:
      kDebugMode ? Duration.zero : const Duration(minutes: 15),
);
```

Do **not** init RC when Firebase init failed.

- [ ] **Step 5: AndroidManifest queries**

Inside existing `<queries>`, add:

```xml
<intent>
    <action android:name="android.intent.action.VIEW" />
    <data android:scheme="https" />
</intent>
```

- [ ] **Step 6: Analyze + format changed files**

Run: `dart analyze lib/data/clients/remote_config_client.dart lib/data/repositories/app_update_repository_impl.dart lib/core/firebase/firebase_bootstrap.dart`  
Expected: no issues

---

### Task 5: DI registration

**Files:**
- Modify: `lib/core/di/app_repositories.dart`

**Interfaces:**
- Produces: `RepositoryProvider<AppUpdateRepository>`, `RepositoryProvider<CheckAppUpdate>`

- [ ] **Step 1: Register providers**

```dart
RepositoryProvider<AppUpdateRepository>(
  create: (_) => AppUpdateRepositoryImpl(),
),
RepositoryProvider<CheckAppUpdate>(
  create: (context) => CheckAppUpdate(context.read<AppUpdateRepository>()),
),
```

Place near other repository providers (after analytics is fine).

- [ ] **Step 2: Analyze DI file — expect clean**

---

### Task 6: HomeState + HomeCubit

**Files:**
- Modify: `lib/features/home/cubit/home_state.dart`
- Modify: `lib/features/home/cubit/home_cubit.dart`
- Modify: `test/features/home/cubit/home_cubit_test.dart`
- Run build_runner for freezed

**Interfaces:**
- Consumes: `CheckAppUpdate`, `AppUpdateRepository.openStore` (via cubit method)
- Produces on `HomeState`:
  - `@Default(AppUpdateStatus.none) AppUpdateStatus updateStatus`
  - `@Default('') String updateStoreUrl`
  - `@Default('') String updateCurrentLabel`
  - `@Default('') String updateRequiredLabel`
- Cubit: inject `CheckAppUpdate checkAppUpdate` + `AppUpdateRepository appUpdateRepository`; `load()` also applies decision; `Future<void> openStore()`; `Future<void> recheckUpdate()`

- [ ] **Step 1: Extend HomeState**

Add fields above to the freezed factory. Import `app_update_decision.dart`.

- [ ] **Step 2: Regenerate freezed**

```bash
dart run build_runner build --delete-conflicting-outputs
```

- [ ] **Step 3: Update HomeCubit**

```dart
HomeCubit({
  required this.getBestPoints,
  required this.getBestTimeSeconds,
  required this.getStreak,
  required this.analytics,
  required this.checkAppUpdate,
  required this.appUpdateRepository,
  DateTime? now,
  this.playPeriod = PlayPeriod.daily,
}) : ...

final CheckAppUpdate checkAppUpdate;
final AppUpdateRepository appUpdateRepository;

Future<void> load() async {
  // existing score/streak load …
  final decision = await checkAppUpdate();
  if (isClosed) return;
  emit(state.copyWith(
    // …existing fields…
    updateStatus: decision.status,
    updateStoreUrl: decision.storeUrl,
    updateCurrentLabel: decision.currentLabel,
    updateRequiredLabel: decision.requiredLabel,
  ));
}

Future<void> recheckUpdate() async {
  final decision = await checkAppUpdate();
  if (isClosed) return;
  emit(state.copyWith(
    updateStatus: decision.status,
    updateStoreUrl: decision.storeUrl,
    updateCurrentLabel: decision.currentLabel,
    updateRequiredLabel: decision.requiredLabel,
  ));
}

Future<void> openStore() async {
  final url = state.updateStoreUrl;
  if (url.isEmpty) return;
  await appUpdateRepository.openStore(url);
}
```

Prefer a single emit in `load()` that includes both scores and update decision (await update check after streaks, then one `emit`).

- [ ] **Step 4: Update home_cubit_test.dart**

- Add `_MockCheckAppUpdate` / `_MockAppUpdateRepository`
- Default stubs: `check()` → `AppUpdateDecision.none`; `openStore` → `true`
- Pass mocks into every `HomeCubit(...)` construction
- Add `blocTest` cases:
  - soft decision sets `updateStatus.soft` and labels
  - forced decision sets `updateStatus.forced`

- [ ] **Step 5: Run home cubit tests — expect PASS**

```bash
flutter test test/features/home/cubit/home_cubit_test.dart
```

Also fix any other tests that construct `HomeCubit` directly (search for `HomeCubit(`).

- [ ] **Step 6: Wire HomeScreen BlocProvider**

```dart
HomeCubit(
  getBestPoints: context.read<GetBestPoints>(),
  getBestTimeSeconds: context.read<GetBestTimeSeconds>(),
  getStreak: context.read<GetStreak>(),
  analytics: context.read<AnalyticsRepository>(),
  checkAppUpdate: context.read<CheckAppUpdate>(),
  appUpdateRepository: context.read<AppUpdateRepository>(),
  playPeriod: DevFlags.playPeriod,
)..load(),
```

---

### Task 7: AppStrings + Home UI widgets

**Files:**
- Modify: `lib/core/strings/app_strings.dart`
- Create: `lib/features/home/view/widgets/home_update_banner.dart`
- Create: `lib/features/home/view/widgets/home_force_update_overlay.dart`
- Modify: `lib/features/home/view/home_screen.dart`
- Test: `test/features/home/view/home_update_widgets_test.dart`

**Interfaces:**
- Strings: `updateRequiredTitle`, `updateAvailableTitle`, `updateRequiredBody`, `updateAvailableBody`, `updateNow`, `updateCantSkip`
- Banner: `HomeUpdateBanner({required String currentLabel, required String requiredLabel, required VoidCallback onUpdate})`
- Overlay: `HomeForceUpdateOverlay({required String currentLabel, required String requiredLabel, required Future<void> Function() onUpdate})`

- [ ] **Step 1: Add AppStrings**

```dart
// Force update / soft update
static const updateRequiredTitle = 'Update required';
static const updateAvailableTitle = 'Update available';
static const updateRequiredBody =
    'A new version of Winklo is required to continue. Please update from the Play Store.';
static const updateAvailableBody =
    'A new version of Winklo is available. Please update for the latest fixes and puzzles.';
static const updateNow = 'Update now';
static const updateCantSkip = "This update can't be skipped.";
```

- [ ] **Step 2: Soft banner widget**

Non-dismissible; ZipColors paper/wall/ember; title + body + optional version row + filled Update button. No close icon.

- [ ] **Step 3: Force overlay widget**

`Positioned.fill` Material `Colors.black54` + centered dialog card (same content tone as Urbania, Winklo colors). No barrier dismiss. Update button calls `onUpdate`.

- [ ] **Step 4: Wire HomeScreen**

Convert the scaffold body to a `Stack`:

1. Existing scroll/content
2. If soft: insert `HomeUpdateBanner` near the top of the column (above game tiles)
3. If forced: `HomeForceUpdateOverlay` as `Positioned.fill` on the Stack

Wrap with a small `StatefulWidget` (e.g. `_HomeView`) that mixes in `WidgetsBindingObserver`, calls `context.read<HomeCubit>().recheckUpdate()` on `resumed`.

Banner/overlay `onUpdate` → `context.read<HomeCubit>().openStore()`.

- [ ] **Step 5: Widget tests**

```dart
testWidgets('soft banner shows update copy', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: HomeUpdateBanner(
          currentLabel: '1.0.0+1',
          requiredLabel: '1.0.0+2',
          onUpdate: () {},
        ),
      ),
    ),
  );
  expect(find.text(AppStrings.updateAvailableTitle), findsOneWidget);
  expect(find.text(AppStrings.updateNow), findsOneWidget);
});

testWidgets('force overlay blocks underlying button', (tester) async {
  var tapped = false;
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Stack(
          children: [
            TextButton(
              onPressed: () => tapped = true,
              child: const Text('Play'),
            ),
            HomeForceUpdateOverlay(
              currentLabel: '1.0.0+1',
              requiredLabel: '2.0.0+0',
              onUpdate: () async {},
            ),
          ],
        ),
      ),
    ),
  );
  await tester.tap(find.text('Play'), warnIfMissed: false);
  expect(tapped, isFalse);
  expect(find.text(AppStrings.updateRequiredTitle), findsOneWidget);
  expect(find.text(AppStrings.updateCantSkip), findsOneWidget);
});
```

- [ ] **Step 6: Run widget + home tests; format; analyze touched UI files**

```bash
flutter test test/features/home/
dart analyze lib/features/home lib/core/strings/app_strings.dart
```

Also run `flutter test test/widget_test.dart` — Home still loads with new DI deps (RC fail-open).

---

### Task 8: FIREBASE.md ops docs

**Files:**
- Modify: `FIREBASE.md`

- [ ] **Step 1: Add section “Remote Config (force update)”**

Document keys, defaults, soft vs force procedure, fail-open behavior, and that Play Store URL must be set. Note Data Safety: no new PII; confirm existing Firebase disclosures cover Remote Config.

- [ ] **Step 2: Done when docs match the table in the design spec**

---

## Self-review (plan vs spec)

| Spec requirement | Task |
|------------------|------|
| `appVersion` + `minBuildNumber` compare | 1, 3 |
| `forceUpdate` soft vs forced | 3, 6, 7 |
| Soft non-dismissible Home banner | 7 |
| Forced Home-only overlay | 7 |
| Fail open | 3, 4 |
| Package info behind repository | 2, 4 |
| HomeCubit ownership | 6 |
| Resume recheck | 7 |
| RC init in FirebaseBootstrap | 4 |
| DI | 5 |
| AppStrings | 7 |
| FIREBASE.md | 8 |
| url_launcher + Android queries | 4 |
| Tests (domain/usecase/cubit/widget) | 1–3, 6–7 |

No placeholders left; types consistent (`AppUpdateStatus`, `AppUpdateDecision`, `CheckAppUpdate`, `AppUpdateRepository`).

---

## Execution handoff

Plan complete and saved to `docs/superpowers/plans/2026-09-22-force-update.md`.

**Two execution options:**

1. **Subagent-Driven (recommended)** — fresh subagent per task, review between tasks  
2. **Inline Execution** — run tasks in this session with executing-plans checkpoints  

Which approach?
