# TutorialCoachMark

Example 1             |  Example 2
:-------------------------:|:-------------------------:
![](https://github.com/RafaelBarbosatec/tutorial_coach_mark/blob/master/img/exampleTutorialCoachMark.gif)  |  ![](https://github.com/RafaelBarbosatec/tutorial_coach_mark/blob/master/img/example_boleiro.gif)

# Usage
To use this plugin, add `tutorial_coach_mark` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).

### Example

``` dart
import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

void showTutorial() {
    TutorialCoachMark(
      context,
      targets: targets, // List<TargetFocus>
      colorShadow: Colors.red, // DEFAULT Colors.black
       // alignSkip: Alignment.bottomRight,
       // textSkip: "SKIP",
       // paddingFocus: 10,
      finish: (){
        print("finish");
      },
      clickTarget: (target){
        print(target);
      },
      clickSkip: (){
        print("skip");
      }
    )..show();
  }
```
#### WARN: Certifique-se que a sua view foi renderizada antes de chamar 'show' para que a lib possa localizar a posição do widget na tela.

### Creating targets (TargetFocus)

TargetFocus é a classe que representa o widget que será focado e configurar oque será exibido após foca-lo.

Seus atributos:

| Attribute | Type | Description |
| --- | --- | --- |
| `identify` | dynamic | atributo livre para uso de identificação |
| `keyTarget` | GlobalKey | GlobalKey do widget que deseja ser focado |
| `targetPosition` | TargetPosition | Caso não deseje utilizar GlobalKey, você pode criar um TargetPosition para determinar onde focar |
| `contents` | ContentTarget[] | Lista de conteudo que deseja exibir após focar widget |

### Creating contents (ContentTarget)

ContentTarget é a classe responsavel por determinar o que deverar ser exibido e como será exibido após focar widget.

Seus atributos:

| Attribute | Type | Description |
| --- | --- | --- |
| `align` | AlignContent | Com esse atributo você determina em qual região deve exibir o conteudo em relação ao widget focado (top,bottom,left,right) |
| `child` | Widget | Conteudo que deseja ser exibito |

### Example Complete

``` dart
import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

List<TargetFocus> targets = List();

 @override
 void initState() {
    targets.add(
        TargetFocus(
            identify: "Target 1",
            keyTarget: keyButton,
            contents: [
              ContentTarget(
                  align: AlignContent.bottom,
                  child: Container(
                    child:Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "Titulo lorem ipsum",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 20.0
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin pulvinar tortor eget maximus iaculis.",
                            style: TextStyle(
                                color: Colors.white
                            ),),
                        )
                      ],
                    ),
                  )
              )
            ]
        )
    );

    targets.add(
        TargetFocus(
            identify: "Target 2",
            keyTarget: keyButton4,
            contents: [
              ContentTarget(
                  align: AlignContent.left,
                  child: Container(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "Multiples content",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 20.0
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin pulvinar tortor eget maximus iaculis.",
                            style: TextStyle(
                                color: Colors.white
                            ),),
                        )
                      ],
                    ),
                  )
              ),
              ContentTarget(
                  align: AlignContent.top,
                  child: Container(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "Multiples content",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 20.0
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin pulvinar tortor eget maximus iaculis.",
                            style: TextStyle(
                                color: Colors.white
                            ),),
                        )
                      ],
                    ),
                  )
              )
            ]
        )
    );

    targets.add(
        TargetFocus(
            identify: "Target 3",
            keyTarget: keyButton5,
            contents: [
              ContentTarget(
                  align: AlignContent.right,
                  child: Container(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "Title lorem ipsum",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 20.0
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin pulvinar tortor eget maximus iaculis.",
                            style: TextStyle(
                                color: Colors.white
                            ),),
                        )
                      ],
                    ),
                  )
              )
            ]
        )
    );
}

void showTutorial() {
    TutorialCoachMark(
      context,
      targets: targets, // List<TargetFocus>
      colorShadow: Colors.red, // DEFAULT Colors.black
       // alignSkip: Alignment.bottomRight,
       // textSkip: "SKIP",
       // paddingFocus: 10,
      finish: (){
        print("finish");
      },
      clickTarget: (target){
        print(target);
      },
      clickSkip: (){
        print("skip");
      }
    )..show();
  }
```

# Contribution

If you find any errors or want to add improvements, you can open a issue or develop the fix and open a pull request. Thank you for your cooperation!
