import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tutorial_coach_mark/src/paint/light_paint.dart';
import 'package:tutorial_coach_mark/src/paint/light_paint_rect.dart';
import 'package:tutorial_coach_mark/src/target/target_focus.dart';
import 'package:tutorial_coach_mark/src/target/target_position.dart';
import 'package:tutorial_coach_mark/src/util.dart';

class AnimatedFocusLight extends StatefulWidget {
  final List<TargetFocus> targets;
  final Function(TargetFocus)? focus;
  final FutureOr Function(TargetFocus)? clickTarget;
  final FutureOr Function(TargetFocus)? clickOverlay;
  final Function? removeFocus;
  final Function()? finish;
  final double paddingFocus;
  final Color colorShadow;
  final double opacityShadow;
  final Duration? focusAnimationDuration;
  final Duration? pulseAnimationDuration;
  final Tween<double>? pulseVariation;
  final bool pulseEnable;

  const AnimatedFocusLight({
    Key? key,
    required this.targets,
    this.focus,
    this.finish,
    this.removeFocus,
    this.clickTarget,
    this.clickOverlay,
    this.paddingFocus = 10,
    this.colorShadow = Colors.black,
    this.opacityShadow = 0.8,
    this.focusAnimationDuration,
    this.pulseAnimationDuration,
    this.pulseVariation,
    this.pulseEnable = true,
  })  : assert(targets.length > 0),
        super(key: key);

  @override
  AnimatedFocusLightState createState() => pulseEnable
      ? AnimatedPulseFocusLightState()
      : AnimatedStaticFocusLightState();
}

abstract class AnimatedFocusLightState extends State<AnimatedFocusLight>
    with TickerProviderStateMixin {
  final borderRadiusDefault = 10.0;
  final defaultFocusAnimationDuration = Duration(milliseconds: 600);
  late AnimationController _controller;
  late CurvedAnimation _curvedAnimation;

  late TargetFocus _targetFocus;
  Offset _positioned = Offset(0.0, 0.0);
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

    WidgetsBinding.instance?.addPostFrameCallback((_) => _runFocus());
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

  void _runFocus();

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
    setState(() => _currentFocus = 0);
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
              Container(
                width: double.maxFinite,
                height: double.maxFinite,
                child: CustomPaint(
                  painter: _getPainter(_targetFocus),
                ),
              ),
              Positioned(
                left:
                    (_targetPosition?.offset.dx ?? 0) - _getPaddingFocus() * 2,
                top: (_targetPosition?.offset.dy ?? 0) - _getPaddingFocus() * 2,
                child: InkWell(
                  borderRadius: _betBorderRadiusTarget(),
                  onTap: _targetFocus.enableTargetTab
                      ? () => _tapHandler(targetTap: true)
                      : null,
                  child: Container(
                    color: Colors.transparent,
                    width: (_targetPosition?.size.width ?? 0) +
                        _getPaddingFocus() * 4,
                    height: (_targetPosition?.size.height ?? 0) +
                        _getPaddingFocus() * 4,
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
    setState(() => _goNext = goNext);
    _controller.reverse();
  }

  @override
  void _runFocus() {
    if (_currentFocus < 0) return;
    _targetFocus = widget.targets[_currentFocus];

    _controller.duration = _targetFocus.focusAnimationDuration ??
        widget.focusAnimationDuration ??
        defaultFocusAnimationDuration;

    var targetPosition = getTargetCurrent(_targetFocus);

    if (targetPosition == null) {
      _finish();
      return;
    }

    setState(() {
      _targetPosition = targetPosition;

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
  final defaultPulseAnimationDuration = Duration(milliseconds: 500);
  final defaultPulseVariation = Tween(begin: 1.0, end: 0.99);
  late AnimationController _controllerPulse;
  late Animation _tweenPulse;

  bool _finishFocus = false;
  bool _initReverse = false;

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
                  Container(
                    width: double.maxFinite,
                    height: double.maxFinite,
                    child: CustomPaint(
                      painter: _getPainter(_targetFocus),
                    ),
                  ),
                  Positioned(
                    left: (_targetPosition?.offset.dx ?? 0) -
                        _getPaddingFocus() * 2,
                    top: (_targetPosition?.offset.dy ?? 0) -
                        _getPaddingFocus() * 2,
                    child: InkWell(
                      borderRadius: _betBorderRadiusTarget(),
                      onTap: _targetFocus.enableTargetTab
                          ? () => _tapHandler(targetTap: true)
                          : null,
                      child: Container(
                        color: Colors.transparent,
                        width: (_targetPosition?.size.width ?? 0) +
                            _getPaddingFocus() * 4,
                        height: (_targetPosition?.size.height ?? 0) +
                            _getPaddingFocus() * 4,
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
    if (_currentFocus < 0) return;
    _targetFocus = widget.targets[_currentFocus];

    _controller.duration = _targetFocus.focusAnimationDuration ??
        widget.focusAnimationDuration ??
        defaultFocusAnimationDuration;

    _tweenPulse = _createTweenAnimation(_targetFocus.pulseVariation ??
        widget.pulseVariation ??
        defaultPulseVariation);

    var targetPosition = getTargetCurrent(_targetFocus);

    if (targetPosition == null) {
      _finish();
      return;
    }

    setState(() {
      _finishFocus = false;
      _targetPosition = targetPosition;

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
    setState(() {
      _goNext = goNext;
      _initReverse = true;
    });
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
      setState(() => _finishFocus = true);

      widget.focus?.call(_targetFocus);

      _controllerPulse.forward();
    }
    if (status == AnimationStatus.dismissed) {
      setState(() {
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
        setState(() => _finishFocus = false);
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
