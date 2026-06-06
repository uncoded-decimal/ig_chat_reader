import 'dart:convert';
import 'dart:js_interop';
import 'dart:math';
import 'package:flutter/material.dart' hide Element;
import 'package:html/dom.dart' show Element;
import 'package:html/parser.dart';
import 'package:ig_chat_reader/src/presentation/components/base_view.dart';
import 'package:ig_chat_reader/src/presentation/helpers/extensions/rxdart_extension.dart';
import 'package:ig_chat_reader/src/presentation/modules/app/mixins/app_ops_mixin.dart';
import 'package:ig_chat_reader/src/presentation/modules/chat/controllers/find_controller.dart';
import 'package:ig_chat_reader/src/presentation/modules/chat/models/message_model.dart';
import 'package:ig_chat_reader/src/presentation/modules/home/models/file_model.dart';
import 'package:ig_chat_reader/src/presentation/router/routes.dart';
import 'package:rxdart/subjects.dart';
import 'package:web/web.dart' hide Element, Navigator, Text;

class ChatController with AppOpsMixin {
  final String username;
  final List<FileModel> files;

  late final FindController _findController;

  ChatController({required this.username, required this.files});

  late final NavigatorState _navigator;

  late HTMLMediaElement audioMediaElement;
  late AudioContext audioContext;
  late HTMLButtonElement playButtonElement;

  final List<FileModel> _chatFiles = [];
  final List<String> _loadedFileIDs = [];

  final BehaviorSubject<Set<String>> namesFound = BehaviorSubject();
  final BehaviorSubject<String> myName = BehaviorSubject.seeded('');

  // all chat messages are channeled into this
  final BehaviorSubject<List<MessageModel>> chatMessagesSubject =
      BehaviorSubject.seeded([]);

  final BehaviorSubject<bool> showAttachments = BehaviorSubject.seeded(true);

  final scrollController = ScrollController();

  String? _chatKey;

  bool get hasMoreContent => _loadedFileIDs.length < _chatFiles.length;

  BuildContext get context => _navigator.context;

  double getSafeCacheLength(LayoutMode currentLayoutMode) {
    if (_chatFiles.length == 1) {
      return 3000;
    } else {
      return switch (currentLayoutMode) {
        LayoutMode.desktop when _loadedFileIDs.length == 1 => 2000,
        LayoutMode.desktop when _loadedFileIDs.length > 1 => 1000,
        (_) => 800,
      };
    }
  }

  List<FileModel> get allAudios =>
      files
          .where((file) => file.type == FileType.audio)
          .toList()
          .reversed
          .toList();

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

  void dispose() {
    debugPrint('Dropping all ${files.length} URLs for $username');
    for (FileModel file in files) {
      file.revokeFileUrl();
    }
    debugPrint('Closing all streams');
    namesFound.close();
    myName.close();
    chatMessagesSubject.sink.add([]);
    chatMessagesSubject.close();
    showAttachments.close();
    debugPrint('Removing all HTML chat elements');
    audioMediaElement.remove();
    playButtonElement.remove();
    debugPrint('Removing scroll controller');
    scrollController
      ..removeListener(__updateChatProgress)
      ..dispose();
    debugPrint('Removing image cache');
    PaintingBinding.instance.imageCache.clear();
  }

  void init(BuildContext context) async {
    _navigator = Navigator.of(context);
    _addKeyboardActions();
    //set to load maximum of 3 images at a time
    PaintingBinding.instance.imageCache.maximumSize = 3;
    //set to load maximum of 50 MB in image cache
    PaintingBinding.instance.imageCache.maximumSizeBytes = 50 * 1024 * 1024;
    _setupAudioPlayer();
    await _processChat();
    _findController = FindController(chatController: this);
    myName.waitUntilValue().then((name) async {
      final sortedNames =
          (await namesFound.waitUntilValue()).toList()
            ..sort((a, b) => a.compareTo(b));
      _chatKey =
          sortedNames
              .join(':')
              .replaceAll(RegExp(r'[^a-zA-Z0-9:]'), '_')
              .toLowerCase();
      _setupChatProgress();
    });
  }

  void _addKeyboardActions() {
    final screenHeight = MediaQuery.sizeOf(_navigator.context).height;
    window.onKeyDown.listen((KeyboardEvent event) {
      switch (event.keyCode) {
        case 40:
          scrollController.animateTo(
            scrollController.offset + screenHeight / 2,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCirc,
          );
          break;
        case 38:
          scrollController.animateTo(
            scrollController.offset - screenHeight / 2,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCirc,
          );
          break;
      }
    });

    window.onKeyPress.listen((KeyboardEvent event) {
      if (event.ctrlKey && event.code == 'KeyF') {
        startFinder();
      }
    });
  }

  void _setupChatProgress() {
    // scroll to messages last found for user
    final progressFound = getChatProgress(chatKey: _chatKey!);
    if (progressFound > 100) {
      __onProgressFound(progressFound);
    }

    // setup listener to update chat progress
    scrollController.addListener(__updateChatProgress);
  }

