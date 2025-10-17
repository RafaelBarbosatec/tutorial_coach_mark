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
/// - Automatic screen resize and orientation handling
///
/// The tutorial can be controlled programmatically using methods like:
/// - [show] - Displays the tutorial
/// - [next] - Moves to next target
/// - [previous] - Returns to previous target
/// - [skip] - Skips the tutorial
/// - [finish] - Ends the tutorial

class TutorialCoachMark {
  /// List of targets to focus during the tutorial sequence.
  final List<TargetFocus> targets;
  
  /// Callback executed before focus
  final FutureOr<void> Function(TargetFocus)? beforeFocus;

  /// Callback executed when a target area is tapped.
  final FutureOr<void> Function(TargetFocus)? onClickTarget;

  /// Callback executed when a target is tapped, providing tap position details.
  final FutureOr<void> Function(TargetFocus, TapDownDetails)?
      onClickTargetWithTapPosition;

  /// Callback executed when the overlay area (outside target) is tapped.
  final FutureOr<void> Function(TargetFocus)? onClickOverlay;

  /// Callback executed when the tutorial is completed.
  final Function()? onFinish;

  /// Default padding around focus areas for all targets.
  final double paddingFocus;

  /// Callback executed when skip button is pressed.
  /// If returns false, the overlay will not be dismissed and will call `next` instead.
  final bool Function()? onSkip;

  /// Alignment of the skip button on screen.
  final AlignmentGeometry alignSkip;

  /// Text displayed on the skip button.
  final String textSkip;

  /// Text style for the skip button.
  final TextStyle textStyleSkip;

  /// Whether to hide the skip button completely.
  final bool hideSkip;

  /// Whether to respect device safe areas (notches, status bar, etc.).
  final bool useSafeArea;

  /// Color of the shadow overlay behind the tutorial.
  final Color colorShadow;

  /// Opacity of the shadow overlay (0.0 to 1.0).
  final double opacityShadow;

  /// Duration of the focus animation when highlighting a target.
  final Duration focusAnimationDuration;

  /// Duration of the unfocus animation when moving between targets.
  final Duration unFocusAnimationDuration;

  /// Duration of the pulse animation effect on targets.
  final Duration pulseAnimationDuration;

  /// Whether to enable pulse animation on focused targets.
  final bool pulseEnable;

  /// Custom widget to use instead of the default skip button.
  final Widget? skipWidget;

  /// Whether to show the skip button on the last target.
  final bool showSkipInLastTarget;

  /// Image filter effect to apply to the background overlay.
  final ImageFilter? imageFilter;

  /// Semantic label for the background overlay for accessibility.
  final String? backgroundSemanticLabel;

  /// Index of the target to focus initially (0-based).
  final int initialFocus;

  /// Internal widget key for controlling the tutorial widget state.
  final GlobalKey<TutorialCoachMarkWidgetState> _widgetKey = GlobalKey();

  /// Whether to disable the device back button during the tutorial.
  final bool disableBackButton;

  OverlayEntry? _overlayEntry;
  ModalRoute?
      _blockBackRoute; // Referencia a la ruta que bloquea el botón "Atrás"
  BuildContext? _contextTutorial; // Almacena el contexto para usarlo después

  /// Creates a tutorial coach mark with the specified configuration.
  ///
  /// Parameters:
  /// - [targets]: List of target focuses to highlight during the tutorial. Required.
  /// - [colorShadow]: Color of the shadow overlay. Default is [Colors.black].
  /// - [onClickTarget]: Callback when target area is tapped.
  /// - [onClickTargetWithTapPosition]: Callback when target is tapped, provides tap details.
  /// - [onClickOverlay]: Callback when overlay area (outside target) is tapped.
  /// - [onFinish]: Callback when tutorial is completed.
  /// - [paddingFocus]: Padding around focus area. Default is 10.
  /// - [onSkip]: Callback when skip button is pressed. Return false to prevent skipping.
  /// - [alignSkip]: Alignment of skip button. Default is [Alignment.bottomRight].
  /// - [textSkip]: Text for skip button. Default is "SKIP".
  /// - [textStyleSkip]: Style for skip button text.
  /// - [hideSkip]: Whether to hide skip button. Default is false.
  /// - [useSafeArea]: Whether to respect safe areas. Default is true.
  /// - [opacityShadow]: Opacity of shadow overlay (0.0 to 1.0). Default is 0.8.
  /// - [focusAnimationDuration]: Duration of focus animation. Default is 600ms.
  /// - [unFocusAnimationDuration]: Duration of unfocus animation. Default is 600ms.
  /// - [pulseAnimationDuration]: Duration of pulse animation. Default is 500ms.
  /// - [pulseEnable]: Whether to enable pulse animation. Default is true.
  /// - [skipWidget]: Custom widget for skip button.
  /// - [showSkipInLastTarget]: Whether to show skip in last target. Default is true.
  /// - [imageFilter]: Image filter effect for background.
  /// - [initialFocus]: Index of initial focus target. Default is 0.
  /// - [backgroundSemanticLabel]: Semantic label for background overlay.
  /// - [disableBackButton]: Whether to disable device back button. Default is false.
  TutorialCoachMark({
    required this.targets,
    this.colorShadow = Colors.black,
    this.onClickTarget,
    this.beforeFocus,
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
    this.disableBackButton = false,
  }) : assert(opacityShadow >= 0 && opacityShadow <= 1);

