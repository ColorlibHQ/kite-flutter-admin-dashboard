# Architecture

## The one rule

**No `shadcn_ui` type may appear outside `lib/kite_ui/`.**

It is a pre-1.0 library (0.56) moving fast enough to ship breaking changes mid-build, and it is
also the decision most likely to be revisited — it has 3× the downloads of `forui` but shipped 7
commits last quarter against forui's 90. Feature code imports Kite widgets; Kite widgets import the
design library. When the dependency breaks, the blast radius is one folder.

`lib/kite_ui/_shadcn.dart` is the single import surface — the named swap point.

CI enforces this with a grep. It is not a convention people have to remember.

That wrapper is also the distribution play: it is what gets published to pub.dev as `kite_ui` in
Phase 2. The architecture and the marketing are the same decision.

**Build it as a folder for the whole of Phase 1.** Extracting a layer that twenty-two real screens
have already exercised is safe. Designing a library speculatively and discovering its API is wrong
at screen fifteen is not.

## Layout

```
lib/
├── main.dart
├── app.dart
├── kite_ui/              ← the ONLY folder that imports the design library
│   ├── _shadcn.dart      single import surface — swap point if Spike B fails
│   ├── tokens.dart       colour, spacing, radius, elevation
│   ├── button.dart  card.dart  input.dart  badge.dart
│   ├── data_table.dart   wraps trina_grid
│   └── chart.dart        wraps fl_chart
├── core/
│   ├── router/           go_router: shells, guards, typed routes, 404
│   ├── theme/            light + dark × 3 accents
│   ├── data/             DataProvider + mock / rest / supabase adapters
│   ├── auth/             session controller, guard wiring
│   └── l10n/             5 locales, RTL verified
├── shared/
│   ├── layout/           AppShell, sidebar, topbar, breadcrumbs
│   └── widgets/          KpiCard, ChartCard, EmptyState, ErrorState
└── features/
    ├── dashboard/        analytics · ecommerce · project
    ├── auth/             sign_in · sign_up · reset · otp · lock
    ├── resources/        generic list / detail / form — drives all CRUD
    ├── apps/             inbox · calendar · kanban · chat
    ├── forms/            elements · layouts · wizard
    └── system/           settings · profile · errors
```

## DataProvider

react-admin's entire value is that screens don't know where data comes from. No Flutter admin
template has an equivalent, and it is a few hundred lines.

Deliberately untyped at the boundary — the template cannot know the user's models, and forcing a
codegen step on someone evaluating a template is how you lose them in the first ten minutes.

```dart
typedef JsonMap = Map<String, Object?>;

final class ListParams {
  const ListParams({
    this.page = 1,
    this.perPage = 25,
    this.sort,
    this.filters = const {},
  });

  final int page;
  final int perPage;
  final SortSpec? sort;
  final Map<String, Object?> filters;
}

final class ListResult {
  const ListResult({required this.rows, required this.total});
  final List<JsonMap> rows;
  final int total; // server-side total — drives pagination
}

/// Implement this once against your backend and every screen works.
abstract interface class DataProvider {
  Future<ListResult> getList(String resource, ListParams params);
  Future<JsonMap>    getOne (String resource, String id);
  Future<JsonMap>    create (String resource, JsonMap data);
  Future<JsonMap>    update (String resource, String id, JsonMap data);
  Future<void>       delete (String resource, String id);
}
```

Ships with three: `MockDataProvider` (default, zero setup), `RestDataProvider`,
`SupabaseDataProvider`.

**The mock adapter is the most important one.** It is what someone sees in the first sixty seconds:
`git clone` → `flutter run` → a working admin with realistic data, no backend, no config, no API
key. Every competitor either hardcodes arrays into widgets or needs Firebase set up before anything
renders. Getting this right is worth more than three extra dashboards.

## Version set

SDK version from the official releases feed; packages verified on pub.dev, both 2026-08-26. Unverified against a real resolve until the SDK exists.

| Package | Version | Note |
|---|---|---|
| Flutter / Dart | **3.47.1 / 3.13.1** | Current stable, released 2026-08-19. Use dot shorthands — a visible "this is current" signal in every sample |
| go_router | 18.0.0 | Nested shell routes, redirect guard, typed routes, deep links |
| riverpod | 3.4 | Codegen **off** — readable source matters more than terseness in a template |
| shadcn_ui | 0.56.1 | pre-1.0. Chosen on adoption; validate in Spike B |
| fl_chart | 1.2.0 | MIT. Deliberately not Syncfusion — its community licence is a trap in a free template |
| trina_grid | 2.3.0 | Maintained fork of `pluto_grid`, which last shipped Dec 2025 |
