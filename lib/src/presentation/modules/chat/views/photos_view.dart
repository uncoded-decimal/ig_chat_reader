import 'package:flutter/material.dart';
import 'package:ig_chat_reader/src/presentation/components/base_view.dart';
import 'package:ig_chat_reader/src/presentation/modules/home/models/file_model.dart';

class AllPhotosView extends BaseResponsiveStatelessWidget {
  final List<FileModel> photos;
  final void Function(String url) onClick;
  AllPhotosView({super.key, required this.photos, required this.onClick});

  @override
  Widget defaultWidget(BuildContext context) {
    return Scaffold(appBar: _appBar, body: _body);
  }

  AppBar get _appBar => AppBar(title: Text('All Photos'));

  Widget get _body => GridView.builder(
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: switch (currentLayoutMode) {
        LayoutMode.mobile => 2,
        LayoutMode.tablet => 4,
        LayoutMode.desktop => 6,
        (_) => 4,
      },
    ),
    itemCount: photos.length,
    itemBuilder:
        (context, index) => InkWell(
          onTap: () => onClick(photos.elementAt(index).blobUrl!),
          child: Image.network(
            photos.elementAt(index).blobUrl!,
            width: double.maxFinite,
            fit: BoxFit.cover,
          ),
        ),
  );
}
