import 'package:flutter/material.dart';
import 'package:ig_chat_reader/src/presentation/components/base_view.dart';
import 'package:ig_chat_reader/src/presentation/modules/chat/widgets/attachment_tile.dart';
import 'package:ig_chat_reader/src/presentation/modules/home/models/file_model.dart';

class AllAudiosView extends BaseResponsiveStatelessWidget {
  final List<FileModel> audios;
  final List<Map<String, String>> audioUsernames;
  final void Function(String url) onClick;
  AllAudiosView({
    super.key,
    required this.audios,
    required this.audioUsernames,
    required this.onClick,
  });

  @override
  Widget defaultWidget(BuildContext context) {
    return Scaffold(appBar: _appBar, body: _body);
  }

  AppBar get _appBar => AppBar(title: Text('All Audios'));

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
      childAspectRatio: 1 / 1.2,
    ),
    itemCount: audios.length,
    itemBuilder: (context, index) {
      final file = audios.elementAt(index);
      final username =
          audioUsernames
              .firstWhere((map) => map['audio'] == file.fileId)['username']
              .toString();
      return Stack(
        children: [
          SizedBox.expand(
            child: AttachmentTile(
              link: file.blobUrl ?? '',
              onClick: () => onClick(file.blobUrl ?? ''),
              file: file,
              drawRadius: false,
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
      );
    },
  );
}
