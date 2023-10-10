import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:ig-public_v3/costant/enumerated.dart';
import 'package:ig-public_v3/costant/colors.dart';
import 'package:ig-public_v3/component/svg/svg_builder.dart';
import 'package:ig-public_v3/widget/custom_text_widget.dart';

class LoginButtonWidget {
  Widget loginWidget(
    BuildContext context, {
    required String title,
    required String logo,
    required Function() press,
    required LoginType type,
  }) {
    return InkWell(
      onTap: press,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),
        margin: EdgeInsets.fromLTRB(40.0, type == LoginType.email ? 8.0 : 0.0,
            40.0, type != LoginType.email ? 8.0 : 0.0),
        decoration: BoxDecoration(
          color: type == LoginType.kakao
              ? ColorConfig().kakaoBackground()
              : type == LoginType.google || type == LoginType.apple
                  ? ColorConfig().white()
                  : type == LoginType.naver
                      ? ColorConfig().naverBackground()
                      : type == LoginType.facebook
                          ? ColorConfig().facebookBackground()
                          : ColorConfig().dark(),
          border: type == LoginType.google || type == LoginType.apple
              ? Border.all(
                  width: 1.0,
                  color: ColorConfig().gray2(),
                )
              : null,
          borderRadius: BorderRadius.circular(6.0.r),
        ),
        child: Row(
          children: [
            SVGStringBuilder(
              image: logo,
              width: 24.0.w,
              height: 24.0.w,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width - (156.0 + 24.0.w),
              child: Center(
                child: CustomTextBuilder(
                  text: title,
                  fontColor: type == LoginType.naver ||
                          type == LoginType.facebook ||
                          type == LoginType.email
                      ? ColorConfig().white()
                      : ColorConfig().dark(),
                  fontSize: 13.0.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
