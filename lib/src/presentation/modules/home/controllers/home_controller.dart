import 'dart:convert';
import 'dart:js_interop';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ig_chat_reader/src/presentation/modules/app/mixins/app_ops_mixin.dart';
import 'package:ig_chat_reader/src/presentation/helpers/services/thumbnail_generation_service.dart';
import 'package:ig_chat_reader/src/presentation/modules/home/models/chat_model.dart';
import 'package:ig_chat_reader/src/presentation/modules/home/models/file_model.dart';
import 'package:ig_chat_reader/src/presentation/router/routes.dart';
import 'package:rxdart/subjects.dart';
import 'package:web/web.dart' hide Navigator;

class HomeController with AppOpsMixin {
  static const String _folderPath = 'your_instagram_activity/messages/inbox/';

  final BehaviorSubject<ChatModel?> _chat = BehaviorSubject.seeded(null);
  late final NavigatorState _navigator;
  late final HTMLInputElement inputElement;

  final BehaviorSubject<String> dndEventSubject = BehaviorSubject.seeded('');
  final BehaviorSubject<List<String>> userNames = BehaviorSubject();

  void init(BuildContext context) {
    _navigator = Navigator.of(context);
    _setupDropAndDrop();
    _setupFilePicker();
    _chat.listen((data) {
      if (data != null) {
        userNames.sink.add(data.usernames);
      } else {
        userNames.sink.add([]);
      }
    });
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
      final fileModel = FileModel.fromArchiveFile(file);
      if (fileModel.type == FileType.video) {
        final thumbnailData = await ThumbnailService.fromBlobUrl(
          fileModel.blobUrl!,
        );
        final dataList = base64Decode(thumbnailData.split(',').last);
        final blob = Blob(
          [dataList.toJS].toJS,
          BlobPropertyBag(type: 'video/mp4'),
        );
        fileModel.thumbnailUrl = URL.createObjectURL(blob);
      }
      chatModel.addFileToUser(username, fileModel);
    }
    _chat.sink.add(chatModel);
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
      final fileModel = FileModel.fromArchiveFile(file);
      if (fileModel.type == FileType.video) {
        final thumbnailData = await ThumbnailService.fromBlobUrl(
          fileModel.blobUrl!,
        );
        final dataList = base64Decode(thumbnailData.split(',').last);
        final blob = Blob(
          [dataList.toJS].toJS,
          BlobPropertyBag(type: 'video/mp4'),
        );
        fileModel.thumbnailUrl = URL.createObjectURL(blob);
      }
      chatModel.addFileToUser(username, fileModel);
    }
    _chat.sink.add(chatModel);
    setGlobalLoading(false);
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
      _chat.value?.getAllAudio(username).length ?? 0;

  int getImagesCountForUsername(String username) =>
      _chat.value?.getAllImages(username).length ?? 0;

  int getVideosCountForUsername(String username) =>
      _chat.value?.getAllVideos(username).length ?? 0;

  void onUsernameClicked(BuildContext context, String username) async {
    // don't set it false until chat screen done loading
    setGlobalLoading(true);
    // delay added to ensure loader is visible
    await Future.delayed(const Duration(milliseconds: 100));
    final userData = await compute(_chat.value!.getCompleteUserData, username);
    _navigator.pushNamed(
      AppRoutes.chat,
      arguments: {'username': username, 'files': userData},
    );
  }

  void requestHelp() => showGitHub();
}
