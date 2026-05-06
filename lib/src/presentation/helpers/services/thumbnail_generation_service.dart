import 'dart:js_interop';

@JS('generateThumbnail')
external JSPromise<JSString> _generateThumbnail(String blobUrl);

class ThumbnailService {
  static Future<String> fromBlobUrl(String blobUrl) async {
    final result = await _generateThumbnail(blobUrl).toDart;
    return result.toDart;
  }
}
