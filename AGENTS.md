# Repository Guidelines

## Project Structure & Module Organization

Kite is a Flutter admin dashboard with a local, publishable UI package.
- `lib/features/`: dashboard, authentication, resource CRUD, and app screens.
- `lib/core/`: auth, roles, preferences, routing, themes, and data adapters.
- `lib/shared/`: shared layout and state widgets.
- `packages/kite_ui/lib/`: reusable widgets, charts, tables, and design tokens; `example/` contains its standalone demo.
- `lib/l10n/`: ARB translation sources and generated localization classes.
- `test/`: auth, roles, persistence, accessibility, data, and formatting tests; `packages/kite_ui/test/` covers responsive widgets.
- `docs/src/`: documentation sources; `docs/site/` is generated. Documentation images live in `docs/`, including `docs/screenshots/`.
- `tools/` and `scripts/`: documentation, bundle measurement, fonts, and promotional asset tooling. Platform directories contain native runners.

## Build, Test, and Development Commands

Use Flutter 3.47.8 to match CI; the root package requires Dart 3.13.1 or compatible.

- `flutter pub get`: resolve app dependencies, including local `kite_ui`.
- `flutter run -d chrome`: run the dashboard locally with mock data.
- `dart format .`: format Dart sources; CI checks with `dart format --set-exit-if-changed .`.
- `flutter analyze --fatal-infos`: run static analysis and lint checks.
- `flutter test --coverage`: run tests and collect coverage.
- `flutter build web --wasm --release`: produce the WebAssembly release; use `flutter build web --release` for JavaScript.
- `flutter gen-l10n`: regenerate localization classes after ARB edits.
- `python3 tools/build-docs.py`: rebuild documentation from HTML fragments.

## Coding Style & Architecture

Use Dart formatter conventions: two-space indentation, `snake_case.dart` filenames, `UpperCamelCase` types, and `lowerCamelCase` members. Follow `analysis_options.yaml`: single quotes, explicit return types, trailing commas, const constructors, and strict typing.

Keep direct `shadcn_ui` imports inside `packages/kite_ui/`; app code uses Kite widgets and `package:kite_ui/shadcn.dart`. CI enforces this boundary. Route backend access through `DataProvider`. Roles come from `kite_user_roles`; enforce permissions with RLS, never user metadata. Keep auth tokens out of display preferences.

## Testing Guidelines

Use `flutter_test`, name files `*_test.dart`, and describe observable behavior in test names. Add regression tests for changed provider, authentication, and formatting behavior. Run individual suites with `flutter test test/rest_provider_test.dart`. CI collects coverage but defines no minimum percentage.

## Commit & Pull Request Guidelines

Recent commits use short, imperative subjects such as “Extract kite_ui into a publishable package”; follow that style. Keep commits focused. PRs should explain the problem and resulting behavior, link relevant issues, and report validation. Include screenshots for UI changes. Ensure formatting, analysis, tests, and affected platform builds pass. Read `docs/DISTRIBUTION.md` before changing the deliberately ordered README.
