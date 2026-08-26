import 'package:flutter/widgets.dart';

import '_shadcn.dart';

enum KiteButtonVariant { primary, secondary, outline, ghost, destructive, link }

/// Buttons. Features use this, never `ShadButton` — see `_shadcn.dart`.
class KiteButton extends StatelessWidget {
  const KiteButton({
    super.key,
    required this.child,
    this.onPressed,
    this.variant = KiteButtonVariant.primary,
    this.leading,
    this.trailing,
    this.expands = false,
    this.enabled = true,
  });

  const KiteButton.secondary({
    super.key,
    required this.child,
    this.onPressed,
    this.leading,
    this.trailing,
    this.expands = false,
    this.enabled = true,
  }) : variant = KiteButtonVariant.secondary;

  const KiteButton.outline({
    super.key,
    required this.child,
    this.onPressed,
    this.leading,
    this.trailing,
    this.expands = false,
    this.enabled = true,
  }) : variant = KiteButtonVariant.outline;

  const KiteButton.ghost({
    super.key,
    required this.child,
    this.onPressed,
    this.leading,
    this.trailing,
    this.expands = false,
    this.enabled = true,
  }) : variant = KiteButtonVariant.ghost;

  const KiteButton.destructive({
    super.key,
    required this.child,
    this.onPressed,
    this.leading,
    this.trailing,
    this.expands = false,
    this.enabled = true,
  }) : variant = KiteButtonVariant.destructive;

  final Widget child;
  final VoidCallback? onPressed;
  final KiteButtonVariant variant;
  final Widget? leading;
  final Widget? trailing;
  final bool expands;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    // `enabled` must reach ShadButton, not just gate onPressed — it is what
    // dims the button. Nulling the callback alone leaves a disabled control
    // looking identical to an active one.
    final press = enabled ? onPressed : null;
    final width = expands ? double.infinity : null;
    return switch (variant) {
      KiteButtonVariant.primary => ShadButton(
        onPressed: press,
        enabled: enabled,
        leading: leading,
        trailing: trailing,
        width: width,
        child: child,
      ),
      KiteButtonVariant.secondary => ShadButton.secondary(
        onPressed: press,
        enabled: enabled,
        leading: leading,
        trailing: trailing,
        width: width,
        child: child,
      ),
      KiteButtonVariant.outline => ShadButton.outline(
        onPressed: press,
        enabled: enabled,
        leading: leading,
        trailing: trailing,
        width: width,
        child: child,
      ),
      KiteButtonVariant.ghost => ShadButton.ghost(
        onPressed: press,
        enabled: enabled,
        leading: leading,
        trailing: trailing,
        width: width,
        child: child,
      ),
      KiteButtonVariant.destructive => ShadButton.destructive(
        onPressed: press,
        enabled: enabled,
        leading: leading,
        trailing: trailing,
        width: width,
        child: child,
      ),
      KiteButtonVariant.link => ShadButton.link(
        onPressed: press,
        enabled: enabled,
        child: child,
      ),
    };
  }
}
