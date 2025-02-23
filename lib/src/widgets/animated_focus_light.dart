import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/src/clipper/circle_clipper.dart';
import 'package:tutorial_coach_mark/src/clipper/rect_clipper.dart';
import 'package:tutorial_coach_mark/src/paint/light_paint.dart';
import 'package:tutorial_coach_mark/src/paint/light_paint_rect.dart';
import 'package:tutorial_coach_mark/src/target/target_focus.dart';
import 'package:tutorial_coach_mark/src/target/target_position.dart';
import 'package:tutorial_coach_mark/src/util.dart';

class AnimatedFocusLight extends StatefulWidget {
  const AnimatedFocusLight({
    Key? key,
    required this.targets,
    this.focus,
    this.finish,
    this.removeFocus,
    this.clickTarget,
    this.clickTargetWithTapPosition,
    this.clickOverlay,
    this.paddingFocus = 10,
    this.colorShadow = Colors.black,
    this.opacityShadow = 0.8,
    this.focusAnimationDuration,
    this.unFocusAnimationDuration,
    this.pulseAnimationDuration,
    this.pulseVariation,
    this.imageFilter,
    this.pulseEnable = true,
    this.rootOverlay = false,
    this.initialFocus = 0,
    this.backgroundSemanticLabel,
  })  : assert(targets.length > 0),
        super(key: key);

  final List<TargetFocus> targets;
  final Function(TargetFocus)? focus;
  final FutureOr Function(TargetFocus)? clickTarget;
  final FutureOr Function(TargetFocus, TapDownDetails)?
      clickTargetWithTapPosition;
  final FutureOr Function(TargetFocus)? clickOverlay;
  final Function? removeFocus;
  final Function()? finish;
  final double paddingFocus;
  final Color colorShadow;
  final double opacityShadow;
  final Duration? focusAnimationDuration;
  final Duration? unFocusAnimationDuration;
  final Duration? pulseAnimationDuration;
  final Tween<double>? pulseVariation;
  final bool pulseEnable;
  final bool rootOverlay;
  final ImageFilter? imageFilter;
  final int initialFocus;
  final String? backgroundSemanticLabel;

  @override
  // ignore: no_logic_in_create_state
  AnimatedFocusLightState createState() => pulseEnable
      ? AnimatedPulseFocusLightState()
      : AnimatedStaticFocusLightState();
}

