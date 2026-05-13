import 'package:flutter/material.dart';
import 'package:ig_chat_reader/src/presentation/components/base_view.dart';
import 'package:ig_chat_reader/src/presentation/helpers/resources/colors.dart';

class UserTile extends StatefulWidget {
  final LayoutMode currentLayoutMode;
  final String username;
  final int imageCount, audioCount, videoCount;
  final VoidCallback onTap;
  const UserTile({
    super.key,
    required this.username,
    required this.imageCount,
    required this.audioCount,
    required this.videoCount,
    required this.onTap,
    required this.currentLayoutMode,
  });

  @override
  State<UserTile> createState() => _UserTileState();
}

class _UserTileState extends State<UserTile> {
  bool viewFullSize = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      onHover:
          (value) => setState(() {
            viewFullSize = value;
          }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(
          vertical: viewFullSize ? 12 : 8,
          horizontal: 20,
        ),
        child: Row(
          spacing: switch (widget.currentLayoutMode) {
            LayoutMode.mobile => 4,
            LayoutMode.tablet => 8,
            LayoutMode.desktop => 16,
          },
          children: [
            Expanded(flex: 3, child: _animatedText),
            Expanded(
              child: Text(
                widget.imageCount.toString(),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: Text(
                widget.audioCount.toString(),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: Text(
                widget.videoCount.toString(),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget get _animatedText => ShaderMask(
    shaderCallback: (bounds) {
      return LinearGradient(
        colors:
            viewFullSize
                ? [
                  AppColors.yellow,
                  AppColors.orange,
                  AppColors.pink,
                  AppColors.violet,
                  AppColors.purple,
                ]
                : [Colors.black, Colors.black, Colors.black],
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
      ).createShader(bounds);
    },
    child: Text(
      widget.username,
      style: TextStyle(
        fontSize: viewFullSize ? 16 : 12,
        fontWeight: viewFullSize ? FontWeight.w500 : FontWeight.w400,
        color: Colors.white,
      ),
    ),
  );
}
