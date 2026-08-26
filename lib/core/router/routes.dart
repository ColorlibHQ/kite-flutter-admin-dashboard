import 'package:flutter/material.dart';

/// Route paths in one place so the router, the sidebar and every `context.go`
/// call agree. Typed constants rather than string literals scattered around.
abstract final class R {
  static const signIn = '/sign-in';
  static const signUp = '/sign-up';
  static const forgot = '/forgot-password';
  static const otp = '/verify';
  static const lock = '/lock';

  static const dashboard = '/';
  static const orders = '/orders';
  static const customers = '/customers';
  static const products = '/products';
  static const components = '/components';
  static const forms = '/forms';
  static const settings = '/settings';
  static const profile = '/profile';

  static bool isAuthRoute(String location) =>
      location.startsWith(signIn) ||
      location.startsWith(signUp) ||
      location.startsWith(forgot) ||
      location.startsWith(otp) ||
      location.startsWith(lock);
}

@immutable
class NavItem {
  const NavItem(this.label, this.path, this.icon);
  final String label;
  final String path;
  final IconData icon;
}

/// The sidebar on desktop, the bottom bar on mobile — same source, so the two
/// can never drift apart.
const kNav = <NavItem>[
  NavItem('Dashboard', R.dashboard, Icons.dashboard_outlined),
  NavItem('Orders', R.orders, Icons.receipt_long_outlined),
  NavItem('Customers', R.customers, Icons.people_outline),
  NavItem('Products', R.products, Icons.inventory_2_outlined),
  NavItem('Components', R.components, Icons.widgets_outlined),
  NavItem('Forms', R.forms, Icons.edit_note_outlined),
  NavItem('Settings', R.settings, Icons.settings_outlined),
];
