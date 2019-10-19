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
  final Function() finish;
  final double paddingFocus;
  final Function() clickSkip;
  final AlignmentGeometry alignSkip;
  final String textSkip;
  final bool hideSkip;
  final Color colorShadow;
  final double opacityShadow;

  OverlayEntry _overlayEntry;

  TutorialCoachMark(
    this._context, {
    this.targets,
    this.colorShadow = Colors.black,
    this.clickTarget,
    this.finish,
    this.paddingFocus = 10,
    this.clickSkip,
    this.alignSkip = Alignment.bottomRight,
    this.textSkip = "SKIP",
    this.hideSkip = false,
    this.opacityShadow = 0.8,
  }) : assert(targets != null, opacityShadow >= 0 && opacityShadow <= 1);

  OverlayEntry _buildOverlay() {
    return OverlayEntry(builder: (context) {
      return TutorialCoachMarkWidget(
        targets: targets,
        clickTarget: clickTarget,
        paddingFocus: paddingFocus,
        clickSkip: clickSkip,
        alignSkip: alignSkip,
        textSkip: textSkip,
        hideSkip: hideSkip,
        colorShadow: colorShadow,
        opacityShadow: opacityShadow,
        finish: () {
          _hide();
          if (finish != null) finish();
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

  void _hide() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
