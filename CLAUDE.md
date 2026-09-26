# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Flutter app (Dart SDK `^3.13.0`; Android uses the declarative Gradle plugin DSL) — a CAPTCHA-based game for teaching Arabic letters to kids. Players answer questions about printed CAPTCHA word images; clearing a level unlocks the next one and shows a cyber-security/internet-safety tip as a reward. All UI text is Arabic, rendered with the bundled `NotoKufi` font.

## Commands

```bash
flutter pub get            # install dependencies
flutter run                # run on a connected device/emulator (Android is the primary target)
flutter analyze            # lint (flutter_lints 6); currently reports ~50 pre-existing infos/warnings and exits non-zero — check for *errors*
flutter test               # run all tests
flutter test test/widget_test.dart            # run one test file
flutter test --plain-name "<test name>"       # run a single test by name
```

Tests must not touch the global `databaseService` (it is only initialized in `main()`, and sqflite needs a device) — pump `MyApp` from `views/main_menu_view.dart` directly, as `test/widget_test.dart` does. `sqflite` has no web support, so `flutter run -d chrome` won't work; use an Android device/emulator.

## Architecture

**Startup (`lib/main.dart`)** — Initializes a global `late DatabaseService databaseService` and awaits copying/opening the bundled SQLite DB, then kicks off `setInitialWorldValue()` (seeds SharedPreferences defaults) **without awaiting it** before `runApp` — reads of those keys fall back to `??` defaults if they race it. `MyApp` and the main menu (`MyHomePage`) actually live in `lib/views/main_menu_view.dart`, not `main.dart`.

**Data: bundled SQLite (`lib/db_servieces.dart`)** — `db/game_db.db` is shipped as an asset and copied into the app's databases directory on first launch only (if a file already exists it is not replaced, so schema/content changes to the bundled DB won't reach existing installs unless `clearOldDB` is called or the app data is cleared). Tables referenced: `images` (columns `image_id`, `image`, `word`, `number_of_points`, `number_of_md_letters`, `is_connected`) and `selectedImages`. The `image` column is a filename resolved against `assets/images/`.

**CAPTCHA model (`lib/classes/answers_generator.dart`)** — `CaptchaImage` stores everything in **static** fields; constructing it kicks off (without awaiting) a random-row fetch from the DB, and the static getters read whatever row is currently loaded. `Answer` is a simple `(answer, isCorrect)` pair.

**Progression state (SharedPreferences)** — Two int keys drive the whole game:
- `worldCount`: encoded as `world * 100 + level`, where level is 10/20/30 (e.g. `110` = world 1, level 1). Default `110`. `LevelView._incrementLevel` adds 10 and, on reaching `x40`, jumps +70 to the next world's first level (`140 → 210`). `WorldsView.LevelButton` decodes it with `~/ 100` and `% 100` to decide locked / current / completed.
- `cyberCount`: index into `LevelView.cyberAdvice` for the tip shown after each cleared level. Default `-1` (incremented before first display).

Both are reset by the settings screen (`settings_dialog.dart`). `lib/shared_preferences.dart` (`Helper`) is an unused wrapper; views access SharedPreferences directly.

**Level logic (`lib/views/level_view.dart`)** — Question type is selected by `leveltype` (1–9, currently hard-coded), with `isMcq` choosing between multiple-choice (`setPossibleMultipleChoicesAnswers`, types 1/3/5/7) and true/false (`setPossibleTrueFalseAnswers`, types 2/4/6/8/9) answer generation. Answering 5 questions correctly (`questionCount >= 4`) completes the level.

**Styling** — Shared colors and `MaterialColor` swatches are in `lib/classes/constants.dart`, imported as `Constants`. The app theme (in `MyApp`) deliberately uses Material 2 (`useMaterial3: false`); its text theme must be derived from that M2 base theme, not `Theme.of(context)`, or M3 line heights leak in and squeeze the Arabic glyphs (covered by a test in `test/widget_test.dart`).

## Assets

Any new asset directory must be listed under `flutter: assets:` in `pubspec.yaml` (currently `assets/`, `assets/images/`, `db/`).