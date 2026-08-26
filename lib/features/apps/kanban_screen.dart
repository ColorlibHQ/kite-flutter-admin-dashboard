import 'package:flutter/material.dart';

import '../../kite_ui/kite_ui.dart';

@immutable
class KanbanCard {
  const KanbanCard({
    required this.id,
    required this.title,
    required this.assignee,
    required this.tag,
    required this.tone,
    this.due,
  });

  final String id;
  final String title;
  final String assignee;
  final String tag;
  final KiteTone tone;
  final String? due;
}

/// A board with real drag-and-drop.
///
/// Most free templates ship a kanban that cannot be dragged — a picture of a
/// board. Cards here move between columns and the counts update, because the
/// interaction is the entire point of the screen.
class KanbanScreen extends StatefulWidget {
  const KanbanScreen({super.key});
  @override
  State<KanbanScreen> createState() => _KanbanScreenState();
}

class _KanbanScreenState extends State<KanbanScreen> {
  static const _columns = ['Backlog', 'In progress', 'Review', 'Done'];

  static const Map<String, List<KanbanCard>> _seed = {
    'Backlog': [
      KanbanCard(
        id: 'K-104',
        title: 'Rework the checkout error states',
        assignee: 'Ada Lovelace',
        tag: 'Design',
        tone: KiteTone.info,
        due: 'Fri',
      ),
      KanbanCard(
        id: 'K-108',
        title: 'Audit third-party script weight',
        assignee: 'Linus Torvalds',
        tag: 'Perf',
        tone: KiteTone.warning,
      ),
      KanbanCard(
        id: 'K-112',
        title: 'Write the refund policy copy',
        assignee: 'Grace Hopper',
        tag: 'Content',
        tone: KiteTone.neutral,
      ),
    ],
    'In progress': [
      KanbanCard(
        id: 'K-97',
        title: 'Server-side pagination for orders',
        assignee: 'Barbara Liskov',
        tag: 'Backend',
        tone: KiteTone.info,
        due: 'Today',
      ),
      KanbanCard(
        id: 'K-99',
        title: 'Dark mode contrast pass',
        assignee: 'Radia Perlman',
        tag: 'Design',
        tone: KiteTone.info,
      ),
    ],
    'Review': [
      KanbanCard(
        id: 'K-91',
        title: 'Rate-limit the export endpoint',
        assignee: 'Ken Thompson',
        tag: 'Backend',
        tone: KiteTone.danger,
        due: 'Overdue',
      ),
    ],
    'Done': [
      KanbanCard(
        id: 'K-88',
        title: 'Ship the mobile bottom bar',
        assignee: 'Margaret Hamilton',
        tag: 'Mobile',
        tone: KiteTone.success,
      ),
      KanbanCard(
        id: 'K-84',
        title: 'Replace the hamburger column icons',
        assignee: 'Anita Borg',
        tag: 'Design',
        tone: KiteTone.success,
      ),
    ],
  };

  /// Mutable working copy.
  ///
  /// The seed lists are `const`, so calling `removeWhere` on them throws
  /// `UnsupportedError` — which is exactly what broke every drag. Copy once,
  /// mutate the copies.
  late final Map<String, List<KanbanCard>> _board = {
    for (final entry in _seed.entries)
      entry.key: List<KanbanCard>.of(entry.value),
  };

  String? _hovered;

  String? _columnOf(KanbanCard card) {
    for (final entry in _board.entries) {
      if (entry.value.any((c) => c.id == card.id)) return entry.key;
    }
    return null;
  }

