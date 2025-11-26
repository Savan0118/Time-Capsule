# Time Capsule — Copilot / AI Agent Guidance

This file is focused on the essential knowledge an AI coding assistant needs to be immediately productive working on this Flutter app.

Short summary
- Flutter mobile app (Android/iOS/desktop) that stores user accounts and memories locally.
- Data persistence: `sqflite` used by `DBHelper` (memories) and `UserDB` (accounts). `SharedPreferences` used via `SessionManager` to persist session info.
- Images are persisted to the app's documents directory under `memory_images` and referenced by file path strings in the DB.

Key architectural files
- `lib/main.dart` — global app routes; `onGenerateRoute` for typed `/view` route.
- `lib/session_manager.dart` — session helpers (saveLogin/getEmail/getUserId/logout).
- `lib/db_helper.dart` — SQLite database for memories. _DB version is set in `_dbVersion` (currently 3). Migrations are handled in `_onUpgrade`.
- `lib/user_db.dart` — SQLite for local user accounts.
- `lib/memory_model.dart` — canonical data model for a Memory. Important: `photoPath` column stores either `''`, a single string (legacy), or a JSON stringified array; `Memory.fromMap` handles both.
- `lib/create_memory_page.dart` — writes images to files, creates Memory instances and inserts them into `DBHelper`.
- `lib/home_page.dart` — loads only the current user's memories using `SessionManager.getEmail()`.

Conventions & patterns (do not break)
- Use `SessionManager` to scope data access. Example: `final email = await SessionManager.getEmail(); await DBHelper().getAllMemoriesForEmail(email!);`.
- `Memory.photoPaths` is canonical; `photoPath` DB column can contain JSON or legacy single value. When adding fields, support backward compatibility in `fromMap`.
- Always check `mounted` after `await` before updating UI. (See `signin_page.dart`, `create_memory_page.dart`.)
- Use `SnackBar` to display user-facing error/confirmation messages (rather than throwing UI errors directly).
- Routes: `main.dart` uses `routes` for basic pages and `onGenerateRoute` for typed routes (e.g. `/view` expects a `Memory`). If you add typed routes, add them to `onGenerateRoute`.
- Import prefixing is used in `main.dart` to avoid name collisions:
  - `import 'memory_model.dart' as mem;` and `import 'session_manager.dart' as session;`

DB & migrations
- When adding new columns or changing the DB schema:
  - Bump `DBHelper._dbVersion`.
  - Update `_onUpgrade` to safely add new columns via `ALTER TABLE` and catch errors if the column already exists.
  - Update `Memory` model `toMap`/`fromMap` to handle missing fields and legacy values.

Image handling
- Images are stored under application's documents directory: `getApplicationDocumentsDirectory()` then `memory_images`.
- `create_memory_page.dart` writes images using `File.writeAsBytes` and saves string paths into the Memory model.
- When deleting a memory, `home_page.dart` deletes the image files. Keep these two behaviors synchronized.

Platform permissions
- Android: `AndroidManifest.xml` includes `CAMERA`, `READ_EXTERNAL_STORAGE`, `WRITE_EXTERNAL_STORAGE`, and `READ_MEDIA_IMAGES` (Android 13+). Flutter will request runtime permissions via `image_picker`.
- iOS: `Info.plist` currently lacks camera/photo key entries (e.g., `NSCameraUsageDescription`, `NSPhotoLibraryAddUsageDescription`); add them when working with camera/gallery code.

Common developer workflows
- Setup: `flutter pub get`
- Run on iOS/Android: `flutter run -d <deviceId>` (ensure iOS requires macOS and `pod install` for native dependencies).
- Clean & rebuild: `flutter clean; flutter pub get; flutter run`.
- Reset DB locally: uninstall the app or delete the DB on device; `sqflite` stores DB in app data path returned by `getDatabasesPath()`.
- Debugging images: check `getApplicationDocumentsDirectory()` and inspect the `memory_images` folder on the device or emulator.

Integration & external deps
- `sqflite`, `path`, `path_provider`, `shared_preferences`, `image_picker`, `intl`.
- Check code that uses these packages for platform-specific setup (e.g., native permissions, Android 11+ scoped storage considerations).

Safety & security
- Passwords are currently saved as plain text in `UserDB`. Treat this as unsafe for production. Use secure storage or hashing for password data when evolving the app.
- Avoid exposing user file paths in logs; these point to app-controlled data and may contain PII (photo paths).

Testing & quality
- There are currently no automated tests in `lib/` — add unit tests for `Memory.fromMap`, `DBHelper` migrations, and `SessionManager` helpers.
- Suggested targets to test: insert/update/delete behavior in `DBHelper`, migration from old to new database schema, backward/forward compatibility of `memory_model.dart`.

Example tasks and tips
- Add a new memory field (e.g. `tags`): (1) bump `_dbVersion`, (2) add `ALTER TABLE` migration in `_onUpgrade`, (3) add `tags` to `Memory`, support missing values in `fromMap` and serialization in `toMap`.
- Add a new route with typed arguments: add to `routes` in `main.dart`, and if the route requires typed args, update `onGenerateRoute` with type checks and a MaterialPageRoute that constructs the page with the typed object.

Files to always check for related changes
- `lib/main.dart`, `lib/memory_model.dart`, `lib/db_helper.dart`, `lib/user_db.dart`, `lib/create_memory_page.dart`, `lib/home_page.dart`, `lib/view_page.dart`, `lib/session_manager.dart`, `pubspec.yaml`, `android/app/src/main/AndroidManifest.xml`, `ios/Runner/Info.plist`.

PR checklist for contributors
1. Pass `flutter analyze` and `flutter test` (add tests if feature warrants them).
2. If DB schema changed: update `_dbVersion`, add migration code, and add tests for migration or manual testing steps in PR description.
3. If adding camera/gallery functionality: ensure required native permissions are declared for all target platforms.
4. Keep UI updates behind `if (mounted)` when using async operations.
5. Maintain backward compatibility when changing `Memory` or DB serialization format.

If anything in these instructions is unclear or incomplete — please ask. I can expand sections (migration examples, test scaffolding, or common PR templates) on request.
