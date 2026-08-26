import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/auth_screens.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/forms/forms_screen.dart';
import '../../features/resources/resource_list_screen.dart';
import '../../features/system/error_screen.dart';
import '../../features/system/settings_screen.dart';
import '../../shared/layout/app_shell.dart';
import '../auth/session.dart';
import 'routes.dart';

/// Bridges Riverpod state into go_router's `refreshListenable`, so signing in
/// or out re-evaluates the guard immediately rather than on the next
/// navigation.
class _SessionRefresh extends ChangeNotifier {
  _SessionRefresh(Ref ref) {
    ref.listen(sessionProvider, (_, _) => notifyListeners());
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _SessionRefresh(ref);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: R.dashboard,
    refreshListenable: refresh,
    redirect: (context, state) {
      final signedIn = ref.read(sessionProvider) != null;
      final onAuth = R.isAuthRoute(state.matchedLocation);
      if (!signedIn && !onAuth) return R.signIn;
      if (signedIn && onAuth) return R.dashboard;
      return null;
    },
    errorBuilder: (context, state) => NotFoundScreen(location: state.uri.path),
    routes: [
      GoRoute(path: R.signIn, builder: (_, _) => const SignInScreen()),
      GoRoute(path: R.signUp, builder: (_, _) => const SignUpScreen()),
      GoRoute(path: R.forgot, builder: (_, _) => const ForgotPasswordScreen()),
      GoRoute(path: R.otp, builder: (_, _) => const OtpScreen()),
      GoRoute(path: R.lock, builder: (_, _) => const LockScreen()),

      // Everything below renders inside the persistent shell: the sidebar and
      // top bar survive navigation instead of rebuilding on every route.
      ShellRoute(
        builder: (context, state, child) =>
            AppShell(location: state.matchedLocation, child: child),
        routes: [
          GoRoute(
            path: R.dashboard,
            builder: (_, _) => const DashboardScreen(),
          ),
          GoRoute(
            path: R.orders,
            builder: (_, _) => const ResourceListScreen(resource: 'orders'),
          ),
          GoRoute(
            path: R.customers,
            builder: (_, _) => const ResourceListScreen(resource: 'customers'),
          ),
          GoRoute(
            path: R.products,
            builder: (_, _) => const ResourceListScreen(resource: 'products'),
          ),
          GoRoute(path: R.forms, builder: (_, _) => const FormsScreen()),
          GoRoute(path: R.settings, builder: (_, _) => const SettingsScreen()),
        ],
      ),
    ],
  );
});
