import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

enum LayoutMode {
  mobile(fontSizeFactor: 1.0, imageScaleFactor: 1.0, vectorScaleFactor: 1.0),
  tablet(fontSizeFactor: 1.3, imageScaleFactor: 1.3, vectorScaleFactor: 1.3),
  desktop(fontSizeFactor: 1.5, imageScaleFactor: 1.5, vectorScaleFactor: 1.5);

  final double fontSizeFactor;
  final double imageScaleFactor;
  final double vectorScaleFactor;

  const LayoutMode({
    required this.fontSizeFactor,
    required this.imageScaleFactor,
    required this.vectorScaleFactor,
  });
}

/// This widget is to be provided at the project root ONLY
/// ONCE to ensure smooth updation of [MediaQueryData] throughout
/// the app.
///
/// This ensures the Text scale factor is update app-wide. Even the
/// widgets that don't depend on [ThemeData] to render their text will
/// be updated.
class MediaQueryUpdateWrapper extends StatelessWidget {
  final Widget child;
  const MediaQueryUpdateWrapper({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double textScaleFactor = 1.0;
        if (constraints.maxWidth <= 450) {
          textScaleFactor = LayoutMode.mobile.fontSizeFactor;
        } else if (constraints.maxWidth <= 850) {
          textScaleFactor = LayoutMode.tablet.fontSizeFactor;
        } else {
          textScaleFactor = LayoutMode.desktop.fontSizeFactor;
        }
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScaleFactor)),
          child: child,
        );
      },
    );
  }
}

/// Extension on [StatelessWidget].
///
/// May override the [BaseResponsiveStatelessWidget.build] function to provide
/// one layout for all screens. This would be the generally used stateless
/// widget layout.
/// Alternatively, override the [BaseResponsiveStatelessWidget.defaultWidget] to
/// provide a default layout for all cases and then override the [mobileLayout],
/// [tabletLayout] or the [desktopLayout] to provide screen specific layouts.
/// This will lead to the screen specific layouts being served when the screen
/// requirements are met, and [defaultWidget] will be used for the cases
/// when the layout is not defined.
///
/// Current layout mode is exposed via [BaseResponsiveStatelessWidget.currentLayoutMode].
/// No value is available until the widgets have been layed out. Wait for the
/// [BaseResponsiveStatelessWidget.onLayoutChange] method to be called to ensure the
/// framework has started drawing.
///
/// Currently handles updates for [TextStyle.fontSizeFactor] and Graphic assets
/// scaling through [GraphicScaleFactor.imageScaleFactor] and [GraphicScaleFactor.vectorScaleFactor].
/// Also supports providing device pixel density through [GraphicScaleFactor.devicePixelRatio].
///
/// #### Usage example:
///
/// ```dart
///  Icon(
///       Icons.abc,
///       size: 28 * Theme.of(context)
///             .extension<GraphicScaleFactor>()!
///             .vectorScaleFactor,
///      )
/// ```
abstract class BaseResponsiveStatelessWidget extends StatelessWidget {
  final BehaviorSubject<LayoutMode> _layoutMode = BehaviorSubject();
  final BehaviorSubject<LayoutMode> _lastLayoutMode = BehaviorSubject();
  final BehaviorSubject<GraphicScaleFactor> _lastScaleFactor =
      BehaviorSubject();

  BaseResponsiveStatelessWidget({super.key});

  LayoutMode? get currentLayoutMode => _layoutMode.valueOrNull;

  void initState(BuildContext context) {}

  @mustCallSuper
  void onLayoutChange(BuildContext context) {
    final updateScaleFactor =
        _updateTheme(context).extension<GraphicScaleFactor>();
    final wasLayoutUpdated =
        _lastLayoutMode.valueOrNull != currentLayoutMode ||
        _lastScaleFactor.valueOrNull?.devicePixelRatio !=
            updateScaleFactor?.devicePixelRatio;
    if (!wasLayoutUpdated) {
      return;
    }
    _lastLayoutMode.sink.add(currentLayoutMode!);
    StringBuffer layoutChangeData = StringBuffer();
    layoutChangeData
      ..writeln("===========================")
      ..writeln("||")
      ..writeln("|| Layout updated to ${currentLayoutMode!.name}")
      ..writeln("|| Layout Params updated:")
      ..writeln("|| - TextScaleFactor: ${currentLayoutMode!.fontSizeFactor}")
      ..writeln("|| - ImageScaleFactor: ${updateScaleFactor!.imageScaleFactor}")
      ..writeln(
        "|| - VectorScaleFactor: ${updateScaleFactor.vectorScaleFactor}",
      )
      ..writeln("|| - ScreenDensity: ${updateScaleFactor.screenDensity.name}")
      ..writeln("||")
      ..writeln("===========================");
    // log(layoutChangeData.toString());
  }

