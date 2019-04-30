
import 'package:flutter/widgets.dart';

enum AlignContent{
  top,
  bottom,
  left,
  right
}

class ContentTarget{

  final AlignContent align;
  final Widget child;

  ContentTarget(
      {
        this.align = AlignContent.bottom,
        this.child
      }):assert(child != null);

  @override
  String toString() {
    return 'ContentTarget{align: $align, child: $child}';
  }


}