import 'package:flutter/material.dart';

import '../../kite_ui/kite_ui.dart';

@immutable
class Message {
  const Message({
    required this.id,
    required this.from,
    required this.subject,
    required this.preview,
    required this.body,
    required this.at,
    this.unread = false,
    this.starred = false,
    this.label,
    this.labelTone = KiteTone.neutral,
  });

  final String id;
  final String from;
  final String subject;
  final String preview;
  final String body;
  final String at;
  final bool unread;
  final bool starred;
  final String? label;
  final KiteTone labelTone;

  Message copyWith({bool? unread, bool? starred}) => Message(
    id: id,
    from: from,
    subject: subject,
    preview: preview,
    body: body,
    at: at,
    unread: unread ?? this.unread,
    starred: starred ?? this.starred,
    label: label,
    labelTone: labelTone,
  );
}

/// Split list/detail — the other layout an admin is expected to have.
///
/// On mobile the detail is a full-screen push rather than a squeezed second
/// column, which is the same "mobile is not a reflow" rule the shell follows.
class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});
  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  late List<Message> _messages = _seed;
  String _selectedId = 'm1';
  String _filter = 'All';

  static const _seed = <Message>[
    Message(
      id: 'm1',
      from: 'Ada Lovelace',
      at: '09:42',
      unread: true,
      subject: 'Refund request for order #10265',
      preview: 'The customer says the desk arrived with a cracked leg…',
      label: 'Support',
      labelTone: KiteTone.info,
      body:
          'The customer says the desk arrived with a cracked leg and has sent '
          'photographs. Courier damage looks likely — the outer packaging is '
          'intact but the corner is crushed.\n\n'
          'I have offered a replacement rather than a refund and they seem happy '
          'with that. Can you confirm we have stock before I commit us?',
    ),
    Message(
      id: 'm2',
      from: 'Grace Hopper',
      at: '08:15',
      unread: true,
      subject: 'Q3 inventory reconciliation',
      preview: 'Numbers are close but three SKUs are off by more than…',
      label: 'Finance',
      labelTone: KiteTone.warning,
      body:
          'Numbers are close but three SKUs are off by more than ten units. '
          'SKU-2014, SKU-2088 and SKU-2131.\n\n'
          'My guess is the returns from the July promotion were never scanned '
          'back in. Worth a physical count before we close the quarter.',
    ),
    Message(
      id: 'm3',
      from: 'Linus Torvalds',
      at: 'Yesterday',
      starred: true,
      subject: 'Export endpoint is getting hammered',
      preview: 'Someone is pulling the full CSV every ninety seconds…',
      label: 'Ops',
      labelTone: KiteTone.danger,
      body:
          'Someone is pulling the full CSV every ninety seconds from a single '
          'API key. It is not breaking anything yet but it is 40% of database '
          'time on that box.\n\n'
          'I would rate-limit it to once an hour and email the key owner.',
    ),
    Message(
      id: 'm4',
      from: 'Radia Perlman',
      at: 'Yesterday',
      subject: 'Dark mode contrast — second pass',
      preview: 'Muted foreground on card background is 3.9:1, which fails…',
      label: 'Design',
      labelTone: KiteTone.info,
      body:
          'Muted foreground on card background is 3.9:1, which fails AA for '
          'small text. Bumping the muted token two steps darker fixes it '
          'without touching anything else.',
    ),
    Message(
      id: 'm5',
      from: 'Margaret Hamilton',
      at: 'Mon',
      subject: 'Mobile build is on TestFlight',
      preview: 'Build 42 is up. The bottom bar behaves properly now…',
      body:
          'Build 42 is up. The bottom bar behaves properly now and the back '
          'gesture no longer drops you to the dashboard from a detail screen.',
    ),
  ];

  Message get _selected => _messages.firstWhere(
    (m) => m.id == _selectedId,
    orElse: () => _messages.first,
  );

  List<Message> get _visible => switch (_filter) {
    'Unread' => _messages.where((m) => m.unread).toList(),
    'Starred' => _messages.where((m) => m.starred).toList(),
    _ => _messages,
  };

  void _select(String id) {
    setState(() {
      _selectedId = id;
      _messages = [
        for (final m in _messages) m.id == id ? m.copyWith(unread: false) : m,
      ];
    });
  }

  void _toggleStar(String id) {
    setState(() {
      _messages = [
        for (final m in _messages)
          m.id == id ? m.copyWith(starred: !m.starred) : m,
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    final wide = KiteBreak.isDesktop(context);
    final list = _MessageList(
      messages: _visible,
      selectedId: wide ? _selectedId : null,
      filter: _filter,
      unreadCount: _messages.where((m) => m.unread).length,
      onFilter: (f) => setState(() => _filter = f),
      onSelect: (id) {
        _select(id);
        if (!wide) {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => Scaffold(
                appBar: AppBar(title: const Text('Message')),
                body: _Reader(
                  message: _selected,
                  onStar: () => _toggleStar(_selectedId),
                ),
              ),
            ),
          );
        }
      },
      onStar: _toggleStar,
    );

    if (!wide) return list;

    return Padding(
      padding: const EdgeInsets.all(KiteSpace.xl),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(width: 380, child: list),
          const SizedBox(width: KiteSpace.xl),
          Expanded(
            child: KiteCard(
              child: _Reader(
                message: _selected,
                onStar: () => _toggleStar(_selectedId),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageList extends StatelessWidget {
  const _MessageList({
    required this.messages,
    required this.selectedId,
    required this.filter,
    required this.unreadCount,
    required this.onFilter,
    required this.onSelect,
    required this.onStar,
  });

  final List<Message> messages;
  final String? selectedId;
  final String filter;
  final int unreadCount;
  final ValueChanged<String> onFilter;
  final ValueChanged<String> onSelect;
  final ValueChanged<String> onStar;

  @override
  Widget build(BuildContext context) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: KiteSpace.md),
          child: Row(
            children: [
              Text('Inbox', style: t.large),
              const SizedBox(width: KiteSpace.sm),
              if (unreadCount > 0)
                KiteBadge('$unreadCount unread', tone: KiteTone.info),
              const Spacer(),
              for (final f in const ['All', 'Unread', 'Starred'])
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                    start: KiteSpace.xs,
                  ),
                  child: KiteButton.ghost(
                    onPressed: () => onFilter(f),
                    child: Text(
                      f,
                      style: t.small.copyWith(
                        color: filter == f ? c.foreground : c.mutedForeground,
                        fontWeight: filter == f
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: messages.isEmpty
              ? const Center(child: Text('Nothing here'))
              : ListView.separated(
                  itemCount: messages.length,
                  separatorBuilder: (_, _) => const KiteSeparator(),
                  itemBuilder: (context, i) {
                    final m = messages[i];
                    final selected = m.id == selectedId;
                    return Material(
                      color: selected ? c.accent : Colors.transparent,
                      borderRadius: KiteRadius.allMd,
                      child: InkWell(
                        borderRadius: KiteRadius.allMd,
                        onTap: () => onSelect(m.id),
                        child: Padding(
                          padding: const EdgeInsets.all(KiteSpace.md),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              KiteAvatar(name: m.from, size: 34),
                              const SizedBox(width: KiteSpace.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            m.from,
                                            overflow: TextOverflow.ellipsis,
                                            style: t.small.copyWith(
                                              fontWeight: m.unread
                                                  ? FontWeight.w700
                                                  : FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          m.at,
                                          style: t.muted.copyWith(fontSize: 11),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      m.subject,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: t.small.copyWith(
                                        fontWeight: m.unread
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      m.preview,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: t.muted.copyWith(fontSize: 12),
                                    ),
                                    if (m.label != null) ...[
                                      const SizedBox(height: KiteSpace.sm),
                                      KiteBadge(m.label!, tone: m.labelTone),
                                    ],
                                  ],
                                ),
                              ),
                              IconButton(
                                iconSize: 16,
                                visualDensity: VisualDensity.compact,
                                color: m.starred
                                    ? const Color(0xFFC08A19)
                                    : c.border,
                                icon: Icon(
                                  m.starred ? Icons.star : Icons.star_border,
                                ),
                                onPressed: () => onStar(m.id),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _Reader extends StatelessWidget {
  const _Reader({required this.message, required this.onStar});
  final Message message;
  final VoidCallback onStar;

  @override
  Widget build(BuildContext context) {
    final t = KiteText.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(KiteSpace.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              KiteAvatar(name: message.from, size: 44),
              const SizedBox(width: KiteSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(message.from, style: t.large),
                    Text('to me · ${message.at}', style: t.muted),
                  ],
                ),
              ),
              KiteTooltip(
                message: message.starred ? 'Remove star' : 'Star this message',
                child: KiteButton.ghost(
                  onPressed: onStar,
                  child: Icon(
                    message.starred ? Icons.star : Icons.star_border,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: KiteSpace.xl),
          Text(message.subject, style: t.h3),
          const SizedBox(height: KiteSpace.lg),
          Text(message.body, style: t.p),
          const SizedBox(height: KiteSpace.xxl),
          Row(
            children: [
              KiteButton(
                leading: const Icon(Icons.reply, size: 16),
                onPressed: () => KiteToast.show(
                  context,
                  title: 'Reply sent',
                  description: 'Your message is on its way to ${message.from}.',
                  tone: KiteTone.success,
                ),
                child: const Text('Reply'),
              ),
              const SizedBox(width: KiteSpace.md),
              KiteButton.outline(
                onPressed: () => KiteToast.show(context, title: 'Archived'),
                child: const Text('Archive'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
