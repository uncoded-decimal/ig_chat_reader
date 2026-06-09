import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ig_chat_reader/src/presentation/components/base_view.dart';
import 'package:ig_chat_reader/src/presentation/components/loading_screen.dart';
import 'package:ig_chat_reader/src/presentation/modules/chat/controllers/find_controller.dart';
import 'package:ig_chat_reader/src/presentation/modules/chat/models/message_model.dart';
import 'package:ig_chat_reader/src/presentation/modules/chat/widgets/chat_message_item.dart';

class FindResultView extends BaseResponsiveStatelessWidget {
  final FindController _controller;

  FindResultView({super.key, required FindController controller})
    : _controller = controller;

  @override
  Widget defaultWidget(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<bool>(
        stream: _controller.isLoading.stream,
        builder: (context, snapshot) {
          return Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _findResultTitle,
                  Expanded(child: _findResultMessages),
                  _actionButtons,
                ],
              ),
              if (!snapshot.hasData || snapshot.data!) const LoadingScreen(),
            ],
          );
        },
      ),
    );
  }

  Widget get _findResultTitle => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24),
    child: Text(
      'Search result for "${_controller.queryTextController.value.text}"',
      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
    ),
  );

  Widget get _findResultMessages {
    return StreamBuilder<List<MessageModel>>(
      stream: _controller.messages.stream,
      builder: (context, snapshot) {
        if (snapshot.data == null) {
          return const SizedBox.shrink();
        }
        final list = snapshot.data as List<MessageModel>;
        return Container(
          margin: const EdgeInsets.all(24),
          width: double.maxFinite,
          decoration: BoxDecoration(
            color: Color(0xfffffffa),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black54, width: 1.2),
          ),
          child: ListView.builder(
            controller: _controller.findResultScrollController,
            itemCount: list.length,
            itemBuilder: (_, index) {
              final currentItem = list.elementAt(index);
              final previousItem = index > 0 ? list.elementAt(index - 1) : null;
              final nextItem =
                  index < list.length - 1 ? list.elementAt(index + 1) : null;
              final isMarked = _controller.stringContainsQuery(
                currentItem.content.message,
              );
              return ChatMessageItem(
                isMyMessage: _controller.chatController.getIsMyMessage(
                  currentItem.username,
                ),
                chatMessage: currentItem,
                sameSenderAsLast:
                    currentItem.username == previousItem?.username,
                sameSenderAsNext: currentItem.username == nextItem?.username,
                onAttachmentClick: _controller.chatController.onAttachmentClick,
                selectionMode: false,
                isSelected: isMarked,
                onSelectionToggle: () {},
                showAttachments:
                    _controller.chatController.showAttachments.valueOrNull ??
                    true,
              );
            },
          ),
        );
      },
    );
  }

  Widget get _actionButtons => StreamBuilder<Completer>(
    stream: _controller.findContinueCompleter.stream,
    builder: (context, snapshot) {
      if (snapshot.data == null) {
        return const SizedBox.shrink();
      }
      final completer = snapshot.data as Completer;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24),
        child: Row(
          spacing: 16,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton(
              onPressed: () {
                try {
                  completer.complete(false);
                } on StateError catch (_) {
                  debugPrint(
                    'last result; nothing new found with completer already finished.',
                  );
                }
                Navigator.of(context).pop();
              },
              child: Text('Stop'),
            ),
            ElevatedButton(
              onPressed: () => completer.complete(true),
              child: Text('Next'),
            ),
          ],
        ),
      );
    },
  );
}
