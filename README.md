# 2048 — Flutter Android Game

A polished, offline-capable 2048 puzzle game built with Flutter and Dart.

## Features
- Classic 4×4 2048 gameplay and merge rules
- Swipe controls plus on-screen directional buttons
- Score and best score (best score saved locally)
- Undo last move
- New game and restart confirmation
- Win overlay at 2048, with an option to keep playing
- Game-over detection
- Responsive board, rounded tile colors, subtle animations
- No demo data, ads, accounts, backend, or network requirement

## Run on Android
1. Install Flutter and Android SDK.
2. Extract this ZIP and open the `2048_flutter_android` folder in VS Code.
3. Start an Android emulator or connect an Android device with USB debugging.
4. In the project folder run:

```bash
flutter create . --platforms=android
flutter pub get
flutter run
```

If Flutter reports that Android is not supported by the project, `flutter create . --platforms=android` generates the missing Android platform folder while preserving the Dart source.

## Build an APK
```bash
flutter build apk --release
```
APK output: `build/app/outputs/flutter-apk/app-release.apk`

## Controls
Swipe up/down/left/right on the board, or use the directional buttons below it. Matching tiles combine into their sum; each tile can merge only once per move. Reach 2048 to win.
