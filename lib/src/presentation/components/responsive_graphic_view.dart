import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ig_chat_reader/src/presentation/components/base_view.dart';

class ResponsiveGraphicView extends StatelessWidget {
  final String path;
  final bool _isImage, _isVector;
  final double? height, width;
  final BoxFit? fit;

  const ResponsiveGraphicView.dummy({super.key, this.height, this.width})
    : path = '',
      _isImage = false,
      _isVector = false,
      fit = BoxFit.contain;

  const ResponsiveGraphicView.image({
    super.key,
    required this.path,
    this.height,
    this.width,
    this.fit,
  }) : _isImage = true,
       _isVector = false;

  const ResponsiveGraphicView.vector({
    super.key,
    required this.path,
    this.height,
    this.width,
    this.fit,
  }) : _isImage = false,
       _isVector = true;

  @override
  Widget build(BuildContext context) {
    final scaleFactor = Theme.of(context).extension<GraphicScaleFactor>();
    final isURLPath = path.contains('.com') || path.contains('http');
    if (_isImage) {
      return isURLPath
          ? Hero(
            tag: path,
            child: Image.network(
              path,
              height:
                  height == null
                      ? null
                      : (height! * (scaleFactor?.imageScaleFactor ?? 1.0)),
              width:
                  width == null
                      ? null
                      : (width! * (scaleFactor?.imageScaleFactor ?? 1.0)),
              fit: fit,
            ),
          )
          : Hero(
            tag: path,
            child: Image.asset(
              path,
              height:
                  height == null
                      ? null
                      : (height! * (scaleFactor?.imageScaleFactor ?? 1.0)),
              width:
                  width == null
                      ? null
                      : (width! * (scaleFactor?.imageScaleFactor ?? 1.0)),
              fit: fit,
            ),
          );
    } else if (_isVector) {
      return isURLPath
          ? SvgPicture.network(
            path,
            height:
                height == null
                    ? null
                    : (height! * (scaleFactor?.vectorScaleFactor ?? 1.0)),
            width:
                width == null
                    ? null
                    : (width! * (scaleFactor?.vectorScaleFactor ?? 1.0)),
          )
          : SvgPicture.asset(
            path,
            height:
                height == null
                    ? null
                    : (height! * (scaleFactor?.vectorScaleFactor ?? 1.0)),
            width:
                width == null
                    ? null
                    : (width! * (scaleFactor?.vectorScaleFactor ?? 1.0)),
          );
    } else {
      return Placeholder();
    }
  }
}
