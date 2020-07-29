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
  final Function removeFocus;
  final Function() finish;
  final double paddingFocus;
  final Color colorShadow;
  final double opacityShadow;

  const AnimatedFocusLight({
    Key key,
    this.targets,
    this.focus,
    this.finish,
    this.removeFocus,
    this.clickTarget,
    this.paddingFocus = 10,
    this.colorShadow = Colors.black,
    this.opacityShadow = 0.8,
  }) : super(key: key);

  @override
  AnimatedFocusLightState createState() => AnimatedFocusLightState();
}

class AnimatedFocusLightState extends State<AnimatedFocusLight>
    with TickerProviderStateMixin {
  AnimationController _controller;
  AnimationController _controllerPulse;
  CurvedAnimation _curvedAnimation;
  Animation tweenPulse;
  Offset positioned = Offset(0.0, 0.0);
  TargetPosition targetPosition;

  double sizeCircle = 100;
  int currentFocus = 0;
  bool finishFocus = false;
  bool initReverse = false;
  double progressAnimated = 0;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );

    _curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.ease,
    );

    _controllerPulse = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    tweenPulse = Tween(begin: 1.0, end: 0.99).animate(
      CurvedAnimation(
        parent: _controllerPulse,
        curve: Curves.ease,
      ),
    );

    _controller..addStatusListener(_listener);
    _controllerPulse.addStatusListener(_listenerPulse);

    WidgetsBinding.instance.addPostFrameCallback((_) => _runFocus());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, child) {
        progressAnimated = _curvedAnimation.value;
        return AnimatedBuilder(
          animation: _controllerPulse,
          builder: (_, child) {
            TargetFocus target = widget?.targets[currentFocus];

            if (finishFocus) {
              progressAnimated = tweenPulse.value;
            }
            return Stack(
              children: <Widget>[
                Container(
                  width: double.maxFinite,
                  height: double.maxFinite,
                  child: CustomPaint(
                    painter: _getPainter(target),
                  ),
                ),
                Positioned(
                  left: (targetPosition?.offset?.dx ?? 0) - 10,
                  top: (targetPosition?.offset?.dy ?? 0) - 10,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(5),
                    onTap: tapHandler,
                    child: Container(
                      color: Colors.transparent,
                      width: (targetPosition?.size?.width ?? 0) + 20,
                      height: (targetPosition?.size?.height ?? 0) + 20,
                    ),
                  ),
                )
              ],
            );
          },
        );
      },
    );
  }

  void tapHandler() {
    setState(() {
      initReverse = true;
    });
    _controllerPulse.reverse(from: _controllerPulse.value);
    widget?.clickTarget(widget.targets[currentFocus]);
  }

  void _nextFocus() {
    if (currentFocus >= widget.targets.length - 1) {
      this._finish();
      return;
    }
    currentFocus++;
    _runFocus();
  }

  void _runFocus() {
    var targetPosition = getTargetCurrent(widget.targets[currentFocus]);
    if (targetPosition == null) {
      this._finish();
      return;
    }

    setState(() {
      finishFocus = false;
      this.targetPosition = targetPosition;

      positioned = Offset(
        targetPosition.offset.dx + (targetPosition.size.width / 2),
        targetPosition.offset.dy + (targetPosition.size.height / 2),
      );

      if (targetPosition.size.height > targetPosition.size.width) {
        sizeCircle = targetPosition.size.height * 0.6 + widget.paddingFocus;
      } else {
        sizeCircle = targetPosition.size.width * 0.6 + widget.paddingFocus;
      }
    });

    _controller.forward();
  }

  void _finish() {
    setState(() {
      currentFocus = 0;
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
      if (initReverse) {
        setState(() {
          finishFocus = false;
        });
        _controller.reverse();
      } else if (finishFocus) {
        _controllerPulse.forward();
      }
    }
  }

  void _listener(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      setState(() {
        finishFocus = true;
      });
      widget?.focus(widget.targets[currentFocus]);

      _controllerPulse.forward();
    }
    if (status == AnimationStatus.dismissed) {
      setState(() {
        finishFocus = false;
        initReverse = false;
      });
      _nextFocus();
    }

    if (status == AnimationStatus.reverse) {
      widget?.removeFocus();
    }
  }

  CustomPainter _getPainter(TargetFocus target) {
    if (target?.shape == ShapeLightFocus.RRect) {
      return LightPaintRect(
        colorShadow: target?.color ?? widget.colorShadow,
        progress: progressAnimated,
        offset: widget.paddingFocus,
        target: targetPosition,
        radius: target?.radius ?? 0,
        opacityShadow: widget.opacityShadow,
      );
    } else {
      return LightPaint(
        progressAnimated,
        positioned,
        sizeCircle,
        colorShadow: target?.color ?? widget.colorShadow,
        opacityShadow: widget.opacityShadow,
      );
    }
  }
}
