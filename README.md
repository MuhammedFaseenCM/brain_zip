# Winklo

Solo Android mini-games built with Flutter + Flame:

1. **Zip** — drag a path through numbered cells (1→N), avoid walls, fill the grid  
2. **Word Match** — drag words onto their pairs  
3. **Category Race** — timed category + letter typing race  

Content loads from **Firebase Firestore** when configured, otherwise from local seed assets. High scores use `shared_preferences`.

## Run

```bash
flutter pub get
flutter run -d android
```

## Firebase

See [FIREBASE.md](FIREBASE.md). The app runs without Firebase using `assets/`.

## Project layout

- `lib/features/zip` — Flame Zip game  
- `lib/features/word_match` — Flame Word Match  
- `lib/features/category_race` — Flutter Category Race  
- `lib/data` — models + Firestore/asset repositories  
- `assets/` — seed levels, decks, word lists  
