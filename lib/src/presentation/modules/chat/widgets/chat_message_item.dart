import 'package:flutter/material.dart';
import 'package:ig_chat_reader/src/presentation/components/responsive_graphic_view.dart';
import 'package:ig_chat_reader/src/presentation/helpers/resources/strings.dart';
import 'package:ig_chat_reader/src/presentation/modules/chat/models/message_model.dart';
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
        _attachments,
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
    child: Text(
      DateFormat('hh:mm a').format(timestamp),
      style: TextStyle(fontSize: 8),
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
                        Text(
                          'Temporary content',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black54,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    )
                    : chatMessage.content.message.split('\n').length > 3
                    ? ___getLongMessageWidget(chatMessage.content.message)
                    : Text(chatMessage.content.message),
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
                  child: Text(
                    message,
                    overflow: TextOverflow.fade,
                    maxLines: entireMessageVisible ? null : 3,
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
    return InkWell(onTap: onClick, child: _attachmentPreview);
  }

  Widget get _attachmentPreview =>
      file != null || link.contains('giphy')
          ? __recognisedItem
          : __unrecognisedLink;

  Widget get __recognisedItem =>
      link.contains('giphy')
          ? ___gifTile
          : switch (file!.type) {
            FileType.audio => ___audioTile,
            FileType.photo => ___imageTile,
            FileType.video => ___videoTile,
            (_) => Container(
              decoration: BoxDecoration(
                color: Colors.white70,
                border: Border.all(color: Colors.black26),
              ),
              child: Icon(Icons.error_outline),
            ),
          };

  Widget get ___gifTile => Container(
    height: 100,
    clipBehavior: Clip.hardEdge,
    decoration: BoxDecoration(
      color: Colors.white70,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.black26),
    ),
    foregroundDecoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.black26),
    ),
    child: ResponsiveGraphicView.image(path: link, fit: BoxFit.cover),
  );

  Widget get ___imageTile => Container(
    height: 250,
    clipBehavior: Clip.hardEdge,
    decoration: BoxDecoration(
      color: Colors.white70,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.black26),
    ),
    foregroundDecoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.black26),
    ),
    child: ResponsiveGraphicView.image(
      path: file!.blobUrl!,
      fit: BoxFit.contain,
    ),
  );

  Widget get ___audioTile => Container(
    width: 150,
    clipBehavior: Clip.hardEdge,
    decoration: BoxDecoration(
      color: Colors.white70,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.black26),
    ),
    foregroundDecoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.black26),
    ),
    child: Icon(Icons.audio_file),
  );

  Widget get ___videoTile => Container(
    width: 150,
    clipBehavior: Clip.hardEdge,
    decoration: BoxDecoration(
      color: Colors.white70,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.black26),
    ),
    foregroundDecoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.black26),
    ),
    child: Stack(
      children: [
        ResponsiveGraphicView.image(
          path: file!.thumbnailUrl!,
          width: double.maxFinite,
          height: double.maxFinite,
          fit: BoxFit.cover,
        ),
        Align(
          alignment: Alignment.center,
          child: Icon(Icons.play_arrow, color: Colors.white),
        ),
      ],
    ),
  );

  Widget get __unrecognisedLink => AspectRatio(
    aspectRatio: 3 / 4,
    child: Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black26),
        color: Colors.amber.shade100,
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black26),
      ),
      padding: const EdgeInsets.all(16),
      child: Text(
        ___getAttachmentTypeFromLink(link),
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        textAlign: TextAlign.center,
      ),
    ),
  );

  String ___getAttachmentTypeFromLink(String link) {
    if (link.contains('reel')) {
      return 'Reel';
    } else if (link.contains('/p/')) {
      return 'Post';
    } else if (link.contains('stories')) {
      return 'Story';
    } else if (link.contains('giphy')) {
      return 'GIF';
    } else if (link.contains('/_u/')) {
      return 'Instagram User';
    } else if (RegExp(r'https://www.instagram.com/.+').hasMatch(link)) {
      return 'Instagram Profile';
    } else {
      return link;
    }
  }
}
