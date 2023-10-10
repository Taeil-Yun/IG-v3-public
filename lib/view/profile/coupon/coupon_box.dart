import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ig-public_v3/api/coupon/add_coupon.dart';

import 'package:ig-public_v3/costant/build_config.dart';
import 'package:ig-public_v3/costant/text.dart';
import 'package:ig-public_v3/costant/colors.dart';
import 'package:ig-public_v3/api/coupon/coupon_list.dart';
import 'package:ig-public_v3/component/border/dashed_border.dart';
import 'package:ig-public_v3/component/date_calculator/date_calculator.dart';
import 'package:ig-public_v3/component/svg/svg_builder.dart';
import 'package:ig-public_v3/component/appbar/appbar.dart';
import 'package:ig-public_v3/component/appbar/appbar_leading.dart';
import 'package:ig-public_v3/component/appbar/appbar_title.dart';
import 'package:ig-public_v3/util/set_intl.dart';
import 'package:ig-public_v3/util/toast.dart';
import 'package:ig-public_v3/widget/custom_text_widget.dart';
import 'package:ig-public_v3/widget/ticket_cliper.dart';
import 'package:intl/intl.dart';

class CouponBoxScreen extends StatefulWidget {
  const CouponBoxScreen({super.key});

  @override
  State<CouponBoxScreen> createState() => _CouponBoxScreenState();
}

class _CouponBoxScreenState extends State<CouponBoxScreen> {
  late TextEditingController couponInputController;
  late FocusNode couponInputFocusNode;

  Map<String, dynamic> couponData = {};

  @override
  void initState() {
    super.initState();

    couponInputController = TextEditingController()..addListener(() {
      setState(() {});
    });
    couponInputFocusNode = FocusNode();

    initializeAPI();
  }

  @override
  void dispose() {
    super.dispose();

    couponInputController.dispose();
    couponInputFocusNode.dispose();
  }

  Future<void> initializeAPI() async {
    CouponListAPI().couponList(accessToken: await SecureStorageConfig().storage.read(key: 'access_token')).then((value) {
      setState(() {
        couponData = value.result['data'];
      });
    });
  }

