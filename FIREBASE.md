# Firebase setup (Brain Zip)

The app works **without** Firebase using local seed JSON under `assets/`.  
Connect Firebase when you want to edit words/levels remotely.

## 1. Create project

1. Open [Firebase Console](https://console.firebase.google.com/)
2. Create a project (Spark / free plan is fine)
3. Add an **Android** app with package name: `com.brainzip.brain_zip`

## 2. Wire the Android app

```bash
# from project root
dart pub global activate flutterfire_cli
flutterfire configure --project=YOUR_PROJECT_ID --platforms=android
```

Or manually:

1. Download `google-services.json` into `android/app/`
2. In `android/settings.gradle.kts` plugins block, add:
   `id("com.google.gms.google-services") version "4.4.2" apply false`
3. In `android/app/build.gradle.kts` plugins block, add:
   `id("com.google.gms.google-services")`

## 3. Firestore

1. Create a Firestore database
2. Deploy rules from `firestore/firestore.rules` (public read, no client writes)
3. Seed collections (same shape as assets):

### `zip_levels/{id}`
```json
{
  "size": 3,
  "order": 1,
  "numbers": { "0,0": 1, "1,1": 2, "2,2": 3 },
  "walls": []
}
```

### `word_match_decks/{id}`
```json
{
  "title": "Opposites",
  "seconds": 60,
  "order": 1,
  "pairs": [{ "a": "hot", "b": "cold" }]
}
```

### `categories/{id}`
```json
{
  "name": "Animals",
  "order": 1,
  "words": ["ant", "bear", "cat"]
}
```

You can copy fields from files in:

- `assets/zip/levels/`
- `assets/word_match/decks/`
- `assets/words/categories/`

## 4. Behavior

- On launch, the app tries `Firebase.initializeApp()`
- If that fails (no config yet), it uses asset seeds and shows a home banner
- If Firebase works but a collection is empty, it also falls back to assets
- Firestore offline persistence is enabled for solo play after first sync