  @override
  Widget build(BuildContext context) {
    initState(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth <= 450) {
          _layoutMode.sink.add(LayoutMode.mobile);
          onLayoutChange(context);
          return Theme(
            data: _updateTheme(context),
            child: mobileLayout(context),
          );
        } else if (constraints.maxWidth <= 850) {
          _layoutMode.sink.add(LayoutMode.tablet);
          onLayoutChange(context);
          return Theme(
            data: _updateTheme(context),
            child: tabletLayout(context),
          );
        }
        _layoutMode.sink.add(LayoutMode.desktop);
        onLayoutChange(context);
        return Theme(
          data: _updateTheme(context),
          child: desktopLayout(context),
        );
      },
    );
  }

  ThemeData _updateTheme(BuildContext context) {
    final pixelDensity = MediaQuery.devicePixelRatioOf(context);
    return Theme.of(context).copyWith(
      extensions: [
        GraphicScaleFactor(
          imageScaleFactor: currentLayoutMode!.imageScaleFactor,
          vectorScaleFactor: currentLayoutMode!.vectorScaleFactor,
          devicePixelRatio: pixelDensity,
          screenDensity: ScreenDensity.fromPixelDensity(pixelDensity),
        ),
      ],
    );
  }

  Widget mobileLayout(BuildContext context) => defaultWidget(context);
  Widget tabletLayout(BuildContext context) => defaultWidget(context);
  Widget desktopLayout(BuildContext context) => defaultWidget(context);

  /// Layout to be used for screens that don't have a custom definition.
  ///
  /// Defaults to returning a [SizedBox.shrink].
  Widget defaultWidget(BuildContext context) => const SizedBox.shrink();
}

class GraphicScaleFactor extends ThemeExtension<GraphicScaleFactor> {
  final double imageScaleFactor;
  final double vectorScaleFactor;

  /// The pixel density, while assumed to be a constant across a device,
  /// may update itself based on the attached devices. This can especially
  /// be problematic for Foldable or Attached Screens.
  ///
  /// Offers granular control but for development, utilise [screenDensity]
  /// enum instead.
  final double devicePixelRatio;

  /// Accounts for the standard screen densities.
  ///
  /// For granular control use [devicePixelRatio].
  final ScreenDensity screenDensity;

  GraphicScaleFactor({
    required this.imageScaleFactor,
    required this.vectorScaleFactor,
    required this.devicePixelRatio,
    required this.screenDensity,
  });

  @override
  ThemeExtension<GraphicScaleFactor> copyWith({
    double? imageScaleFactor,
    double? vectorScaleFactor,
    double? devicePixelRatio,
    ScreenDensity? screenDensity,
  }) => GraphicScaleFactor(
    imageScaleFactor: imageScaleFactor ?? this.imageScaleFactor,
    vectorScaleFactor: vectorScaleFactor ?? this.vectorScaleFactor,
    devicePixelRatio: devicePixelRatio ?? this.devicePixelRatio,
    screenDensity: screenDensity ?? this.screenDensity,
  );

  @override
  ThemeExtension<GraphicScaleFactor> lerp(
    covariant ThemeExtension<GraphicScaleFactor>? other,
    double t,
  ) {
    if (other is! GraphicScaleFactor) {
      return this;
    }
    return GraphicScaleFactor(
      imageScaleFactor:
          lerpDouble(imageScaleFactor, other.imageScaleFactor, t) ??
          imageScaleFactor,
      vectorScaleFactor:
          lerpDouble(vectorScaleFactor, other.vectorScaleFactor, t) ??
          vectorScaleFactor,
      devicePixelRatio:
          lerpDouble(devicePixelRatio, other.devicePixelRatio, t) ??
          devicePixelRatio,
      screenDensity: ScreenDensity.fromPixelDensity(
        lerpDouble(devicePixelRatio, other.devicePixelRatio, t) ??
            devicePixelRatio,
      ),
    );
  }
}

enum ScreenDensity {
  mdpi,
  hdpi,
  xhdpi,
  xxhdpi,
  xxxhdpi,
  tvdpi;

  static ScreenDensity fromPixelDensity(double pixelDensity) {
    if (pixelDensity <= 1) {
      return ScreenDensity.mdpi;
    } else if (pixelDensity <= 1.5) {
      return ScreenDensity.hdpi;
    } else if (pixelDensity <= 2) {
      return ScreenDensity.xhdpi;
    } else if (pixelDensity <= 3) {
      return ScreenDensity.xxhdpi;
    } else if (pixelDensity <= 4) {
      return ScreenDensity.xxxhdpi;
    }
    return ScreenDensity.tvdpi;
  }
}
