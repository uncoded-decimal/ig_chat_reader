import 'package:ig_chat_reader/src/presentation/helpers/services/opfs_service.dart';
import 'package:ig_chat_reader/src/presentation/modules/home/models/file_model.dart';
import 'package:rxdart/subjects.dart';
import 'package:web/web.dart';

class AppController {
  AppController._();
  static final AppController instance = AppController._();

  final _opfs = OPFSService();

  static const String _usernameStorageKey = 'username';

  final BehaviorSubject<bool> loading = BehaviorSubject.seeded(false);

  void initialise() async {
    await _opfs.initialise();
  }

  void showMediumArticle() {
    window.open(
      'https://uncoded-decimal.medium.com/flutter-web-how-i-built-an-instagram-chat-reader-b1d8c79de5d9',
      '_blank',
    );
  }

  void showDeveloperProfile() {
    window.open('https://github.com/uncoded-decimal', '_blank');
  }

  void setCurrentUsername(String username) =>
      window.sessionStorage.setItem(_usernameStorageKey, username);
  String getCurrentUsername() =>
      window.sessionStorage.getItem(_usernameStorageKey) ?? '';

  void setCurrentChatProgress(String identifier, double progress) =>
      window.localStorage.setItem(identifier, progress.toString());
  double getChatProgress(String identifier) =>
      double.parse(window.localStorage.getItem(identifier) ?? '0');

  Future<void> setupForUsername(String username) =>
      _opfs.getFolderAtRootRef(username);

  Future<void> addFileToUser({
    required FileModel file,
    required String username,
  }) => _opfs.createFileInFolder(
    folderName: username,
    subfolderName: file.type.name,
    fileName: file.fileId,
    fileData: file.fileData!,
  );

  Future<FileModel> getHTMLFileForUser({
    required String username,
    required String fileName,
  }) async {
    final data = await _opfs.getFileInFolder(
      folderName: username,
      subfolderName: FileType.html.name,
      fileName: fileName,
    );
    return FileModel(type: FileType.html, fileId: fileName, fileData: data);
  }

  Future<FileModel> getImageFileForUser({
    required String username,
    required String fileName,
  }) async {
    final data = await _opfs.getFileInFolder(
      folderName: username,
      subfolderName: FileType.photo.name,
      fileName: fileName,
    );
    return FileModel(type: FileType.photo, fileId: fileName, fileData: data);
  }

  Future<FileModel> getAudioFileForUser({
    required String username,
    required String fileName,
  }) async {
    final data = await _opfs.getFileInFolder(
      folderName: username,
      subfolderName: FileType.audio.name,
      fileName: fileName,
    );
    return FileModel(type: FileType.audio, fileId: fileName, fileData: data);
  }

  Future<FileModel> getVideoFileForUser({
    required String username,
    required String fileName,
  }) async {
    final data = await _opfs.getFileInFolder(
      folderName: username,
      subfolderName: FileType.video.name,
      fileName: fileName,
    );
    return FileModel(type: FileType.video, fileId: fileName, fileData: data);
  }

  Future<void> removeUsersData(List<String> username) =>
      _opfs.clearDB(username);
}
