import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ig_chat_reader/src/presentation/modules/chat/controllers/chat_controller.dart';
import 'package:ig_chat_reader/src/presentation/modules/chat/models/message_model.dart';
import 'package:ig_chat_reader/src/presentation/modules/chat/widgets/find_dialog_box.dart';
import 'package:ig_chat_reader/src/presentation/modules/chat/views/find_result_view.dart';
import 'package:rxdart/subjects.dart';

class FindController {
  final ChatController chatController;
  final TextEditingController queryTextController = TextEditingController();

  FindController({required this.chatController});

  final BehaviorSubject<bool> isLoading = BehaviorSubject.seeded(false);
  final BehaviorSubject<List<MessageModel>> messages = BehaviorSubject();
  final BehaviorSubject<Completer> findContinueCompleter = BehaviorSubject();

  void showFindDialogBox() {
    showAdaptiveDialog(
      context: chatController.context,
      builder:
          (_) => ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 250),
            child: FindDialogBox(controller: this),
          ),
    );
  }

  Future<void> find() async {
    final query = queryTextController.value.text;
    _displayResultsView(query);
    int startIndex = 0;
    do {
      if (startIndex != 0) {
        isLoading.sink.add(true);
        // load more content when available
        await chatController.loadNext();
        isLoading.sink.add(false);
      }
      final continueSearch = await _queryText(
        query: query,
        startIndex: startIndex,
      );
      if (!continueSearch) {
        break;
      }
      startIndex = chatController.chatMessagesSubject.value.length;
    } while (chatController.hasMoreContent);
    chatController.showMessage('No more results to be found.');
  }

  // returns whether to continue search
  Future<bool> _queryText({required String query, int startIndex = 0}) async {
    // creating local value to ensure a flexible limit
    // when more messages are loaded in
    final chat = chatController.chatMessagesSubject.value;
    for (int i = startIndex; i < chat.length; i++) {
      isLoading.sink.add(true);
      final message = chat.elementAt(i);
      final containsQuery = message.content.message.toLowerCase().contains(
        query.toLowerCase(),
      );
      isLoading.sink.add(false);
      if (containsQuery) {
        final continueSearch = await __onQueryFound(
          foundAtIndex: i,
          query: query,
          message: message,
        );
        if (!continueSearch) {
          return false;
        }
      }
    }
    return true;
  }

  Future<bool> __onQueryFound({
    required int foundAtIndex,
    required String query,
    required MessageModel message,
  }) async {
    bool continueSearch = true;
    debugPrint('=======================================');
    debugPrint('Found $query at $foundAtIndex in ${{message.content.message}}');
    debugPrint('=======================================');

    Completer findResultAction = Completer();
    findContinueCompleter.sink.add(findResultAction);
    messages.sink.add([message]);

    continueSearch = await findResultAction.future;
    if (continueSearch) {
      // allow time to visually pop the results screen before
      // pushing again
      await Future.delayed(const Duration(milliseconds: 0));
    }
    return continueSearch;
  }

  void _displayResultsView(String query) =>
      Navigator.of(chatController.context).push<bool?>(
        MaterialPageRoute(
          barrierDismissible: true,
          builder: (_) => FindResultView(controller: this),
          fullscreenDialog: true,
          requestFocus: true,
          settings: RouteSettings(name: '/find_result'),
        ),
      );
}
