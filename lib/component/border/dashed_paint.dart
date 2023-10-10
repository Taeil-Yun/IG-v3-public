part of 'dashed_border.dart';

typedef PathBuilder = Path Function(Size);

class CustomDashPainter extends CustomPainter {
  final double strokeWidth;
  final List<double> pattern;
  final Color color;
  final BorderType borderType;
  final Radius radius;
  final StrokeCap strokeCap;
  final PathBuilder? customPath;

  CustomDashPainter({
    this.strokeWidth = 1.0,
    this.pattern = const <double>[3, 1],
    this.color = ColorConfig.defaultBlack,
    this.borderType = BorderType.rect,
    this.radius = const Radius.circular(0),
    this.strokeCap = StrokeCap.butt,
    this.customPath,
  }) {
    assert(pattern.isNotEmpty, 'Dash Pattern cannot be empty');
  }

  @override
  bool shouldRepaint(CustomDashPainter oldDelegate) {
    return oldDelegate.strokeWidth != strokeWidth || oldDelegate.color != color || oldDelegate.pattern != pattern || oldDelegate.borderType != borderType;
  }

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..strokeWidth = strokeWidth
      ..color = color
      ..strokeCap = strokeCap
      ..style = PaintingStyle.stroke;

    Path path;
    
    if (customPath != null) {
      path = dashPath(
        customPath!(size),
        dashArray: CircularIntervalList(pattern),
      );
    } else {
      path = _getPath(size);
    }

    canvas.drawPath(path, paint);
  }

  Path _getPath(Size size) {
    Path path;

    switch (borderType) {
      case BorderType.circle:
        path = circlePath(size);
        break;
      case BorderType.rrect:
        path = rrectPath(size, radius);
        break;
      case BorderType.rect:
        path = rectPath(size);
        break;
      case BorderType.oval:
        path = ovalPath(size);
        break;
    }

    return dashPath(path, dashArray: CircularIntervalList(pattern));
  }

  Path circlePath(Size size) {
    double w = size.width;
    double h = size.height;
    double s = size.shortestSide;

    return Path()..addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          w > s ? (w - s) / 2 : 0,
          h > s ? (h - s) / 2 : 0,
          s,
          s,
        ),
        Radius.circular(s / 2),
      ),
    );
  }

  Path rrectPath(Size size, Radius radius) {
    return Path()..addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          0,
          0,
          size.width,
          size.height,
        ),
        radius,
      ),
    );
  }

  Path rectPath(Size size) {
    return Path()..addRect(
      Rect.fromLTWH(
        0,
        0,
        size.width,
        size.height,
      ),
    );
  }

  Path ovalPath(Size size) {
    return Path()..addOval(
      Rect.fromLTWH(
        0,
        0,
        size.width,
        size.height,
      ),
    );
  }
}