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

  /// for temporary messages, the html presents as:
  /// ```html
  /// <div>
  ///   <h2></h2> //sender
  ///   <div>
  ///     <div>
  ///       <div></div>     }
  ///       <div></div>     } four empty div imply
  ///       <div></div>     } a temporary message
  ///       <div></div>     }
  ///       <div></div>     // present for reactions made
  ///     </div>
  ///    </div> //message content
  ///   <div></div> //timestamp
  /// </div>
  /// ```
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
  final ContentType type;

  Content({
    required this.message,
    required this.media,
    required this.reactions,
    required this.type,
  });

  static Content fromHTML(Element content) {
    final contentType = ContentType.fromHTMLElement(content);
    final mediaList = content.findAllMedia();
    final reactions = content.findAllReactions();
    content.removeEmptyTags();
    String textContent =
        contentType == ContentType.temporary
            ? AppStrings.tempContentHTML
            : content.text;
    return Content(
      message: textContent,
      media: mediaList,
      reactions: reactions,
      type: contentType,
    );
  }
}

enum ContentType {
  message,
  temporary,
  reaction;

  static ContentType fromHTMLElement(Element element) {
    final finalContentDiv = element.children.first;
    int emptyDivCount = 0;
    for (Element childDiv in finalContentDiv.children) {
      if (childDiv.localName == 'div' && childDiv.innerHtml.isEmpty) {
        emptyDivCount++;
      }
    }
    if (emptyDivCount >= 4) {
      return ContentType.temporary;
    } else if (emptyDivCount == 3 &&
        finalContentDiv.children.elementAt(1).innerHtml.isEmpty) {
      return ContentType.reaction;
    }

    return ContentType.message;
  }
}
