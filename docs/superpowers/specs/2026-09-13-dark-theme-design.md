# Dark-only theme (icon ink canvas)

**Date:** 2026-09-13  
**Status:** Approved (Approach 1 — remap `ZipColors` + dark `ThemeData`)  
**Decision:** Force dark theme app-wide; canvas = app icon ink `#0F172A`.

## Palette

| Role | Token | Hex |
|------|-------|-----|
| Canvas | `ink` | `#0F172A` |
| Raised surface | `wall` | `#1E293B` |
| Soft surface | `paper` | `#243044` |
| Soft track / fill | `mistDeep` | `#334155` |
| Canvas alias | `mist` | `#0F172A` |
| Secondary text | `inkSoft` | `#94A3B8` |
| Primary CTA | `ember` | `#FF6B2C` |
| CTA pressed | `emberDeep` | `#E85A1C` |
| Ember wash | `emberSoft` | `#3A241C` |
| Success | `success` | `#2DD4BF` |
| Success wash | `successSoft` | `#134E4A` |
| Numbers / danger accent | `number` | `#FB7185` |
| Outline | theme | `#475569` |
| Outline quiet | theme | `#334155` |
| Primary text | theme `onSurface` | `#F8FAFC` |

## Scope

- Remap `ZipColors` + `buildAppTheme()` → `Brightness.dark`
- Update `ZipAtmosphere`, shared widgets, home/results hardcoded borders
- Align Zip + Word Match Flame paints with dark tokens
- Splash/icon already ink — no change required unless contrast fix needed
