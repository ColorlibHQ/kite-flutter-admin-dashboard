import '../auth/auth_models.dart';
import 'routes.dart';

/// Keeps bookmarked locations through sign-in, including filters and fragments.
/// Only local, non-auth destinations can be used as a return location.
String? authRedirect({
  required bool signedIn,
  required Uri location,
  UserRole? role,
  bool needsPasswordReset = false,
}) {
  if (signedIn && needsPasswordReset) {
    return location.path == R.resetPassword ? null : R.resetPassword;
  }
  if (location.path == R.resetPassword || location.path == R.lock) {
    return signedIn ? null : R.signIn;
  }
  if (signedIn && role != null) {
    if (!role.canRead &&
        !const {R.settings, R.profile, R.forbidden}.contains(location.path) &&
        !R.isAuthRoute(location.path)) {
      return R.forbidden;
    }
    final parts = location.pathSegments;
    if (!role.canWrite &&
        parts.length >= 2 &&
        const {'orders', 'customers', 'products'}.contains(parts.first) &&
        const {'new', 'edit'}.contains(parts.last)) {
      return R.forbidden;
    }
  }
  final onAuth = R.isAuthRoute(location.path);
  if (!signedIn && !onAuth) {
    return Uri(
      path: R.signIn,
      queryParameters: {'from': location.toString()},
    ).toString();
  }
  if (signedIn && onAuth) {
    final from = Uri.tryParse(location.queryParameters['from'] ?? '');
    if (from != null &&
        !from.hasScheme &&
        !from.hasAuthority &&
        from.path.startsWith('/') &&
        !from.path.startsWith('//') &&
        !from.path.contains('\\') &&
        !R.isAuthRoute(from.path)) {
      return from.toString();
    }
    return R.dashboard;
  }
  return null;
}
