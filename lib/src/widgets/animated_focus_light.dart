import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/src/paint/light_paint.dart';
import 'package:tutorial_coach_mark/src/paint/light_paint_rect.dart';
import 'package:tutorial_coach_mark/src/target/target_focus.dart';
import 'package:tutorial_coach_mark/src/target/target_position.dart';
import 'package:tutorial_coach_mark/src/util.dart';

class AnimatedFocusLight extends StatefulWidget {
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
    this.pulseEnable = true,
    this.rootOverlay = false,
  })  : assert(targets.length > 0),
        super(key: key);

  @override
  // ignore: no_logic_in_create_state
  AnimatedFocusLightState createState() => pulseEnable
      ? AnimatedPulseFocusLightState()
      : AnimatedStaticFocusLightState();
}

abstract class AnimatedFocusLightState extends State<AnimatedFocusLight>
    with TickerProviderStateMixin {
  final borderRadiusDefault = 10.0;
  final defaultFocusAnimationDuration = const Duration(milliseconds: 600);
  late AnimationController _controller;
  late CurvedAnimation _curvedAnimation;

  late TargetFocus _targetFocus;
  Offset _positioned = const Offset(0.0, 0.0);
  TargetPosition? _targetPosition;

  double _sizeCircle = 100;
  int _currentFocus = 0;
  double _progressAnimated = 0;
  bool _goNext = true;

  @override
  void initState() {
    super.initState();
    _targetFocus = widget.targets[_currentFocus];
    _controller = AnimationController(
      vsync: this,
      duration: _targetFocus.focusAnimationDuration ??
          widget.focusAnimationDuration ??
          defaultFocusAnimationDuration,
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

  void previous() => _tapHandler(goNext: false);

  Future _tapHandler({
    bool goNext = true,
    bool targetTap = false,
    bool overlayTap = false,
  }) async {
    if (targetTap) {
      await widget.clickTarget?.call(_targetFocus);
    }
    if (overlayTap) {
      await widget.clickOverlay?.call(_targetFocus);
    }
  }

  Future _tapHandlerForPosition(TapDownDetails tapDetails) async {
    await widget.clickTargetWithTapPosition?.call(_targetFocus, tapDetails);
  }

  void _runFocus() {
    if (_currentFocus < 0) return;
    _targetFocus = widget.targets[_currentFocus];

    _controller.duration = _targetFocus.focusAnimationDuration ??
        widget.focusAnimationDuration ??
        defaultFocusAnimationDuration;

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

    _controller.forward();
    _controller.duration = _targetFocus.unFocusAnimationDuration ??
        widget.unFocusAnimationDuration ??
        _targetFocus.focusAnimationDuration ??
        widget.focusAnimationDuration ??
        defaultFocusAnimationDuration;
  }

  void _nextFocus() {
    if (_currentFocus >= widget.targets.length - 1) {
      _finish();
      return;
    }
    _currentFocus++;

    _runFocus();
  }

  void _previousFocus() {
    if (_currentFocus <= 0) {
      _finish();
      return;
    }
    _currentFocus--;
    _runFocus();
  }

  void _finish() {
    safeSetState(() => _currentFocus = 0);
    widget.finish!();
  }

  void _listener(AnimationStatus status);

  CustomPainter _getPainter(TargetFocus? target) {
    if (target?.shape == ShapeLightFocus.RRect) {
      return LightPaintRect(
        colorShadow: target?.color ?? widget.colorShadow,
        progress: _progressAnimated,
        offset: _getPaddingFocus(),
        target: _targetPosition ?? TargetPosition(Size.zero, Offset.zero),
        radius: target?.radius ?? 0,
        borderSide: target?.borderSide,
        opacityShadow: widget.opacityShadow,
      );
    } else {
      return LightPaint(
        _progressAnimated,
        _positioned,
        _sizeCircle,
        colorShadow: target?.color ?? widget.colorShadow,
        borderSide: target?.borderSide,
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
    return InkWell(
      onTap: _targetFocus.enableOverlayTab
          ? () => _tapHandler(overlayTap: true)
          : null,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, child) {
          _progressAnimated = _curvedAnimation.value;
          return Stack(
            children: <Widget>[
              SizedBox(
                width: double.maxFinite,
                height: double.maxFinite,
                child: CustomPaint(
                  painter: _getPainter(_targetFocus),
                ),
              ),
              Positioned(
                left: left,
                top: top,
                child: InkWell(
                  borderRadius: _betBorderRadiusTarget(),
                  onTapDown: _tapHandlerForPosition,
                  onTap: _targetFocus.enableTargetTab
                      ? () => _tapHandler(targetTap: true)

                      /// Essential for collecting [TapDownDetails]. Do not make [null]
                      : () {},
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
    );
  }

  @override
  Future _tapHandler({
    bool goNext = true,
    bool targetTap = false,
    bool overlayTap = false,
  }) async {
    await super._tapHandler(
      goNext: goNext,
      targetTap: targetTap,
      overlayTap: overlayTap,
    );
    safeSetState(() => _goNext = goNext);
    _controller.reverse();
  }

  @override
  void _listener(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      widget.focus?.call(_targetFocus);
    }
    if (status == AnimationStatus.dismissed) {
      if (_goNext) {
        _nextFocus();
      } else {
        _previousFocus();
      }
    }

    if (status == AnimationStatus.reverse) {
      widget.removeFocus!();
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

    _tweenPulse = _createTweenAnimation(_targetFocus.pulseVariation ??
        widget.pulseVariation ??
        defaultPulseVariation);

    _controllerPulse.addStatusListener(_listenerPulse);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
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
                  ClipPath(
                    clipper: _targetFocus.shape == ShapeLightFocus.RRect
                        ? MyRectClipper(
                            progress: _progressAnimated,
                            offset: _getPaddingFocus(),
                            target: _targetPosition ??
                                TargetPosition(Size.zero, Offset.zero),
                            radius: _targetFocus.radius ?? 0,
                            borderSide: _targetFocus.borderSide,
                          )
                        : MyCircleClipper(
                            _progressAnimated,
                            _positioned,
                            _sizeCircle,
                            _targetFocus.borderSide,
                          ),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                      child: SizedBox(
                        width: double.maxFinite,
                        height: double.maxFinite,
                        child: CustomPaint(
                          painter: _getPainter(_targetFocus),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: left,
                    top: top,
                    child: InkWell(
                      borderRadius: _betBorderRadiusTarget(),
                      onTap: _targetFocus.enableTargetTab
                          ? () => _tapHandler(targetTap: true)

                          /// Essential for collecting [TapDownDetails]. Do not make [null]
                          : () {},
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
    );
  }

  @override
  void _runFocus() {
    _tweenPulse = _createTweenAnimation(_targetFocus.pulseVariation ??
        widget.pulseVariation ??
        defaultPulseVariation);
    _finishFocus = false;
    super._runFocus();
  }

  @override
  Future _tapHandler({
    bool goNext = true,
    bool targetTap = false,
    bool overlayTap = false,
  }) async {
    await super._tapHandler(
      goNext: goNext,
      targetTap: targetTap,
      overlayTap: overlayTap,
    );
    if (mounted) {
      safeSetState(() {
        _goNext = goNext;
        _initReverse = true;
      });
    }

    _controllerPulse.reverse(from: _controllerPulse.value);
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
      safeSetState(() {
        _finishFocus = false;
        _initReverse = false;
      });
      if (_goNext) {
        _nextFocus();
      } else {
        _previousFocus();
      }
    }

    if (status == AnimationStatus.reverse) {
      widget.removeFocus!();
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

class MyCircleClipper extends CustomClipper<Path> {
  final double progress;
  final Offset positioned;
  final double sizeCircle;
  final BorderSide? borderSide;

  MyCircleClipper(
    this.progress,
    this.positioned,
    this.sizeCircle,
    this.borderSide,
  );

  @override
  Path getClip(Size size) {
    if (positioned == Offset.zero) return Path();
    var maxSize = max(size.width, size.height);

    double radius = maxSize * (1 - progress) + sizeCircle;
    final circleHole = Path()
      ..moveTo(0, 0)
      ..lineTo(0, positioned.dy)
      ..arcTo(
        Rect.fromCircle(center: positioned, radius: radius),
        pi,
        pi,
        false,
      )
      ..arcTo(
        Rect.fromCircle(center: positioned, radius: radius),
        0,
        pi,
        false,
      )
      ..lineTo(0, positioned.dy)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width, 0)
      ..close();
    return circleHole;
  }

  @override
  bool shouldReclip(covariant MyCircleClipper oldClipper) {
    return progress != oldClipper.progress;
  }
}

class MyRectClipper extends CustomClipper<Path> {
  final double progress;
  final TargetPosition target;
  final double offset;
  final double radius;
  final BorderSide? borderSide;

  MyRectClipper({
    required this.progress,
    required this.target,
    required this.offset,
    required this.radius,
    this.borderSide,
  });

  @override
  Path getClip(Size size) {
    if (target.offset == Offset.zero) return Path();

    var maxSize = max(size.width, size.height) +
        max(target.size.width, target.size.height) +
        target.getBiggerSpaceBorder(size);

    double x = -maxSize / 2 * (1 - progress) + target.offset.dx - offset / 2;

    double y = -maxSize / 2 * (1 - progress) + target.offset.dy - offset / 2;

    double w = maxSize * (1 - progress) + target.size.width + offset;

    double h = maxSize * (1 - progress) + target.size.height + offset;
    return Path()
      ..moveTo(0, 0)
      ..lineTo(0, y)
      ..lineTo(x + w, y)
      ..lineTo(x + w, y + h)
      ..lineTo(x, y + h)
      ..lineTo(x, y)
      ..lineTo(0, y)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width, 0)
      ..close();
  }

  @override
  bool shouldReclip(covariant MyRectClipper oldClipper) {
    return progress != oldClipper.progress;
  }
}
