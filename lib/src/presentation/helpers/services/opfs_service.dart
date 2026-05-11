import 'dart:js_interop';
import 'package:flutter/foundation.dart';
import 'package:web/web.dart';

class OPFSService {
  late final FileSystemDirectoryHandle _opfsBaseReference;

  Future<void> initialise() async {
    _opfsBaseReference = await (window.navigator.storage.getDirectory()).toDart;
  }

  Future<FileSystemDirectoryHandle> getFolderAtRootRef(String name) async {
    return await (_opfsBaseReference.getDirectoryHandle(
      name,
      FileSystemGetDirectoryOptions(create: true),
    )).toDart;
  }

  Future<void> createFileInFolder({
    required String folderName,
    required String subfolderName,
    required String fileName,
    required Uint8List fileData,
  }) async {
    final rootDirectoryRef = await getFolderAtRootRef(folderName);
    final subFolderRef =
        await (rootDirectoryRef
            .getDirectoryHandle(
              subfolderName,
              FileSystemGetDirectoryOptions(create: true),
            )
            .toDart);

    final fileRef =
        await (subFolderRef
            .getFileHandle(fileName, FileSystemGetFileOptions(create: true))
            .toDart);
    final writeStream =
        await fileRef
            .createWritable(
              FileSystemCreateWritableOptions(keepExistingData: false),
            )
            .toDart;
    await writeStream.write(fileData.toJS as JSAny).toDart;
    await writeStream.close().toDart;
    debugPrint('Written $folderName/$subfolderName/$fileName');
  }

  Future<Uint8List?> getFileInFolder({
    required String folderName,
    required String subfolderName,
    required String fileName,
  }) async {
    debugPrint('Fetching $folderName/$subfolderName/$fileName');
    try {
      final rootFolderRef = await getFolderAtRootRef(folderName);
      final subFolderRef =
          await (rootFolderRef
              .getDirectoryHandle(
                subfolderName,
                FileSystemGetDirectoryOptions(create: true),
              )
              .toDart);
      final fileRef = await (subFolderRef.getFileHandle(fileName).toDart);
      final fileData =
          (await (await fileRef.getFile().toDart).arrayBuffer().toDart).toDart;
      return fileData.asUint8List();
    } on Exception catch (e) {
      debugPrint('Unable to fetch file: $e');
    }
    return null;
  }

  Future<void> clearDB(List<String> folderNames) async {
    for (String folderName in folderNames) {
      await _opfsBaseReference
          .removeEntry(folderName, FileSystemRemoveOptions(recursive: true))
          .toDart;
      debugPrint('Removed $folderName/');
    }
  }
}
