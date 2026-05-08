import 'dart:convert';
import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Element;
import 'package:html/dom.dart' show Element;
import 'package:html/parser.dart';
import 'package:ig_chat_reader/src/presentation/helpers/extensions/rxdart_extension.dart';
import 'package:ig_chat_reader/src/presentation/modules/app/mixins/app_ops_mixin.dart';
import 'package:ig_chat_reader/src/presentation/modules/chat/models/message_model.dart';
import 'package:ig_chat_reader/src/presentation/modules/home/models/file_model.dart';
import 'package:ig_chat_reader/src/presentation/router/routes.dart';
import 'package:rxdart/subjects.dart';
import 'package:web/web.dart' hide Element, Navigator;

class ChatController with AppOpsMixin {
  final String username;
  final List<FileModel> files;
  late final NavigatorState _navigator;

  ChatController({required this.username, required this.files});

  late HTMLMediaElement audioMediaElement;
  late AudioContext audioContext;
  late HTMLButtonElement playButtonElement;

  final List<FileModel> _chatFiles = [];
  final List<String> _loadedFileIDs = [];

  final BehaviorSubject<Set<String>> namesFound = BehaviorSubject();
  final BehaviorSubject<String> myName = BehaviorSubject();

  final BehaviorSubject<List<MessageModel>> chatMessagesSubject =
      BehaviorSubject();

  final scrollController = ScrollController();

  bool get hasMoreContent => _loadedFileIDs.length < _chatFiles.length;

  List<FileModel> get allPhotos =>
      files
          .where((file) => file.type == FileType.photo)
          .toList()
          .reversed
          .toList();

  List<FileModel> get allVideos =>
      files
          .where((file) => file.type == FileType.video)
          .toList()
          .reversed
          .toList();

  void init(BuildContext context) {
    _navigator = Navigator.of(context);
    _setupAudioPlayer();
    _processChat();
  }

  void _setupAudioPlayer() {
    playButtonElement = HTMLButtonElement()..className = 'paused';
    audioMediaElement = HTMLAudioElement();
    audioContext = AudioContext();

    document.body
      ?..appendChild(audioMediaElement)
      ..appendChild(playButtonElement);

    final source = audioContext.createMediaElementSource(audioMediaElement);
    source.connect(audioContext.destination);

    playButtonElement.addEventListener(
      "click",
      (Event _) {
        if (playButtonElement.classList.contains("paused")) {
          audioContext.resume().toDart.then((_) {
            playButtonElement.classList
              ..remove("paused")
              ..add("playing");
            audioMediaElement.play();
          });
        } else if (playButtonElement.classList.contains("playing")) {
          audioContext.suspend().toDart.then((_) {
            playButtonElement.classList
              ..add("paused")
              ..remove("playing");
            audioMediaElement.pause();
          });
        }
      }.toJS,
    );

    // https://developer.mozilla.org/en-US/docs/Web/API/HTMLMediaElement#events
    audioMediaElement.addEventListener(
      "ended",
      (Event _) {
        URL.revokeObjectURL(audioMediaElement.src);
        playButtonElement.classList
          ..add("paused")
          ..remove("playing");
      }.toJS,
    );
  }

  void _processChat() async {
    // reversing because messages_2 is later than messages_1
    final chatFiles =
        files.where((file) => file.type == FileType.html).toList().reversed;
    _chatFiles.addAll(chatFiles);
    // in case chat exists through multiple files, load them one by one
    __loadFile(_chatFiles.first.fileId);
  }

  void loadNext() {
    for (FileModel file in _chatFiles) {
      if (_loadedFileIDs.contains(file.fileId)) {
        continue;
      }
      __loadFile(file.fileId);
      break;
    }
  }

