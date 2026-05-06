import 'dart:js_interop';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:ig_chat_reader/src/presentation/modules/app/mixins/app_ops_mixin.dart';
import 'package:ig_chat_reader/src/presentation/modules/chat/models/message_model.dart';
import 'package:ig_chat_reader/src/presentation/modules/chat/widgets/chat_message_item.dart';
import 'package:ig_chat_reader/src/presentation/router/routes.dart';
import 'package:rxdart/rxdart.dart';
import 'package:screenshot/screenshot.dart';
import 'package:web/web.dart' hide Navigator;

class ChatExportController with AppOpsMixin {
  late final NavigatorState _navigator;

  final ScreenshotController screenshotController = ScreenshotController();

  final BehaviorSubject<bool> selectionMode = BehaviorSubject.seeded(false);
  final BehaviorSubject<List<MessageModel>> selectedMessages =
      BehaviorSubject.seeded([]);

  String get currentUsername => getUsername();

  void init(BuildContext context) {
    _navigator = Navigator.of(context);
  }

  void toggleSelectionMode() {
    final currentStatus = selectionMode.value;
    selectionMode.sink.add(!currentStatus);
    if (currentStatus) {
      selectedMessages.sink.add([]);
    }
  }

  void toggleSelection(MessageModel message) {
    final selectedList = selectedMessages.value;
    if (isSelected(message)) {
      selectedList.remove(message);
    } else {
      selectedList.add(message);
    }
    selectedMessages.sink.add(selectedList);
  }

  bool isSelected(MessageModel message) {
    if (!selectionMode.value) {
      return false;
    }
    return selectedMessages.value.contains(message);
  }

  void onExportClick() => _navigator.pushNamed(
    AppRoutes.exportChat,
    arguments: {'export_controller': this},
  );

  void onConfirmExport() async {
    setGlobalLoading(true);
    final messages = selectedMessages.value;
    final data = await screenshotController.captureFromLongWidget(
      MediaQuery(
        data: MediaQuery.of(_navigator.context),
        child: Localizations(
          locale: Localizations.localeOf(_navigator.context),
          delegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          child: InheritedTheme.captureAll(
            _navigator.context,
            Material(
              child: Column(
                children: List.generate(messages.length, (index) {
                  final currentItem = messages.elementAt(index);
                  final previousItem =
                      index > 0 ? messages.elementAt(index - 1) : null;
                  final isMyMessage = currentUsername == currentItem.username;
                  return Align(
                    alignment:
                        isMyMessage
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                    child: ChatMessageItem(
                      isMyMessage: isMyMessage,
                      chatMessage: currentItem,
                      sameSenderAsLast:
                          currentItem.username == previousItem?.username,
                      onAttachmentClick: (_, _) {},
                      selectionMode: false,
                      isSelected: false,
                      onSelectionToggle: () {},
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
      context: _navigator.context,
      constraints: BoxConstraints(maxWidth: 600),
    );
    final blob = Blob([data.toJS].toJS, BlobPropertyBag(type: 'image/png'));
    setGlobalLoading(false);
    final url = URL.createObjectURL(blob);
    HTMLAnchorElement()
      ..href = url
      ..download = 'chat_screenshot.png'
      ..click();
    Future.delayed(
      const Duration(seconds: 1),
    ).then((_) => URL.revokeObjectURL(url));
  }
}
