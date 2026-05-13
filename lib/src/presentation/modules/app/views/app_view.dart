import 'package:flutter/material.dart';
import 'package:ig_chat_reader/src/presentation/components/base_view.dart';
import 'package:ig_chat_reader/src/presentation/components/loading_screen.dart';
import 'package:ig_chat_reader/src/presentation/core/app_theme.dart';
import 'package:ig_chat_reader/src/presentation/modules/app/controllers/app_controller.dart';
import 'package:ig_chat_reader/src/presentation/router/router.dart';

class MyApp extends StatelessWidget {
  final AppController _controller;
  MyApp({super.key}) : _controller = AppController.instance..initialise();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Instagram Chat Reader',
      theme: AppTheme.appTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: AppRouter.initialRoute,
      onGenerateRoute: AppRouter.generateRoutes,
      builder: (context, child) {
        return MediaQueryUpdateWrapper(
          child: StreamBuilder<bool>(
            stream: _controller.loading.stream,
            builder: (context, snapshot) {
              return Stack(
                children: [
                  child ?? const SizedBox.shrink(),
                  if (!snapshot.hasData || snapshot.data!)
                    const LoadingScreen(),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
