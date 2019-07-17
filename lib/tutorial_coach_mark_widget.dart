import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/animated_focus_light.dart';
import 'package:tutorial_coach_mark/content_target.dart';
import 'package:tutorial_coach_mark/target_focus.dart';
import 'package:tutorial_coach_mark/target_position.dart';
import 'package:tutorial_coach_mark/util.dart';

class TutorialCoachMarkWidget extends StatefulWidget {
  final List<TargetFocus> targets;
  final Function(TargetFocus) clickTarget;
  final Function() finish;
  final Color colorShadow;
  final double opacityShadow;
  final double paddingFocus;
  final Function() clickSkip;
  final AlignmentGeometry alignSkip;
  final String textSkip;
  const TutorialCoachMarkWidget(
      {Key key,
        this.targets,
        this.finish,
        this.paddingFocus = 10,
        this.clickTarget,
        this.alignSkip = Alignment.bottomRight,
        this.textSkip = "SKIP",
        this.clickSkip,
        this.colorShadow = Colors.black,
        this.opacityShadow = 0.8})
      : super(key: key);

  @override
  _TutorialCoachMarkWidgetState createState() =>
      _TutorialCoachMarkWidgetState();
}

class _TutorialCoachMarkWidgetState extends State<TutorialCoachMarkWidget> {
  StreamController _controllerFade = StreamController<double>.broadcast();
  StreamController _controllerTapChild = StreamController<void>.broadcast();

  TargetFocus currentTarget;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: <Widget>[
          AnimatedFocusLight(
            targets: widget.targets,
            finish: widget.finish,
            paddingFocus: widget.paddingFocus,
            colorShadow: widget.colorShadow,
            opacityShadow: widget.opacityShadow,
            clickTarget: (target) {
              if (widget.clickTarget != null) widget.clickTarget(target);
            },
            focus: (target) {
              currentTarget = target;
              _controllerFade.sink.add(1.0);
            },
            removeFocus: () {
              _controllerFade.sink.add(0.0);
            },
            streamTap: _controllerTapChild.stream,
          ),
          _buildContents(),
          _buildSkip()
        ],
      ),
    );
  }

  _buildContents() {
    return StreamBuilder(
      stream: _controllerFade.stream,
      initialData: 0.0,
      builder: (_, snapshot) {
        try {
          return AnimatedOpacity(
            opacity: snapshot.data,
            duration: Duration(milliseconds: 300),
            child: _buildPositionedsContents(),
          );
        } catch (err) {
          return Container();
        }
      },
    );
  }

  _buildPositionedsContents() {
    if (currentTarget == null) {
      return Container();
    }

    List<Widget> widgtes = List();

    TargetPosition target = getTargetCurrent(currentTarget);
    var positioned = Offset(target.offset.dx + target.size.width / 2,
        target.offset.dy + target.size.height / 2);
    double haloWidth;
    double haloHeight;
    if (currentTarget.shape == ShapeLightFocus.Circle) {
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

    double top;
    double bottom;
    double left;

    widgtes = currentTarget.contents.map<Widget>((i) {
      switch (i.align) {
        case AlignContent.bottom:
          {
            weight = MediaQuery.of(context).size.width;
            left = 0;
            top = positioned.dy + haloHeight;
            bottom = null;
          }
          break;
        case AlignContent.top:
          {
            weight = MediaQuery.of(context).size.width;
            left = 0;
            top = null;
            bottom = haloHeight +
                (MediaQuery.of(context).size.height - positioned.dy);
          }
          break;
        case AlignContent.left:
          {
            weight = positioned.dx - haloWidth;
            left = 0;
            top = positioned.dy - target.size.height / 2 - haloHeight;
            bottom = null;
          }
          break;
        case AlignContent.right:
          {
            left = positioned.dx + haloWidth;
            top = positioned.dy - target.size.height / 2 - haloHeight;
            bottom = null;
            weight = MediaQuery.of(context).size.width - left;
          }
          break;
      }

      return Positioned(
        top: top,
        bottom: bottom,
        left: left,
        child: GestureDetector(
          onTap: () {
            _controllerTapChild.add(null);
          },
          child: Container(
            width: weight,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: i.child,
            ),
          ),
        ),
      );
    }).toList();

    return Stack(
      children: widgtes,
    );
  }

  _buildSkip() {
    return Align(
      alignment: widget.alignSkip,
      child: StreamBuilder(
        stream: _controllerFade.stream,
        initialData: 0.0,
        builder: (_, snapshot) {
          return AnimatedOpacity(
            opacity: snapshot.data,
            duration: Duration(milliseconds: 300),
            child: InkWell(
              onTap: () {
                widget.finish();
                if (widget.clickSkip != null) {
                  widget.clickSkip();
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  widget.textSkip,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controllerFade.close();
    super.dispose();
  }
}
