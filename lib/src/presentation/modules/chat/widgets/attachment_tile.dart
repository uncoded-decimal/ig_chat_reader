import 'package:flutter/material.dart';
import 'package:ig_chat_reader/src/presentation/components/responsive_graphic_view.dart';
import 'package:ig_chat_reader/src/presentation/modules/home/models/file_model.dart';

class AttachmentTile extends StatefulWidget {
  final String link;
  final FileModel? file;
  final VoidCallback onClick;
  final bool drawRadius;
  const AttachmentTile({
    super.key,
    required this.link,
    required this.onClick,
    this.file,
    this.drawRadius = true,
  });

  @override
  State<AttachmentTile> createState() => _AttachmentTileState();
}

class _AttachmentTileState extends State<AttachmentTile> {
  @override
  void initState() {
    super.initState();
    if (mounted && widget.file != null) {
      // creating and disposing blob urls within the
      // widget allows for having an alive URL only as long
      // as it is actually needed.
      widget.file!.createBlobUrls().then((_) {
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  @override
  void dispose() {
    widget.file?.revokeFileUrl();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onClick,
      child:
          widget.file?.blobUrl != null || widget.link.isNotEmpty
              ? _attachmentPreview
              : const SizedBox.shrink(),
    );
  }

  Widget get _attachmentPreview =>
      widget.file != null || widget.link.contains('giphy')
          ? __recognisedItem
          : __unrecognisedLink;

  Widget get __recognisedItem =>
      widget.link.contains('giphy')
          ? ___gifTile
          : switch (widget.file!.type) {
            FileType.audio => ___audioTile,
            FileType.photo => ___imageTile,
            FileType.video => ___videoTile,
            (_) => Container(
              decoration: BoxDecoration(
                color: Colors.white70,
                border: Border.all(color: Colors.black26),
              ),
              child: Icon(Icons.error_outline),
            ),
          };

  Widget get ___gifTile => Container(
    height: 100,
    clipBehavior: Clip.hardEdge,
    decoration: BoxDecoration(
      color: Colors.white70,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.black26),
    ),
    foregroundDecoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.black26),
    ),
    child: ResponsiveGraphicView.image(path: widget.link, fit: BoxFit.cover),
  );

  Widget get ___imageTile => Container(
    height: 250,
    clipBehavior: Clip.hardEdge,
    decoration: BoxDecoration(
      color: Colors.white70,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.black26),
    ),
    foregroundDecoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.black26),
    ),
    child: ResponsiveGraphicView.image(
      path: widget.file!.blobUrl!,
      fit: BoxFit.contain,
    ),
  );

  Widget get ___audioTile => Container(
    width: 150,
    clipBehavior: Clip.hardEdge,
    decoration: BoxDecoration(
      color: Colors.white70,
      borderRadius: widget.drawRadius ? BorderRadius.circular(12) : null,
      border: Border.all(color: Colors.black26),
    ),
    foregroundDecoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.black26),
    ),
    child: Icon(Icons.audio_file),
  );

  Widget get ___videoTile => Container(
    width: 150,
    clipBehavior: Clip.hardEdge,
    decoration: BoxDecoration(
      color: Colors.white70,
      borderRadius: widget.drawRadius ? BorderRadius.circular(12) : null,
      border: Border.all(color: Colors.black26),
    ),
    foregroundDecoration: BoxDecoration(
      borderRadius: widget.drawRadius ? BorderRadius.circular(12) : null,
      border: Border.all(color: Colors.black26),
    ),
    child: Stack(
      children: [
        if (widget.file!.thumbnailUrl == null)
          ResponsiveGraphicView.dummy(
            width: double.maxFinite,
            height: double.maxFinite,
          ),
        if (widget.file!.thumbnailUrl != null)
          ResponsiveGraphicView.image(
            path: widget.file!.thumbnailUrl!,
            width: double.maxFinite,
            height: double.maxFinite,
            fit: BoxFit.cover,
          ),
        Align(
          alignment: Alignment.center,
          child: Icon(Icons.play_arrow, color: Colors.white),
        ),
      ],
    ),
  );

  Widget get __unrecognisedLink => AspectRatio(
    aspectRatio: 3 / 4,
    child: Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: widget.drawRadius ? BorderRadius.circular(12) : null,
        border: Border.all(color: Colors.black26),
        color: Colors.amber.shade100,
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: widget.drawRadius ? BorderRadius.circular(12) : null,
        border: Border.all(color: Colors.black26),
      ),
      padding: const EdgeInsets.all(16),
      child: Text(
        ___getAttachmentTypeFromLink(widget.link),
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        textAlign: TextAlign.center,
      ),
    ),
  );

  String ___getAttachmentTypeFromLink(String link) {
    if (link.contains('reel')) {
      return 'Reel';
    } else if (link.contains('/p/')) {
      return 'Post';
    } else if (link.contains('stories')) {
      return 'Story';
    } else if (link.contains('giphy')) {
      return 'GIF';
    } else if (link.contains('/_u/')) {
      return 'Instagram User';
    } else if (RegExp(r'https://www.instagram.com/.+').hasMatch(link)) {
      return 'Instagram Profile';
    } else {
      return link;
    }
  }
}
