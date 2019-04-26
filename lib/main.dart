import 'dart:math';

import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin{

  List<TargetFocus> targets = List();

  AnimationController _controller;
  AnimationController _controllerPulse;
  CurvedAnimation _curvedAnimation;
  Animation tweenPulse ;

  double paddingFocus = 10;

  GlobalKey keyButton = GlobalKey();
  GlobalKey keyButton2 = GlobalKey();
  GlobalKey keyButton3 = GlobalKey();
  GlobalKey keyButton4 = GlobalKey();
  GlobalKey keyButton5 = GlobalKey();

  List<GlobalKey> keys = List();

  Offset positioned = Offset(0.0, 0.0);
  double sizeCircle = 100;
  int currentKey = -1;
  double progressAnimated = 0;
  bool finishFocus = false;
  bool init = false;
  bool initReverse = false;

  double _opacityContent = 0.0;

  @override
  void initState() {

    targets.add(
      TargetFocus(
        keyTarget: keyButton,
        contents: [
          ContentTarget(
            align: AlignContent.bottom,
            child: Container(
              child:Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin pulvinar tortor eget maximus iaculis.",
              style: TextStyle(
                color: Colors.white
              ),),
            )
          )
        ]
      )
    );

    targets.add(
        TargetFocus(
            keyTarget: keyButton4,
            contents: [
              ContentTarget(
                  align: AlignContent.left,
                  child: Container(
                    child: Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin pulvinar tortor eget maximus iaculis.",
                      style: TextStyle(
                          color: Colors.white
                      ),),
                  )
              )
            ]
        )
    );

    targets.add(
        TargetFocus(
            keyTarget: keyButton5,
            contents: [
              ContentTarget(
                  align: AlignContent.right,
                  child: Container(
                    child: Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin pulvinar tortor eget maximus iaculis.",
                      style: TextStyle(
                          color: Colors.white
                      ),),
                  )
              )
            ]
        )
    );

    targets.add(
        TargetFocus(
            keyTarget: keyButton3,
            contents: [
              ContentTarget(
                  align: AlignContent.top,
                  child: Container(
                    child: Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin pulvinar tortor eget maximus iaculis.",
                      style: TextStyle(
                          color: Colors.white
                      ),),
                  )
              )
            ]
        )
    );



    _controller = AnimationController(vsync: this,duration: Duration(milliseconds: 600));
    _controller..addStatusListener((status){
      if(status == AnimationStatus.completed){
        setState(() {
          finishFocus = true;
        });
        _showContent(true);
        _controllerPulse.forward();
      }
      if(status == AnimationStatus.dismissed){
        setState(() {
          finishFocus = false;
          initReverse = false;
        });
        _nextFocus();
      }

      if(status == AnimationStatus.reverse){
        _showContent(false);
      }
    });

    _curvedAnimation = CurvedAnimation(parent: _controller, curve: Curves.ease);


    _controllerPulse = AnimationController(vsync: this,duration: Duration(milliseconds: 500));
    _controllerPulse.addStatusListener((status){

      if(status == AnimationStatus.completed){
        _controllerPulse.reverse();
      }

      if(status == AnimationStatus.dismissed){
        if(initReverse){
          setState(() {
            finishFocus = false;
          });
          _controller.reverse();
        }else if(finishFocus) {
          _controllerPulse.forward();
        }
      }
    });
    tweenPulse = Tween(begin: 1.0,end: 0.99).animate(CurvedAnimation(parent: _controllerPulse, curve: Curves.ease));
    //WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Container(
        color: Colors.cyan,
        child: InkWell(
          onTap: (){
            if(!init){
              setState(() {
                init = true;
              });
              _nextFocus();
            }else if(finishFocus){
              setState(() {
                initReverse = true;
              });
            }
          },
          child: Stack(
            children: <Widget>[
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.all(50.0),
                  child: SizedBox(
                    width: 50,
                    height: 50,
                    child: RaisedButton(
                      key: keyButton,
                      onPressed: (){
                    },),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: 50,
                  height: 50,
                  child: RaisedButton(
                    key: keyButton2,
                    onPressed: (){

                    },),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(50.0),
                  child: SizedBox(
                    width: 50,
                    height: 50,
                    child: RaisedButton(
                      key: keyButton3,
                      onPressed: (){

                      },),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.all(50.0),
                  child: SizedBox(
                    width: 50,
                    height: 50,
                    child: RaisedButton(
                      key: keyButton4,
                      onPressed: (){

                      },),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.all(50.0),
                  child: SizedBox(
                    width: 50,
                    height: 50,
                    child: RaisedButton(
                      key: keyButton5,
                      onPressed: (){

                      },),
                  ),
                ),
              ),
              AnimatedBuilder(
                  animation: _controller,
                  builder: (_,chuild){
                    progressAnimated = _curvedAnimation.value;
                    return AnimatedBuilder(
                      animation: _controllerPulse,
                      builder: (_,child){
                        if(finishFocus) {
                          progressAnimated = tweenPulse.value;
                        }
                        return Container(
                          width: double.maxFinite,
                          height: double.maxFinite,
                          child: CustomPaint(
                              painter: MyCustomPaint(
                                  progressAnimated,
                                  positioned,
                                  sizeCircle: sizeCircle
                              )),
                        );
                      },
                    );
                  }
              ),
              _buildContent()
            ],
          ),
          ),
        ),
    );
  }

  void _nextFocus() {

    currentKey++;

    if(currentKey > targets.length -1){

      setState(() {
        currentKey = -1;
        init = false;
      });

      return;

    }

    TargetPosition target = _getTargetCurrent();


    setState(() {

      finishFocus = false;

      positioned = Offset(target.offset.dx + (target.size.width /2), target.offset.dy + (target.size.height /2));

      if(target.size.height > target.size.width){
        sizeCircle = target.size.height * 0.6 + paddingFocus;
      }else{
        sizeCircle = target.size.width * 0.6 + paddingFocus;
      }

    });

    _controller.forward();

  }

  @override
  void dispose() {
    _controllerPulse.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _showContent(bool show) {
    setState(() {
      if(show){
        _opacityContent = 1.0;
      }else{
        _opacityContent = 0.0;
      }
    });
  }

  Widget _buildContent() {


    List<Widget> widgtes = List();

    if(currentKey > -1){

      TargetPosition target = _getTargetCurrent();
      double weight = 0.0;

      widgtes = targets[currentKey].contents.map<Widget>((i){
        Alignment align;

        switch(i.align){
          case AlignContent.bottom:{
            align = Alignment(0, positioned.dy + sizeCircle);
            weight = MediaQuery.of(context).size.width;
          }break;
          case AlignContent.top:{
            align = Alignment(0, sizeCircle + (MediaQuery.of(context).size.height - positioned.dy));
            weight = MediaQuery.of(context).size.width;
          } break;
          case AlignContent.left:{
            align = Alignment(0, positioned.dy - target.size.height);
            weight = positioned.dx - sizeCircle;
          } break;
          case AlignContent.right:{
            align = Alignment(positioned.dx + sizeCircle, positioned.dy - target.size.height);
            weight = MediaQuery.of(context).size.width - align.x;
          } break;
        }

        if(i.align == AlignContent.top){

          return Positioned(
            bottom: align.y,
            left: align.x,
            child: Container(
              width: weight,
              child: AnimatedOpacity(
                opacity: _opacityContent,
                duration: Duration(milliseconds: 300),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: i.child,
                ),
              ),
            ),
          );
        }

        return Positioned(
          top: align.y,
          left: align.x,
          child: Container(
            width: weight,
            child: AnimatedOpacity(
              opacity: _opacityContent,
              duration: Duration(milliseconds: 300),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: i.child,
              ),
            ),
          ),
        );

      }).toList();
    }

    return Container(
      width: double.maxFinite,
      height: double.maxFinite,
      child: Stack(
        children: widgtes,
      ),
    );
  }

  TargetPosition _getTargetCurrent() {

    var target = targets[currentKey];

    if(target.keyTarget != null){

      var key = target.keyTarget;

      try{

        final RenderBox renderBoxRed = key.currentContext.findRenderObject();
        final size = renderBoxRed.size;
        final offset = renderBoxRed.localToGlobal(Offset.zero);

        return TargetPosition(
          size,
          offset
        );

      }catch(e){
        print("ERROR: Não foi possivem oter informações da KEY");
        return null;
      }

    }else{
      return target.targetPosition;
    }
  }

}

