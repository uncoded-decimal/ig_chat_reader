import 'package:flutter/material.dart';
import 'package:ig_chat_reader/src/presentation/components/responsive_graphic_view.dart';
import 'package:web/web.dart';

class BuyMeAChaiButton extends StatelessWidget {
  const BuyMeAChaiButton({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        window.open('https://buymeachai.ezee.li/uncoded_decimal', '_blank');
      },
      child: ResponsiveGraphicView.image(
        path: 'assets/images/buymeachai-button.png',
        height: 24,
      ),
    );
  }
}
