library tutorial_coach_mark;

import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/src/target/target_focus.dart';
import 'package:tutorial_coach_mark/src/util.dart';
import 'package:tutorial_coach_mark/src/widgets/tutorial_coach_mark_widget.dart';

export 'package:tutorial_coach_mark/src/target/target_content.dart';
export 'package:tutorial_coach_mark/src/target/target_focus.dart';
export 'package:tutorial_coach_mark/src/target/target_position.dart';
export 'package:tutorial_coach_mark/src/util.dart';

/// A controller class that manages tutorial coach marks in your Flutter application.
///
/// This class provides functionality to display and control interactive tutorials
/// that guide users through your app's features. It creates an overlay with
/// highlighted areas and explanatory content.
///
/// Example usage:
/// ```dart
/// TutorialCoachMark(
///   targets: targets, // List<TargetFocus>
///   colorShadow: Colors.red,
///   onSkip: () {
///     return true; // returning true closes the tutorial
///   },
/// )..show(context: context);
/// ```
///
/// Key features:
/// - Multiple target focusing
/// - Customizable animations and styling
/// - Skip button functionality
/// - Support for safe area
/// - Pulse animation effects
/// - Custom overlay filters
///
/// The tutorial can be controlled programmatically using methods like:
/// - [show] - Displays the tutorial
/// - [next] - Moves to next target
/// - [previous] - Returns to previous target
/// - [skip] - Skips the tutorial
/// - [finish] - Ends the tutorial
class TutorialCoachMark {
  final List<TargetFocus> targets;
  final FutureOr<void> Function(TargetFocus)? onClickTarget;
  final FutureOr<void> Function(TargetFocus, TapDownDetails)?
      onClickTargetWithTapPosition;
  final FutureOr<void> Function(TargetFocus)? onClickOverlay;
  final Function()? onFinish;
  final double paddingFocus;

  // if onSkip return false, the overlay will not be dismissed and call `next`
  final bool Function()? onSkip;
  final AlignmentGeometry alignSkip;
  final String textSkip;
  final TextStyle textStyleSkip;
  final bool hideSkip;
  final bool useSafeArea;
  final Color colorShadow;
  final double opacityShadow;
  final GlobalKey<TutorialCoachMarkWidgetState> _widgetKey = GlobalKey();
  final Duration focusAnimationDuration;
  final Duration unFocusAnimationDuration;
  final Duration pulseAnimationDuration;
  final bool pulseEnable;
  final Widget? skipWidget;
  final bool showSkipInLastTarget;
  final ImageFilter? imageFilter;
  final String? backgroundSemanticLabel;
  final int initialFocus;

  OverlayEntry? _overlayEntry;

  TutorialCoachMark({
    required this.targets,
    this.colorShadow = Colors.black,
    this.onClickTarget,
    this.onClickTargetWithTapPosition,
    this.onClickOverlay,
    this.onFinish,
    this.paddingFocus = 10,
    this.onSkip,
    this.alignSkip = Alignment.bottomRight,
    this.textSkip = "SKIP",
    this.textStyleSkip = const TextStyle(color: Colors.white),
    this.hideSkip = false,
    this.useSafeArea = true,
    this.opacityShadow = 0.8,
    this.focusAnimationDuration = const Duration(milliseconds: 600),
    this.unFocusAnimationDuration = const Duration(milliseconds: 600),
    this.pulseAnimationDuration = const Duration(milliseconds: 500),
    this.pulseEnable = true,
    this.skipWidget,
    this.showSkipInLastTarget = true,
    this.imageFilter,
    this.initialFocus = 0,
    this.backgroundSemanticLabel,
  }) : assert(opacityShadow >= 0 && opacityShadow <= 1);

  OverlayEntry _buildOverlay({bool rootOverlay = false}) {
    return OverlayEntry(
      builder: (context) {
        return TutorialCoachMarkWidget(
          key: _widgetKey,
          targets: targets,
          clickTarget: onClickTarget,
          onClickTargetWithTapPosition: onClickTargetWithTapPosition,
          clickOverlay: onClickOverlay,
          paddingFocus: paddingFocus,
          onClickSkip: skip,
          alignSkip: alignSkip,
          skipWidget: skipWidget,
          textSkip: textSkip,
          textStyleSkip: textStyleSkip,
          hideSkip: hideSkip,
          useSafeArea: useSafeArea,
          colorShadow: colorShadow,
          opacityShadow: opacityShadow,
          focusAnimationDuration: focusAnimationDuration,
          unFocusAnimationDuration: unFocusAnimationDuration,
          pulseAnimationDuration: pulseAnimationDuration,
          pulseEnable: pulseEnable,
          finish: finish,
          rootOverlay: rootOverlay,
          showSkipInLastTarget: showSkipInLastTarget,
          imageFilter: imageFilter,
          initialFocus: initialFocus,
          backgroundSemanticLabel: backgroundSemanticLabel,
        );
      },
    );
  }

  void show({required BuildContext context, bool rootOverlay = false}) {
    OverlayState? overlay = Overlay.of(context, rootOverlay: rootOverlay);
    overlay.let((it) {
      showWithOverlayState(overlay: it, rootOverlay: rootOverlay);
    });
  }

  // `navigatorKey` needs to be the one that you passed to MaterialApp.navigatorKey
  void showWithNavigatorStateKey({
    required GlobalKey<NavigatorState> navigatorKey,
    bool rootOverlay = false,
  }) {
    navigatorKey.currentState?.overlay.let((it) {
      showWithOverlayState(
        overlay: it,
        rootOverlay: rootOverlay,
      );
    });
  }

  void showWithOverlayState({
    required OverlayState overlay,
    bool rootOverlay = false,
  }) {
    postFrame(() => _createAndShow(overlay, rootOverlay: rootOverlay));
  }

  void _createAndShow(
    OverlayState overlay, {
    bool rootOverlay = false,
  }) {
    if (_overlayEntry == null) {
      _overlayEntry = _buildOverlay(rootOverlay: rootOverlay);
      overlay.insert(_overlayEntry!);
    }
  }

  void finish() {
    onFinish?.call();
    _removeOverlay();
  }

  void skip() {
    bool removeOverlay = onSkip?.call() ?? true;
    if (removeOverlay) {
      _removeOverlay();
    } else {
      next();
    }
  }

  bool get isShowing => _overlayEntry != null;

  GlobalKey<TutorialCoachMarkWidgetState> get widgetKey => _widgetKey;

  void next() => _widgetKey.currentState?.next();

  void previous() => _widgetKey.currentState?.previous();

  void goTo(int index) => _widgetKey.currentState?.goTo(index);

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