  void _move(KanbanCard card, String to) {
    final from = _columnOf(card);
    // Dropping a card back where it started is a no-op, not a duplicate.
    if (from == to) {
      setState(() => _hovered = null);
      return;
    }
    setState(() {
      for (final list in _board.values) {
        list.removeWhere((c) => c.id == card.id);
      }
      _board[to]!.add(card);
      _hovered = null;
    });
    KiteToast.show(context, title: '${card.id} moved to $to');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(KiteSpace.xl),
      child: LayoutBuilder(
        builder: (context, constraints) {
          Widget column(String name) => _Column(
            name: name,
            cards: _board[name]!,
            hovering: _hovered == name,
            onWillAccept: () => setState(() => _hovered = name),
            onLeave: () => setState(() => _hovered = null),
            onAccept: (card) => _move(card, name),
          );

          // Columns share the width when they fit and only scroll sideways
          // when they cannot. A board that clips its last column reads as
          // broken; one that scrolls reads as a board.
          const minColumn = 260.0;
          final gaps = KiteSpace.lg * (_columns.length - 1);
          final fits =
              constraints.maxWidth >= minColumn * _columns.length + gaps;

          final children = <Widget>[
            for (final name in _columns) ...[
              if (fits)
                Expanded(child: column(name))
              else
                SizedBox(width: minColumn, child: column(name)),
              if (name != _columns.last) const SizedBox(width: KiteSpace.lg),
            ],
          ];

          if (fits) {
            return SingleChildScrollView(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            );
          }
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          );
        },
      ),
    );
  }
}

class _Column extends StatelessWidget {
  const _Column({
    required this.name,
    required this.cards,
    required this.hovering,
    required this.onWillAccept,
    required this.onLeave,
    required this.onAccept,
  });

  final String name;
  final List<KanbanCard> cards;
  final bool hovering;
  final VoidCallback onWillAccept;
  final VoidCallback onLeave;
  final ValueChanged<KanbanCard> onAccept;

  @override
  Widget build(BuildContext context) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);

    return DragTarget<KanbanCard>(
      onWillAcceptWithDetails: (_) {
        onWillAccept();
        return true;
      },
      onLeave: (_) => onLeave(),
      onAcceptWithDetails: (d) => onAccept(d.data),
      builder: (context, candidate, rejected) => AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.all(KiteSpace.md),
        decoration: BoxDecoration(
          color: hovering ? c.accent : c.card,
          border: Border.all(color: hovering ? c.primary : c.border),
          borderRadius: KiteRadius.allLg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                KiteSpace.sm,
                KiteSpace.sm,
                KiteSpace.sm,
                KiteSpace.md,
              ),
              child: Row(
                children: [
                  Text(
                    name,
                    style: t.small.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: KiteSpace.sm),
                  KiteBadge('${cards.length}'),
                ],
              ),
            ),
            for (final card in cards)
              Padding(
                padding: const EdgeInsets.only(bottom: KiteSpace.sm),
                child: Draggable<KanbanCard>(
                  data: card,
                  feedback: Material(
                    color: Colors.transparent,
                    child: Opacity(
                      opacity: 0.92,
                      child: SizedBox(width: 276, child: _Card(card: card)),
                    ),
                  ),
                  childWhenDragging: Opacity(
                    opacity: 0.35,
                    child: _Card(card: card),
                  ),
                  child: _Card(card: card),
                ),
              ),
            if (cards.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: KiteSpace.xl),
                child: Text(
                  'Drop a card here',
                  textAlign: TextAlign.center,
                  style: t.muted.copyWith(fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.card});
  final KanbanCard card;

  @override
  Widget build(BuildContext context) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);
    return Container(
      padding: const EdgeInsets.all(KiteSpace.md),
      decoration: BoxDecoration(
        color: c.background,
        border: Border.all(color: c.border),
        borderRadius: KiteRadius.allMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                card.id,
                style: t.muted.copyWith(
                  fontSize: 11,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const Spacer(),
              KiteBadge(card.tag, tone: card.tone),
            ],
          ),
          const SizedBox(height: KiteSpace.sm),
          Text(card.title, style: t.small),
          const SizedBox(height: KiteSpace.md),
          Row(
            children: [
              KiteAvatar(name: card.assignee, size: 22),
              const SizedBox(width: KiteSpace.sm),
              Expanded(
                child: Text(
                  card.assignee,
                  style: t.muted.copyWith(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (card.due != null)
                Text(
                  card.due!,
                  style: t.muted.copyWith(
                    fontSize: 11,
                    color: card.due == 'Overdue'
                        ? c.destructive
                        : c.mutedForeground,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
