import 'package:flutter/material.dart';
import 'package:ig_chat_reader/src/presentation/components/base_view.dart';
import 'package:ig_chat_reader/src/presentation/modules/home/models/file_model.dart';

class AllVideosView extends BaseResponsiveStatelessWidget {
  final List<FileModel> videos;
  final void Function(String url) onClick;
  AllVideosView({super.key, required this.videos, required this.onClick});

  @override
  Widget defaultWidget(BuildContext context) {
    return Scaffold(appBar: _appBar, body: _body);
  }

  AppBar get _appBar => AppBar(title: Text('All Videos'));

  Widget get _body => GridView.builder(
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: switch (currentLayoutMode) {
        LayoutMode.mobile => 2,
        LayoutMode.tablet => 4,
        LayoutMode.desktop => 6,
        (_) => 4,
      },
      crossAxisSpacing: 2,
      mainAxisSpacing: 2,
    ),
    itemCount: videos.length,
    itemBuilder:
        (context, index) => InkWell(
          onTap: () => onClick(videos.elementAt(index).blobUrl!),
          child: DecoratedBox(
            decoration: BoxDecoration(color: Colors.black12),
            child: Icon(Icons.play_arrow),
          ),
        ),
  );
}
