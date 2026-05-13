import 'package:flutter/material.dart';
import 'package:ig_chat_reader/src/presentation/components/base_view.dart';
import 'package:ig_chat_reader/src/presentation/components/responsive_graphic_view.dart';
import 'package:ig_chat_reader/src/presentation/modules/home/controllers/home_controller.dart';
import 'package:ig_chat_reader/src/presentation/modules/home/models/chat_model.dart';
import 'package:ig_chat_reader/src/presentation/modules/home/widgets/empty_view.dart';
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
      if (!snapshot.hasData) {
        return _emptyView;
      }
      return SingleChildScrollView(
        child: Table(
          columnWidths: {
            0: FlexColumnWidth(switch (currentLayoutMode) {
              LayoutMode.mobile => 2,
              LayoutMode.desktop => 4,
              (_) => 3,
            }),
            1: FlexColumnWidth(1),
            2: FlexColumnWidth(1),
            3: FlexColumnWidth(1),
          },
          border: TableBorder(
            horizontalInside: BorderSide(color: Colors.black26),
          ),
          children: [
            _tableTitle,
            ...snapshot.data!.usernames.map(
              (username) => _getUserNameRow(context, username),
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

  TableRow get _tableTitle => TableRow(
    decoration: BoxDecoration(color: Colors.amber.shade100),
    children:
        ['username', 'images', 'audio', 'videos']
            .map(
              (item) => Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                child: Text(
                  item.toUpperCase(),
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ),
            )
            .toList(),
  );

  TableRow _getUserNameRow(BuildContext context, String username) => TableRow(
    children:
        [
              username,
              _controller.getImagesCountForUsername(username),
              _controller.getAudioCountForUsername(username),
              _controller.getVideosCountForUsername(username),
            ]
            .map(
              (item) => InkWell(
                onTap: () => _controller.onUsernameClicked(context, username),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  child: Text(
                    item.toString(),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                  ),
                ),
              ),
            )
            .toList(),
  );
}
