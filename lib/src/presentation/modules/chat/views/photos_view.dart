import 'package:flutter/material.dart';
import 'package:ig_chat_reader/src/presentation/components/base_view.dart';
import 'package:ig_chat_reader/src/presentation/components/responsive_graphic_view.dart';
import 'package:ig_chat_reader/src/presentation/modules/home/models/file_model.dart';

class AllPhotosView extends BaseResponsiveStatelessWidget {
  final List<FileModel> photos;
  final List<Map<String, String>> photoUsernames;
  final void Function(String url) onClick;
  AllPhotosView({
    super.key,
    required this.photos,
    required this.photoUsernames,
    required this.onClick,
  });

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
      childAspectRatio: 1 / 1.5,
    ),
    itemCount: photos.length,
    itemBuilder: (context, index) {
      final file = photos.elementAt(index);
      final username =
          photoUsernames
              .firstWhere((map) => map['photo'] == file.fileId)['username']
              .toString();
      return InkWell(
        onTap: () => onClick(file.blobUrl!),
        child: Stack(
          children: [
            SizedBox.expand(
              child: ResponsiveGraphicView.image(
                path: file.blobUrl!,
                fit: BoxFit.fill,
              ),
            ),
            Chip(
              label: Text(
                username,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                  fontFamily: 'Roboto',
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
