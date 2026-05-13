import 'package:flutter/material.dart';
import 'package:ig_chat_reader/src/presentation/components/base_view.dart';
import 'package:ig_chat_reader/src/presentation/components/responsive_graphic_view.dart';
import 'package:ig_chat_reader/src/presentation/modules/home/controllers/home_controller.dart';
import 'package:ig_chat_reader/src/presentation/modules/home/models/chat_model.dart';
import 'package:ig_chat_reader/src/presentation/modules/home/widgets/empty_view.dart';
import 'package:ig_chat_reader/src/presentation/modules/home/widgets/user_tile.dart';
import 'package:package_info_plus/package_info_plus.dart';

class HomeView extends BaseResponsiveStatelessWidget {
  final HomeController _controller;
  HomeView({super.key}) : _controller = HomeController();

  @override
  void initState(BuildContext context) {
    super.initState(context);
    _controller.init(context);
  }

  @override
  Widget defaultWidget(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: _appBar,
        body: _body,
        bottomNavigationBar: _bottomNavBar,
      ),
    );
  }

  Widget get _bottomNavBar => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    color: _controller.currentTheme.bottomNavigationBarTheme.backgroundColor,
    child: Row(
      children: [
        TextButton(
          onPressed: () {},
          child: FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data == null) {
                return const SizedBox.shrink();
              }
              return Text(
                'Version ${snapshot.data!.version}',
                style: TextStyle(fontSize: 12),
              );
            },
          ),
        ),
        TextButton(
          onPressed: _controller.requestHelp,
          child: Text('Need Help?', style: TextStyle(fontSize: 12)),
        ),
      ],
    ),
  );

  AppBar get _appBar => AppBar(
    toolbarHeight: 100,
    automaticallyImplyLeading: false,
    title: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 8,
      children: [
        ResponsiveGraphicView.image(
          path: 'assets/images/ig_chat_reader.png',
          fit: BoxFit.contain,
          height: 60,
        ),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Instagram',
                style: TextStyle(
                  fontSize: switch (currentLayoutMode) {
                    LayoutMode.mobile => 36,
                    (_) => 48,
                  },
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Quicksand',
                ),
              ),
              TextSpan(
                text: '\nChat Reader',
                style: TextStyle(
                  fontSize: switch (currentLayoutMode) {
                    LayoutMode.mobile => 18,
                    (_) => 24,
                  },
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
    actions: [
      StreamBuilder<ChatModel?>(
        stream: _controller.chatSubject.stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data == null) {
            return const SizedBox.shrink();
          }
          return PopupMenuButton(
            itemBuilder:
                (_) => [
                  PopupMenuItem(
                    onTap: _controller.clearChatData,
                    child: Text('Clear'),
                  ),
                ],
          );
        },
      ),
    ],
  );

  Widget get _body => StreamBuilder(
    stream: _controller.chatSubject.stream,
    builder: (context, snapshot) {
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child:
            !snapshot.hasData
                ? _emptyView
                : Column(
                  children: [
                    __headers,
                    const Divider(height: 4),
                    Expanded(
                      child: ListView.builder(
                        itemBuilder: (context, index) {
                          final username = snapshot.data!.usernames.elementAt(
                            index,
                          );
                          return UserTile(
                            username: username,
                            imageCount: _controller.getImagesCountForUsername(
                              username,
                            ),
                            audioCount: _controller.getAudioCountForUsername(
                              username,
                            ),
                            videoCount: _controller.getVideosCountForUsername(
                              username,
                            ),
                            onTap:
                                () => _controller.onUsernameClicked(
                                  context,
                                  username,
                                ),
                            currentLayoutMode: currentLayoutMode!,
                          );
                        },
                        itemCount: snapshot.data?.usernames.length ?? 0,
                        shrinkWrap: true,
                      ),
                    ),
                  ],
                ),
      );
    },
  );

  Widget get _emptyView => InkWell(
    onTap: _controller.pickFile,
    child:
        currentLayoutMode != null
            ? EmptyView(currentLayoutMode: currentLayoutMode!)
            : const SizedBox.shrink(),
  );

  Widget get __headers => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
    child: Row(
      spacing: switch (currentLayoutMode) {
        LayoutMode.mobile => 4,
        LayoutMode.tablet => 8,
        (_) => 16,
      },
      children: [
        Expanded(
          flex: 3,
          child: Text(
            'usernames'.toUpperCase(),
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Text(
            'images'.toUpperCase(),
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: Text(
            'audios'.toUpperCase(),
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: Text(
            'videos'.toUpperCase(),
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    ),
  );
}
