# Architecture

## Package boundary

Direct `shadcn_ui` imports belong exclusively in `packages/kite_ui/`.
App code imports the reusable widgets from `package:kite_ui/kite_ui.dart` and,
when needed, the explicit bridge at `package:kite_ui/shadcn.dart`.
CI checks this boundary so dependency changes stay concentrated in the UI layer.

The app uses a path dependency on `kite_ui`: contributors can edit the actual
widget implementation without publishing a package or introducing overrides.
`KiteColors` and `KiteText` expose theme values; the package also owns chart
and data-grid integration.

## Layout

```text
lib/
  main.dart             URL strategy and ProviderScope
  app.dart              Theme, localization, and router composition
  core/
    auth/               AuthRepository, Supabase Auth, sessions, and server roles
    data/               DataProvider, role guard, backend factory, and adapters
    preferences/        Cached display settings and serialized persistence
    router/             Routes, navigation, auth redirects, and app shell routes
    theme/              Light/dark themes and three accents
    l10n/               Locale controller
  l10n/                 ARB sources and generated translations
  shared/
    layout/             Sidebar, top bar, breadcrumbs, and mobile navigation
    widgets/            Loading, empty, and error states
  features/             Dashboard, resources, search, apps, forms, and system
packages/kite_ui/
  lib/kite_ui.dart       Public widget exports
  lib/shadcn.dart        Named design-library bridge
  lib/src/              Design tokens and widget implementations
  example/              Standalone package example
```

Riverpod controllers manage session, theme, locale, and list query state without
`build_runner`. `go_router` renders authenticated routes inside a persistent
shell. The guard keeps a local return destination in the sign-in URL, preserving
query parameters and fragments. External return URLs and auth loops are rejected.
Router resources are disposed with their provider.

## Data contract

```dart
typedef JsonMap = Map<String, Object?>;

abstract interface class DataProvider {
  Future<ListResult> getList(String resource, ListParams params);
  Future<JsonMap> getOne(String resource, String id);
  Future<JsonMap> create(String resource, JsonMap data);
  Future<JsonMap> update(String resource, String id, JsonMap data);
  Future<void> delete(String resource, String id);
}
```

`ListParams` carries page, page size, search, sort, and filters. `ListResult`
contains the page of rows and the total across all matching records. Decode
into domain models above this boundary when your application needs them.

`lib/core/data/data_source.dart` selects `MockDataProvider` by default. Setting
`KITE_API_URL` selects `RestDataProvider`; its HTTP client is closed when the
provider is disposed. Replace the factory for Supabase or your own adapter.
The public `apiUrlProvider` also supports Riverpod overrides in embedded apps
and tests. Invalid base URLs fail before an HTTP request is made.

- **Mock:** seeded in-memory records with simulated latency and working CRUD.
- **REST:** resource endpoints; total from `X-Total-Count` or a `total` envelope.
- **Supabase:** PostgREST queries, row ranges, exact counts, and optional user JWT.

Resource screens, command search, and dashboard record lists use this contract.
Aggregate dashboard metrics and app examples still include sample data.
Supabase Auth is configured at bootstrap and supplies refreshed tokens to the
adapters. `AuthorizedDataProvider` mirrors role permissions in the client; the
protected role table and RLS policies enforce them on the server. See
[authentication and roles](AUTHENTICATION.md). Without backend configuration,
the template uses a separate, non-persistent demo identity.

Display preferences load before the first frame. Their queued writes survive
rapid selection changes; failures expose a retry in Settings. Native auth
sessions and PKCE verifiers use the OS credential store, separately from
non-sensitive display settings. Web sessions use SDK browser storage.

## Dependency maintenance

The app and CI pin Flutter **3.47.8 / Dart 3.13.7**. `.fvmrc` provides the same
SDK selection locally. `pubspec.yaml` declares minimum supported SDKs; the
root lockfile records the resolved application dependencies.

Direct package versions were checked against pub.dev on **2026-10-27**:

| Package | Constraint |
| --- | --- |
| go_router | ^18.1.1 |
| flutter_riverpod | ^3.4.3 |
| http | ^1.6.0 |
| cupertino_icons | ^2.0.0 |
| url_launcher | ^6.3.3 |
| shadcn_ui | ^0.55.1 |
| fl_chart | ^1.3.0 |
| trina_grid | ^2.3.0 |
| intl | ^0.20.3 |
| flutter_lints | ^6.0.0 |
| supabase_flutter | ^2.18.3 |
| shared_preferences | ^2.5.6 |
| flutter_secure_storage | ^11.2.0 |
| app_links | ^7.2.2 |

`shadcn_ui` 0.57.3 is newer, but `trina_grid` 2.3.0 requires `^0.55.0`.
Keep the newest compatible 0.55.1 until upstream supports newer releases or the
grid integration is deliberately migrated. Do not force dependency overrides
without validating the affected UI and package consumers.

Run `flutter pub outdated` to inspect direct and transitive constraints.
Dependabot checks Dart, policy-test tooling, and GitHub Actions weekly. CI separately analyzes the
UI package and its example, tests responsive widget layouts, validates generated docs,
runs behavior tests,
and builds web (JavaScript, demo Wasm, and production-auth Wasm), Android, iOS, macOS, and Windows.
