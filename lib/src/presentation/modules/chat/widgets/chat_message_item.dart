import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:ig_chat_reader/src/presentation/components/responsive_graphic_view.dart';
import 'package:ig_chat_reader/src/presentation/helpers/resources/strings.dart';
import 'package:ig_chat_reader/src/presentation/modules/chat/models/message_model.dart';
import 'package:ig_chat_reader/src/presentation/modules/home/models/file_model.dart';
import 'package:intl/intl.dart';

class ChatMessageItem extends StatelessWidget {
  final bool isMyMessage;
  final MessageModel chatMessage;
  final bool sameSenderAsLast;
  final void Function(String link, FileModel? file) onAttachmentClick;

  const ChatMessageItem({
    super.key,
    required this.isMyMessage,
    required this.chatMessage,
    required this.sameSenderAsLast,
    required this.onAttachmentClick,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          isMyMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [..._titleElements, _messageBody],
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
                    style: TextStyle(fontSize: 8, fontWeight: FontWeight.w500),
                  ),
                Text(
                  chatMessage.username,
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
      color: isMyMessage ? Colors.blue.shade50 : Colors.pink.shade50,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(sameSenderAsLast ? 0 : 8),
        topRight: Radius.circular(sameSenderAsLast ? 0 : 8),
        bottomRight: Radius.circular(8),
        bottomLeft: Radius.circular(8),
      ),
    ),
    child: Column(
      spacing: 8,
      crossAxisAlignment:
          isMyMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Row(
          spacing: 16,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment:
              isMyMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
          children:
              isMyMessage
                  ? [
                    Flexible(child: __messageContent),
                    Text(
                      DateFormat('hh:mm').format(chatMessage.timestamp!),
                      style: TextStyle(fontSize: 8),
                    ),
                  ]
                  : [
                    Text(
                      DateFormat('hh:mm').format(chatMessage.timestamp!),
                      style: TextStyle(fontSize: 8),
                    ),
                    Flexible(child: __messageContent),
                  ],
        ),
        _attachments,
        _reactions,
      ],
    ),
  );

  Widget get __messageContent =>
      chatMessage.content.htmlMessage != AppStrings.tempContentHTML ||
              (chatMessage.content.htmlMessage == AppStrings.tempContentHTML &&
                  chatMessage.content.media.isEmpty)
          ? Html(data: chatMessage.content.htmlMessage, shrinkWrap: true)
          : const SizedBox.shrink();

  Widget get _attachments =>
      chatMessage.content.media.isNotEmpty
          ? ConstrainedBox(
            constraints: BoxConstraints(minHeight: 100, maxHeight: 200),
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
                      (e) =>
                          Chip(label: Text(e, style: TextStyle(fontSize: 12))),
                    )
                    .toList(),
          );
}

class AttachmentTile extends StatelessWidget {
  final String link;
  final FileModel? file;
  final VoidCallback onClick;
  const AttachmentTile({
    super.key,
    required this.link,
    required this.onClick,
    this.file,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onClick,
      child: LimitedBox(
        child: Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: Colors.white70,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black26),
          ),
          child: AspectRatio(aspectRatio: 3 / 4, child: _attachmentPreview),
        ),
      ),
    );
  }

  Widget get _attachmentPreview =>
      file != null
          ? switch (file!.type) {
            FileType.audio => Icon(Icons.audio_file),
            FileType.photo => ResponsiveGraphicView.image(
              path: file!.blobUrl!,
              width: 150,
              fit: BoxFit.cover,
            ),
            FileType.video => Icon(Icons.play_arrow),
            FileType.html => Icon(Icons.error_outline),
            FileType.unknown => Icon(Icons.error_outline),
          }
          : Container(
            alignment: Alignment.center,
            color: Colors.amber.shade200,
            padding: const EdgeInsets.all(16),
            child: Text(
              __getAttachmentTypeFromLink(link),
              style: TextStyle(fontSize: 12),
            ),
          );

  String __getAttachmentTypeFromLink(String link) {
    if (link.contains('reel')) {
      return 'Reel';
    } else if (link.contains('/p/')) {
      return 'Post';
    } else if (link.contains('stories')) {
      return 'Story';
    } else if (link.contains('giphy')) {
      return 'GIF';
    } else {
      return link;
    }
  }
}
