# Repository Guidelines

## Project Structure & Module Organization
- `lib/` holds the Flutter application code; keep widgets grouped by feature (e.g., dialogs, providers, pages) and favor small, reusable widgets with accompanying controllers/providers.
- `test/` mirrors `lib/` structure; place widget/unit tests next to the functionality they cover (e.g., `test/chat_interface_test.dart`).
- Platform folders (`android/`, `ios/`, `web/`, `macos/`, `linux/`, `windows/`) contain native integration points—make edits there only when adjusting platform-specific behavior.
- `l10n.yaml` and `lib/l10n/` (generated) manage localized strings; update `.arb` files then run `flutter gen-l10n` (or `flutter pub get` if config changes).
- `icons/` and `assets/` (if used) store static assets; reference them through `pubspec.yaml` entries to keep the asset registry in sync.

## Build, Test, and Development Commands
- `flutter pub get`: fetches dependencies after editing `pubspec.*` or adding assets.
- `flutter run`: runs the app on the last-connected device; use `-d web-server` for the web build.
- `flutter build apk/ios/web`: produces a release bundle for the target platform (example: `flutter build apk --split-per-abi`).
- `flutter analyze`: enforces `analysis_options.yaml` lint rules before merging.
- `dart format lib test`: formats Dart files (run on changed directories).

## Coding Style & Naming Conventions
- Dart code uses 2-space indentation, `lowerCamelCase` for members, and `PascalCase` for classes/widgets.
- Keep widget files named after their main class (e.g., `chat_page.dart` contains `ChatPage`).
- Use the `analysis_options.yaml` rule set; fix analyzer warnings before submitting changes.
- Run `dart format` on affected files before committing to keep formatting consistent.

## Testing Guidelines
- Unit/widget tests live in `test/` and follow the `*_test.dart` suffix; use descriptive names such as `bible_chat_provider_test.dart`.
- Run `flutter test` frequently; focus on provider logic and UI rebuild behavior.
- Keep tests fast—mock external services (e.g., HTTP clients) and avoid hitting real APIs during CI runs.

## Commit & Pull Request Guidelines
- Commit messages follow an imperative style and cite key areas touched (for example, `Add localization keys for onboarding`).
- Each pull request should include a short summary, testing steps, and mention related issues.
- Attach screenshots or screen recordings when UI/layout changes are made to help reviewers validate appearance.
- Re-run `flutter test` and `flutter analyze` locally before proposing a PR to keep CI green.

## Localization & Configuration Tips
- After modifying `.arb` files, regenerate localization classes with `flutter gen-l10n`.
- Keep API keys/configuration out of source control; use `.env` patterns or secret managers per platform.