abstract class AnimatedFocusLightState extends State<AnimatedFocusLight>
    with TickerProviderStateMixin {
  final borderRadiusDefault = 10.0;
  final defaultFocusAnimationDuration = Durations.long4;
  late AnimationController _controller;
  late CurvedAnimation _curvedAnimation;

  late TargetFocus _targetFocus;
  Offset _positioned = Offset.zero;
  TargetPosition? _targetPosition;

  double _sizeCircle = 100;
  int _currentFocus = 0;
  double _progressAnimated = 0;
  int nextIndex = 0;
  bool _isAnimating = true;

  Future<void> _revertAnimation() async {
    _isAnimating = true;
    _controller.duration = unFocusDuration;
  }

  void _listener(AnimationStatus status);

  Duration get focusDuration =>
      _targetFocus.focusAnimationDuration ??
      widget.focusAnimationDuration ??
      defaultFocusAnimationDuration;

  Duration get unFocusDuration =>
      _targetFocus.unFocusAnimationDuration ??
      widget.unFocusAnimationDuration ??
      _targetFocus.focusAnimationDuration ??
      widget.focusAnimationDuration ??
      defaultFocusAnimationDuration;

  @override
  void initState() {
    super.initState();
    _currentFocus = widget.initialFocus;
    _targetFocus = widget.targets[_currentFocus];
    _controller = AnimationController(
      vsync: this,
      duration: focusDuration,
    )..addStatusListener(_listener);

    _curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.ease,
    );

    Future.delayed(Duration.zero, _runFocus);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void next() => _tapHandler();

  void previous() {
    if (_isAnimating) return;
    nextIndex--;
    _revertAnimation();
  }

  void goTo(int index) {
    if (_isAnimating) return;
    nextIndex = index;
    _revertAnimation();
  }

  Future _tapHandler({
    bool targetTap = false,
    bool overlayTap = false,
  }) async {
    if (_isAnimating) return;
    nextIndex++;
    if (targetTap) {
      await widget.clickTarget?.call(_targetFocus);
    }
    if (overlayTap) {
      await widget.clickOverlay?.call(_targetFocus);
    }
    return _revertAnimation();
  }

  Future _tapHandlerForPosition(TapDownDetails tapDetails) async {
    if (_isAnimating) return;
    await widget.clickTargetWithTapPosition?.call(_targetFocus, tapDetails);
  }

  Future<void> _runFocus() async {
    if (_currentFocus < 0) return;
    _targetFocus = widget.targets[_currentFocus];

    _controller.duration = focusDuration;

    TargetPosition? targetPosition;
    try {
      targetPosition = getTargetCurrent(
        _targetFocus,
        rootOverlay: widget.rootOverlay,
      );
    } on NotFoundTargetException catch (e, s) {
      debugPrint(e.toString());
      debugPrintStack(stackTrace: s);
    }

    if (targetPosition == null) {
      _finish();
      return;
    }

    safeSetState(() {
      _targetPosition = targetPosition!;

      _positioned = Offset(
        targetPosition.offset.dx + (targetPosition.size.width / 2),
        targetPosition.offset.dy + (targetPosition.size.height / 2),
      );

      if (targetPosition.size.height > targetPosition.size.width) {
        _sizeCircle = targetPosition.size.height * 0.6 + _getPaddingFocus();
      } else {
        _sizeCircle = targetPosition.size.width * 0.6 + _getPaddingFocus();
      }
    });

    await _controller.forward();
    _isAnimating = false;
  }

  void _goToFocus(int index) {
    if (index >= 0 && index < widget.targets.length) {
      _currentFocus = index;
      _runFocus();
    } else {
      _finish();
    }
  }

  void _finish() {
    safeSetState(() => _currentFocus = 0);
    widget.finish!();
  }

  Widget _getLightPaint(TargetFocus targetFocus) {
    if (widget.imageFilter != null) {
      return ClipPath(
        clipper: _getClipper(targetFocus.shape),
        child: BackdropFilter(
          filter: widget.imageFilter!,
          child: _getSizedPainter(targetFocus),
        ),
      );
    } else {
      return _getSizedPainter(targetFocus);
    }
  }

  SizedBox _getSizedPainter(TargetFocus targetFocus) {
    return SizedBox(
      width: double.maxFinite,
      height: double.maxFinite,
      child: CustomPaint(
        painter: _getPainter(targetFocus),
      ),
    );
  }

  CustomClipper<Path> _getClipper(ShapeLightFocus? shape) {
    return shape == ShapeLightFocus.RRect
        ? RectClipper(
            progress: _progressAnimated,
            offset: _getPaddingFocus(),
            target: _targetPosition ?? TargetPosition(Size.zero, Offset.zero),
            radius: _targetFocus.radius ?? 0,
            borderSide: _targetFocus.borderSide,
          )
        : CircleClipper(
            _progressAnimated,
            _positioned,
            _sizeCircle,
            _targetFocus.borderSide,
          );
  }

  CustomPainter _getPainter(TargetFocus target) {
    if (target.shape == ShapeLightFocus.RRect) {
      return LightPaintRect(
        colorShadow: target.color ?? widget.colorShadow,
        progress: _progressAnimated,
        offset: _getPaddingFocus(),
        target: _targetPosition ?? TargetPosition(Size.zero, Offset.zero),
        radius: target.radius ?? 0,
        borderSide: target.borderSide,
        opacityShadow: widget.opacityShadow,
      );
    } else {
      return LightPaint(
        _progressAnimated,
        _positioned,
        _sizeCircle,
        colorShadow: target.color ?? widget.colorShadow,
        borderSide: target.borderSide,
        opacityShadow: widget.opacityShadow,
      );
    }
  }

  double _getPaddingFocus() {
    return _targetFocus.paddingFocus ?? (widget.paddingFocus);
  }

  BorderRadius _betBorderRadiusTarget() {
    double radius = _targetFocus.shape == ShapeLightFocus.Circle
        ? _targetPosition?.size.width ?? borderRadiusDefault
        : _targetFocus.radius ?? borderRadiusDefault;
    return BorderRadius.circular(radius);
  }

  void _onTargetTap() {
    if (!_targetFocus.enableTargetTab) return;
    _tapHandler(targetTap: true);
  }
}

class AnimatedStaticFocusLightState extends AnimatedFocusLightState {
  double get left => (_targetPosition?.offset.dx ?? 0) - _getPaddingFocus() * 2;

  double get top => (_targetPosition?.offset.dy ?? 0) - _getPaddingFocus() * 2;

  double get width {
    return (_targetPosition?.size.width ?? 0) + _getPaddingFocus() * 4;
  }

