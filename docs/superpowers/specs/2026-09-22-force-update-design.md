# Force update (version + build) — design

Date: 2026-09-22  
Status: approved for planning  
Reference: Urbania `force_update` + `minBuildNumber` (Firebase Remote Config), adapted to Winklo BLoC architecture.

## Goal

Let operators require (or gently prompt) players to update Winklo when the installed app is behind a Remote Config minimum **version** and/or **build number**. Soft prompts live on Home; forced updates block Home only until a re-check finds the install is no longer behind (typically after the user updates and returns).

## Decisions

| Topic | Choice |
|-------|--------|
| Surfaces | Soft banner on Home; escalate to Home-only blocking overlay |
| Soft vs force | Remote Config boolean `forceUpdate` |
| Soft dismiss | Not dismissible — stays on Home until the install is no longer behind |
| Forced scope | Home only (not an app-wide root gate) |
| State ownership | `HomeCubit` (Approach 1) |
| Fail behavior | Fail open — never brick the app if RC/Firebase/URL is missing |
| Platforms | Android primary (`playStoreUrl`); keep `appStoreUrl` key for later |

## Architecture

```
Firebase Remote Config
        │
data/clients/remote_config_client.dart
        │
domain/repositories/app_update_repository.dart   (interface)
data/repositories/app_update_repository_impl.dart
        │
domain/usecases/check_app_update.dart
        │  PackageInfo.version + buildNumber vs RC mins
        │
HomeCubit.load() + resume refresh
        │
HomeState.updateStatus: none | soft | forced
        │
HomeScreen: banner (soft) or home-local blocking overlay (forced)
        └─ Update → url_launcher → Play Store
```

### Layer responsibilities

- **`RemoteConfigClient` (data):** Initialize/fetch Firebase Remote Config; typed getters for update keys; safe defaults when Firebase is not ready.
- **`AppUpdateRepository`:** Returns RC mins, `forceUpdate`, store URLs, and current install `version`/`buildNumber` (reads `PackageInfo` in the impl). Domain and usecase stay plugin-free.
- **`CheckAppUpdate` usecase:** Pure Dart — compare current vs required; return `AppUpdateDecision` (`none` / `soft` / `forced` + display labels + store URL).
- **`HomeCubit`:** Call usecase during `load()`; expose result on `HomeState`; `openStore()`; on `forced`, Home UI blocks game entry via overlay (navigation taps covered by barrier).
- **UI:** Soft banner and force dialog widgets under `features/home/view/widgets/`; all copy via `AppStrings`; styling via `ZipColors` / app theme.

## Remote Config keys

| Key | Type | Default | Purpose |
|-----|------|---------|---------|
| `appVersion` | String | `0.0.0` | Minimum required marketing version |
| `minBuildNumber` | Number | `0` | Minimum build when version is equal |
| `forceUpdate` | Boolean | `false` | `true` → Home blocking overlay; `false` → soft banner |
| `playStoreUrl` | String | `https://play.google.com/store/apps/details?id=com.winklo.faseencm` | Android store link |
| `appStoreUrl` | String | `''` (empty) | Reserved for iOS later |

### Comparison rules (Urbania)

1. If `appVersion` is empty or `0.0.0` → **no update** (RC not configured).
2. If `playStoreUrl` is empty → **no update** (Android-first; ignore `appStoreUrl` for now).
3. Compare semantic-ish dotted versions (`1.0.0` vs `1.0.1`); pad missing segments with `0`.
4. If current version **&lt;** required → update needed.
5. If current version **==** required and current build **&lt;** `minBuildNumber` → update needed.
6. If current version **&gt;** required → no update (ignore build).
7. If update needed and `forceUpdate == true` → `forced`; else → `soft`.

Display labels may show `version+build` (e.g. `1.0.0+3`).

## Home state & UX

### State fields

- `updateStatus`: `none` | `soft` | `forced`
- `updateStoreUrl`, `updateCurrentLabel`, `updateRequiredLabel` (empty when `none`)

### Soft (`updateStatus == soft`)

- Non-dismissible banner near the top of Home.
- Primary CTA “Update” opens the store.
- Games remain playable.

### Forced (`updateStatus == forced`)

- Dimmed full-bleed overlay over Home content only.
- Centered dialog: title, short body, current → required, “Update Now”.
- No dismiss / back / skip; barrier blocks taps to game tiles and other Home actions underneath.
- Re-check on app resume so updating then returning can clear the overlay without restart.

### Lifecycle

- Check on Home `load()`.
- Re-check when Home observes `AppLifecycleState.resumed`.
- Initialize Remote Config once inside `FirebaseBootstrap` after a successful `Firebase.initializeApp`; refresh (best-effort) before each update check. If Firebase is not ready, skip RC init and treat all checks as `none`.

## Dependencies

Add:

- `firebase_remote_config`
- `package_info_plus`
- `url_launcher`

## Firebase / ops

Document in `FIREBASE.md`:

1. Enable Remote Config in the Firebase project.
2. Publish the keys above.
3. To soft-prompt: set `appVersion` / `minBuildNumber` above installed clients; leave `forceUpdate` false.
4. To force: same mins + `forceUpdate` true.
5. Always set a valid `playStoreUrl`.

Privacy: Remote Config uses existing Firebase infrastructure; no new PII. Confirm Play Data Safety still accurate; update CSV/docs only if the console requires an explicit Remote Config disclosure beyond current Firebase entries.

## Testing

- **Domain compare unit tests:** version lower/equal/higher; build tie-break when versions equal; pad short versions; `0.0.0` / empty → none.
- **Usecase tests:** mocked repository + fixed package info → none / soft / forced.
- **`HomeCubit` bloc_test:** emissions for each status; soft does not block `openGame` analytics path.
- **Widget tests:** soft banner present; forced overlay present and game tiles not hittable.

## Out of scope

- App-wide root gate
- Dismissible soft banner / “snooze”
- Google Play In-App Updates API
- Shipping iOS (URL key only)
- Optional/non-blocking updates outside Home

## File sketch (implementation)

```
lib/data/clients/remote_config_client.dart
lib/domain/entities/app_update_decision.dart   # or freezed status + fields
lib/domain/repositories/app_update_repository.dart
lib/data/repositories/app_update_repository_impl.dart
lib/domain/usecases/check_app_update.dart
lib/domain/usecases/compare_app_version.dart    # pure helper if useful
lib/features/home/cubit/home_state.dart        # + update fields
lib/features/home/cubit/home_cubit.dart        # check + openStore + resume
lib/features/home/view/widgets/home_update_banner.dart
lib/features/home/view/widgets/home_force_update_dialog.dart
lib/core/strings/app_strings.dart              # copy
lib/core/di/app_repositories.dart              # register repo + usecase
lib/core/firebase/firebase_bootstrap.dart      # RC init hook
FIREBASE.md                                    # ops docs
test/...                                       # as above
```
