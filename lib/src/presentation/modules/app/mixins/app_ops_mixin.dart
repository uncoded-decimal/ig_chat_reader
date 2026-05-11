import 'package:flutter/foundation.dart';
import 'package:ig_chat_reader/src/presentation/modules/app/controllers/app_controller.dart';
import 'package:ig_chat_reader/src/presentation/modules/home/models/file_model.dart';

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

  Future<void> addUsernameToDB(String username) =>
      _controller.setupForUsername(username);

  Future<void> addFileToUser(String username, FileModel file) =>
      _controller.addFileToUser(username: username, file: file);

  Future<FileModel> getHTMLFileForUser(String username, String fileName) =>
      _controller.getHTMLFileForUser(username: username, fileName: fileName);

  Future<FileModel> getImageFileForUser(String username, String fileName) =>
      _controller.getImageFileForUser(username: username, fileName: fileName);

  Future<FileModel> getAudioFileForUser(String username, String fileName) =>
      _controller.getAudioFileForUser(username: username, fileName: fileName);

  Future<FileModel> getVideoFileForUser(String username, String fileName) =>
      _controller.getVideoFileForUser(username: username, fileName: fileName);

  Future<void> clearUsersData(List<String> usernames) =>
      _controller.removeUsersData(usernames);
}
