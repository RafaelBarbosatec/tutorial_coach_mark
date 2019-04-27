library tutorial_coach_mark;
import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark_widget.dart';

class TutorialCoachMark {
  final BuildContext _context;

  OverlayEntry _overlayEntry;

  TutorialCoachMark(
      this._context,);

  OverlayEntry _buildOverlay() {
    return OverlayEntry(builder: (context) {
      return TutorialCoachMarkWidget();
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
