import 'package:flutter/material.dart';
import 'package:ig_chat_reader/src/presentation/modules/chat/controllers/chat_controller.dart';
import 'package:ig_chat_reader/src/presentation/modules/chat/widgets/chat_message_item.dart';
import 'package:ig_chat_reader/src/presentation/modules/home/models/file_model.dart';

class ChatView extends StatelessWidget {
  final ChatController _controller;
  ChatView({
    super.key,
    required String username,
    required List<FileModel> files,
  }) : _controller = ChatController(username: username, files: files);

  @override
  Widget build(BuildContext context) {
    _controller.init(context);
    return Scaffold(appBar: _appBar, body: _body);
  }

  AppBar get _appBar => AppBar(
    title: Text(_controller.username),
    actions: [
      IconButton(icon: Icon(Icons.image), onPressed: _controller.viewAllPhotos),
    ],
  );

  Widget get _body => StreamBuilder(
    stream: _controller.chatMessagesSubject.stream,
    builder: (context, snapshot) {
      if (!snapshot.hasData || snapshot.data!.isEmpty) {
        return SizedBox.shrink();
      }
      return ListView.builder(
        itemBuilder: (_, index) {
          if (index == snapshot.data!.length) {
            return _controller.hasMoreContent
                ? OutlinedButton(
                  onPressed: _controller.loadNext,
                  child: Text('Load More...'),
                )
                : const SizedBox(height: 80);
          }
          final currentItem = snapshot.data!.elementAt(index);
          final previousItem =
              index > 0 ? snapshot.data!.elementAt(index - 1) : null;
          final sameSender =
              previousItem == null
                  ? false
                  : currentItem.username == previousItem.username;
          return ChatMessageItem(
            isMyMessage: _controller.isMe(currentItem.username),
            chatMessage: currentItem,
            sameSenderAsLast: sameSender,
            onAttachmentClick: _controller.onAttachmentClick,
          );
        },
        itemCount: snapshot.data!.length + 1,
      );
    },
  );
}
