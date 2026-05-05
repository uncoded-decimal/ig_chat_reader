import 'package:html/dom.dart';

extension HTMLTagFilteringExtension on Element {
  static final RegExp _reactionMessagePattern = RegExp(
    r'Reacted .+ to your message',
  );

  List<String> findAllMedia() {
    final list = _traverseForMedia(this);
    return list;
  }

  List<String> _traverseForMedia(Element element) {
    List<String> media = [];
    if (element.localName == 'a' && element.children.isEmpty) {
      element.remove();
      return [element.text];
    } else if (element.localName == 'audio') {
      // removing the element would cause an empty div
      // element.remove();
      final src = element.attributes.cast<String, String>()['src'] ?? '';
      return [src];
    } else if (element.localName == 'img') {
      element.remove();
      final src = element.attributes.cast<String, String>()['src'] ?? '';
      return [src];
    } else if (element.localName == 'video') {
      final src = element.attributes.cast<String, String>()['src'] ?? '';
      return [src];
    }
    if (element.children.isEmpty) {
      return [];
    }
    for (Element childElement in element.children) {
      final list = _traverseForMedia(childElement);
      media.addAll(list);
    }
    return media;
  }

  List<String> findAllReactions() {
    final list = _traverseForReactions(this);
    return list;
  }

  List<String> _traverseForReactions(Element element) {
    List<String> reactions = [];
    if (element.localName == 'span') {
      element.remove();
      return [element.text];
    }
    if (element.children.isEmpty) {
      return [];
    }
    for (Element childElement in element.children) {
      final list = _traverseForReactions(childElement);
      reactions.addAll(list);
    }
    return reactions;
  }

  void removeEmptyTags() {
    _traverseAndRemoveEmptyAs(this);
    _traverseAndRemoveEmptyLIs(this);
    _traverseAndRemoveEmptyULs(this);
    _traverseAndRemoveUnnecessaryDIVs(this);
  }

  void _traverseAndRemoveEmptyDIVs(Element element) {
    if (element.children.isEmpty &&
        element.localName == 'div' &&
        element.text.isEmpty) {
      element.remove();
      return;
    }
    for (Element childElement in element.children) {
      _traverseAndRemoveEmptyDIVs(childElement);
    }
  }

  void _traverseAndRemoveUnnecessaryDIVs(Element element) {
    if (element.children.isEmpty &&
        element.localName == 'div' &&
        (element.text == 'Liked a message' ||
            element.text == 'You sent an attachment.' ||
            _reactionMessagePattern.hasMatch(element.text))) {
      element.remove();
      return;
    }
    for (Element childElement in element.children) {
      _traverseAndRemoveUnnecessaryDIVs(childElement);
      _traverseAndRemoveEmptyDIVs(childElement);
    }
  }

  void _traverseAndRemoveEmptyAs(Element element) {
    if (element.children.isEmpty && element.localName == 'a') {
      element.remove();
      return;
    }
    for (Element childElement in element.children) {
      _traverseAndRemoveEmptyAs(childElement);
    }
  }

  void _traverseAndRemoveEmptyLIs(Element element) {
    if (element.children.isEmpty && element.localName == 'li') {
      element.remove();
      return;
    }
    for (Element childElement in element.children) {
      _traverseAndRemoveEmptyLIs(childElement);
    }
  }

  void _traverseAndRemoveEmptyULs(Element element) {
    if (element.localName == 'ul') {
      element.remove();
      return;
    }
    for (Element childElement in element.children) {
      _traverseAndRemoveEmptyULs(childElement);
    }
  }
}
