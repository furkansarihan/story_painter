import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../story_painter.dart';
import 'utils.dart';

enum PainterDrawType {
  line,
  arc,
  shape,
}

class PathSignaturePainter extends CustomPainter {
  final CubicPath path;
  final bool Function(Size size)? onSize;

  Paint get strokePaint => Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  Paint get fillPaint => Paint()..strokeWidth = 0.0;
  double a = 4;
  double b = 0.2;

  double multiplier() => ((a * pow(1 - b, path.width - 2)) + 1).toDouble();

  double? _maxWidth() {
    if (maxWCache.containsKey(path.width)) {
      return maxWCache[path.width];
    }
    maxWCache[path.width] = path.width * multiplier();
    return maxWCache[path.width];
  }

  PathSignaturePainter({
    required this.path,
    this.onSize,
  }) : assert(path != null);

  @override
  void paint(Canvas canvas, Size size) {
    //TODO: move to widget/state
    if (onSize != null) {
      if (onSize!(size)) {
        return;
      }
    }

    if (path.lines.isEmpty) {
      return;
    }

    switch (path.type) {
      case PainterDrawType.line:
        final paint = strokePaint;

        double _width = path.width;
        canvas.drawPath(
            PathUtil.toLinePath(path.lines),
            paint
              ..color = path.color
              ..strokeWidth = _width);
        break;
      case PainterDrawType.arc:
        final paint = strokePaint;

        double _width = path.width;
        path.arcs.forEach((arc) {
          paint.strokeWidth = _width + (_maxWidth()! - _width) * arc.size;
          canvas.drawPath(
              arc.path,
              paint
                ..color = path.color
                ..strokeWidth = _width);
        });
        break;
      case PainterDrawType.shape:
        final paint = fillPaint;

        double _width = path.width;
        if (path.isFilled) {
          if (path.isDot) {
            canvas.drawCircle(
              path.lines[0].start,
              path.lines[0].startRadius(_width, _maxWidth()!),
              paint..color = path.color,
            );
          } else {
            canvas.drawPath(
              PathUtil.toShapePath(path.lines, _width, _maxWidth()),
              paint..color = path.color,
            );

            final first = path.lines.first;
            final last = path.lines.last;

            canvas.drawCircle(
                first.start,
                first.startRadius(_width, _maxWidth()!),
                paint
                  ..color = path.color
                  ..strokeWidth = path.width);
            canvas.drawCircle(
                last.end,
                last.endRadius(_width, _maxWidth()!),
                paint
                  ..color = path.color
                  ..strokeWidth = path.width);
          }
        }

        break;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class DrawableSignaturePainter extends CustomPainter {
  final DrawableParent drawable;
  final Color? color;
  final double Function(double? width)? strokeWidth;

  DrawableSignaturePainter({
    required this.drawable,
    this.color,
    this.strokeWidth,
  }) : assert(drawable != null);

  @override
  void paint(Canvas canvas, Size size) {
    _draw(
      drawable,
      canvas,
      Paint()
        ..color = color ?? Colors.black
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  void _draw(DrawableParent root, Canvas canvas, Paint paint) {
    if (root.children != null) {
      root.children!.forEach((drawable) {
        if (drawable is DrawableShape) {
          final stroke = drawable.style.stroke;
          final fill = drawable.style.fill;

          if (fill != null && !DrawablePaint.isEmpty(fill)) {
            paint.style = PaintingStyle.fill;
            if (color == null && fill.color != null) {
              paint.color = fill.color!;
            }
          } else if (stroke != null && !DrawablePaint.isEmpty(stroke)) {
            paint.style = PaintingStyle.stroke;

            if (color == null && stroke.color != null) {
              paint.color = stroke.color!;
            }

            if (stroke.strokeWidth != null) {
              if (strokeWidth != null) {
                paint.strokeWidth = strokeWidth!(stroke.strokeWidth);
              } else {
                paint.strokeWidth = stroke.strokeWidth!;
              }
            }
          }

          canvas.drawPath(drawable.path, paint);
        } else if (drawable is DrawableParent) {
          _draw(drawable, canvas, paint);
        }
      });
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class DebugSignaturePainterCP extends CustomPainter {
  final StoryPainterControl control;
  final bool cp;
  final bool cpStart;
  final bool cpEnd;
  final bool dot;
  final Color color;

  DebugSignaturePainterCP({
    required this.control,
    this.cp: false,
    this.cpStart: true,
    this.cpEnd: true,
    this.dot: true,
    this.color: Colors.red,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 1.0;

    control.lines.forEach((line) {
      if (cpStart) {
        canvas.drawLine(line.start, line.cpStart, paint);
        if (dot) {
          canvas.drawCircle(line.cpStart, 1.0, paint);
          canvas.drawCircle(line.start, 1.0, paint);
        }
      } else if (cp) {
        canvas.drawCircle(line.cpStart, 1.0, paint);
      }

      if (cpEnd) {
        canvas.drawLine(line.end, line.cpEnd, paint);
        if (dot) {
          canvas.drawCircle(line.cpEnd, 1.0, paint);
        }
      }
    });
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
