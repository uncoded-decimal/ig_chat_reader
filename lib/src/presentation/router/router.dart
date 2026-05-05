import 'package:flutter/material.dart';
import 'package:ig_chat_reader/src/presentation/modules/chat/views/chat_view.dart';
import 'package:ig_chat_reader/src/presentation/modules/chat/views/photos_view.dart';
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
            (_) => ChatView(
              username: (settings.arguments as Map?)!['username'],
              files: (settings.arguments as Map?)!['files'],
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
