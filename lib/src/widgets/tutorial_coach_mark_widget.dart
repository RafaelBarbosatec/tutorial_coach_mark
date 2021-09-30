import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/src/target/target_content.dart';
import 'package:tutorial_coach_mark/src/target/target_focus.dart';
import 'package:tutorial_coach_mark/src/util.dart';
import 'package:tutorial_coach_mark/src/widgets/animated_focus_light.dart';

class TutorialCoachMarkWidget extends StatefulWidget {
  const TutorialCoachMarkWidget({
    Key? key,
    required this.targets,
    this.finish,
    this.paddingFocus = 10,
    this.clickTarget,
    this.clickOverlay,
    this.alignSkip = Alignment.bottomRight,
    this.textSkip = "SKIP",
    this.onClickSkip,
    this.colorShadow = Colors.black,
    this.opacityShadow = 0.8,
    this.textStyleSkip = const TextStyle(color: Colors.white),
    this.hideSkip,
    this.focusAnimationDuration,
    this.pulseAnimationDuration,
    this.pulseVariation,
    this.skipWidget,
  })  : assert(targets.length > 0),
        super(key: key);

  final List<TargetFocus> targets;
  final Function(TargetFocus)? clickTarget;
  final Function(TargetFocus)? clickOverlay;
  final Function()? finish;
  final Color colorShadow;
  final double opacityShadow;
  final double paddingFocus;
  final Function()? onClickSkip;
  final AlignmentGeometry alignSkip;
  final String textSkip;
  final TextStyle textStyleSkip;
  final bool? hideSkip;
  final Duration? focusAnimationDuration;
  final Duration? pulseAnimationDuration;
  final Tween<double>? pulseVariation;
  final Widget? skipWidget;

  @override
  TutorialCoachMarkWidgetState createState() => TutorialCoachMarkWidgetState();
}

class TutorialCoachMarkWidgetState extends State<TutorialCoachMarkWidget>
    implements TutorialCoachMarkController {
  final GlobalKey<AnimatedFocusLightState> _focusLightKey = GlobalKey();
  bool showContent = false;
  TargetFocus? currentTarget;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: <Widget>[
          AnimatedFocusLight(
            key: _focusLightKey,
            targets: widget.targets,
            finish: widget.finish,
            paddingFocus: widget.paddingFocus,
            colorShadow: widget.colorShadow,
            opacityShadow: widget.opacityShadow,
            focusAnimationDuration: widget.focusAnimationDuration,
            pulseAnimationDuration: widget.pulseAnimationDuration,
            pulseVariation: widget.pulseVariation,
            clickTarget: (target) {
              widget.clickTarget?.call(target);
            },
            clickOverlay: (target) {
              widget.clickOverlay?.call(target);
            },
            focus: (target) {
              setState(() {
                currentTarget = target;
                showContent = true;
              });
            },
            removeFocus: () {
              setState(() {
                showContent = false;
              });
            },
          ),
          AnimatedOpacity(
            opacity: showContent ? 1 : 0,
            duration: Duration(milliseconds: 300),
            child: _buildContents(),
          ),
          _buildSkip()
        ],
      ),
    );
  }

  Widget _buildContents() {
    if (currentTarget == null) {
      return SizedBox.shrink();
    }

    List<Widget> children = <Widget>[];

    final target = getTargetCurrent(currentTarget!);
    if (target == null) {
      return SizedBox.shrink();
    }

    var positioned = Offset(
      target.offset.dx + target.size.width / 2,
      target.offset.dy + target.size.height / 2,
    );

    double haloWidth;
    double haloHeight;

    if (currentTarget!.shape == ShapeLightFocus.Circle) {
      haloWidth = target.size.width > target.size.height
          ? target.size.width
          : target.size.height;
      haloHeight = haloWidth;
    } else {
      haloWidth = target.size.width;
      haloHeight = target.size.height;
    }

    haloWidth = haloWidth * 0.6 + widget.paddingFocus;
    haloHeight = haloHeight * 0.6 + widget.paddingFocus;

    double weight = 0.0;
    double? top;
    double? bottom;
    double? left;

    children = currentTarget!.contents!.map<Widget>((i) {
      switch (i.align) {
        case ContentAlign.bottom:
          {
            weight = MediaQuery.of(context).size.width;
            left = 0;
            top = positioned.dy + haloHeight;
            bottom = null;
          }
          break;
        case ContentAlign.top:
          {
            weight = MediaQuery.of(context).size.width;
            left = 0;
            top = null;
            bottom = haloHeight +
                (MediaQuery.of(context).size.height - positioned.dy);
          }
          break;
        case ContentAlign.left:
          {
            weight = positioned.dx - haloWidth;
            left = 0;
            top = positioned.dy - target.size.height / 2 - haloHeight;
            bottom = null;
          }
          break;
        case ContentAlign.right:
          {
            left = positioned.dx + haloWidth;
            top = positioned.dy - target.size.height / 2 - haloHeight;
            bottom = null;
            weight = MediaQuery.of(context).size.width - left!;
          }
          break;
        case ContentAlign.custom:
          {
            left = i.customPosition!.left;
            top = i.customPosition!.top;
            bottom = i.customPosition!.bottom;
            weight = MediaQuery.of(context).size.width;
          }
          break;
      }

      return Positioned(
        top: top,
        bottom: bottom,
        left: left,
        child: Container(
          width: weight,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: i.builder != null
                ? i.builder?.call(context, this)
                : (i.child ?? SizedBox.shrink()),
          ),
        ),
      );
    }).toList();

    return Stack(
      children: children,
    );
  }

  Widget _buildSkip() {
    if (widget.hideSkip!) {
      return SizedBox.shrink();
    }
    return Align(
      alignment: currentTarget?.alignSkip ?? widget.alignSkip,
      child: SafeArea(
        child: AnimatedOpacity(
          opacity: showContent ? 1 : 0,
          duration: Duration(milliseconds: 300),
          child: InkWell(
            onTap: skip,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: IgnorePointer(
                child: widget.skipWidget ??
                    Text(
                      widget.textSkip,
                      style: widget.textStyleSkip,
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void skip() => widget.onClickSkip?.call();

  void next() => _focusLightKey.currentState?.next();

  void previous() => _focusLightKey.currentState?.previous();
}
