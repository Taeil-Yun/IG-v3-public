import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:ig-public_v3/costant/text.dart';
import 'package:ig-public_v3/costant/colors.dart';
import 'package:ig-public_v3/component/appbar/appbar.dart';
import 'package:ig-public_v3/component/appbar/appbar_leading.dart';
import 'package:ig-public_v3/component/appbar/appbar_title.dart';
import 'package:ig-public_v3/component/svg/svg_builder.dart';
import 'package:ig-public_v3/widget/custom_text_widget.dart';

class BadgeListScreen extends StatefulWidget {
  const BadgeListScreen({super.key});

  @override
  State<BadgeListScreen> createState() => _BadgeListScreenState();
}

class _BadgeListScreenState extends State<BadgeListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ig-publicAppBar(
        leading: ig-publicAppBarLeading(
          press: () => Navigator.pop(context),
        ),
        title: const ig-publicAppBarTitle(
          title: TextConstant.holdBadge,
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: ColorConfig().gray1(),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 8.0, 8.0),
              child: Wrap(
                children: List.generate(20, (index) {
                  return InkWell(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(4.0.r),
                          )
                        ),
                        builder: (context) {
                          return Container(
                            padding: const EdgeInsets.only(top: 16.0, left: 20.0, right: 20.0),
                            decoration: BoxDecoration(
                              color: ColorConfig().white(),
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(4.0.r),
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // 뱃지 이미지 영역
                                Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Container(
                                    width: 90.0.w,
                                    height: 90.0.w,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6.0.r),
                                      image: const DecorationImage(
                                        image: AssetImage('assets/img/d_main_bg_poster.jpeg'),
                                        fit: BoxFit.cover,
                                        filterQuality: FilterQuality.high,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          offset: const Offset(0.0, 4.0),
                                          blurRadius: 4.0,
                                          color: ColorConfig.defaultBlack.withOpacity(0.25),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // 뱃지 타이틀, 설명 영역
                                Container(
                                  margin: const EdgeInsets.symmetric(vertical: 12.0),
                                  child: Column(
                                    children: [
                                      // 뱃지 타이틀 영역
                                      CustomTextBuilder(
                                        text: '포도알',
                                        fontColor: ColorConfig().dark(),
                                        fontSize: 18.0.sp,
                                        fontWeight: FontWeight.w800,
                                      ),
                                      // 획득날짜 영역
                                      Container(
                                        margin: const EdgeInsets.only(top: 4.0, bottom: 12.0),
                                        child: CustomTextBuilder(
                                          text: '2023.04.14 획득',
                                          fontColor: ColorConfig().dark(),
                                          fontSize: 11.0.sp,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      // 뱃지 설명 영역
                                      CustomTextBuilder(
                                        text: 'VIP석에서 뮤지컬 5회이상 관람시에\n받을 수 있는 뱃지입니다.',
                                        fontColor: ColorConfig().dark(),
                                        fontSize: 14.0.sp,
                                        fontWeight: FontWeight.w400,
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                                      decoration: BoxDecoration(
                                        color: ColorConfig().primary(),
                                        borderRadius: BorderRadius.circular(4.0.r),
                                      ),
                                      child: Center(
                                        child: CustomTextBuilder(
                                          text: TextConstant.ok,
                                          fontColor: ColorConfig().white(),
                                          fontSize: 14.0.sp,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    child: Container(
                      width: (MediaQuery.of(context).size.width - 48.0) / 3,
                      margin: const EdgeInsets.only(right: 8.0, bottom: 8.0),
                      padding: const EdgeInsets.fromLTRB(8.0, 12.0, 8.0, 8.0),
                      decoration: BoxDecoration(
                        color: ColorConfig().white(),
                        borderRadius: BorderRadius.circular(4.0.r),
                        boxShadow: [
                          BoxShadow(
                            offset: const Offset(0.0, 1.0),
                            blurRadius: 4.0,
                            color: ColorConfig.defaultBlack.withOpacity(0.06),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // 뱃지 이미지 영역
                          Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  width: 48.0.w,
                                  height: 48.0.w,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6.0.r),
                                    image: const DecorationImage(
                                      image: AssetImage('assets/img/d_main_bg_poster.jpeg'),
                                      fit: BoxFit.cover,
                                      filterQuality: FilterQuality.high,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        offset: const Offset(0.0, 4.0),
                                        blurRadius: 4.0,
                                        color: ColorConfig.defaultBlack.withOpacity(0.25),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // new 아이콘 영역
                              Positioned(
                                right: 0.0,
                                child: SVGStringBuilder(
                                  image: 'assets/icon/New-rnd.svg',
                                  width: 16.0.w,
                                  height: 16.0.w,
                                ),
                              ),
                            ],
                          ),
                          // 뱃지 타이틀, 설명 영역
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            padding: const EdgeInsets.all(4.0),
                            child: Column(
                              children: [
                                // 뱃지 타이틀 영역
                                CustomTextBuilder(
                                  text: '티끌',
                                  fontColor: ColorConfig().dark(),
                                  fontSize: 12.0.sp,
                                  fontWeight: FontWeight.w800,
                                ),
                                // 뱃지 설명 영역
                                Container(
                                  margin: const EdgeInsets.only(top: 4.0),
                                  child: CustomTextBuilder(
                                    text: 'ig-public머니 만원이상 충전시',
                                    fontColor: ColorConfig().gray5(),
                                    fontSize: 10.0.sp,
                                    fontWeight: FontWeight.w700,
                                    textAlign: TextAlign.center,
                                    height: 1.2,
                                  ),
                                )
                              ],
                            ),
                          ),
                          // 획득날짜 영역
                          CustomTextBuilder(
                            text: '2023.04.18 획득',
                            fontColor: ColorConfig().gray3(),
                            fontSize: 9.0.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}