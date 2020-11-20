import 'package:flutter/material.dart';

import '../story_painter.dart';

class StoryPainterPaint extends StatefulWidget {
  final StoryPainterControl control;
  final bool Function(Size size) onSize;

  const StoryPainterPaint({
    Key key,
    this.control,
    this.onSize,
  }) : super(key: key);

  @override
  StoryPainterPaintState createState() => StoryPainterPaintState();
}

class StoryPainterPaintState extends State<StoryPainterPaint> {
  List<SinglePath> pathWidgets = List<SinglePath>();
  @override
  void initState() {
    super.initState();
    widget.control.paths.forEach((_path) {
      pathWidgets.add(SinglePath(
        path: _path,
        onSize: widget.onSize,
        type: _path.type,
      ));
    });
    widget.control.pageState = this;
  }

  void add() {
    pathWidgets.add(
      SinglePath(
        key: ObjectKey(widget.control.paths.last.id),
        path: widget.control.paths.last,
        onSize: widget.onSize,
        type: widget.control.type,
      ),
    );
    refreshState();
  }

  void update() {
    pathWidgets.last?.path?.pathState?.refreshState();
  }

  void remove() {
    pathWidgets.removeLast();
    refreshState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: pathWidgets,
    );
  }

  void refreshState() {
    if (this.mounted) {
      setState(() {});
    }
  }
}

class SinglePath extends StatefulWidget {
  final CubicPath path;
  final PainterDrawType type;
  final bool Function(Size size) onSize;

  const SinglePath({Key key, this.type, this.onSize, this.path})
      : super(key: key);

  @override
  SinglePathState createState() => SinglePathState();
}

class SinglePathState extends State<SinglePath> {
  @override
  void initState() {
    super.initState();
    widget.path.pathState = this;
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        isComplex: true,
        willChange: false,
        painter: PathSignaturePainter(
          path: widget.path,
          onSize: widget.onSize,
        ),
      ),
    );
  }

  void refreshState() {
    if (this.mounted) {
      setState(() {});
    }
  }
}
