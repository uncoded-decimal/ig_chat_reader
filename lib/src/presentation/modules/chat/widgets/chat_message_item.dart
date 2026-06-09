import 'package:flutter/material.dart';
import 'package:ig_chat_reader/src/presentation/helpers/resources/strings.dart';
import 'package:ig_chat_reader/src/presentation/modules/chat/models/message_model.dart';
import 'package:ig_chat_reader/src/presentation/modules/chat/widgets/attachment_tile.dart';
import 'package:ig_chat_reader/src/presentation/modules/home/models/file_model.dart';
import 'package:intl/intl.dart';

class ChatMessageItem extends StatelessWidget {
  final bool isMyMessage;
  final MessageModel chatMessage;
  final bool sameSenderAsLast;
  final bool sameSenderAsNext;
  final void Function(String link, FileModel? file) onAttachmentClick;

  final bool selectionMode;
  final bool isSelected;
  final VoidCallback onSelectionToggle;

  final bool showAttachments;

  const ChatMessageItem({
    super.key,
    required this.isMyMessage,
    required this.chatMessage,
    required this.sameSenderAsLast,
    required this.sameSenderAsNext,
    required this.onAttachmentClick,
    required this.selectionMode,
    required this.isSelected,
    required this.onSelectionToggle,
    required this.showAttachments,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: isSelected ? Colors.black12 : null),
      child: Column(
        crossAxisAlignment:
            isMyMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [..._titleElements, _messageBody],
      ),
    );
  }

  List<Widget> get _titleElements =>
      sameSenderAsLast
          ? []
          : [
                const SizedBox(height: 16),
                if (chatMessage.timestamp != null)
                  Text(
                    DateFormat('MMM dd, yyyy').format(chatMessage.timestamp!),
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Roboto',
                    ),
                  ),
                SelectableText(
                  chatMessage.username,
                  scrollPhysics: const NeverScrollableScrollPhysics(),
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ]
              .map(
                (e) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: e,
                ),
              )
              .toList();

  Widget get _messageBody => Container(
    padding: const EdgeInsets.all(8),
    margin: EdgeInsets.only(
      left: isMyMessage ? 120 : 20,
      right: isMyMessage ? 20 : 120,
    ),
    decoration: BoxDecoration(
      color:
          isSelected
              ? Colors.white70
              : isMyMessage
              ? Colors.blue.shade50
              : Colors.pink.shade50,
      borderRadius: __borderRadiusForMessageBody,
    ),
    child: Column(
      spacing: 8,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment:
          isMyMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Row(
          spacing: 16,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment:
              isMyMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
          children:
              isMyMessage
                  ? [
                    Flexible(child: __messageContent),
                    __timestampWidget(chatMessage.timestamp!),
                    __selectionIndicator,
                  ]
                  : [
                    __selectionIndicator,
                    __timestampWidget(chatMessage.timestamp!),
                    Flexible(child: __messageContent),
                  ],
        ),
        if (showAttachments) _attachments,
        _reactions,
      ],
    ),
  );
  BorderRadius get __borderRadiusForMessageBody => BorderRadius.only(
    topLeft: Radius.circular(
      isMyMessage
          ? sameSenderAsLast
              ? 0
              : 8
          : sameSenderAsLast
          ? 0
          : 8,
    ),
    topRight: Radius.circular(
      isMyMessage
          ? sameSenderAsLast
              ? 0
              : 8
          : sameSenderAsLast
          ? 0
          : 8,
    ),
    bottomLeft: Radius.circular(
      isMyMessage
          ? sameSenderAsNext
              ? 0
              : 8
          : sameSenderAsNext
          ? 0
          : 8,
    ),
    bottomRight: Radius.circular(
      isMyMessage
          ? sameSenderAsNext
              ? 0
              : 8
          : sameSenderAsNext
          ? 0
          : 8,
    ),
  );

  Widget __timestampWidget(DateTime timestamp) => Padding(
    padding: const EdgeInsets.only(top: 12.0),
    child: SelectableText(
      DateFormat('hh:mm a').format(timestamp),
      style: TextStyle(fontSize: 8, fontFamily: 'Roboto'),
    ),
  );

  Widget get __selectionIndicator =>
      selectionMode
          ? Checkbox(value: isSelected, onChanged: (_) => onSelectionToggle())
          : const SizedBox.shrink();

  Widget get __messageContent =>
      chatMessage.content.message != AppStrings.tempContentHTML ||
              (chatMessage.content.message == AppStrings.tempContentHTML &&
                  chatMessage.content.media.isEmpty)
          ? Padding(
            padding: const EdgeInsets.all(8.0),
            child:
                chatMessage.content.message == AppStrings.tempContentHTML
                    ? Row(
                      spacing: 8,
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.timelapse_rounded,
                          size: 24,
                          color: Colors.black54,
                        ),
                        Flexible(
                          child: Text(
                            'Temporary content',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black54,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    )
                    : chatMessage.content.message.split('\n').length > 3
                    ? ___getLongMessageWidget(chatMessage.content.message)
                    : SelectableText(
                      chatMessage.content.message,
                      scrollPhysics: const NeverScrollableScrollPhysics(),
                    ),
          )
          : const SizedBox.shrink();

  Widget ___getLongMessageWidget(String message) {
    bool entireMessageVisible = false;
    return StatefulBuilder(
      builder:
          (context, setState) => InkWell(
            onTap:
                () => setState(
                  () => entireMessageVisible = !entireMessageVisible,
                ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedSize(
                  alignment: Alignment.topCenter,
                  duration: const Duration(milliseconds: 390),
                  child: SelectableText(
                    message,
                    scrollPhysics: const NeverScrollableScrollPhysics(),
                    maxLines: entireMessageVisible ? null : 3,
                    style: TextStyle(overflow: TextOverflow.ellipsis),
                  ),
                ),
                Text(
                  'Tap to ${entireMessageVisible ? 'collapse' : 'expand'}',
                  style: TextStyle(
                    fontSize: 8,
                    color: Colors.black45,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget get _attachments =>
      chatMessage.content.media.isNotEmpty
          ? ConstrainedBox(
            constraints: BoxConstraints(minHeight: 50, maxHeight: 200),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemBuilder: (_, index) {
                final link = chatMessage.content.media.elementAt(index);
                final files = chatMessage.files.where(
                  // this matches only the file name without extension
                  // to allow matches against malformed URLs
                  (fileItem) => link.contains(fileItem.fileId.split('.').first),
                );
                final targetFile = files.isEmpty ? null : files.first;
                return AttachmentTile(
                  link: link,
                  file: targetFile,
                  onClick:
                      () => onAttachmentClick(
                        chatMessage.content.media.elementAt(index),
                        targetFile,
                      ),
                );
              },
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemCount: chatMessage.content.media.length,
            ),
          )
          : const SizedBox.shrink();

  Widget get _reactions =>
      chatMessage.content.reactions.isEmpty
          ? const SizedBox.shrink()
          : Column(
            mainAxisSize: MainAxisSize.min,
            children:
                chatMessage.content.reactions
                    .map(
                      (e) => Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        foregroundDecoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.black45),
                        ),
                        child: Text(e, style: TextStyle(fontSize: 10)),
                      ),
                    )
                    .toList(),
          );
}
