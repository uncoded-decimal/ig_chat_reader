import 'package:ig_chat_reader/src/presentation/modules/home/models/file_model.dart';

class ChatModel {
  final Map<String, ChatUserModel?> _userFilesMap = {};

  List<String> get usernames => _userFilesMap.keys.toList();

  ChatUserModel? getUserData(String username) => _userFilesMap[username];

  bool containsUsername(String username) {
    return _userFilesMap.keys.contains(username);
  }

  void addUser(String username) {
    if (containsUsername(username)) {
      return;
    }
    _userFilesMap[username] = ChatUserModel(
      username: username,
      photos: [],
      audios: [],
      videos: [],
      htmls: [],
    );
  }

  void addFileToUser(String username, FileModel file) {
    addUser(username);
    if (file.type == FileType.photo) {
      _userFilesMap[username]!.photos.add(file.fileId);
    } else if (file.type == FileType.audio) {
      _userFilesMap[username]!.audios.add(file.fileId);
    } else if (file.type == FileType.video) {
      _userFilesMap[username]!.videos.add(file.fileId);
    } else if (file.type == FileType.html) {
      _userFilesMap[username]!.htmls.add(file.fileId);
    }
  }

  List<String> getAllImages(String username) {
    return _userFilesMap[username]?.photos ?? [];
  }

  List<String> getAllAudio(String username) {
    return _userFilesMap[username]?.audios ?? [];
  }

  List<String> getAllVideos(String username) {
    return _userFilesMap[username]?.videos ?? [];
  }

  // Future<List<FileModel>> getCompleteUserData(String username) async {
  //   return _userFilesMap[username] ?? [];
  // }

  /// [exclude] points to the username whose data needs
  /// to be preserved.
  // Future<void> removeAllData() async {
  //   _userFilesMap.clear();
  // }
}

class ChatUserModel {
  final String username;
  final List<String> htmls;
  final List<String> photos;
  final List<String> audios;
  final List<String> videos;

  ChatUserModel({
    required this.username,
    required this.htmls,
    required this.photos,
    required this.audios,
    required this.videos,
  });
}
