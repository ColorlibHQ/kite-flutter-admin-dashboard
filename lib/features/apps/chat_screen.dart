import 'package:flutter/material.dart';

import '../../kite_ui/kite_ui.dart';

@immutable
class ChatMessage {
  const ChatMessage({
    required this.from,
    required this.text,
    required this.at,
    this.mine = false,
  });
  final String from;
  final String text;
  final String at;
  final bool mine;
}

@immutable
class Conversation {
  const Conversation({
    required this.id,
    required this.name,
    required this.last,
    required this.at,
    required this.messages,
    this.unread = 0,
    this.online = false,
  });

  final String id;
  final String name;
  final String last;
  final String at;
  final List<ChatMessage> messages;
  final int unread;
  final bool online;
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _composer = TextEditingController();
  final _scroll = ScrollController();
  String _activeId = 'c1';
  late final Map<String, List<ChatMessage>> _threads = {
    for (final c in _conversations) c.id: List.of(c.messages),
  };

  static const _conversations = <Conversation>[
    Conversation(
      id: 'c1',
      name: 'Ada Lovelace',
      last: 'Stock confirmed — go ahead.',
      at: '09:44',
      unread: 2,
      online: true,
      messages: [
        ChatMessage(
          from: 'Ada Lovelace',
          text: 'Did the replacement desk ship?',
          at: '09:31',
        ),
        ChatMessage(
          from: 'You',
          text: 'Checking the warehouse now.',
          at: '09:38',
          mine: true,
        ),
        ChatMessage(
          from: 'Ada Lovelace',
          text: 'Stock confirmed — go ahead.',
          at: '09:44',
        ),
      ],
    ),
    Conversation(
      id: 'c2',
      name: 'Linus Torvalds',
      last: 'Rate limit is live.',
      at: '08:02',
      online: true,
      messages: [
        ChatMessage(
          from: 'Linus Torvalds',
          text: 'Export endpoint was at 40% of DB time.',
          at: '07:55',
        ),
        ChatMessage(
          from: 'You',
          text: 'Ship the rate limit.',
          at: '07:58',
          mine: true,
        ),
        ChatMessage(
          from: 'Linus Torvalds',
          text: 'Rate limit is live.',
          at: '08:02',
        ),
      ],
    ),
    Conversation(
      id: 'c3',
      name: 'Grace Hopper',
      last: 'Three SKUs are off.',
      at: 'Yesterday',
      messages: [
        ChatMessage(
          from: 'Grace Hopper',
          text: 'Three SKUs are off.',
          at: 'Yesterday',
        ),
      ],
    ),
  ];

  Conversation get _active =>
      _conversations.firstWhere((c) => c.id == _activeId);

  @override
  void dispose() {
    _composer.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send() {
    final text = _composer.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _threads[_activeId] = [
        ..._threads[_activeId]!,
        ChatMessage(from: 'You', text: text, at: 'now', mine: true),
      ];
      _composer.clear();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final wide = KiteBreak.isDesktop(context);
    return Padding(
      padding: const EdgeInsets.all(KiteSpace.xl),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (wide) ...[
            SizedBox(
              width: 280,
              child: _ConversationList(
                conversations: _conversations,
                activeId: _activeId,
                onSelect: (id) => setState(() => _activeId = id),
              ),
            ),
            const SizedBox(width: KiteSpace.xl),
          ],
          Expanded(
            child: KiteCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _ChatHeader(conversation: _active),
                  const KiteSeparator(),
                  Expanded(
                    child: ListView(
                      controller: _scroll,
                      padding: const EdgeInsets.all(KiteSpace.lg),
                      children: [
                        for (final m in _threads[_activeId]!)
                          _Bubble(message: m),
                      ],
                    ),
                  ),
                  const KiteSeparator(),
                  Padding(
                    padding: const EdgeInsets.all(KiteSpace.md),
                    child: Row(
                      children: [
                        Expanded(
                          child: KiteInput(
                            controller: _composer,
                            placeholder: 'Write a message…',
                            onSubmitted: (_) => _send(),
                          ),
                        ),
                        const SizedBox(width: KiteSpace.sm),
                        KiteButton(
                          leading: const Icon(Icons.send, size: 15),
                          onPressed: _send,
                          child: const Text('Send'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConversationList extends StatelessWidget {
  const _ConversationList({
    required this.conversations,
    required this.activeId,
    required this.onSelect,
  });

  final List<Conversation> conversations;
  final String activeId;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);
    return KiteCard(
      title: 'Conversations',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final conv in conversations)
            Material(
              color: conv.id == activeId ? c.accent : Colors.transparent,
              borderRadius: KiteRadius.allMd,
              child: InkWell(
                borderRadius: KiteRadius.allMd,
                onTap: () => onSelect(conv.id),
                child: Padding(
                  padding: const EdgeInsets.all(KiteSpace.sm),
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          KiteAvatar(name: conv.name, size: 34),
                          if (conv.online)
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                width: 9,
                                height: 9,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0C6B62),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: c.card, width: 2),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: KiteSpace.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(conv.name, style: t.small),
                            Text(
                              conv.last,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: t.muted.copyWith(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      if (conv.unread > 0)
                        KiteBadge('${conv.unread}', tone: KiteTone.info),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ChatHeader extends StatelessWidget {
  const _ChatHeader({required this.conversation});
  final Conversation conversation;

  @override
  Widget build(BuildContext context) {
    final t = KiteText.of(context);
    return Padding(
      padding: const EdgeInsets.all(KiteSpace.lg),
      child: Row(
        children: [
          KiteAvatar(name: conversation.name, size: 36),
          const SizedBox(width: KiteSpace.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(conversation.name, style: t.large),
              Text(
                conversation.online ? 'Online' : 'Last seen ${conversation.at}',
                style: t.muted.copyWith(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message});
  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);
    final mine = message.mine;
    return Padding(
      padding: const EdgeInsets.only(bottom: KiteSpace.md),
      child: Row(
        mainAxisAlignment: mine
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!mine) ...[
            KiteAvatar(name: message.from, size: 26),
            const SizedBox(width: KiteSpace.sm),
          ],
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 460),
              padding: const EdgeInsets.symmetric(
                horizontal: KiteSpace.md,
                vertical: KiteSpace.sm,
              ),
              decoration: BoxDecoration(
                color: mine ? c.primary : c.muted,
                borderRadius: BorderRadius.only(
                  topLeft: KiteRadius.md,
                  topRight: KiteRadius.md,
                  bottomLeft: mine ? KiteRadius.md : Radius.zero,
                  bottomRight: mine ? Radius.zero : KiteRadius.md,
                ),
              ),
              child: Column(
                crossAxisAlignment: mine
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: t.small.copyWith(
                      color: mine ? c.primaryForeground : c.foreground,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    message.at,
                    style: t.muted.copyWith(
                      fontSize: 10,
                      color: mine
                          ? c.primaryForeground.withValues(alpha: 0.7)
                          : c.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
