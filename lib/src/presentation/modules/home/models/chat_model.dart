import 'package:flutter/foundation.dart';
import 'package:ig_chat_reader/src/presentation/modules/home/models/file_model.dart';

class ChatModel {
  final List<String> usernames = [];
  final Map<String, List<FileModel>> _userFilesMap = {};

  bool containsUsername(String username) {
    return usernames.contains(username);
  }

  void addUser(String username) {
    if (containsUsername(username)) {
      debugPrint('Already contains $username');
      return;
    }
    usernames.add(username);
  }

  void addFileToUser(String username, FileModel file) {
    if (!containsUsername(username)) {
      addUser(username);
    }
    if (!_userFilesMap.keys.contains(username)) {
      _userFilesMap.putIfAbsent(username, () => []);
    }
    _userFilesMap[username] = _userFilesMap[username]!..add(file);
  }

  List<FileModel> getAllImages(String username) {
    List<FileModel> files = _userFilesMap[username] ?? [];
    return files.where((file) => file.type == FileType.photo).toList();
  }

  List<FileModel> getAllAudio(String username) {
    List<FileModel> files = _userFilesMap[username] ?? [];
    return files.where((file) => file.type == FileType.audio).toList();
  }

  List<FileModel> getAllVideos(String username) {
    List<FileModel> files = _userFilesMap[username] ?? [];
    return files.where((file) => file.type == FileType.video).toList();
  }

  List<FileModel> getCompleteUserData(String username) =>
      _userFilesMap[username] ?? [];
}
