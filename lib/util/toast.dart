import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:oktoast/oktoast.dart';

import 'package:ig-public_v3/costant/colors.dart';
import 'package:ig-public_v3/component/svg/svg_builder.dart';
import 'package:ig-public_v3/widget/custom_text_widget.dart';

class ToastModel {
  ///
  /// 텍스트 전용 toast
  ///
  ToastFuture toast(String message) {
    return showToast(
      message,
      position: ToastPosition.bottom,
      backgroundColor: ColorConfig().dark(opacity: 0.8),
      textStyle: TextStyle(
        color: ColorConfig().white(),
        fontSize: 14.0.sp,
      ),
      dismissOtherToast: true,
      textPadding: const EdgeInsets.all(16.0),
    );
  }

  ///
  /// 아이콘 전용 toast
  /// [iconType] = 아이콘 종류 (기본값 = 1)
  ///    - 1: 성공
  ///    - 2: 에러
  ///
  ToastFuture iconToast(String message, {int iconType = 1}) {
    return showToastWidget(
      Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: ColorConfig().dark(opacity: 0.8),
          borderRadius: BorderRadius.circular(4.0.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SVGBuilder(
              image: iconType == 1
                  ? 'assets/icon/check.svg'
                  : 'assets/icon/info.svg',
              width: 20.0.w,
              height: 20.0.w,
              color: iconType == 1
                  ? ColorConfig().success()
                  : ColorConfig().accent(),
            ),
            Container(
              margin: const EdgeInsets.only(left: 8.0),
              child: CustomTextBuilder(
                text: message,
                fontColor: ColorConfig().white(),
                fontSize: 13.0.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
      position: ToastPosition.bottom,
      dismissOtherToast: true,
    );
  }

  ///
  /// 이모지 전용 toast
  ///
  ToastFuture emojiToast(String message, {required String emoji}) {
    return showToastWidget(
      Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: ColorConfig().dark(opacity: 0.8),
          borderRadius: BorderRadius.circular(4.0.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextBuilder(
              text: emoji,
              fontSize: 16.0.sp,
            ),
            Container(
              margin: const EdgeInsets.only(left: 8.0),
              child: CustomTextBuilder(
                text: message,
                fontColor: ColorConfig().white(),
                fontSize: 13.0.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
      position: ToastPosition.bottom,
      dismissOtherToast: true,
    );
  }
}
