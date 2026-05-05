import 'package:flutter/material.dart';
import 'package:ig_chat_reader/src/presentation/modules/home/models/file_model.dart';

class AllPhotosView extends StatelessWidget {
  final List<FileModel> photos;
  final void Function(String url) onClick;
  const AllPhotosView({super.key, required this.photos, required this.onClick});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: _appBar, body: _body);
  }

  AppBar get _appBar => AppBar(title: Text('All Photos'));

  Widget get _body => GridView.builder(
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
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
