class CustomTargetPosition {
  CustomTargetPosition({
    this.top,
    this.left,
    this.bottom,
  });
  final double top, left, bottom;
  @override
  String toString() {
    return 'CustomTargetPosition{top: $top, left: $left, bottom: $bottom}';
  }
}
