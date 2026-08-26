import 'package:flutter/material.dart';

import '../../kite_ui/_shadcn.dart';
import '../../kite_ui/kite_ui.dart';

@immutable
class CalendarEvent {
  const CalendarEvent({
    required this.title,
    required this.time,
    required this.kind,
    required this.tone,
    required this.people,
  });

  final String title;
  final String time;
  final String kind;
  final KiteTone tone;
  final List<String> people;
}

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});
  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selected = DateTime.now();

  static const _events = <CalendarEvent>[
    CalendarEvent(
      title: 'Quarterly inventory review',
      time: '09:00 – 10:30',
      kind: 'Finance',
      tone: KiteTone.warning,
      people: ['Grace Hopper', 'Ada Lovelace'],
    ),
    CalendarEvent(
      title: 'Design critique — dark mode pass',
      time: '11:00 – 12:00',
      kind: 'Design',
      tone: KiteTone.info,
      people: ['Radia Perlman', 'Anita Borg', 'Ken Thompson'],
    ),
    CalendarEvent(
      title: 'Supplier call — standing desks',
      time: '14:00 – 14:30',
      kind: 'Ops',
      tone: KiteTone.neutral,
      people: ['Linus Torvalds'],
    ),
    CalendarEvent(
      title: 'Release cut — build 43',
      time: '16:00',
      kind: 'Release',
      tone: KiteTone.success,
      people: ['Margaret Hamilton', 'Barbara Liskov'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final wide = KiteBreak.isDesktop(context);
    final calendar = KiteCard(
      title: 'Schedule',
      child: ShadCalendar(
        selected: _selected,
        onChanged: (d) => setState(() => _selected = d ?? _selected),
      ),
    );
    final agenda = KiteCard(
      title: 'Agenda',
      trailing: KiteBadge('${_events.length} events', tone: KiteTone.info),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [for (final e in _events) _EventRow(event: e)],
      ),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(KiteSpace.xl),
      child: wide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                calendar,
                const SizedBox(width: KiteSpace.xl),
                Expanded(child: agenda),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                calendar,
                const SizedBox(height: KiteSpace.xl),
                agenda,
              ],
            ),
    );
  }
}

class _EventRow extends StatelessWidget {
  const _EventRow({required this.event});
  final CalendarEvent event;

  @override
  Widget build(BuildContext context) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: KiteSpace.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // A severity stripe reads before the label does.
          Container(
            width: 3,
            height: 44,
            decoration: BoxDecoration(
              color: switch (event.tone) {
                KiteTone.success => const Color(0xFF0C6B62),
                KiteTone.warning => const Color(0xFFC08A19),
                KiteTone.danger => c.destructive,
                KiteTone.info => c.primary,
                KiteTone.neutral => c.border,
              },
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(width: KiteSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(event.title, style: t.small)),
                    KiteBadge(event.kind, tone: event.tone),
                  ],
                ),
                const SizedBox(height: 2),
                Text(event.time, style: t.muted.copyWith(fontSize: 12)),
                const SizedBox(height: KiteSpace.sm),
                Row(
                  children: [
                    for (final p in event.people)
                      Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: KiteTooltip(
                          message: p,
                          child: KiteAvatar(name: p, size: 22),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
