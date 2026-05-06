import 'package:html/dom.dart';
import 'package:ig_chat_reader/src/presentation/helpers/resources/strings.dart';
import 'package:ig_chat_reader/src/presentation/modules/home/models/file_model.dart';
import 'package:intl/intl.dart';
import 'package:ig_chat_reader/src/presentation/helpers/extensions/html_extension.dart';

class MessageModel {
  final String username;
  final Content content;
  final DateTime? timestamp;

  final List<FileModel> files;

  MessageModel({
    required this.username,
    required this.content,
    required this.timestamp,
    required this.files,
  });

  static MessageModel fromMessageElement(Element message) {
    final username = message.children.first.innerHtml;
    final timestamp = DateFormat(
      'MMM dd, yyyy hh:mm a',
    ).tryParseLoose(message.children.last.innerHtml);
    final parsedContent = Content.fromHTML(message.children.elementAt(1));
    return MessageModel(
      username: username,
      content: parsedContent,
      timestamp: timestamp,
      files: [],
    );
  }

  void addFile(FileModel file) => files.add(file);
}

class Content {
  final String message;
  final List<String> media;
  final List<String> reactions;

  Content({
    required this.message,
    required this.media,
    required this.reactions,
  });

  static Content fromHTML(Element content) {
    final mediaList = content.findAllMedia();
    final reactions = content.findAllReactions();
    content.removeEmptyTags();
    String textContent =
        content.innerHtml.isEmpty
            ? AppStrings.tempContentHTML
            : content.stripToText();
    return Content(
      message: textContent,
      media: mediaList,
      reactions: reactions,
    );
  }
}
