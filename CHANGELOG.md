# Changelog

## [0.2.0] - 2026-10-28

### Added

- Optional Supabase Auth: sign-up, password sign-in, email confirmation by link
  or six- through ten-digit code, PKCE password recovery, and session restoration.
- Server-managed Viewer, Editor, and Admin roles with a migration, row-level
  security policies, route guards, and permission-aware resource actions.
- Secure native session and PKCE storage, plus native callback configuration.
- Persistent theme, accent, and language preferences, including save retry.
- English, Spanish, French, Japanese, and Arabic translations for authentication,
  settings, and resource workflows, including right-to-left layouts.
- Local Supabase/Mailpit setup and integration tests for Auth, roles, revocation,
  and fixture cleanup; independent PostgreSQL policy tests.
- Accessibility checks for labels, contrast, touch targets, keyboard submission,
  error announcements, and narrow layouts at 200% text size.
- Visible demo credentials and placeholders, a configurable public-preview link
  on production sign-in, contributor guidelines, and expanded setup documentation.

### Changed

- Updated Flutter to 3.47.8 and refreshed compatible dependencies and CI actions.
  Committed the app lockfile and added automated dependency update checks.
- Kept the design-library dependency inside `kite_ui`; expanded package checks,
  localization checks, release-build coverage, and web font/bundle guards in CI.
- Improved loading, retry, and permission feedback across resource screens.
- Expanded the README with use cases, demo access, backend setup, and FAQs.

### Fixed

- Vertically centered single-line input values and placeholders, including large
  text and right-to-left layouts, while retaining 48-pixel minimum touch targets.
- Prevented cached roles, user-editable metadata, and late Auth responses from
  granting or restoring access after sign-out or role revocation.
- Preserved bookmarked destinations and password-recovery intent across callbacks.

### Upgrade notes

Use Flutter 3.47.8, run `flutter pub get`, and rebuild your application. Mock mode
still works without configuration. Production Auth requires the included
migration, exact redirect URLs, an SMTP sender, and a trusted initial role
assignment; see [authentication setup](docs/AUTHENTICATION.md). New registrations
receive no resource access until assigned a role. Policies cover one shared
workspace; add tenant isolation before serving unrelated organizations.

Native callback schemes must be customized for your app. Web sessions use SDK
browser storage; display preferences never contain Auth tokens. Some sample
screens still contain English and local-only data. Automated accessibility
checks do not replace assistive-technology testing on target devices.

## 0.1.0

Initial dashboard source: responsive navigation, dashboard and app examples,
resource CRUD with mock/REST/Supabase adapters, themes, command search, and the
extracted `kite_ui` package. This version predates tagged GitHub releases.

[0.2.0]: https://github.com/ColorlibHQ/kite-flutter-admin-dashboard/releases/tag/v0.2.0
