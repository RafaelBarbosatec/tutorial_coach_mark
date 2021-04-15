library tutorial_coach_mark;

import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/src/target/target_focus.dart';
import 'package:tutorial_coach_mark/src/widgets/tutorial_coach_mark_widget.dart';

export 'package:tutorial_coach_mark/src/target/target_content.dart';
export 'package:tutorial_coach_mark/src/target/target_focus.dart';
export 'package:tutorial_coach_mark/src/util.dart';

class TutorialCoachMark {
  final BuildContext _context;
  final List<TargetFocus> targets;
  final Function(TargetFocus)? onClickTarget;
  final Function(TargetFocus)? onClickOverlay;
  final Function()? onFinish;
  final double paddingFocus;
  final Function()? onSkip;
  final AlignmentGeometry alignSkip;
  final String textSkip;
  final TextStyle textStyleSkip;
  final bool hideSkip;
  final Color colorShadow;
  final double opacityShadow;
  final GlobalKey<TutorialCoachMarkWidgetState> _widgetKey = GlobalKey();
  final Duration focusAnimationDuration;
  final Duration pulseAnimationDuration;

  OverlayEntry? _overlayEntry;

  TutorialCoachMark(
    this._context, {
    required this.targets,
    this.colorShadow = Colors.black,
    this.onClickTarget,
    this.onClickOverlay,
    this.onFinish,
    this.paddingFocus = 10,
    this.onSkip,
    this.alignSkip = Alignment.bottomRight,
    this.textSkip = "SKIP",
    this.textStyleSkip = const TextStyle(color: Colors.white),
    this.hideSkip = false,
    this.opacityShadow = 0.8,
    this.focusAnimationDuration = const Duration(milliseconds: 600),
    this.pulseAnimationDuration = const Duration(milliseconds: 500),
  }) : assert(targets != null, opacityShadow >= 0 && opacityShadow <= 1);

  OverlayEntry _buildOverlay() {
    return OverlayEntry(
      builder: (context) {
        return TutorialCoachMarkWidget(
          key: _widgetKey,
          targets: targets,
          clickTarget: onClickTarget,
          clickOverlay: onClickOverlay,
          paddingFocus: paddingFocus,
          onClickSkip: skip,
          alignSkip: alignSkip,
          textSkip: textSkip,
          textStyleSkip: textStyleSkip,
          hideSkip: hideSkip,
          colorShadow: colorShadow,
          opacityShadow: opacityShadow,
          focusAnimationDuration: focusAnimationDuration,
          pulseAnimationDuration: pulseAnimationDuration,
          finish: finish,
        );
      },
    );
  }

  void show() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      Future.delayed(Duration.zero, () {
        if (_overlayEntry == null) {
          _overlayEntry = _buildOverlay();
          Overlay.of(_context)!.insert(_overlayEntry!);
        }
      });
    });
  }

  void finish() {
    onFinish?.call();
    _removeOverlay();
  }

  void skip() {
    onSkip?.call();
    _removeOverlay();
  }

  bool get isShowing => _overlayEntry != null;

  void next() => _widgetKey.currentState?.next();
  void previous() => _widgetKey.currentState?.previous();

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
