## BrainZip — Project guide (BLoC + domain/data)

This repo uses **feature-first** organization with a clean separation of **domain** (pure business logic) and **data** (implementations).

## `lib/` layout

- `lib/main.dart`
  - App entrypoint. Sets up bootstrap + DI (e.g. `MultiRepositoryProvider`).
- `lib/app.dart`
  - Root `MaterialApp`/routing + top-level wiring.

- `lib/core/`
  - **Cross-cutting** utilities shared across features.
  - Typical subfolders:
    - `core/bloc/` (observers, shared bloc utilities)
    - `core/di/` (repository provider builders, app-level DI)
    - `core/router/` (navigation/routing)
    - `core/strings/` (`AppStrings` for all user-facing copy)
    - `core/theme/` (themes, typography)
    - `core/widgets/` (shared widgets used by 2+ features)

- `lib/domain/`
  - **Pure Dart** business rules:
    - `domain/entities/` value types / models
    - `domain/failures.dart` error/failure types
    - `domain/repositories/` repository *interfaces* only
    - `domain/usecases/` single-purpose actions (orchestration)
  - **Rule**: `domain/` must not import Flutter/UI (`package:flutter/*`, widgets, `BuildContext`).

- `lib/data/`
  - Concrete implementations:
    - `data/clients/` external clients (network, storage, etc.)
    - `data/repositories/` `*_repository_impl.dart` implementing `domain/repositories/*`
  - Keep mapping/serialization here (DTOs/mappers) when needed.

- `lib/features/`
  - Each feature owns UI + state management:
    - `features/<feature>/view/` screens + feature widgets
    - `features/<feature>/bloc/` blocs + events/states (use `freezed` as needed)
    - `features/<feature>/cubit/` cubits + states
    - optional: `features/<feature>/game/` (Flame game code)
    - optional: `features/<feature>/logic/` (pure helpers local to feature)

## State management rules

- Prefer **`Cubit`** for straightforward state.
- Use **`Bloc`** when event-driven flows are clearer or necessary.
- Use **`bloc_test` + `mocktail`** for tests (bloc/cubit tests + repository mocks).

## DI rules

- Register repository implementations via **`RepositoryProvider` / `MultiRepositoryProvider`** in `core/di/`.
- UI reads dependencies from context (`context.read<T>()`), never constructs repositories directly.

## Flame integration rule

- Flame/game code should expose **one-shot callbacks** to the app layer (e.g. `onFinished`, `onScore`).
- Do not keep long-lived app/UI state inside Flame classes; source of truth stays in Cubit/Bloc.

