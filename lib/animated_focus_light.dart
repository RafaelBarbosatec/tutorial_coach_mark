import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tutorial_coach_mark/light_paint.dart';
import 'package:tutorial_coach_mark/light_paint_rect.dart';
import 'package:tutorial_coach_mark/target_focus.dart';
import 'package:tutorial_coach_mark/target_position.dart';
import 'package:tutorial_coach_mark/util.dart';

enum ShapeLightFocus { Circle, RRect }

class AnimatedFocusLight extends StatefulWidget {
  final List<TargetFocus> targets;
  final Function(TargetFocus) focus;
  final Function(TargetFocus) clickTarget;
  final Function(TargetFocus) clickOverlay;
  final Function removeFocus;
  final Function() finish;
  final double paddingFocus;
  final Color colorShadow;
  final double opacityShadow;
  final Duration focusAnimationDuration;
  final Duration pulseAnimationDuration;

  const AnimatedFocusLight({
    Key key,
    this.targets,
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
  }) : super(key: key);

  @override
  AnimatedFocusLightState createState() => AnimatedFocusLightState();
}

class AnimatedFocusLightState extends State<AnimatedFocusLight> with TickerProviderStateMixin {
  static const BORDER_RADIUS_DEFAULT = 10.0;
  AnimationController _controller;
  AnimationController _controllerPulse;
  CurvedAnimation _curvedAnimation;
  Animation _tweenPulse;
  Offset _positioned = Offset(0.0, 0.0);
  TargetPosition _targetPosition;

  double _sizeCircle = 100;
  int _currentFocus = 0;
  bool _finishFocus = false;
  bool _initReverse = false;
  double _progressAnimated = 0;
  TargetFocus _targetFocus;

  bool _goNext = true;

  @override
  void initState() {
    _targetFocus = widget?.targets[_currentFocus];
    _controller = AnimationController(
      vsync: this,
      duration: widget.focusAnimationDuration ?? Duration(milliseconds: 600),
    );

    _curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.ease,
    );

    _controllerPulse = AnimationController(
      vsync: this,
      duration: widget.pulseAnimationDuration ?? Duration(milliseconds: 500),
    );

    _tweenPulse = Tween(begin: 1.0, end: 0.99).animate(
      CurvedAnimation(
        parent: _controllerPulse,
        curve: Curves.ease,
      ),
    );

    _controller.addStatusListener(_listener);
    _controllerPulse.addStatusListener(_listenerPulse);

    WidgetsBinding.instance.addPostFrameCallback((_) => _runFocus());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _targetFocus.enableOverlayTab ? () => _tapHandler(overlayTap: true) : null,
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
                    left: (_targetPosition?.offset?.dx ?? 0) - _getPaddingFocus() * 2,
                    top: (_targetPosition?.offset?.dy ?? 0) - _getPaddingFocus() * 2,
                    child: InkWell(
                      borderRadius: _betBorderRadiusTarget(),
                      onTap: _targetFocus.enableTargetTab ? () => _tapHandler(targetTap: true) : null,
                      child: Container(
                        color: Colors.transparent,
                        width: (_targetPosition?.size?.width ?? 0) + _getPaddingFocus() * 4,
                        height: (_targetPosition?.size?.height ?? 0) + _getPaddingFocus() * 4,
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

  void next() => _tapHandler();
  void previous() => _tapHandler(goNext: false);

  void _tapHandler({bool goNext = true, bool targetTap = false, bool overlayTap = false}) {
    setState(() {
      _goNext = goNext;
      _initReverse = true;
    });
    _controllerPulse.reverse(from: _controllerPulse.value);
    if (targetTap) {
      widget?.clickTarget(_targetFocus);
    }
    if (overlayTap) {
      widget?.clickOverlay(_targetFocus);
    }
  }

  void _nextFocus() {
    if (_currentFocus >= widget.targets.length - 1) {
      this._finish();
      return;
    }
    _currentFocus++;
    _runFocus();
  }

  void _previousFocus() {
    if (_currentFocus <= 0) {
      this._finish();
      return;
    }
    _currentFocus--;
    _runFocus();
  }

  void _runFocus() {
    if (_currentFocus < 0) return;
    _targetFocus = widget.targets[_currentFocus];
    var targetPosition = getTargetCurrent(_targetFocus);
    if (targetPosition == null) {
      this._finish();
      return;
    }

    setState(() {
      _finishFocus = false;
      this._targetPosition = targetPosition;

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

  void _finish() {
    setState(() {
      _currentFocus = 0;
    });
    widget.finish();
  }

  @override
  void dispose() {
    _controllerPulse.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _listenerPulse(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _controllerPulse.reverse();
    }

    if (status == AnimationStatus.dismissed) {
      if (_initReverse) {
        setState(() {
          _finishFocus = false;
        });
        _controller.reverse();
      } else if (_finishFocus) {
        _controllerPulse.forward();
      }
    }
  }

  void _listener(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      setState(() {
        _finishFocus = true;
      });
      widget?.focus(_targetFocus);

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
      widget?.removeFocus();
    }
  }

  CustomPainter _getPainter(TargetFocus target) {
    if (target?.shape == ShapeLightFocus.RRect) {
      return LightPaintRect(
        colorShadow: target?.color ?? widget.colorShadow,
        progress: _progressAnimated,
        offset: _getPaddingFocus(),
        target: _targetPosition ?? TargetPosition(Size.zero, Offset.zero),
        radius: target?.radius ?? 0,
        opacityShadow: widget.opacityShadow,
      );
    } else {
      return LightPaint(
        _progressAnimated,
        _positioned,
        _sizeCircle,
        colorShadow: target?.color ?? widget.colorShadow,
        opacityShadow: widget.opacityShadow,
      );
    }
  }

  double _getPaddingFocus() {
    return _targetFocus?.paddingFocus ?? (widget.paddingFocus ?? 10);
  }

  BorderRadius _betBorderRadiusTarget() {
    double radius = _targetFocus?.shape == ShapeLightFocus.Circle
        ? (_targetPosition?.size?.width ?? BORDER_RADIUS_DEFAULT)
        : _targetFocus?.radius ?? BORDER_RADIUS_DEFAULT;
    return BorderRadius.circular(radius);
  }
}