  bool dateOverCheck(int index) {
    if (DateTime.parse(couponData['list'][index]['end_date']).toLocal().millisecondsSinceEpoch > DateTime.now().toLocal().millisecondsSinceEpoch) {
      return false;
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        couponInputFocusNode.unfocus();
      },
      child: Scaffold(
        appBar: ig-publicAppBar(
          leading: ig-publicAppBarLeading(
            press: () => Navigator.pop(context),
          ),
          title: const ig-publicAppBarTitle(
            title: TextConstant.couponBox,
          ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(32.0 + 32.0 + 16.0.sp),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Row(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width - (40.0 + 24.0 + 40.0 + 16.0.sp),
                    constraints: BoxConstraints(
                      maxHeight: 32.0 + 16.0.sp,
                    ),
                    margin: const EdgeInsets.only(right: 12.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4.0.r),
                    ),
                    child: TextFormField(
                      controller: couponInputController,
                      focusNode: couponInputFocusNode,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp("[ㄱ-ㅎ가-힣a-zA-Z0-9]"))
                      ],
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: ColorConfig().primaryLight3(),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                        hintText: TextConstant.inputCouponNumber,
                        hintStyle: TextStyle(
                          color: ColorConfig().gray3(),
                          fontSize: 14.0.sp,
                          fontWeight: FontWeight.w800,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.all(Radius.circular(4.0.r))
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.all(Radius.circular(4.0.r))
                        ),
                      ),
                      style: TextStyle(
                        color: ColorConfig().dark(),
                        fontSize: 14.0.sp,
                        fontWeight: FontWeight.w800,
                      ),
                      cursorColor: ColorConfig().primary(),
                      keyboardType: TextInputType.text,
                    ),
                  ),
                  InkWell(
                    onTap: couponInputController.text.trim().isNotEmpty ? () async {
                      AddCouponAPI().addCoupon(accessToken: await SecureStorageConfig().storage.read(key: 'access_token'), couponCode: couponInputController.text.trim()).then((value) async {
                        couponInputController.clear();
                        
                        if (value.result['status'] == 0) {
                          ToastModel().iconToast(value.result['message'], iconType: 2);
                        } else if (value.result['status'] == 1) {
                          ToastModel().iconToast(value.result['message']);
                          
                          CouponListAPI().couponList(accessToken: await SecureStorageConfig().storage.read(key: 'access_token')).then((value) {
                            setState(() {
                              couponData = value.result['data'];
                            });
                          });
                        } else if (value.result['status'] == -1) {
                          ToastModel().iconToast(value.result['message'], iconType: 2);
                        }
                      });
                    } : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                      decoration: BoxDecoration(
                        color: ColorConfig().primary(),
                        borderRadius: BorderRadius.circular(4.0.r),
                      ),
                      child: Center(
                        child: CustomTextBuilder(
                          text: TextConstant.regist,
                          fontColor: ColorConfig().white(),
                          fontSize: 14.0.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: couponData.isNotEmpty ? Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: ColorConfig().gray1(),
          child: SafeArea(
            child: Column(
              children: [
                // 쿠폰 리스트 영역
                Expanded(
                  child: couponData['list'].isNotEmpty ? ListView.builder(
                    itemCount: couponData['list'].length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: index == 0 ? const EdgeInsets.only(top: 8.0) : index == couponData['list'].length - 1 ? const EdgeInsets.only(bottom: 40.0) : null,
                        padding: EdgeInsets.symmetric(horizontal: 20.0.w, vertical: 4.0.w),
                        child: ClipPath(
                          clipper: TicketClipper(),
                          child: Container(
                            decoration: BoxDecoration(
                              color: dateOverCheck(index) == false ? ColorConfig().white() : ColorConfig().white(opacity: 0.6),
                              borderRadius: BorderRadius.circular(8.0.r),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 쿠폰 이미지 영역
                                Container(
                                  padding: couponData['list'][index]['type'] == 1 ? EdgeInsets.symmetric(horizontal: 28.0.w, vertical: 44.0.w) : EdgeInsets.all(20.0.w),
                                  decoration: BoxDecoration(
                                    color: couponData['list'][index]['type'] == 1
                                      ? dateOverCheck(index) == false
                                        ? ColorConfig().primary()
                                        : ColorConfig().primary(opacity: 0.6)
                                      : null,
                                    borderRadius: couponData['list'][index]['type'] == 1 ? BorderRadius.only(
                                      topLeft: Radius.circular(8.0.r),
                                      bottomLeft: Radius.circular(8.0.r),
                                    ) : null,
                                  ),
                                  child: Container(
                                    width: couponData['list'][index]['type'] == 1 ? 65.0.w : 80.0.w,
                                    height: couponData['list'][index]['type'] == 1 ? 65.0.w : 114.0.w,
                                    decoration: BoxDecoration(
                                      color: couponData['list'][index]['image'] == null
                                        ? dateOverCheck(index) == false
                                          ? ColorConfig().gray2()
                                          : ColorConfig().gray2(opacity: 0.6)
                                        : null,
                                      borderRadius: BorderRadius.circular(8.0.r),
                                      image: couponData['list'][index]['image'] != null ? DecorationImage(
                                        image: NetworkImage(couponData['list'][index]['image']),
                                        fit: BoxFit.cover,
                                        filterQuality: FilterQuality.high,
                                        opacity: dateOverCheck(index) == false ? 1.0 : 0.6,
                                      ) : null,
                                    ),
                                    child: couponData['list'][index]['image'] == null ? Center(
                                      child: SVGBuilder(
                                        image: 'assets/icon/album.svg',
                                        width: 22.0.w,
                                        height: 22.0.w,
                                        color: dateOverCheck(index) == false ? ColorConfig().white() : ColorConfig().white(),
                                      ),
                                    ) : Container(),
                                  ),
                                ),
                                // 점선 라인 영역
                                couponData['list'][index]['type'] == 2 ? CustomDottedBorderBuilder(
                                  pattern: const [4.0,8.0],
                                  color: dateOverCheck(index) == false ? ColorConfig().gray2() : ColorConfig().gray2(opacity: 0.6),
                                  child: SizedBox(height: 114.0.w + 40.0),
                                ) : Container(),
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.all(20.0.w),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // 쿠폰 이름 영역
                                        Container(
                                          margin: EdgeInsets.only(bottom: 12.0.w),
                                          child: CustomTextBuilder(
                                            text: '${couponData['list'][index]['name']}',
                                            fontColor: dateOverCheck(index) == false ? ColorConfig().primary() : ColorConfig().primary(opacity: 0.6),
                                            fontSize: 14.0.sp,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        // 발행처, 공연명 영역
                                        Container(
                                          margin: EdgeInsets.only(top: 8.0.w),
                                          child: CustomTextBuilder(
                                            text: '${couponData['list'][index]['type'] == 1 ? '발행' : '공연'} : ${couponData['list'][index]['item_name']}',
                                            fontColor: dateOverCheck(index) == false ? ColorConfig().dark() : ColorConfig().dark(opacity: 0.6),
                                            fontSize: 12.0.sp,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        // 잔여금액, 좌석 영역
                                        Container(
                                          margin: EdgeInsets.only(top: 4.0.w),
                                          child: CustomTextBuilder(
                                            text: '${couponData['list'][index]['type'] == 1 ? '잔여금액' : '좌석'} : ${couponData['list'][index]['type'] == 1 ? '${SetIntl().numberFormat(couponData['list'][index]['available_point'])}원' : couponData['list'][index]['seat_name']}',
                                            fontColor: dateOverCheck(index) == false ? ColorConfig().dark() : ColorConfig().dark(opacity: 0.6),
                                            fontSize: 12.0.sp,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        // 회차 영역
                                        couponData['list'][index]['type'] == 2 ? Container(
                                          margin: EdgeInsets.only(top: 4.0.w),
                                          child: CustomTextBuilder(
                                            text: couponData['list'][index]['open_date'] == '전 회차' ? '회차 : 전 회차' : '회차 : ${DateFormat('yyyy. M. d. a H:m', 'ko').format(DateTime.parse(couponData['list'][index]['open_date']).toLocal())}',
                                            fontColor: dateOverCheck(index) == false ? ColorConfig().dark() : ColorConfig().dark(opacity: 0.6),
                                            fontSize: 12.0.sp,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ) : Container(),
                                        // 공연 관람권 전용 텍스트 영역
                                        couponData['list'][index]['type'] == 1 ? Container(
                                          margin: EdgeInsets.only(top: 8.0.w),
                                          child: CustomTextBuilder(
                                            text: TextConstant.showTicketCouponText,
                                            fontColor: dateOverCheck(index) == false ? ColorConfig().gray3() : ColorConfig().gray3(opacity: 0.6),
                                            fontSize: 12.0.sp,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ) : Container(),
                                        Container(
                                          margin: couponData['list'][index]['type'] == 2 ? EdgeInsets.only(top: 16.0.w) : EdgeInsets.only(top: 8.0.w),
                                          child: CustomTextBuilder(
                                            text: DateCalculatorWrapper().deadlineCalculator(couponData['list'][index]['end_date']),
                                            fontColor: dateOverCheck(index) == false ? ColorConfig().gray3() : ColorConfig().gray3(opacity: 0.6),
                                            fontSize: 12.0.sp,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ) : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 60.0.w,
                        height: 60.0.w,
                        margin: const EdgeInsets.only(bottom: 24.0),
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/img/no-data-coupon.png'),
                            filterQuality: FilterQuality.high,
                          ),
                        ),
                      ),
                      CustomTextBuilder(
                        text: '사용가능한 쿠폰이 없습니다.\n쿠폰을 등록해주세요.',
                        fontColor: ColorConfig().gray4(),
                        fontSize: 14.0.sp,
                        fontWeight: FontWeight.w400,
                        height: 1.2,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ) : Container(),
      ),
    );
  }
}