import 'package:flutter/material.dart';
import 'package:ig_chat_reader/src/presentation/components/base_view.dart';
import 'package:ig_chat_reader/src/presentation/modules/chat/controllers/chat_controller.dart';
import 'package:ig_chat_reader/src/presentation/modules/chat/models/message_model.dart';
import 'package:ig_chat_reader/src/presentation/modules/chat/widgets/chat_message_item.dart';
import 'package:ig_chat_reader/src/presentation/modules/home/models/file_model.dart';
import 'package:rxdart/rxdart.dart';

class ChatView extends BaseResponsiveStatelessWidget {
  final ChatController _controller;
  ChatView({
    super.key,
    required String username,
    required List<FileModel> files,
  }) : _controller = ChatController(username: username, files: files);

  @override
  void initState(BuildContext context) {
    super.initState(context);
    _controller.init(context);
  }

  @override
  Widget defaultWidget(BuildContext context) {
    return Scaffold(appBar: _appBar, body: _body);
  }

  AppBar get _appBar => AppBar(
    title: Text(_controller.username),
    actions: [
      PopupMenuButton(
        itemBuilder:
            (_) => [
              PopupMenuItem(
                child: ListTile(
                  leading: Icon(Icons.image),
                  title: Text('View all Photos'),
                  onTap: _controller.viewAllPhotos,
                ),
              ),
              PopupMenuItem(
                child: Row(
                  spacing: 8,
                  children: [
                    Text('I am'),
                    StreamBuilder<Map>(
                      stream: Rx.combineLatest(
                        [
                          _controller.myName.stream,
                          _controller.namesFound.stream,
                        ],
                        (list) => {
                          'my_name': list.elementAt(0),
                          'all_names': list.elementAt(1),
                        },
                      ),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return SizedBox.shrink();
                        }
                        final myName = snapshot.data!['my_name'] as String;
                        final allNames =
                            snapshot.data!['all_names'] as Set<String>;
                        return DropdownButton<String>(
                          items:
                              allNames
                                  .map(
                                    (name) => DropdownMenuItem<String>(
                                      value: name,
                                      child: Text(name),
                                    ),
                                  )
                                  .toList(),
                          value: myName,
                          onChanged: _controller.onNameChange,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
      ),
    ],
  );

  Widget get _body => StreamBuilder(
    stream: Rx.combineLatest([
      _controller.myName.stream,
      _controller.chatMessagesSubject.stream,
    ], (list) => {'my_name': list.elementAt(0), 'messages': list.elementAt(1)}),
    builder: (context, snapshot) {
      if (!snapshot.hasData || snapshot.data!.isEmpty) {
        return SizedBox.shrink();
      }
      final myName = snapshot.data!['my_name'] as String;
      final messages = snapshot.data!['messages'] as List<MessageModel>;
      return ListView.builder(
        itemBuilder: (_, index) {
          if (index == messages.length) {
            return _controller.hasMoreContent
                ? Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 36,
                  ),
                  child: OutlinedButton(
                    onPressed: _controller.loadNext,
                    child: Text('Load More...'),
                  ),
                )
                : const SizedBox(height: 80);
          }
          final currentItem = messages.elementAt(index);
          final previousItem = index > 0 ? messages.elementAt(index - 1) : null;
          final sameSender =
              previousItem == null
                  ? false
                  : currentItem.username == previousItem.username;
          return ChatMessageItem(
            isMyMessage: currentItem.username == myName,
            chatMessage: currentItem,
            sameSenderAsLast: sameSender,
            onAttachmentClick: _controller.onAttachmentClick,
          );
        },
        itemCount: messages.length + 1,
      );
    },
  );
}