  double get height {
    return (_targetPosition?.size.height ?? 0) + _getPaddingFocus() * 4;
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.backgroundSemanticLabel,
      button: true,
      child: InkWell(
        excludeFromSemantics: true,
        onTap: _targetFocus.enableOverlayTab
            ? () => _tapHandler(overlayTap: true)
            : null,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (_, child) {
            _progressAnimated = _curvedAnimation.value;
            return Stack(
              children: <Widget>[
                _getLightPaint(_targetFocus),
                Positioned(
                  left: left,
                  top: top,
                  child: InkWell(
                    borderRadius: _betBorderRadiusTarget(),
                    onTapDown: _tapHandlerForPosition,
                    onTap: _onTargetTap,
                    child: Container(
                      color: Colors.transparent,
                      width: width,
                      height: height,
                    ),
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  Future<void> _revertAnimation() async {
    await super._revertAnimation();
    return _controller.reverse();
  }

  @override
  void _listener(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      widget.focus?.call(_targetFocus);
    }
    if (status == AnimationStatus.dismissed) {
      _goToFocus(nextIndex);
    }

    if (status == AnimationStatus.reverse) {
      widget.removeFocus?.call();
    }
  }
}

class AnimatedPulseFocusLightState extends AnimatedFocusLightState {
  final defaultPulseAnimationDuration = const Duration(milliseconds: 500);
  final defaultPulseVariation = Tween(begin: 1.0, end: 0.99);
  late AnimationController _controllerPulse;
  late Animation _tweenPulse;

  bool _finishFocus = false;
  bool _initReverse = false;

  get left => (_targetPosition?.offset.dx ?? 0) - _getPaddingFocus() * 2;

  get top => (_targetPosition?.offset.dy ?? 0) - _getPaddingFocus() * 2;

  get width => (_targetPosition?.size.width ?? 0) + _getPaddingFocus() * 4;

  get height => (_targetPosition?.size.height ?? 0) + _getPaddingFocus() * 4;

  @override
  void initState() {
    super.initState();
    _controllerPulse = AnimationController(
      vsync: this,
      duration: widget.pulseAnimationDuration ?? defaultPulseAnimationDuration,
    );

    _tweenPulse = _createTweenAnimation(
      _targetFocus.pulseVariation ??
          widget.pulseVariation ??
          defaultPulseVariation,
    );

    _controllerPulse.addStatusListener(_listenerPulse);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.backgroundSemanticLabel,
      button: true,
      child: InkWell(
        excludeFromSemantics: true,
        onTap: _targetFocus.enableOverlayTab
            ? () => _tapHandler(overlayTap: true)
            : null,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (_, child) {
            _progressAnimated = _curvedAnimation.value;
            return AnimatedBuilder(
              animation: _controllerPulse,
              builder: (_, child) {
                if (_finishFocus) {
                  _progressAnimated = _tweenPulse.value;
                }
                return Stack(
                  children: <Widget>[
                    _getLightPaint(_targetFocus),
                    Positioned(
                      left: left,
                      top: top,
                      child: InkWell(
                        borderRadius: _betBorderRadiusTarget(),
                        onTap: _onTargetTap,
                        onTapDown: _tapHandlerForPosition,
                        child: Container(
                          color: Colors.transparent,
                          width: width,
                          height: height,
                        ),
                      ),
                    )
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  @override
  Future<void> _runFocus() {
    _tweenPulse = _createTweenAnimation(
      _targetFocus.pulseVariation ??
          widget.pulseVariation ??
          defaultPulseVariation,
    );
    _finishFocus = false;
    return super._runFocus();
  }

  @override
  Future<void> _revertAnimation() async {
    await super._revertAnimation();
    _initReverse = true;
    return _controllerPulse.reverse(from: _controllerPulse.value);
  }

  @override
  void dispose() {
    _controllerPulse.dispose();
    super.dispose();
  }

  @override
  void _listener(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      safeSetState(() => _finishFocus = true);

      widget.focus?.call(_targetFocus);

      _controllerPulse.forward();
    }
    if (status == AnimationStatus.dismissed) {
      _finishFocus = false;
      _initReverse = false;
      _goToFocus(nextIndex);
    }

    if (status == AnimationStatus.reverse) {
      widget.removeFocus?.call();
    }
  }

  void _listenerPulse(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _controllerPulse.reverse();
    }

    if (status == AnimationStatus.dismissed) {
      if (_initReverse) {
        safeSetState(() => _finishFocus = false);
        _controller.reverse();
      } else if (_finishFocus) {
        _controllerPulse.forward();
      }
    }
  }

  Animation _createTweenAnimation(Tween<double> tween) {
    return tween.animate(
      CurvedAnimation(parent: _controllerPulse, curve: Curves.ease),
    );
  }
}