  void __updateChatProgress() {
    setChatProgress(chatKey: _chatKey!, scrollIndex: scrollController.offset);
  }

  void __onProgressFound(double progressFound) {
    ScaffoldMessenger.of(_navigator.context).showSnackBar(
      SnackBar(
        content: Text('Found progress made for this user'),
        showCloseIcon: true,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Show',
          onPressed:
              () => ___loadChatFilesAndScrollUntilRequired(progressFound),
        ),
      ),
    );
  }

  Future<void> ___loadChatFilesAndScrollUntilRequired(
    double progressFound,
  ) async {
    final stepScrollLength = scrollController.position.viewportDimension;
    final currentMaximum = scrollController.position.maxScrollExtent;
    debugPrint('Scroll length on page: $currentMaximum');
    int pagesCount = progressFound ~/ currentMaximum;
    while (pagesCount != 0) {
      await loadNext();
      pagesCount--;
    }

    double scrolledLength = 0;
    do {
      setGlobalLoading(true);

      // disabling hiding to ensure accurate scrolls
      // showAttachments.sink.add(false);

      await Future.delayed(const Duration(milliseconds: 100));
      await scrollController.animateTo(
        scrolledLength,
        curve: Curves.linear,
        duration: Duration(milliseconds: 200),
      );
      scrolledLength += stepScrollLength;
    } while (scrolledLength <= progressFound);
    showAttachments.sink.add(true);
    setGlobalLoading(false);
    showMessage('Scroll completed');
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

  Future<void> _processChat() async {
    // reversing because messages_2 is later than messages_1
    final chatFiles =
        files.where((file) => file.type == FileType.html).toList().reversed;
    _chatFiles.addAll(chatFiles);
    // in case chat exists through multiple files, load them one by one
    if (_chatFiles.isNotEmpty) {
      await __loadFile(_chatFiles.first.fileId);
    } else {
      debugPrint('Unable to find chat files');
    }
  }

  Future<void> loadNext() async {
    for (FileModel file in _chatFiles) {
      if (_loadedFileIDs.contains(file.fileId)) {
        continue;
      }
      await __loadFile(file.fileId);
      break;
    }
  }

  Future<void> __loadFile(String fileID) async {
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
    final contents = utf8.decode(fileData);
    final messagesList = await __processHTMLContent(contents);

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

  bool getIsMyMessage(String username) => myName.valueOrNull == username;

  Future<List<MessageModel>> __processHTMLContent(String content) async {
    final Set<String> usernamesFound = {};
    List<MessageModel> messages = [];
    final htmlDocument = parse(content);
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

  void viewAllAudios() {
    try {
      final List<Map<String, String>> audioUsernameList = [];
      for (FileModel file in allAudios) {
        final message = chatMessagesSubject.valueOrNull?.firstWhere(
          (message) => message.files.contains(file),
        );
        final sender = message?.username ?? '';
        audioUsernameList.add({'username': sender, 'audio': file.fileId});
      }
      _navigator.pushNamed(
        AppRoutes.allChatAudios,
        arguments: {
          'audios': allAudios,
          'audio_username': audioUsernameList,
          'onClick': (String url) => playAudio(url),
        },
      );
    } catch (e) {
      showMessage('No Audios found in currently loaded chat');
    }
  }

  void viewAllPhotos() async {
    try {
      final List<Map<String, String>> photoUsernameList = [];
      for (FileModel file in allPhotos) {
        final message = chatMessagesSubject.valueOrNull?.firstWhere(
          (message) => message.files.contains(file),
        );
        final sender = message?.username ?? '';
        photoUsernameList.add({'username': sender, 'photo': file.fileId});
        await file.createBlobUrls();
      }
      await _navigator.pushNamed(
        AppRoutes.allChatPhotos,
        arguments: {
          'photos': allPhotos,
          'photo_username': photoUsernameList,
          'onClick': (String url) => window.open(url, 'new'),
        },
      );
      for (FileModel file in allPhotos) {
        file.revokeFileUrl();
      }
    } catch (e) {
      showMessage('No Photos found in currently loaded chat');
    }
  }

  void viewAllVideos() {
    try {
      final List<Map<String, String>> videoUsernameList = [];
      for (FileModel file in allVideos) {
        final message = chatMessagesSubject.valueOrNull?.firstWhere(
          (message) => message.files.contains(file),
        );
        final sender = message?.username ?? '';
        videoUsernameList.add({'username': sender, 'video': file.fileId});
      }
      _navigator.pushNamed(
        AppRoutes.allChatVideos,
        arguments: {
          'videos': allVideos,
          'video_username': videoUsernameList,
          'onClick': (String url) => window.open(url, '_blank'),
        },
      );
    } catch (e) {
      showMessage('No Videos found in currently loaded chat');
    }
  }

  void onNameChange(String? value) {
    if (value == null) {
      return;
    }
    myName.sink.add(value);
    setUsername(value);
  }

  void startFinder() => _findController.showFindDialogBox();

  void showMessage(String message) => ScaffoldMessenger.of(
    _navigator.context,
  ).showSnackBar(SnackBar(content: Text(message), showCloseIcon: true));
}
