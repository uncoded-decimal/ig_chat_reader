import 'package:flutter/material.dart';
import 'package:ig_chat_reader/src/presentation/components/base_view.dart';
import 'package:ig_chat_reader/src/presentation/components/responsive_graphic_view.dart';
import 'package:ig_chat_reader/src/presentation/modules/home/controllers/home_controller.dart';

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
        bottomNavigationBar: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.blueGrey.shade100,
          child: Row(
            children: [
              TextButton(
                onPressed: () {},
                child: Text('Version 1.0.1', style: TextStyle(fontSize: 12)),
              ),
              TextButton(
                onPressed: _controller.requestHelp,
                child: Text('Need Help?', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  AppBar get _appBar => AppBar(
    toolbarHeight: 120,
    automaticallyImplyLeading: false,
    centerTitle: false,
    title: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (currentLayoutMode != LayoutMode.mobile)
          ResponsiveGraphicView.vector(
            path: 'assets/vectors/ig_chat_reader.svg',
            fit: BoxFit.contain,
            height: 60,
          ),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Instagram',
                style: TextStyle(fontSize: 64, fontWeight: FontWeight.w400),
              ),
              TextSpan(
                text: '\nChat Reader',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget get _body => StreamBuilder(
    stream: _controller.userNames.stream,
    builder: (context, snapshot) {
      if (!snapshot.hasData || snapshot.data!.isEmpty) {
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
            ...snapshot.data!.map(
              (username) => _getUserNameRow(context, username),
            ),
          ],
        ),
      );
    },
  );

  Widget get _emptyView => InkWell(
    onTap: _controller.pickFile,
    child: Container(
      margin: const EdgeInsets.all(20),
      padding: switch (currentLayoutMode) {
        LayoutMode.mobile => const EdgeInsets.all(24),
        (_) => const EdgeInsets.all(64),
      },
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade100,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        spacing: 16,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Upload your Instagram archive here',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w100),
            textAlign: TextAlign.center,
          ),
          Text(
            'You can request an HTML export of your data using the Instagram app or website to view and browse your DM\'s using this tool',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w300,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            '- 100% Free Tool',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w300,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            '- No Data leaves your device',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w300,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            '- Privacy-focused',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w300,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Drag & Drop your archive here or Click anywhere to get started',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Colors.black38,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
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
