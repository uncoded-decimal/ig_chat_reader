import 'package:flutter/material.dart';
import 'package:ig_chat_reader/src/presentation/components/base_view.dart';
import 'package:ig_chat_reader/src/presentation/modules/chat/controllers/chat_export_controller.dart';
import 'package:ig_chat_reader/src/presentation/modules/chat/models/message_model.dart';
import 'package:ig_chat_reader/src/presentation/modules/chat/widgets/chat_message_item.dart';
import 'package:screenshot/screenshot.dart';

class ExportChatView extends BaseResponsiveStatelessWidget {
  final ChatExportController _controller;
  ExportChatView({super.key, required ChatExportController controller})
    : _controller = controller;

  @override
  Widget defaultWidget(BuildContext context) {
    return Scaffold(appBar: _appBar, body: _body);
  }

  AppBar get _appBar => AppBar(
    title: Text('Export'),
    actions: [
      IconButton(
        icon: Icon(Icons.send),
        onPressed: _controller.onConfirmExport,
      ),
    ],
  );

  Widget get _body => StreamBuilder<List<MessageModel>>(
    stream: _controller.selectedMessages.stream,
    builder: (context, snapshot) {
      final messages = snapshot.data ?? [];
      return Screenshot(
        controller: _controller.screenshotController,
        child: SingleChildScrollView(
          child: Column(
            children: List.generate(messages.length, (index) {
              final currentItem = messages.elementAt(index);
              final previousItem =
                  index > 0 ? messages.elementAt(index - 1) : null;
              final nextItem =
                  index < messages.length - 1
                      ? messages.elementAt(index + 1)
                      : null;
              final isMyMessage =
                  _controller.currentUsername == currentItem.username;
              return Align(
                alignment:
                    isMyMessage ? Alignment.centerRight : Alignment.centerLeft,
                child: ChatMessageItem(
                  isMyMessage: isMyMessage,
                  chatMessage: currentItem,
                  sameSenderAsLast:
                      currentItem.username == previousItem?.username,
                  sameSenderAsNext: currentItem.username == nextItem?.username,
                  onAttachmentClick: (_, _) {},
                  selectionMode: false,
                  isSelected: false,
                  onSelectionToggle: () {},
                ),
              );
            }),
          ),
        ),
      );
    },
  );
}
