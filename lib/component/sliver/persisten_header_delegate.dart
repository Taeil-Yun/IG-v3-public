import 'package:flutter/material.dart';

class CustomSliverPersistenHeaderDelegate extends SliverPersistentHeaderDelegate {
  double? maxExtented;
  double? minExtented;
  Widget child;

  CustomSliverPersistenHeaderDelegate({
    required this.child,
    this.maxExtented,
    this.minExtented,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => maxExtented ?? 80.0;

  @override
  double get minExtent => minExtented ?? 50.0;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}