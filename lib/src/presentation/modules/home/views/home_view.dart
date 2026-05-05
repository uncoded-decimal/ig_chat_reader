import 'package:flutter/material.dart';
import 'package:ig_chat_reader/src/presentation/components/base_view.dart';
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
      child: Scaffold(appBar: _appBar, body: _body),
    );
  }

  AppBar get _appBar => AppBar(
    toolbarHeight: 120,
    automaticallyImplyLeading: false,
    centerTitle: false,
    title: RichText(
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
      padding: const EdgeInsets.all(20),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade100,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        'Upload your Instagram downloaded archive here',
        style: TextStyle(fontSize: 36, fontWeight: FontWeight.w100),
        textAlign: TextAlign.center,
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
