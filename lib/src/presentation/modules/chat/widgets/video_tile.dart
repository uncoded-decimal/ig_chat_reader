import 'dart:convert';
import 'dart:js_interop';

import 'package:flutter/material.dart';
// import 'package:web/web.dart';

@JS('generateThumbnail')
external JSPromise<JSString> _generateThumbnail(String blobUrl);

class ThumbnailService {
  static Future<String> fromBlobUrl(String blobUrl) async {
    final result = await _generateThumbnail(blobUrl).toDart;
    return result.toDart;
  }
}

class VideoTile extends StatelessWidget {
  final String videoUrl;
  const VideoTile({super.key, required this.videoUrl});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FutureBuilder<String>(
          future: ThumbnailService.fromBlobUrl(videoUrl),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Image.memory(
                base64Decode(snapshot.data!.split(',').last),
                fit: BoxFit.cover,
                width: double.maxFinite,
                height: double.maxFinite,
              );
            }
            return Center(child: const CircularProgressIndicator());
          },
        ),
        Align(
          alignment: Alignment.center,
          child: Icon(Icons.play_arrow, color: Colors.white),
        ),
      ],
    );
  }
}
