import 'package:flutter/material.dart';
import 'package:ig-public_v3/component/svg/svg_builder.dart';
import 'package:ig-public_v3/costant/colors.dart';
import 'package:ig-public_v3/costant/default_value.dart';

// ignore: must_be_immutable
class PreviousMonthWidget extends StatelessWidget {
  PreviousMonthWidget({
    super.key,
    required this.pageController,
    this.reverse = false,
    required this.year,
    required this.month,
    required this.minimumYear,
    required this.minumumMonth,
  });

  PageController pageController;
  bool reverse;
  int year;
  int month;
  int minimumYear;
  int minumumMonth;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: reverse
          ? !(DateTime(year, month).millisecondsSinceEpoch <=
                  DateTime(GetDefaultValue.minimumYear,
                          GetDefaultValue.minimumMonth)
                      .millisecondsSinceEpoch)
              ? () {
                  pageController.nextPage(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeIn);
                }
              : null
          : (DateTime(minimumYear, minumumMonth).millisecondsSinceEpoch <
                  DateTime(year, month).millisecondsSinceEpoch)
              ? () {
                  pageController.previousPage(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeIn);
                }
              : null,
      icon: SVGBuilder(
        image: 'assets/icon/arrow_left_bold.svg',
        color: reverse
            ? !(DateTime(year, month).millisecondsSinceEpoch <=
                    DateTime(GetDefaultValue.minimumYear,
                            GetDefaultValue.minimumMonth)
                        .millisecondsSinceEpoch)
                ? ColorConfig().dark()
                : ColorConfig().dark(opacity: 0.4)
            : (DateTime(minimumYear, minumumMonth).millisecondsSinceEpoch <
                    DateTime(year, month).millisecondsSinceEpoch)
                ? ColorConfig().dark()
                : ColorConfig().dark(opacity: 0.4),
      ),
    );
  }
}

// ignore: must_be_immutable
class NextMonthWidget extends StatelessWidget {
  NextMonthWidget({
    super.key,
    required this.pageController,
    this.reverse = false,
    required this.year,
    required this.month,
    required this.maximumYear,
    required this.maximumMonth,
  });

  PageController pageController;
  bool reverse;
  int year;
  int month;
  int maximumYear;
  int maximumMonth;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: reverse
          ? !(DateTime(year, month).millisecondsSinceEpoch <=
                  DateTime(GetDefaultValue.minimumYear,
                          GetDefaultValue.minimumMonth)
                      .millisecondsSinceEpoch)
              ? () {
                  pageController.previousPage(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeIn);
                }
              : null
          : DateTime(year, month).millisecondsSinceEpoch <
                  DateTime(maximumYear, maximumMonth).millisecondsSinceEpoch
              ? () {
                  pageController.nextPage(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeIn);
                }
              : null,
      icon: SVGBuilder(
        image: 'assets/icon/arrow_right_bold.svg',
        color: reverse
            ? !(DateTime(year, month).millisecondsSinceEpoch <=
                    DateTime(GetDefaultValue.minimumYear,
                            GetDefaultValue.minimumMonth)
                        .millisecondsSinceEpoch)
                ? ColorConfig().dark()
                : ColorConfig().dark(opacity: 0.4)
            : DateTime(year, month).millisecondsSinceEpoch <
                    DateTime(maximumYear, maximumMonth).millisecondsSinceEpoch
                ? ColorConfig().dark()
                : ColorConfig().dark(opacity: 0.4),
      ),
    );
  }
}
