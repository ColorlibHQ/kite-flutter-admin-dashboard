/// The single import surface for the design library.
///
/// **This is the only file in the project permitted to name `shadcn_ui`.**
/// Everything else in `lib/kite_ui/` imports this; everything outside
/// `lib/kite_ui/` imports `kite_ui.dart` and never sees a `Shad*` type.
///
/// shadcn_ui is pre-1.0 (0.55.x, capped by trina_grid) and moving fast enough
/// to ship breaking changes mid-build. When it breaks, the blast radius is this
/// folder. If Spike B's verdict ever reverses, `forui` is the documented
/// fallback and this file is where the swap happens.
///
/// CI enforces the rule — see the `architecture` job in .github/workflows/ci.yml.
library;

export 'package:shadcn_ui/shadcn_ui.dart';
