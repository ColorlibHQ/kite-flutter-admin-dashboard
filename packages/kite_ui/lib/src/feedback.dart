import 'package:flutter/material.dart';

import '../shadcn.dart';
import 'badge.dart';
import 'tokens.dart';

/// Inline notice. Tone is semantic and separate from the brand accent, so a
/// warning reads as a warning in every theme.
class KiteAlert extends StatelessWidget {
  const KiteAlert({
    super.key,
    required this.title,
    this.description,
    this.tone = KiteTone.info,
    this.icon,
  });

  final String title;
  final String? description;
  final KiteTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final fallback = switch (tone) {
      KiteTone.success => Icons.check_circle_outline,
      KiteTone.warning => Icons.warning_amber_outlined,
      KiteTone.danger => Icons.error_outline,
      _ => Icons.info_outline,
    };
    final child = tone == KiteTone.danger
        ? ShadAlert.destructive(
            icon: Icon(icon ?? fallback, size: 16),
            title: Text(title),
            description: description == null ? null : Text(description!),
          )
        : ShadAlert(
            icon: Icon(icon ?? fallback, size: 16),
            title: Text(title),
            description: description == null ? null : Text(description!),
          );
    return child;
  }
}

/// Action feedback.
///
/// A control that says what will happen should be followed by a message saying
/// it happened — "Delete" then "Order deleted", not a silent table refresh.
abstract final class KiteToast {
  static void show(
    BuildContext context, {
    required String title,
    String? description,
    KiteTone tone = KiteTone.neutral,
  }) {
    final toast = tone == KiteTone.danger
        ? ShadToast.destructive(
            title: Text(title),
            description: description == null ? null : Text(description),
          )
        : ShadToast(
            title: Text(title),
            description: description == null ? null : Text(description),
          );
    ShadToaster.of(context).show(toast);
  }
}

/// Destructive confirmation.
///
/// Returns true only when the person actively confirms — dismissing by tapping
/// the barrier or pressing escape resolves to false, never to "yes".
Future<bool> kiteConfirm(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Delete',
  String cancelLabel = 'Cancel',
}) async {
  final result = await showShadDialog<bool>(
    context: context,
    builder: (dialogContext) => ShadDialog.alert(
      title: Text(title),
      description: Padding(
        padding: const EdgeInsets.only(top: KiteSpace.sm),
        child: Text(message),
      ),
      actions: [
        ShadButton.outline(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(cancelLabel),
        ),
        ShadButton.destructive(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}

/// Right-hand detail drawer — the admin pattern for inspecting a row without
/// losing your place in the table.
Future<T?> kiteSheet<T>(
  BuildContext context, {
  required String title,
  String? description,
  required Widget body,
  List<Widget> actions = const [],
  double width = 460,
}) {
  return showShadSheet<T>(
    context: context,
    side: ShadSheetSide.right,
    builder: (sheetContext) => ShadSheet(
      constraints: BoxConstraints(maxWidth: width),
      title: Text(title),
      description: description == null ? null : Text(description),
      actions: actions,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: KiteSpace.lg),
        child: body,
      ),
    ),
  );
}
