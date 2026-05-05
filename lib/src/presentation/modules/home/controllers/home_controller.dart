import 'dart:js_interop';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ig_chat_reader/src/presentation/modules/app/mixins/app_ops_mixin.dart';
import 'package:ig_chat_reader/src/presentation/modules/home/models/chat_model.dart';
import 'package:ig_chat_reader/src/presentation/modules/home/models/file_model.dart';
import 'package:ig_chat_reader/src/presentation/router/routes.dart';
import 'package:rxdart/subjects.dart';
import 'package:web/web.dart' hide Navigator;

class HomeController with AppOpsMixin {
  static const String _folderPath = 'your_instagram_activity/messages/inbox/';

  late final ChatModel _chat;
  late final NavigatorState _navigator;
  late final HTMLInputElement inputElement;

  final BehaviorSubject<String> dndEventSubject = BehaviorSubject.seeded('');
  final BehaviorSubject<List<String>> userNames = BehaviorSubject();

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
    ChatModel chatModel = ChatModel();
    setGlobalLoading(true);
    final ByteBuffer bufferedData = (await file.arrayBuffer().toDart).toDart;
    final fileBytes = bufferedData.asUint8List();
    final archive = ZipDecoder().decodeBytes(fileBytes);
    for (ArchiveFile file in archive.files) {
      if (!file.name.contains(_folderPath)) {
        continue;
      }
      final username = ___usernameFromFileName(file.name);
      if (username == 'instagramuser') {
        continue;
      }
      chatModel.addFileToUser(username, FileModel.fromArchiveFile(file));
    }
    ___processChat(chatModel);
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
    ChatModel chatModel = ChatModel();
    setGlobalLoading(true);
    final ByteBuffer bufferedData =
        (await file.getAsFile()!.arrayBuffer().toDart).toDart;
    final fileBytes = bufferedData.asUint8List();
    final archive = ZipDecoder().decodeBytes(fileBytes);
    for (ArchiveFile file in archive.files) {
      if (!file.name.contains(_folderPath)) {
        continue;
      }
      final username = ___usernameFromFileName(file.name);
      if (username == 'instagramuser') {
        // skip users with deleted accounts
        continue;
      }
      chatModel.addFileToUser(username, FileModel.fromArchiveFile(file));
    }
    ___processChat(chatModel);
    setGlobalLoading(false);
  }

  String ___usernameFromFileName(String filename) {
    final firstPartRemoved = filename.substring(_folderPath.length);
    final secondPartRemoved =
        firstPartRemoved.contains('/')
            ? firstPartRemoved.substring(0, firstPartRemoved.indexOf('/'))
            : firstPartRemoved;
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

  void ___processChat(ChatModel chatModel) {
    _chat = chatModel;
    userNames.sink.add(chatModel.usernames);
  }

  int getAudioCountForUsername(String username) =>
      _chat.getAllAudio(username).length;

  int getImagesCountForUsername(String username) =>
      _chat.getAllImages(username).length;

  int getVideosCountForUsername(String username) =>
      _chat.getAllVideos(username).length;

  void onUsernameClicked(BuildContext context, String username) async {
    setGlobalLoading(true);
    final userData = await compute(_chat.getCompleteUserData, username);

    setGlobalLoading(false);
    _navigator.pushNamed(
      AppRoutes.chat,
      arguments: {'username': username, 'files': userData},
    );
  }
}