  OverlayEntry _buildOverlay({bool rootOverlay = false}) {
    return OverlayEntry(
      builder: (context) {
        return TutorialCoachMarkWidget(
          key: _widgetKey,
          targets: targets,
          clickTarget: onClickTarget,
          beforeFocus: beforeFocus,
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

  /// Displays the tutorial using the provided build context.
  ///
  /// This is the primary method for showing the tutorial. It automatically
  /// finds the appropriate overlay state from the context.
  ///
  /// Parameters:
  /// - [context]: The build context to find overlay state from.
  /// - [rootOverlay]: Whether to use the root overlay instead of nearest overlay.
  void show({required BuildContext context, bool rootOverlay = false}) {
    OverlayState? overlay = Overlay.of(context, rootOverlay: rootOverlay);
    overlay.let((it) {
      showWithOverlayState(overlay: it, rootOverlay: rootOverlay);
    });
  }

  /// Displays the tutorial using a specific navigator state key.
  ///
  /// Use this when you need to show the tutorial on a specific navigator
  /// instead of using the current build context.
  ///
  /// Parameters:
  /// - [navigatorKey]: The global key of the navigator state.
  /// - [rootOverlay]: Whether to use the root overlay.
  void showWithNavigatorStateKey({
    required GlobalKey<NavigatorState> navigatorKey,
    bool rootOverlay = false,
  }) {
    navigatorKey.currentState?.overlay?.let((it) {
      showWithOverlayState(
        overlay: it,
        rootOverlay: rootOverlay,
      );
    });
  }

  /// Displays the tutorial using a specific overlay state.
  ///
  /// This provides the most control over where the tutorial is displayed.
  /// Use when you have direct access to the overlay state.
  ///
  /// Parameters:
  /// - [overlay]: The overlay state to insert the tutorial into.
  /// - [rootOverlay]: Whether to use root overlay positioning.
  void showWithOverlayState({
    required OverlayState overlay,
    bool rootOverlay = false,
  }) {
    _contextTutorial = overlay.context; // Guarda el contexto del overlay
    postFrame(() {
      _createAndShow(overlay, rootOverlay: rootOverlay);
      if (disableBackButton) {
        // Bloquea el botón "Atrás" mientras el tutorial está activo
        _blockBackRoute = PageRouteBuilder(
          opaque: false,
          barrierDismissible: false,
          pageBuilder: (context, _, __) {
            return PopScope(
              canPop: false,
              onPopInvokedWithResult: (value, result) async =>
                  false, // Bloquea el retroceso
              child: const SizedBox(), // No muestra nada
            );
          },
        );
        Navigator.of(_contextTutorial!).push(_blockBackRoute!);
      }
    });
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

  /// Finishes the tutorial and removes the overlay.
  ///
  /// Calls the [onFinish] callback if provided, then removes the tutorial overlay.
  void finish() {
    onFinish?.call();
    _removeOverlay();
  }

  /// Skips the tutorial.
  ///
  /// Calls the [onSkip] callback if provided. If the callback returns false,
  /// the tutorial will proceed to the next step instead of closing.
  void skip() {
    bool removeOverlay = onSkip?.call() ?? true;
    if (removeOverlay) {
      _removeOverlay();
    } else {
      next();
    }
  }

  /// Whether the tutorial is currently being displayed.
  bool get isShowing => _overlayEntry != null;

  /// Internal widget key for accessing tutorial state.
  GlobalKey<TutorialCoachMarkWidgetState> get widgetKey => _widgetKey;

  /// Advances to the next target in the tutorial sequence.
  void next() => _widgetKey.currentState?.next();

  /// Goes back to the previous target in the tutorial sequence.
  void previous() => _widgetKey.currentState?.previous();

  /// Jumps directly to a specific target by index.
  ///
  /// Parameters:
  /// - [index]: Zero-based index of the target to jump to.
  void goTo(int index) => _widgetKey.currentState?.goTo(index);

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    closeHiddenView();
  }

  void removeOverlayEntry() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    closeHiddenView();
  }

  void closeHiddenView() {
    // Verifica si hay un contexto válido antes de intentar remover la ruta
    if (_contextTutorial != null &&
        _contextTutorial!.mounted &&
        _blockBackRoute != null) {
      Navigator.of(_contextTutorial!).removeRoute(_blockBackRoute!);
      _blockBackRoute = null;
    }
    _contextTutorial = null;
  }
}
