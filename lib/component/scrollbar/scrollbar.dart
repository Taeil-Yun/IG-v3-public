import 'package:flutter/material.dart';

import 'package:ig-public_v3/costant/colors.dart';

const double _kMinThumbExtent = 18.0;
const Duration _kScrollbarFadeDuration = Duration(milliseconds: 300);
const Duration _kScrollbarTimeToFade = Duration(milliseconds: 600);

// ignore: must_be_immutable
class ScrollBarBuilder extends StatelessWidget {
  ///
  /// 사용시에 스크롤바를 넣어줄 부모위젯에다가 감싸주면 스크롤할 때 스크롤바가 보여짐
  /// [ScrollBarBuilder]의 필요한 속성들을 변경
  ///
  ScrollBarBuilder(
      {Key? key,
      required this.child,
      this.controller,
      this.radius = const Radius.circular(100.0),
      this.thickness,
      this.thumbColor,
      this.minThumbLength = _kMinThumbExtent,
      this.minOverscrollLength,
      this.fadeDuration = _kScrollbarFadeDuration,
      this.timeToFade = _kScrollbarTimeToFade,
      this.pressDuration = Duration.zero,
      this.notificationPredicate = defaultScrollNotificationPredicate,
      this.interactive,
      this.scrollbarOrientation,
      this.mainAxisMargin = 0.0,
      this.crossAxisMargin = 0.0})
      : assert(minThumbLength >= 0),
        assert(minOverscrollLength == null ||
            minOverscrollLength <= minThumbLength),
        assert(minOverscrollLength == null || minOverscrollLength >= 0),
        super(key: key);

  final Widget child;
  final ScrollController? controller;
  final Radius radius;
  final double? thickness;
  Color? thumbColor = ColorConfig().gray2();
  final double minThumbLength;
  final double? minOverscrollLength;
  final Duration fadeDuration;
  final Duration timeToFade;
  final Duration pressDuration;
  final bool Function(ScrollNotification) notificationPredicate;
  final bool? interactive;
  final ScrollbarOrientation? scrollbarOrientation;
  final double mainAxisMargin;
  final double crossAxisMargin;

  @override
  Widget build(BuildContext context) {
    return RawScrollbar(
      controller: controller,
      radius: radius,
      thickness: thickness,
      thumbColor: thumbColor,
      minThumbLength: minThumbLength,
      minOverscrollLength: minOverscrollLength,
      fadeDuration: fadeDuration,
      timeToFade: timeToFade,
      pressDuration: pressDuration,
      notificationPredicate: notificationPredicate,
      interactive: interactive,
      scrollbarOrientation: scrollbarOrientation,
      mainAxisMargin: mainAxisMargin,
      crossAxisMargin: crossAxisMargin,
      child: child,
    );
  }
}
