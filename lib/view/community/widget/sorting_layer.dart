import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ig-public_v3/component/svg/svg_builder.dart';
import 'package:ig-public_v3/costant/colors.dart';
import 'package:ig-public_v3/costant/text.dart';
import 'package:ig-public_v3/widget/custom_text_widget.dart';

class CommunitySortingLayerWidget {
  Widget sorting(BuildContext context) {
    return Container(
      color: ColorConfig().gray1(),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(10.0, 8.0, 8.0, 8.0),
            decoration: BoxDecoration(
              color: ColorConfig().white(),
              border: Border.all(
                width: 1.0,
                color: ColorConfig().gray2(),
              ),
              borderRadius: BorderRadius.circular(4.0.r),
            ),
            child: Row(
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 4.0),
                  child: CustomTextBuilder(
                    text: TextConstant.all,
                    fontColor: ColorConfig().gray5(),
                    fontSize: 12.0.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SVGBuilder(
                  image: 'assets/icon/arrow_down_light.svg',
                  width: 16.0.w,
                  height: 16.0.w,
                  color: ColorConfig().gray5(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
