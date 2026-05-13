import 'dart:js_interop';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:ig_chat_reader/src/presentation/modules/app/mixins/app_ops_mixin.dart';
import 'package:ig_chat_reader/src/presentation/modules/home/models/chat_model.dart';
import 'package:ig_chat_reader/src/presentation/modules/home/models/file_model.dart';
import 'package:ig_chat_reader/src/presentation/router/routes.dart';
import 'package:rxdart/subjects.dart';
import 'package:web/web.dart' hide Navigator, Text;

class HomeController with AppOpsMixin {
  static const String _folderPath = 'your_instagram_activity/messages/inbox/';

  late final NavigatorState _navigator;
  late final HTMLInputElement inputElement;

  final BehaviorSubject<String> dndEventSubject = BehaviorSubject.seeded('');
  final BehaviorSubject<ChatModel?> chatSubject = BehaviorSubject.seeded(null);

  ThemeData get currentTheme => Theme.of(_navigator.context);

  void init(BuildContext context) {
    _navigator = Navigator.of(context);
    _setupDropAndDrop();
    _setupFilePicker();
  }

  void _setupFilePicker() {
    inputElement =
        HTMLInputElement()
          ..type = 'file'
          ..accept = 'application/zip';

    inputElement.onchange =
        (Event e) {
          final file = inputElement.files?.item(0);
          if (file == null) return;
          _processPickedFile(file);
        }.toJS;
    document.body?.appendChild(inputElement);
  }

  void pickFile() {
    inputElement.click();
  }

  void _processPickedFile(File file) async {
    if (file.type != 'application/zip') {
      debugPrint('Unsupported file type');
      return;
    }
    setGlobalLoading(true);
    final ByteBuffer bufferedData = (await file.arrayBuffer().toDart).toDart;
    final fileBytes = bufferedData.asUint8List();
    final archive = ZipDecoder().decodeBytes(fileBytes);
    await ___processArchive(archive);
    setGlobalLoading(false);
  }

  void _setupDropAndDrop() {
    document.body
      ?..ondrop =
          (Event e) {
            dndEventSubject.sink.add('drop');
            final event = e as DragEvent;
            if (event.dataTransfer != null) {
              __processDrop(event.dataTransfer!);
            }
            (document.querySelector('flt-glass-pane') as HTMLElement?)?.style
                .setProperty('pointer-events', 'none');
            e.preventDefault();
          }.toJS
      ..ondragenter =
          (Event e) {
            dndEventSubject.sink.add('enter');
            (document.querySelector('flt-glass-pane') as HTMLElement?)?.style
                .setProperty('pointer-events', 'auto');
            e.preventDefault();
          }.toJS
      ..ondragover =
          (Event e) {
            dndEventSubject.sink.add('over');
            e.preventDefault();
          }.toJS;
  }

  void __processDrop(DataTransfer droppedData) async {
    final file = droppedData.items[0];
    if (file.type != 'application/zip') {
      debugPrint('Unsupported file type');
      return;
    }
    setGlobalLoading(true);
    final ByteBuffer bufferedData =
        (await file.getAsFile()!.arrayBuffer().toDart).toDart;
    final fileBytes = bufferedData.asUint8List();
    final archive = ZipDecoder().decodeBytes(fileBytes);
    await ___processArchive(archive);
    setGlobalLoading(false);
  }

  Future<void> ___processArchive(Archive archive) async {
    final chatModel = ChatModel();
    chatSubject.sink.add(null);
    for (ArchiveFile file in archive.files) {
      if (!file.name.contains(_folderPath)) {
        continue;
      }
      final username = ___usernameFromFileName(file.name);
      final fileModel = FileModel.fromArchiveFile(file);
      await addFileToUser(username, fileModel);
      chatModel.addFileToUser(username, fileModel);
    }
    chatSubject.sink.add(chatModel);
  }

  String ___usernameFromFileName(String filename) {
    final firstPartRemoved = filename.substring(_folderPath.length);
    final secondPartRemoved =
        firstPartRemoved.contains('/')
            ? firstPartRemoved.substring(0, firstPartRemoved.indexOf('/'))
            : firstPartRemoved;
    if (filename.contains('instagramuser')) {
      return secondPartRemoved;
    }
    if (secondPartRemoved.contains('_')) {
      final thirdPartRemoved = secondPartRemoved.substring(
        0,
        secondPartRemoved.lastIndexOf('_'),
      );
      return thirdPartRemoved;
    } else {
      return secondPartRemoved;
    }
  }

  int getAudioCountForUsername(String username) =>
      chatSubject.valueOrNull?.getAllAudio(username).length ?? 0;

  int getImagesCountForUsername(String username) =>
      chatSubject.valueOrNull?.getAllImages(username).length ?? 0;

  int getVideosCountForUsername(String username) =>
      chatSubject.valueOrNull?.getAllVideos(username).length ?? 0;

  void onUsernameClicked(BuildContext context, String username) async {
    // don't set it false until chat screen done loading
    setGlobalLoading(true);
    // delay added to ensure loader is visible
    await Future.delayed(const Duration(milliseconds: 100));
    final userData = chatSubject.valueOrNull?.getUserData(username);
    if (userData == null) {
      debugPrint('Chat data not found for $username');
      return;
    }

    List<FileModel> files = [];
    for (String htmlFileName in userData.htmls) {
      final file = await getHTMLFileForUser(username, htmlFileName);
      files.add(file);
    }
    for (String imageFileName in userData.photos) {
      final file = await getImageFileForUser(username, imageFileName);
      files.add(file);
    }
    for (String audioFileName in userData.audios) {
      final file = await getAudioFileForUser(username, audioFileName);
      files.add(file);
    }
    for (String videoFileName in userData.videos) {
      final file = await getVideoFileForUser(username, videoFileName);
      files.add(file);
    }

    _navigator.pushNamed(
      AppRoutes.chat,
      arguments: {'username': username, 'files': files},
    );
  }

  void requestHelp() => showGitHub();

  void clearChatData() async {
    setGlobalLoading(true);
    await clearUsersData(chatSubject.value!.usernames);
    chatSubject.sink.add(null);
    setGlobalLoading(false);
  }

  void showMessage(String message) => ScaffoldMessenger.of(
    _navigator.context,
  ).showSnackBar(SnackBar(content: Text(message), showCloseIcon: true));
}
