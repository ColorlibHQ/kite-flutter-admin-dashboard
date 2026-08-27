import 'package:flutter/widgets.dart';

import 'tokens.dart';

/// Lays out stat tiles at a **fixed height** with flexible width.
///
/// The obvious tool is `GridView.count` with a `childAspectRatio`, and it is
/// the wrong one: aspect ratio ties height to width, so on a wide screen the
/// tiles grow taller while every other card on the page keeps its natural
/// content height. The row ends up looking inflated next to everything below it.
///
/// A stat tile has a fixed amount to say — a label, a number, a delta, and a
/// trend. That is a constant height. Only the width should respond to the
/// viewport, which is also what lets the sparkline stretch instead of
/// stretching the card.
class KiteStatGrid extends StatelessWidget {
  const KiteStatGrid({
    super.key,
    required this.children,
    this.height = 200,
    this.spacing = KiteSpace.lg,
    this.minTileWidth = 220,
  });

  final List<Widget> children;

  /// Same at every viewport width. Tune here, not per screen.
  final double height;
  final double spacing;

  /// Below this, drop a column rather than squeezing.
  final double minTileWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final fit =
            ((constraints.maxWidth + spacing) / (minTileWidth + spacing))
                .floor();
        final columns = fit.clamp(1, children.length);

        final rows = <List<Widget>>[];
        for (var i = 0; i < children.length; i += columns) {
          rows.add(
            children.sublist(i, (i + columns).clamp(0, children.length)),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var r = 0; r < rows.length; r++) ...[
              if (r > 0) SizedBox(height: spacing),
              SizedBox(
                height: height,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < columns; i++) ...[
                      if (i > 0) SizedBox(width: spacing),
                      // Pad the final row so a lone tile does not stretch to
                      // the full width and break the column rhythm.
                      Expanded(
                        child: i < rows[r].length
                            ? rows[r][i]
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
