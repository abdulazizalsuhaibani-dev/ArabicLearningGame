# CAPTCHA Gamification for Arabic Learning

An Arabic Flutter game for practicing letter recognition using printed CAPTCHA word images. The app works offline and uses Material 2 with the bundled NotoKufi Arabic font. Android is the primary target.

## Implemented features

- Three worlds with three levels each; five correct answers unlock the next level.
- Nine question types: dot count, dot presence, letter count, letter-count comparison, first letter position, letter presence, long-vowel letter count, long-vowel letter presence, and connected letters.
- Forty bundled CAPTCHA images with SQLite metadata.
- Stable questions and answers while retrying an incorrect answer; loading and retry states for unavailable questions.
- A cybersecurity tip after each completed level and a completion message after the ninth level.
- Saved progress across launches, confirmed reset, and Arabic game instructions.

Letter counts ignore vowel marks, spaces, and tatweel. Letter-position questions use the first occurrence, counting from 1. Dot counts, long-vowel counts, and connection flags use the bundled metadata (`T` means connected, `F` means disconnected).

## Setup and run

Install Flutter with Dart SDK compatible with `^3.13.0`, Android Studio, and an Android SDK. From the project directory:

```sh
flutter pub get
flutter devices
flutter run -d <android-device-id>
```

Alternatively, start an Android emulator:

```sh
flutter emulators
flutter emulators --launch <emulator-id>
flutter run -d <android-device-id>
```

The SQLite configuration supports Android and iOS. Web and desktop runners are present, but the current database setup does not support running the game on them.

## Validation

```sh
flutter test
flutter analyze
flutter build apk --debug
flutter test integration_test/game_test.dart -d <android-device-id>
```

Unit and widget tests use fixtures and mock preferences without accessing the global database service. Android integration tests use their own database service and exercise all nine levels, rewards, saved completion, reset, empty/single-row databases, and every bundled image. They reset progress in the test app on the selected device.

The analyzer has five existing informational notices for uppercase color constants; there should be no errors or warnings.

## Code map

- `lib/main.dart`: initializes SQLite and saved progress before displaying the app.
- `lib/classes/answers_generator.dart`: immutable CAPTCHA data and question/answer generation.
- `lib/db_servieces.dart`: copies the bundled database on first launch and selects random images.
- `lib/shared_preferences.dart`: reads, advances, and resets progress using the existing `worldCount` and `cyberCount` keys.
- `lib/views/`: main menu, worlds, gameplay, and settings.

Progress retains the existing encoding: `110`, `120`, `130`, `210`, through `330`; `410` marks completion. Existing installed databases are preserved. Updating the bundled database alone does not replace an installed copy; future schema or content changes need a migration.

## Future work

Handwriting recognition, image processing, typing challenges, and research-data collection are planned features and are not implemented.

Treat handwriting as a separate project: define the drawing input and supported letters, choose an on-device or server recognition approach, evaluate it on representative handwriting with explicit accuracy and response-time targets, and decide consent, retention, and deletion requirements before collecting data. The current game stores only local progress and has no research-data collection pipeline.