class MyCustomPaint extends CustomPainter {

  final double progress;
  final Offset positioned;

  final double sizeCircle;

  MyCustomPaint(this.progress, this.positioned, {this.sizeCircle = 100});

  @override
  void paint(Canvas canvas, Size size) {

    double sizeFocus = (size.height * 1.4) * (1-progress) + sizeCircle;

    Paint paintFocus = Paint()
    ..color = Colors.transparent
      ..blendMode = BlendMode.clear;

    canvas.saveLayer(Offset.zero & size, Paint());
    canvas.drawColor(Colors.black.withOpacity(0.8), BlendMode.dstATop);

    double radius  = min(sizeFocus,sizeFocus);
    canvas.drawCircle(
        positioned,
        radius,
        paintFocus
    );
    canvas.restore();

  }

  @override
  bool shouldRepaint(MyCustomPaint oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class TargetPosition{
  final Size size;
  final Offset offset;

  TargetPosition(this.size, this.offset);
}

enum AlignContent{
  top,
  bottom,
  left,
  right
}

class ContentTarget{

  final AlignContent align;
  final Widget child;

  ContentTarget({this.align = AlignContent.bottom, this.child}):assert(child != null);
}

class TargetFocus{

  final GlobalKey keyTarget;
  final TargetPosition targetPosition;
  final List<ContentTarget> contents;

  TargetFocus({this.keyTarget, this.targetPosition, this.contents}):assert(keyTarget != null || targetPosition != null);

}
