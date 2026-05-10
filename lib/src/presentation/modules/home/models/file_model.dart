import 'dart:convert';
import 'dart:js_interop';

import 'package:archive/archive_io.dart';
import 'package:flutter/foundation.dart';
import 'package:ig_chat_reader/src/presentation/helpers/services/thumbnail_generation_service.dart';
import 'package:web/web.dart';
import 'package:worker_manager/worker_manager.dart';

class FileModel {
  final FileType type;
  final String fileId;
  final Uint8List? fileData;

  /// this can be used as an extra URL holder for when the message
  /// holds a Video, or a file type where thumbnails will be generated
  /// at a later time.
  String? thumbnailUrl;

  /// blobs urls are created at the time of need
  String? blobUrl;

  FileModel({required this.type, required this.fileId, required this.fileData});

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
        final processedFileData = processedFile.readBytes();
        final processedFileId = processedFile.name.substring(
          file.name.lastIndexOf('/') + 1,
        );
        return FileModel(
          type: FileType.photo,
          fileId: processedFileId,
          fileData: processedFileData,
        );
      } else if (file.name.contains('audio')) {
        return FileModel(
          type: FileType.audio,
          fileId: fileId,
          fileData: fileData,
        );
      } else if (file.name.contains('videos')) {
        return FileModel(
          type: FileType.video,
          fileId: fileId,
          fileData: fileData,
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

  Future<void> createBlobUrls() async {
    debugPrint('Creating URL for $type $fileId');
    if (type == FileType.audio) {
      final jsData = [fileData!.toJS].toJS;
      final blob = Blob(jsData, BlobPropertyBag(type: 'audio/mp4'));
      blobUrl = URL.createObjectURL(blob);
    } else if (type == FileType.video) {
      final jsData = [fileData!.toJS].toJS;
      final blob = Blob(jsData, BlobPropertyBag(type: 'video/mp4'));
      blobUrl = URL.createObjectURL(blob);
      final thumbnailData = await workerManager.execute(
        () async => await ThumbnailService.fromBlobUrl(blobUrl!),
      );
      final dataList = base64Decode(thumbnailData.split(',').last);
      final thumbnailBlob = Blob(
        [dataList.toJS].toJS,
        BlobPropertyBag(type: 'video/mp4'),
      );
      thumbnailUrl = URL.createObjectURL(thumbnailBlob);
    } else if (type == FileType.photo) {
      final jsData = [fileData!.toJS].toJS;
      final blob = Blob(jsData, BlobPropertyBag(type: 'image/jpeg'));
      blobUrl = URL.createObjectURL(blob);
    }
  }

  void revokeFileUrl() {
    if (blobUrl != null) {
      debugPrint('Dropping URL for $type $fileId');
      URL.revokeObjectURL(blobUrl!);
    }
    if (thumbnailUrl != null) {
      debugPrint('Dropping thumbnailUrl for $type $fileId');
      URL.revokeObjectURL(thumbnailUrl!);
    }
  }

  FileModel clone() =>
      FileModel(
          type: type,
          fileId: fileId,
          fileData: Uint8List.fromList(fileData ?? []),
        )
        ..blobUrl = blobUrl
        ..thumbnailUrl = thumbnailUrl;
}

enum FileType { audio, video, photo, html, unknown }
