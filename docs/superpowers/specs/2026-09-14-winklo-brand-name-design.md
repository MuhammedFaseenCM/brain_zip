# Winklo — app brand name

**Date:** 2026-09-14  
**Status:** Approved  
**Decision:** Rename the whole-app brand from Brain Zip / Zip to **Winklo**.

## Brief

| Constraint | Choice |
|------------|--------|
| What to name | Whole app (store title / umbrella brand) |
| Vibe | Sharp & fast + warm & playful |
| Zip in brand? | No — Zip stays one game inside |
| Genre signal | Abstract brand; genre from icon + store subtitle |

## Brand

- **App name:** Winklo  
- **Store subtitle:** Quick solo mini-games  
- **In-app games (unchanged):** Zip, Word Match, Category Race  
- **Tone:** abstract, friendly speed; not “brain puzzle” literal  

## Collision note

No existing app/game titled **Winklo** found in App Store / Google Play / Steam / itch screening. Near-homophone **Winko** (voice-chat app) exists — differentiate with icon + subtitle. This is not legal trademark clearance; verify package/display name availability before store publish.

## Rename scope (implementation later)

User-facing / store:

- `AppStrings.appTitle` and related branding strings (replace Zip-as-app-title usage)
- Android application label / launcher name
- Splash / marketing copy that presents the app brand (not the Zip game)

Do **not** rename:

- Zip game feature, levels, or Zip-specific UI copy (`playTodaysZip`, path puzzle branding)
- Word Match / Category Race game titles
- Dart package path `brain_zip` unless a separate migration is planned (out of scope for brand lock)

## Out of scope

- New logo / icon redesign (optional follow-up)
- Full package rename (`com.…` / `package:brain_zip`)
- Trademark filing
