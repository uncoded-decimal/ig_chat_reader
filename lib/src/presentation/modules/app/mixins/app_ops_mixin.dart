import 'package:flutter/foundation.dart';
import 'package:ig_chat_reader/src/presentation/modules/app/controllers/app_controller.dart';

mixin AppOpsMixin {
  final _controller = AppController.instance;

  void setGlobalLoading(bool loading) => _controller.loading.sink.add(loading);

  void showGitHub() => _controller.showDeveloperProfile();

  void setUsername(String name) {
    debugPrint('Setting current username: $name');
    _controller.setCurrentUsername(name);
  }

  /// may return an empty string
  String getUsername() {
    final name = _controller.getCurrentUsername();
    debugPrint('Found current username: $name');
    return name;
  }

  void setChatProgress({
    required String chatKey,
    required double scrollIndex,
  }) => _controller.setCurrentChatProgress(chatKey, scrollIndex);

  double getChatProgress({required String chatKey}) =>
      _controller.getChatProgress(chatKey);
}
