import 'package:flutter/material.dart';

import 'package:ig-public_v3/costant/colors.dart';

class SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  SliverAppBarDelegate(
    this._tabBar,
    this._isCollapse, {
    this.backgroundColor,
    this.border,
  });

  final TabBar _tabBar;
  final bool _isCollapse;
  final Color? backgroundColor;
  final Border? border;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor ?? ColorConfig.defaultWhite,
          border: border,
          boxShadow: _isCollapse
              ? [
                  BoxShadow(
                    color: ColorConfig.defaultBlack.withOpacity(0.16),
                    blurRadius: 8.0,
                    offset: const Offset(0.0, 2.0),
                  ),
                ]
              : null,
        ),
        child: _tabBar,
      ),
    );
  }

  @override
  bool shouldRebuild(SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

class CustomTabIndicator extends Decoration {
  ///
  /// [height] = indicator 크기, 기본값: 4.0
  /// [tabPosition] = 탭의 위치, 기본값: [TabPosition.bottom]
  /// [topRightRadius] = 우측상단 Radius값, 기본값: 5.0
  /// [topLeftRadius] = 좌측상단 Radius값, 기본값: 5.0
  /// [bottomRightRadius] = 우측하단 Radius값, 기본값: 0.0
  /// [bottomLeftRadius] = 좌측하단 Radius값, 기본값: 0.0
  /// [color] = indicator 색상, 기본값: [ColorConfig.defaultBlack]
  /// [horizontalPadding] = indicator 좌측/우측 padding값, 기본값: 0.0
  /// [paintingStyle] = indicator의 paint fill/stroke, 기본: fill
  /// [strokeWidth] = [PaintingStyle.stroke]에 사용되는 StrokeWidth, 기본값: 2.0
  ///
  final double height;
  final TabPosition tabPosition;
  final double topRightRadius;
  final double topLeftRadius;
  final double bottomRightRadius;
  final double bottomLeftRadius;
  final Color color;
  final double horizontalPadding;
  final PaintingStyle paintingStyle;
  final double strokeWidth;

  const CustomTabIndicator({
    this.height = 4.0,
    this.tabPosition = TabPosition.bottom,
    this.topRightRadius = 5.0,
    this.topLeftRadius = 5.0,
    this.bottomRightRadius = 0.0,
    this.bottomLeftRadius = 0.0,
    this.color = ColorConfig.defaultBlack,
    this.horizontalPadding = 0.0,
    this.paintingStyle = PaintingStyle.fill,
    this.strokeWidth = 2.0,
  });

  @override
  // ignore: library_private_types_in_public_api
  _CustomPainter createBoxPainter([VoidCallback? onChanged]) {
    return _CustomPainter(
      this,
      onChanged,
      bottomLeftRadius: bottomLeftRadius,
      bottomRightRadius: bottomRightRadius,
      color: color,
      height: height,
      horizontalPadding: horizontalPadding,
      tabPosition: tabPosition,
      topLeftRadius: topLeftRadius,
      topRightRadius: topRightRadius,
      paintingStyle: paintingStyle,
      strokeWidth: strokeWidth,
    );
  }
}

class _CustomPainter extends BoxPainter {
  final CustomTabIndicator decoration;
  final double height;
  final TabPosition tabPosition;
  final double topRightRadius;
  final double topLeftRadius;
  final double bottomRightRadius;
  final double bottomLeftRadius;
  final Color color;
  final double horizontalPadding;
  final double strokeWidth;
  final PaintingStyle paintingStyle;

  _CustomPainter(
    this.decoration,
    VoidCallback? onChanged, {
    required this.height,
    required this.tabPosition,
    required this.topRightRadius,
    required this.topLeftRadius,
    required this.bottomRightRadius,
    required this.bottomLeftRadius,
    required this.color,
    required this.horizontalPadding,
    required this.paintingStyle,
    required this.strokeWidth,
  }) : super(onChanged);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    assert(horizontalPadding >= 0);
    assert(horizontalPadding < configuration.size!.width / 2,
        "Padding must be less than half of the size of the tab");
    assert(height > 0);
    assert(strokeWidth >= 0 &&
        strokeWidth < configuration.size!.width / 2 &&
        strokeWidth < configuration.size!.height / 2);

    // offset = 그려야 하는 위치
    // configuration.size = 탭의 높이와 너비
    Size drawSize =
        Size(configuration.size!.width - (horizontalPadding * 2), height);

    Offset drawOffset = Offset(
      offset.dx + (horizontalPadding),
      offset.dy +
          (tabPosition == TabPosition.bottom
              ? configuration.size!.height - height
              : 0),
    );

    final Rect rect = drawOffset & drawSize;
    final Paint paint = Paint();
    paint.color = color;
    paint.style = paintingStyle;
    paint.strokeWidth = strokeWidth;
    canvas.drawRRect(
        RRect.fromRectAndCorners(
          rect,
          bottomRight: Radius.circular(bottomRightRadius),
          bottomLeft: Radius.circular(bottomLeftRadius),
          topLeft: Radius.circular(topLeftRadius),
          topRight: Radius.circular(topRightRadius),
        ),
        paint);
  }
}

enum TabPosition { top, bottom }
