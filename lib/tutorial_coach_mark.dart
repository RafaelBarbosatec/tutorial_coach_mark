library tutorial_coach_mark;

import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/target_focus.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark_widget.dart';
export 'package:tutorial_coach_mark/content_target.dart';
export 'package:tutorial_coach_mark/target_focus.dart';

class TutorialCoachMark {
  final BuildContext _context;
  final List<TargetFocus> targets;
  final Function(TargetFocus) clickTarget;
  final Function(TargetFocus) currentTarget;
  final Function() finish;
  final double paddingFocus;
  final Function() clickSkip;
  final String textSkip;
  final String textPrevious;
  final String textNext;
  final TextStyle textStyleSkip;
  final TextStyle textStylePrevious;
  final TextStyle textStyleNext;
  final Color colorShadow;
  final double opacityShadow;

  OverlayEntry _overlayEntry;

  TutorialCoachMark(
    this._context, {
    this.targets,
    this.colorShadow = Colors.black,
    this.clickTarget,
    this.currentTarget,
    this.finish,
    this.paddingFocus = 10,
    this.clickSkip,
    this.textSkip = "SKIP",
    this.textPrevious = "PREVIOUS",
    this.textNext = "NEXT",
    this.textStyleSkip = const TextStyle(color: Colors.white),
    this.textStylePrevious = const TextStyle(color: Colors.white),
    this.textStyleNext = const TextStyle(color: Colors.white),
    this.opacityShadow = 0.8,
  }) : assert(targets != null, opacityShadow >= 0 && opacityShadow <= 1);

  OverlayEntry _buildOverlay() {
    return OverlayEntry(builder: (context) {
      return TutorialCoachMarkWidget(
        targets: targets,
        clickTarget: clickTarget,
        currentTarget: currentTarget,
        paddingFocus: paddingFocus,
        clickSkip: clickSkip,
        textSkip: textSkip,
        textStyleSkip: textStyleSkip,
        textPrevious: textPrevious,
        textNext: textNext,
        textStylePrevious: textStylePrevious,
        textStyleNext: textStyleNext,
        colorShadow: colorShadow,
        opacityShadow: opacityShadow,
        finish: () {
          hide();
        },
      );
    });
  }

  void show() {
    if (_overlayEntry == null) {
      _overlayEntry = _buildOverlay();
      Overlay.of(_context).insert(_overlayEntry);
    }
  }

  void hide() {
    if (finish != null) finish();
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
