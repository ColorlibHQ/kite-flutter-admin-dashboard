import '../../l10n/app_localizations.dart';
import '../auth/auth_models.dart';

String roleLabel(L l, UserRole role) => switch (role) {
  UserRole.none => l.roleNone,
  UserRole.viewer => l.roleViewer,
  UserRole.editor => l.roleEditor,
  UserRole.admin => l.roleAdmin,
};

/// Translate display labels, keeping schema keys and server values stable.
String fieldLabel(L l, String label) => switch (label) {
  'Order' => l.order,
  'Customer' => l.customer,
  'Product' => l.product,
  'Status' => l.fieldStatus,
  'Items' => l.fieldItems,
  'Total' => l.fieldTotal,
  'Date' => l.fieldDate,
  'Notes' => l.fieldNotes,
  'Name' => l.fieldName,
  'Email' => l.fieldEmail,
  'Orders' => l.navOrders,
  'Lifetime spend' => l.fieldSpend,
  'SKU' => l.fieldSku,
  'Price' => l.fieldPrice,
  'Stock' => l.fieldStock,
  _ => label,
};

String resourceLabel(L l, String resource) => switch (resource) {
  'orders' => l.navOrders,
  'customers' => l.navCustomers,
  'products' => l.navProducts,
  _ => resource,
};

String statusLabel(L l, String value) => switch (value) {
  'Paid' => l.statusPaid,
  'Pending' => l.statusPending,
  'Refunded' => l.statusRefunded,
  'Shipped' => l.statusShipped,
  'Cancelled' => l.statusCancelled,
  'Active' => l.statusActive,
  'Churned' => l.statusChurned,
  'In stock' => l.statusInStock,
  'Low' => l.statusLow,
  'Out of stock' => l.statusOutOfStock,
  _ => value,
};
