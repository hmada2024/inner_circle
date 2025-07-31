// lib/features/chat/widgets/message_bubble.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart'; // <<<--- تم إضافة هذا السطر
import 'package:inner_circle/core/models/user_model.dart';
import 'package:inner_circle/features/chat/controller/chat_controller.dart';
import 'package:inner_circle/features/chat/models/message_model.dart';
import 'package:inner_circle/features/chat/screens/chat_screen.dart';
import 'package:intl/intl.dart';

class MessageBubble extends ConsumerWidget {
  final MessageModel message;
  final bool isMe;
  final UserModel peerUser;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.peerUser,
  });

  void _showReactionsDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final reactions = ['👍', '❤️', '😂', '😯', '😢', '🙏'];
        return SafeArea(
          child: Wrap(
            alignment: WrapAlignment.center,
            children: reactions.map((reaction) {
              return IconButton(
                icon: Text(reaction, style: const TextStyle(fontSize: 24)),
                onPressed: () {
                  ref.read(chatControllerProvider).reactToMessage(
                      peerUser.uid, message.messageId, reaction);
                  Navigator.of(context).pop();
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final borderRadius = BorderRadius.circular(16);
    final theme = Theme.of(context);

    Widget buildReplyWidget() {
      if (message.repliedToMessageText == null) return const SizedBox.shrink();
      return Container(
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.1),
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'الرد على ${message.repliedToSenderName ?? ""}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isMe ? Colors.white70 : Colors.black87,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              message.messageType == MessageType.image
                  ? '📷 صورة'
                  : message.repliedToMessageText!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isMe ? Colors.white70 : Colors.black54,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    Widget buildMessageContentWidget() {
      if (message.messageType == MessageType.image &&
          message.imageUrl != null) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            message.imageUrl!,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(strokeWidth: 2),
              );
            },
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.broken_image, size: 40),
          ),
        );
      }
      return Text(
        message.text,
        style: TextStyle(
          color: isMe ? Colors.white : Colors.black87,
          fontSize: 16,
        ),
      );
    }

    Widget buildReactionsWidget() {
      if (message.reactions.isEmpty) return const SizedBox.shrink();

      return Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Wrap(
          spacing: 4,
          children: message.reactions.entries
              .map((entry) => Text(entry.value))
              .toList(),
        ),
      );
    }

    return Slidable(
      key: ValueKey(message.messageId),
      startActionPane: ActionPane(
        motion: const StretchMotion(),
        children: [
          SlidableAction(
            onPressed: (context) {
              ref.read(replyingToProvider.notifier).state = message;
            },
            backgroundColor: Theme.of(context).colorScheme.secondary,
            foregroundColor: Colors.white,
            icon: Icons.reply,
            label: 'رد',
          ),
        ],
      ),
      child: GestureDetector(
        onLongPress: () => _showReactionsDialog(context, ref),
        child: Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            decoration: BoxDecoration(
                color: isMe
                    ? theme.colorScheme.primary
                    : theme.scaffoldBackgroundColor,
                borderRadius: borderRadius,
                border: isMe ? null : Border.all(color: Colors.grey.shade300)),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                buildReplyWidget(),
                buildMessageContentWidget(),
                buildReactionsWidget(),
                const SizedBox(height: 5),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat('hh:mm a').format(message.timestamp.toDate()),
                      style: TextStyle(
                        color: isMe ? Colors.white70 : Colors.black54,
                        fontSize: 11,
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 4),
                      Icon(
                        message.isRead ? Icons.done_all : Icons.done,
                        size: 14,
                        color: message.isRead
                            ? Colors.lightBlueAccent
                            : Colors.white70,
                      )
                    ]
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
