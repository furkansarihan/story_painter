import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/parser.dart';

import '../story_painter.dart';
import 'utils.dart';

class StoryPainter extends StatelessWidget {
  final StoryPainterControl control;

  StoryPainter({Key? key, required this.control}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: control.painterKey,
      child: Stack(
        children: [
          StoryPainterPaint(
            control: control,
            onSize: control.notifyDimension,
          ),
          GestureDetector(
            onLongPressStart: (args) => control.startPath(args.localPosition),
            onLongPressEnd: (args) => control.closePath(),
            onLongPressMoveUpdate: (args) =>
                control.alterPath(args.localPosition),
            onTapUp: (args) => control.closePath(),
            //onTapCancel: () => control.closePath(),
            onTapDown: (args) => control.startPath(args.localPosition),
            onScaleStart: (args) => control.startPath(args.localFocalPoint),
            onScaleUpdate: (args) => control.alterPath(args.localFocalPoint),
            onScaleEnd: (args) => control.closePath(),
          ),
        ],
      ),
    );
  }
}

class StoryPainterView extends StatelessWidget {
  final Drawable? data;
  final Color? color;
  final double Function(double? width)? strokeWidth;
  final EdgeInsets? padding;
  final Widget? placeholder;

  const StoryPainterView({
    Key? key,
    required this.data,
    this.color,
    this.strokeWidth,
    this.padding,
    this.placeholder,
  }) : super(key: key);

  static _StoryPainterViewSvg svg({
    Key? key,
    required String data,
    Color? color,
    double Function(double? width)? strokeWidth,
    EdgeInsets? padding,
    Widget? placeholder,
  }) =>
      _StoryPainterViewSvg(
        key: key,
        data: data,
        color: color,
        strokeWidth: strokeWidth,
        padding: padding,
        placeholder: placeholder,
      );

  @override
  Widget build(BuildContext context) {
    if (data == null) {
      return placeholder ?? Container(color: Colors.transparent);
    }

    return Padding(
      padding: padding ?? EdgeInsets.all(8.0),
      child: FittedBox(
        fit: BoxFit.contain,
        alignment: Alignment.center,
        child: SizedBox.fromSize(
          size: PathUtil.getDrawableSize(data as DrawableRoot),
          child: CustomPaint(
            painter: DrawableSignaturePainter(
              drawable: data as DrawableParent,
              color: color,
              strokeWidth: strokeWidth,
            ),
          ),
        ),
      ),
    );
  }
}

class _StoryPainterViewSvg extends StatefulWidget {
  final String data;
  final Color? color;
  final double Function(double? width)? strokeWidth;
  final EdgeInsets? padding;
  final Widget? placeholder;

  const _StoryPainterViewSvg({
    Key? key,
    required this.data,
    this.color,
    this.strokeWidth,
    this.padding,
    this.placeholder,
  }) : super(key: key);

  @override
  _StoryPainterViewSvgState createState() => _StoryPainterViewSvgState();
}

class _StoryPainterViewSvgState extends State<_StoryPainterViewSvg> {
  DrawableParent? drawable;

  @override
  void initState() {
    super.initState();

    _parseData(widget.data);
  }

  void _parseData(String data) async {
    if (data == null) {
      drawable = null;
    } else {
      final parser = SvgParser();
      drawable = await parser.parse(data);
    }

    setState(() {});
  }

  @override
  void didUpdateWidget(_StoryPainterViewSvg oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.data != widget.data) {
      if (drawable != null) {
        setState(() {
          drawable = null;
        });
      }

      _parseData(widget.data);
    }
  }

  @override
  Widget build(BuildContext context) => StoryPainterView(
        data: drawable,
        color: widget.color,
        strokeWidth: widget.strokeWidth,
        padding: widget.padding,
        placeholder: widget.placeholder,
      );
}

class _SinglePanGestureRecognizer extends PanGestureRecognizer {
  _SinglePanGestureRecognizer({Object? debugOwner})
      : super(debugOwner: debugOwner);

  bool isDown = false;

  @override
  void addAllowedPointer(PointerEvent event) {
    if (isDown) {
      return;
    }

    isDown = true;
    super.addAllowedPointer(event as PointerDownEvent);
  }

  @override
  void handleEvent(PointerEvent event) {
    super.handleEvent(event);

    if (!event.down) {
      isDown = false;
    }
  }
}
