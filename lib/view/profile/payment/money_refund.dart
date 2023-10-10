import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:ig-public_v3/costant/text.dart';
import 'package:ig-public_v3/costant/colors.dart';
import 'package:ig-public_v3/component/appbar/appbar.dart';
import 'package:ig-public_v3/component/appbar/appbar_leading.dart';
import 'package:ig-public_v3/component/appbar/appbar_title.dart';
import 'package:ig-public_v3/component/svg/svg_builder.dart';
import 'package:ig-public_v3/widget/custom_text_widget.dart';

enum RefundType {direct, chat, none}

class MoneyRefundScreen extends StatefulWidget {
  const MoneyRefundScreen({super.key});

  @override
  State<MoneyRefundScreen> createState() => _MoneyRefundScreenState();
}

class _MoneyRefundScreenState extends State<MoneyRefundScreen> {
  late TextEditingController refundTextController;
  late FocusNode refundFocusNode;

  RefundType refundType = RefundType.none;

  @override
  void initState() {
    super.initState();

    refundTextController = TextEditingController()..addListener(() {
      setState(() {});
    });
    refundFocusNode = FocusNode();
  }

  @override
  void dispose() {
    super.dispose();

    refundTextController.dispose();
    refundFocusNode.dispose();
  }

  void payCalculator(int money) {
    String text = refundTextController.text;
    int amount = 0;
    text = text.replaceAll(',', '');
    refundTextController.clear();
    setState(() {
      if (text.isNotEmpty) {
        amount = int.parse(text);
        refundTextController.text = refundTextController.text = (amount + money).toString();
      } else {
        refundTextController.text = refundTextController.text = (0 + money).toString();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (refundFocusNode.hasFocus) {
          refundFocusNode.unfocus();
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: ig-publicAppBar(
          leading: ig-publicAppBarLeading(
            press: () => Navigator.pop(context),
          ),
          title: const ig-publicAppBarTitle(
            title: TextConstant.ig-publicMoneyRefund,
          ),
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          color: ColorConfig().white(),
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                      child: CustomTextBuilder(
                        text: TextConstant.selectRefundMethod,
                        fontColor: ColorConfig().dark(),
                        fontSize: 14.0.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    // 직접 환불하기
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                      onTap: () {
                        setState(() {
                          refundType = RefundType.direct;
                        });
                      },
                      leading: Container(
                        width: 24.0.w,
                        height: 24.0.w,
                        decoration: BoxDecoration(
                          color: refundType != RefundType.direct ? ColorConfig().gray1() : ColorConfig().primary(),
                          border: refundType != RefundType.direct ? Border.all(
                            width: 1.0,
                            color: ColorConfig().gray2(),
                          ) : null,
                          borderRadius: BorderRadius.circular(12.0.r),
                        ),
                        child: refundType == RefundType.direct ? Center(
                          child: SVGBuilder(
                            image: 'assets/icon/check.svg',
                            width: 20.0.w,
                            height: 20.0.w,
                            color: ColorConfig().white(),
                          ),
                        ) : Container(),
                      ),
                      title: CustomTextBuilder(
                        text: TextConstant.directRefund,
                        fontColor: ColorConfig().dark(),
                        fontSize: 14.0.sp,
                        fontWeight: FontWeight.w700,
                      ),
                      subtitle: Text.rich(
                        TextSpan(
                          children: <TextSpan> [
                            TextSpan(
                              text: TextConstant.creditCard,
                              style: TextStyle(
                                color: ColorConfig().gray5(),
                                fontSize: 12.0.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            TextSpan(
                              text: ' 또는 ',
                              style: TextStyle(
                                color: ColorConfig().gray5(),
                                fontSize: 12.0.sp,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            TextSpan(
                              text: TextConstant.kakaoPay,
                              style: TextStyle(
                                color: ColorConfig().gray5(),
                                fontSize: 12.0.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            TextSpan(
                              text: '로 결제하신 경우',
                              style: TextStyle(
                                color: ColorConfig().gray5(),
                                fontSize: 12.0.sp,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // 환불금액 입력 창
                    refundType == RefundType.direct ? Container(
                      width: MediaQuery.of(context).size.width,
                      color: ColorConfig().gray1(),
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 보유 ig-public머니 영역
                          purchaseAreaTitleWidget(),
                          // 충전금액 입력 영역
                          moneyPurchaseInputWidget(),
                          // 충전금액 버튼 영역
                          purchaseInputButtonWidget(),
                        ],
                      ),
                    ) : Container(),
                    // 채팅문의로 환불하기
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                      onTap: () {
                        setState(() {
                          refundType = RefundType.chat;
                        });
                      },
                      leading: Container(
                        width: 24.0.w,
                        height: 24.0.w,
                        decoration: BoxDecoration(
                          color: refundType != RefundType.chat ? ColorConfig().gray1() : ColorConfig().primary(),
                          border: refundType != RefundType.chat ? Border.all(
                            width: 1.0,
                            color: ColorConfig().gray2(),
                          ) : null,
                          borderRadius: BorderRadius.circular(12.0.r),
                        ),
                        child: refundType == RefundType.chat ? Center(
                          child: SVGBuilder(
                            image: 'assets/icon/check.svg',
                            width: 20.0.w,
                            height: 20.0.w,
                            color: ColorConfig().white(),
                          ),
                        ) : Container(),
                      ),
                      title: CustomTextBuilder(
                        text: TextConstant.chatRefund,
                        fontColor: ColorConfig().dark(),
                        fontSize: 14.0.sp,
                        fontWeight: FontWeight.w700,
                      ),
                      subtitle: Text.rich(
                        TextSpan(
                          children: <TextSpan> [
                            TextSpan(
                              text: '그 외 결제수단',
                              style: TextStyle(
                                color: ColorConfig().gray5(),
                                fontSize: 12.0.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            TextSpan(
                              text: '을 사용하셨거나 ',
                              style: TextStyle(
                                color: ColorConfig().gray5(),
                                fontSize: 12.0.sp,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            TextSpan(
                              text: '결제 수단이 기억나지 않는 경우',
                              style: TextStyle(
                                color: ColorConfig().gray5(),
                                fontSize: 12.0.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: refundFocusNode.hasFocus ? MediaQuery.of(context).viewInsets.bottom  + (112.0 + 16.0.sp) : 0.0),
                  ],
                ),
              ),
              moneyRefundApplicationButtonWidget(),
            ],
          ),
        ),
      ),
    );
  }

  // 보유 ig-public머니 위젯
  Widget purchaseAreaTitleWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SVGStringBuilder(
            image: 'assets/icon/money_won.svg',
            width: 16.0.w,
            height: 16.0.w,
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            child: CustomTextBuilder(
              text: '999,999',
              fontColor: ColorConfig().dark(),
              fontSize: 14.0.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
          CustomTextBuilder(
            text: TextConstant.holding,
            fontColor: ColorConfig().gray5(),
            fontSize: 14.0.sp,
            fontWeight: FontWeight.w700,
          ),
        ],
      ),
    );
  }

  // 충전금액 입력 위젯
  Widget moneyPurchaseInputWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.5, vertical: 8.0),
      child: TextFormField(
        controller: refundTextController,
        focusNode: refundFocusNode,
        scrollPadding: EdgeInsets.only(bottom: WidgetsBinding.instance.window.viewInsets.bottom),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.5),
          filled: true,
          fillColor: ColorConfig().white(),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              width: 1.0,
              color: ColorConfig().primary(),
            ),
            borderRadius: BorderRadius.circular(4.0.r),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              width: 1.0,
              color: ColorConfig().primary(),
            ),
            borderRadius: BorderRadius.circular(4.0.r),
          ),
          hintText: TextConstant.inputPleaseMoney,
          hintStyle: TextStyle(
            color: ColorConfig().gray3(),
            fontSize: 18.0.sp,
            fontWeight: FontWeight.w800,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.only(left: 16.0, right: 8.0),
            child: SVGStringBuilder(
              image: 'assets/icon/money_won.svg',
              width: 22.0.w,
              height: 22.0.w,
            ),
          ),
        ),
        style: TextStyle(
          color: ColorConfig().gray5(),
          fontSize: 18.0.sp,
          fontWeight: FontWeight.w800,
        ),
        cursorHeight: 18.0.sp,
        cursorColor: ColorConfig().primary(),
        keyboardType: TextInputType.number,
      ),
    );
  }

  // 정해진 충전금액 입력 버튼 위젯
  Widget purchaseInputButtonWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              payCalculator(10000);
            },
            child: Container(
              width: (MediaQuery.of(context).size.width - 52.0) / 4,
              padding: const EdgeInsets.symmetric(vertical: 13.0),
              margin: const EdgeInsets.only(right: 4.0),
              decoration: BoxDecoration(
                color: ColorConfig().white(),
                border: Border.all(
                  width: 1.0,
                  color: ColorConfig().primaryLight2(),
                ),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Center(
                child: CustomTextBuilder(
                  text: '+ 1만원',
                  fontColor: ColorConfig().gray5(),
                  fontSize: 13.0.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          InkWell(
            onTap: () {
              payCalculator(30000);
            },
            child: Container(
              width: (MediaQuery.of(context).size.width - 52.0) / 4,
              padding: const EdgeInsets.symmetric(vertical: 13.0),
              margin: const EdgeInsets.only(right: 4.0),
              decoration: BoxDecoration(
                color: ColorConfig().white(),
                border: Border.all(
                  width: 1.0,
                  color: ColorConfig().primaryLight2(),
                ),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Center(
                child: CustomTextBuilder(
                  text: '+ 3만원',
                  fontColor: ColorConfig().gray5(),
                  fontSize: 13.0.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          InkWell(
            onTap: () {
              payCalculator(50000);
            },
            child: Container(
              width: (MediaQuery.of(context).size.width - 52.0) / 4,
              padding: const EdgeInsets.symmetric(vertical: 13.0),
              margin: const EdgeInsets.only(right: 4.0),
              decoration: BoxDecoration(
                color: ColorConfig().white(),
                border: Border.all(
                  width: 1.0,
                  color: ColorConfig().primaryLight2(),
                ),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Center(
                child: CustomTextBuilder(
                  text: '+ 5만원',
                  fontColor: ColorConfig().gray5(),
                  fontSize: 13.0.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          InkWell(
            onTap: () {
              payCalculator(100000);
            },
            child: Container(
              width: (MediaQuery.of(context).size.width - 52.0) / 4,
              padding: const EdgeInsets.symmetric(vertical: 13.0),
              decoration: BoxDecoration(
                color: ColorConfig().white(),
                border: Border.all(
                  width: 1.0,
                  color: ColorConfig().primaryLight2(),
                ),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Center(
                child: CustomTextBuilder(
                  text: '+ 10만원',
                  fontColor: ColorConfig().gray5(),
                  fontSize: 13.0.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 환불신청 버튼 위젯
  Widget moneyRefundApplicationButtonWidget() {
    return Positioned(
      bottom: refundFocusNode.hasFocus ? MediaQuery.of(context).viewInsets.bottom : 0.0,
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 24.0),
        decoration: BoxDecoration(
          color: ColorConfig().white(),
          boxShadow: [
            BoxShadow(
              offset: const Offset(0.0, 0.0),
              blurRadius: 8.0,
              color: ColorConfig.defaultBlack.withOpacity(0.12),
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18.0),
          decoration: BoxDecoration(
            color: ColorConfig().gray2(),
            borderRadius: BorderRadius.circular(4.0.r),
          ),
          child: Center(
            child: CustomTextBuilder(
              text: TextConstant.moneyRefundApplication,
              fontColor: ColorConfig().gray3(),
              fontSize: 16.0.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}