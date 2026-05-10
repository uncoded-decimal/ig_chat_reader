import 'package:flutter/material.dart';
import 'package:ig_chat_reader/src/presentation/modules/chat/views/chat_view.dart';
import 'package:ig_chat_reader/src/presentation/modules/chat/views/export_view.dart';
import 'package:ig_chat_reader/src/presentation/modules/chat/views/photos_view.dart';
import 'package:ig_chat_reader/src/presentation/modules/chat/views/videos_view.dart';
import 'package:ig_chat_reader/src/presentation/modules/home/views/home_view.dart';
import 'package:ig_chat_reader/src/presentation/router/routes.dart';

class AppRouter {
  static String get initialRoute => AppRoutes.home;
  static Route generateRoutes(RouteSettings settings) {
    if (settings.name == AppRoutes.home) {
      return MaterialPageRoute(builder: (_) => HomeView());
    } else if (settings.name == AppRoutes.chat) {
      return MaterialPageRoute(
        builder:
            (_) => ChatViewStatefulWrapper(
              username: (settings.arguments as Map?)!['username'],
              files: (settings.arguments as Map?)!['files'],
              shouldDropArchiveData: (settings.arguments as Map?)!['drop_data'],
            ),
      );
    } else if (settings.name == AppRoutes.allChatPhotos) {
      return MaterialPageRoute(
        builder:
            (_) => AllPhotosView(
              photos: (settings.arguments as Map?)!['photos'],
              onClick: (settings.arguments as Map?)!['onClick'],
            ),
      );
    } else if (settings.name == AppRoutes.allChatVideos) {
      return MaterialPageRoute(
        builder:
            (_) => AllVideosView(
              videos: (settings.arguments as Map?)!['videos'],
              onClick: (settings.arguments as Map?)!['onClick'],
            ),
      );
    } else if (settings.name == AppRoutes.exportChat) {
      return MaterialPageRoute(
        builder:
            (_) => ExportChatView(
              controller: (settings.arguments as Map?)!['export_controller'],
            ),
      );
    }

    return MaterialPageRoute(
      builder:
          (_) => Container(
            alignment: Alignment.center,
            child: Text('Unkown Route discovered'),
          ),
    );
  }
}