  void __loadFile(String fileID) async {
    if (_loadedFileIDs.contains(fileID)) {
      debugPrint('Already loaded $fileID');
      return;
    }

    setGlobalLoading(true);
    debugPrint('loading file $fileID');
    final fileByFileID = _chatFiles.where((file) => file.fileId == fileID);
    final fileData = fileByFileID.firstOrNull?.fileData;
    if (fileByFileID.isEmpty || fileData == null) {
      debugPrint('File empty');
      return;
    }
    final contents = await compute(utf8.decode, fileData);
    final messagesList = await compute(__processHTMLContent, contents);

    ___setupMyName();

    final updatedChatMessagesList =
        (chatMessagesSubject.valueOrNull ?? [])..addAll(messagesList);

    chatMessagesSubject.sink.add(updatedChatMessagesList);
    _loadedFileIDs.add(fileID);
    setGlobalLoading(false);
  }

  void ___setupMyName() async {
    final namesInChat = await namesFound.waitUntilValue();
    final storedName = getUsername();
    if (storedName.isNotEmpty && namesInChat.contains(storedName)) {
      myName.sink.add(storedName);
      return;
    }

    final differentName = namesInChat.firstWhere(
      (name) => name.replaceAll(' ', '').toLowerCase() != username,
      orElse: () => namesInChat.first,
    );
    myName.sink.add(differentName);
    onNameChange(differentName);
  }

  Future<List<MessageModel>> __processHTMLContent(String content) async {
    final Set<String> usernamesFound = {};
    List<MessageModel> messages = [];
    final htmlDocument = await compute(parse, content);
    final elementsList = htmlDocument.getElementsByClassName('_a706');
    for (Element element in elementsList) {
      // reversing here so all is in order
      for (Element child in element.children.reversed) {
        if (child.className == '_7s7q') {
          // skip adding html file links
          continue;
        }
        final model = MessageModel.fromMessageElement(child);
        usernamesFound.add(model.username);
        if (model.content.message.isNotEmpty) {
          // only adds chat messages with some content
          if (model.content.media.isNotEmpty) {
            // traverse and add from files wherever found
            // by matching for included fileID (name + extension)
            for (String mediaLink in model.content.media) {
              // some images do not have an extension by default
              final isMalformedMediaLink =
                  !mediaLink.contains('http') && !mediaLink.contains('.');
              if (isMalformedMediaLink) {
                debugPrint('\nMalformed $mediaLink');
                final keyToSearchFor = mediaLink.substring(
                  mediaLink.lastIndexOf('/') + 1,
                );
                final filesFound = files.where(
                  (file) => file.fileId.contains(keyToSearchFor),
                );
                for (var e in filesFound) {
                  debugPrint('adding files =${e.blobUrl}');
                }
                model.files.addAll(filesFound);
              } else {
                final filesFound = files.where((file) {
                  final adding =
                      file.type != FileType.html &&
                      mediaLink.contains(file.fileId);
                  return adding;
                });
                model.files.addAll(filesFound);
              }
            }
          }
          messages.add(model);
        }
      }
    }
    namesFound.sink.add(usernamesFound);
    return messages;
  }

  void onAttachmentClick(String? link, FileModel? file) async {
    if (file != null) {
      // process file here
      if (file.type == FileType.audio) {
        playAudio(file.blobUrl!);
      } else if (file.type == FileType.video) {
        window.open(file.blobUrl!, 'new');
      } else if (file.type == FileType.photo) {
        window.open(file.blobUrl!, 'new');
      }
      return;
    }

    // if not file, a link
    if (link != null) {
      window.open(link, 'new');
    }
  }

  void playAudio(String src) {
    audioMediaElement.src = src;
    playButtonElement.click();
  }

  void viewAllPhotos() {
    _navigator.pushNamed(
      AppRoutes.allChatPhotos,
      arguments: {
        'photos': allPhotos,
        'onClick': (String url) => window.open(url, 'new'),
      },
    );
  }

  void viewAllVideos() {
    _navigator.pushNamed(
      AppRoutes.allChatVideos,
      arguments: {
        'videos': allVideos,
        'onClick': (String url) => window.open(url, '_blank'),
      },
    );
  }

  void onNameChange(String? value) {
    if (value == null) {
      return;
    }
    myName.sink.add(value);
    setUsername(value);
  }
}
