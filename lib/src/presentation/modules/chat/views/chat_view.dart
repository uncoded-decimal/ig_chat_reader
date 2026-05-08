import 'package:flutter/material.dart';
import 'package:ig_chat_reader/src/presentation/components/base_view.dart';
import 'package:ig_chat_reader/src/presentation/modules/chat/controllers/chat_controller.dart';
import 'package:ig_chat_reader/src/presentation/modules/chat/controllers/chat_export_controller.dart';
import 'package:ig_chat_reader/src/presentation/modules/chat/models/message_model.dart';
import 'package:ig_chat_reader/src/presentation/modules/chat/widgets/chat_message_item.dart';
import 'package:ig_chat_reader/src/presentation/modules/home/models/file_model.dart';
import 'package:rxdart/rxdart.dart';

class ChatView extends BaseResponsiveStatelessWidget {
  final ChatController _controller;
  final ChatExportController _exportController;
  ChatView({
    super.key,
    required String username,
    required List<FileModel> files,
  }) : _controller = ChatController(username: username, files: files),
       _exportController = ChatExportController();

  @override
  void initState(BuildContext context) {
    super.initState(context);
    _controller.init(context);
    _exportController.init(context);
  }

  @override
  Widget defaultWidget(BuildContext context) {
    return Scaffold(appBar: _appBar, body: _body);
  }

  AppBar get _appBar => AppBar(
    title: Text(_controller.username),
    actions: [
      StreamBuilder<bool>(
        stream: _exportController.selectionMode.stream,
        builder: (_, snapshot) {
          return Row(
            spacing: 8,
            children: [
              Text('Selection Mode'),
              Switch(
                value: snapshot.data ?? false,
                onChanged: (_) => _exportController.toggleSelectionMode(),
              ),
            ],
          );
        },
      ),
      StreamBuilder<Map>(
        stream: Rx.combineLatest2(
          _exportController.selectionMode.stream,
          _exportController.selectedMessages.stream,
          (a, b) => {'switch': a, 'count': b.length},
        ),
        builder: (_, snapshot) {
          final selectionModeOn = snapshot.data?['switch'] ?? false;
          final selectedMessagesCount = snapshot.data?['count'] ?? 0;
          final showExportButton = selectionModeOn && selectedMessagesCount > 0;
          return showExportButton
              ? IconButton(
                onPressed: _exportController.onExportClick,
                icon: Icon(Icons.share),
              )
              : const SizedBox.shrink();
        },
      ),
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
                child: ListTile(
                  leading: Icon(Icons.movie),
                  title: Text('View all Videos'),
                  onTap: _controller.viewAllVideos,
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
                        return Flexible(
                          child: DropdownButton<String>(
                            isExpanded: true,
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
                          ),
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
    stream: Rx.combineLatest(
      [
        _controller.myName.stream,
        _controller.chatMessagesSubject.stream,
        _exportController.selectionMode.stream,
        _exportController.selectedMessages.stream,
      ],
      (list) => {
        'my_name': list.elementAt(0),
        'messages': list.elementAt(1),
        'selection_mode': list.elementAt(2),
        'selected_messages': list.elementAt(3),
      },
    ),
    builder: (context, snapshot) {
      if (!snapshot.hasData || snapshot.data!.isEmpty) {
        return SizedBox.shrink();
      }
      final myName = snapshot.data!['my_name'] as String;
      final messages = snapshot.data!['messages'] as List<MessageModel>;
      final selectionMode = snapshot.data!['selection_mode'] as bool;
      // final selected =
      //     snapshot.data!['selected_messages'] as List<MessageModel>;
      return Scrollbar(
        controller: _controller.scrollController,
        child: ListView.builder(
          controller: _controller.scrollController,
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
            final previousItem =
                index > 0 ? messages.elementAt(index - 1) : null;
            final nextItem =
                index < messages.length - 1
                    ? messages.elementAt(index + 1)
                    : null;
            return ChatMessageItem(
              isMyMessage: currentItem.username == myName,
              chatMessage: currentItem,
              sameSenderAsLast: currentItem.username == previousItem?.username,
              sameSenderAsNext: currentItem.username == nextItem?.username,
              onAttachmentClick: _controller.onAttachmentClick,
              selectionMode: selectionMode,
              isSelected: _exportController.isSelected(currentItem),
              onSelectionToggle:
                  () => _exportController.toggleSelection(currentItem),
            );
          },
          itemCount: messages.length + 1,
          addRepaintBoundaries: false,
          addAutomaticKeepAlives: false,
          cacheExtent: 500,
        ),
      );
    },
  );
}
