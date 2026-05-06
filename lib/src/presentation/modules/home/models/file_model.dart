import 'dart:js_interop';

import 'package:archive/archive_io.dart';
import 'package:flutter/foundation.dart';
import 'package:web/web.dart';

class FileModel {
  final FileType type;
  final String fileId;
  final Uint8List? fileData;
  final String? blobUrl;

  /// this can be used as an extra URL holder for when the message
  /// holds a Video, or a file type where thumbnails will be generated
  /// at a later time.
  String? thumbnailUrl;

  FileModel({
    required this.type,
    required this.fileId,
    this.fileData,
    this.blobUrl,
  });

  static FileModel fromArchiveFile(ArchiveFile file) {
    try {
      final fileId = file.name.substring(file.name.lastIndexOf('/') + 1);
      final fileData = file.readBytes();
      if (file.name.contains('.html')) {
        return FileModel(
          type: FileType.html,
          fileId: fileId,
          fileData: fileData,
        );
      } else if (file.name.contains('photos')) {
        final processedFile =
            file.name.contains('.') ? file : _cloneWithExtension(file, 'jpg');
        final jsData = [processedFile.readBytes()!.toJS].toJS;
        final blob = Blob(jsData, BlobPropertyBag(type: 'image/jpeg'));
        final processedFileId = processedFile.name.substring(
          file.name.lastIndexOf('/') + 1,
        );
        final url = URL.createObjectURL(blob);
        return FileModel(
          type: FileType.photo,
          fileId: processedFileId,
          blobUrl: url,
        );
      } else if (file.name.contains('audio')) {
        final jsData = [fileData!.toJS].toJS;
        final blob = Blob(jsData, BlobPropertyBag(type: 'audio/mp4'));
        return FileModel(
          type: FileType.audio,
          fileId: fileId,
          blobUrl: URL.createObjectURL(blob),
        );
      } else if (file.name.contains('videos')) {
        final jsData = [fileData!.toJS].toJS;
        final blob = Blob(jsData, BlobPropertyBag(type: 'video/mp4'));
        return FileModel(
          type: FileType.video,
          fileId: fileId,
          blobUrl: URL.createObjectURL(blob),
        );
      }
    } on RangeError catch (e) {
      debugPrint('Error processing file ${file.name} ::::\n$e');
    }
    return FileModel(type: FileType.unknown, fileId: 'N/A', fileData: null);
  }

  static ArchiveFile _cloneWithExtension(ArchiveFile file, String extension) {
    final bytes = file.readBytes()!;
    return ArchiveFile('${file.name}.$extension', bytes.length, bytes);
  }
}

enum FileType { audio, video, photo, html, unknown }
