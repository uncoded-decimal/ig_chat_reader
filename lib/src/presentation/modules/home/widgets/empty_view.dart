import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:ig_chat_reader/src/presentation/components/base_view.dart';
import 'package:ig_chat_reader/src/presentation/helpers/resources/colors.dart';
import 'package:web/web.dart' show window;

class EmptyView extends StatefulWidget {
  final LayoutMode currentLayoutMode;
  const EmptyView({super.key, required this.currentLayoutMode});

  @override
  State<EmptyView> createState() => _EmptyViewState();
}

class _EmptyViewState extends State<EmptyView> {
  final _scroller = ScrollController();
  Alignment _imageAlignment = Alignment.topCenter;
  double _currentScrollFraction = 0;

  @override
  void initState() {
    super.initState();
    _scroller.addListener(_scrollListener);
  }

  void _scrollListener() => setState(() {
    _currentScrollFraction =
        (_scroller.offset / _scroller.position.maxScrollExtent).clamp(0, 0.7);
    debugPrint('cqc $_currentScrollFraction');
    _imageAlignment = Alignment(0, _currentScrollFraction * 0.4);
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/background.png'),
          fit: BoxFit.fitWidth,
          alignment: _imageAlignment,
          opacity: 0.05,
          colorFilter: ColorFilter.mode(AppColors.violet, BlendMode.modulate),
        ),
      ),
      child: SingleChildScrollView(
        controller: _scroller,
        padding: _padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 24,
          children: [_introduction, _howToUse(context), _features(context)],
        ),
      ),
    );
  }

  EdgeInsets get _padding => switch (widget.currentLayoutMode) {
    LayoutMode.mobile => EdgeInsets.all(24),
    LayoutMode.tablet => EdgeInsets.all(48),
    LayoutMode.desktop => EdgeInsets.all(96),
  };

  Widget get _introduction => _IntroductionTile(
    currentLayoutMode: widget.currentLayoutMode,
    currentScrollFraction: _currentScrollFraction,
  );

  Widget _features(BuildContext context) =>
      _FeatureCard(currentLayoutMode: widget.currentLayoutMode);

  Widget _howToUse(BuildContext context) =>
      _HowToUseCard(currentLayoutMode: widget.currentLayoutMode);

  @override
  void dispose() {
    _scroller.removeListener(_scrollListener);
    _scroller.dispose();
    super.dispose();
  }
}

class _IntroductionTile extends StatelessWidget {
  final LayoutMode currentLayoutMode;
  final double currentScrollFraction;
  const _IntroductionTile({
    required this.currentLayoutMode,
    required this.currentScrollFraction,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      duration: const Duration(milliseconds: 250),
      padding: _padding,
      child: Column(
        spacing: 12,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Upload your',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                ),
                TextSpan(
                  text: ' Instagram Archive ',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: AppColors.purple,
                    fontFamily: 'Quicksand',
                  ),
                ),
                TextSpan(
                  text: 'to get started.',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          Text(
            'Drag & Drop your archive here or click anywhere.',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.orange,
              fontFamily: 'Roboto',
            ),
          ),
        ],
      ),
    );
  }

  EdgeInsets get _padding => switch (currentLayoutMode) {
    LayoutMode.mobile => EdgeInsets.symmetric(
      vertical: 164.0 * (1 - currentScrollFraction),
    ),
    LayoutMode.tablet => EdgeInsets.symmetric(
      vertical: 180.0 * (1 - currentScrollFraction),
    ),
    LayoutMode.desktop => EdgeInsets.symmetric(
      vertical: 148.0 * (1 - currentScrollFraction),
    ),
  };
}

class _HowToUseCard extends StatelessWidget {
  final LayoutMode currentLayoutMode;
  const _HowToUseCard({required this.currentLayoutMode});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: __cardPadding,
        child: Column(
          spacing: 8,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How to use?',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                color: AppColors.pink,
              ),
            ),
            __instructionsWidget,
            Text(
              '» Click the Messages checkbox',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                fontFamily: 'Quicksand',
              ),
            ),
            Text(
              '» Choose the HTML Export format',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                fontFamily: 'Quicksand',
              ),
            ),
            Text(
              '» Upload your archive here',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                fontFamily: 'Quicksand',
              ),
            ),
          ],
        ),
      ),
    );
  }

  EdgeInsets get __cardPadding => switch (currentLayoutMode) {
    LayoutMode.mobile => EdgeInsets.all(16),
    LayoutMode.tablet => EdgeInsets.all(24),
    LayoutMode.desktop => EdgeInsets.all(64),
  };

  Widget get __instructionsWidget => RichText(
    text: TextSpan(
      children: [
        TextSpan(
          text: '» You can find instructions to export your data ',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            fontFamily: 'Quicksand',
          ),
        ),
        TextSpan(
          text: 'here',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.violet,
            decoration: TextDecoration.underline,
            fontFamily: 'Quicksand',
          ),
          recognizer:
              TapGestureRecognizer()
                ..onTap =
                    () => window.open(
                      'https://help.instagram.com/181231772500920',
                      '_blank',
                    ),
        ),
        TextSpan(
          text: '.',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            fontFamily: 'Quicksand',
          ),
        ),
      ],
    ),
  );
}

class _FeatureCard extends StatelessWidget {
  final LayoutMode currentLayoutMode;
  const _FeatureCard({required this.currentLayoutMode});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: __cardPadding,
        child: Column(
          spacing: 8,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This tool is:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            getFeatureTile(
              '- Built for convenience',
              'Have you tried reading the reverse and inverted chats the export gives us?',
            ),
            getFeatureTile('- 100% Free', 'No cost, ever.'),
            getFeatureTile(
              '- Privacy Focused',
              'Un-archives your data locally and sets up all chat data on your device itself.',
            ),
            getFeatureTile(
              '- Readability Friendly',
              'Records your Chat progress and stores it locally so you can resume your Read progress the next time you visit the same chat.',
            ),
            getFeatureTile('- Feature Rich', '''
» Allows you to select the user you're browsing as.
» You can select messages and export them as an image directly onto your device.
      '''),
          ],
        ),
      ),
    );
  }

  EdgeInsets get __cardPadding => switch (currentLayoutMode) {
    LayoutMode.mobile => EdgeInsets.all(16),
    LayoutMode.tablet => EdgeInsets.all(24),
    LayoutMode.desktop => EdgeInsets.all(64),
  };

  Widget getFeatureTile(String title, String description) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.purple,
        ),
      ),
      Padding(
        padding: EdgeInsets.only(
          left: switch (currentLayoutMode) {
            LayoutMode.mobile => 12,
            LayoutMode.tablet => 16,
            LayoutMode.desktop => 24,
          },
        ),
        child: Text(
          description,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            fontFamily: 'Roboto',
          ),
        ),
      ),
    ],
  );
}
