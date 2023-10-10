import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ig-public_v3/api/main/main_myprofile.dart';
import 'package:ig-public_v3/api/payment/payment_order.dart';
import 'package:ig-public_v3/api/profile/my_money.dart';

import 'package:ig-public_v3/component/appbar/appbar.dart';
import 'package:ig-public_v3/component/appbar/appbar_leading.dart';
import 'package:ig-public_v3/component/appbar/appbar_title.dart';
import 'package:ig-public_v3/component/iamport/payment.dart';
import 'package:ig-public_v3/component/svg/svg_builder.dart';
import 'package:ig-public_v3/costant/build_config.dart';
import 'package:ig-public_v3/costant/colors.dart';
import 'package:ig-public_v3/costant/text.dart';
import 'package:ig-public_v3/util/set_intl.dart';
import 'package:ig-public_v3/util/toast.dart';
import 'package:ig-public_v3/widget/custom_text_widget.dart';

class ig-publicMoneyPurchaseScreen extends StatefulWidget {
  const ig-publicMoneyPurchaseScreen({super.key});

  @override
  State<ig-publicMoneyPurchaseScreen> createState() => _ig-publicMoneyPurchaseScreenState();
}

class _ig-publicMoneyPurchaseScreenState extends State<ig-publicMoneyPurchaseScreen> {
  late TextEditingController purchaseTextController;
  late FocusNode purchaseFocusNode;

  List<bool> checkListStatuses = <bool> [false, false, false];
  List<String> purchaseMethodName = ['신용카드', '계좌이체', '카카오페이', '네이버페이'];

  int selectedPurchaseMethodIndex = -1;
  int ig-publicMoney = 0;

  String selectedPurchaseMethod = '';
  String payType = '';
  String pg = '';
  String payMethod = '';

  Map<String, dynamic> myProfileData = {};

  @override
  void initState() {
    super.initState();

    purchaseTextController = TextEditingController()..addListener(() {
      setState(() {});
    });
    purchaseFocusNode = FocusNode();

    initializeAPI();
  }

  @override
  void dispose() {
    super.dispose();

    purchaseTextController.dispose();
    purchaseFocusNode.dispose();
  }

  void payCalculator(int money) {
    String text = purchaseTextController.text;
    int amount = 0;
    text = text.replaceAll(',', '');
    purchaseTextController.clear();
    setState(() {
      if (text.isNotEmpty) {
        amount = int.parse(text);
        purchaseTextController.text = purchaseTextController.text = (amount + money).toString();
      } else {
        purchaseTextController.text = purchaseTextController.text = (0 + money).toString();
      }
    });
  }

  Future<void> initializeAPI() async {
    Myig-publicMoneyAPI().ig-publicMoney(accessToken: await SecureStorageConfig().storage.read(key: 'access_token')).then((value) {
      setState(() {
        ig-publicMoney = value.result['data'][0]['point'];
      });
    });
    MainMyProfileAPI().myProfile(accessToken: await SecureStorageConfig().storage.read(key: 'access_token')).then((value) {
      setState(() {
        myProfileData = value.result['data'];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (purchaseFocusNode.hasFocus) {
          purchaseFocusNode.unfocus();
        }
      },
      child: Scaffold(
        appBar: ig-publicAppBar(
          leading: ig-publicAppBarLeading(
            press: () => Navigator.pop(context),
          ),
          title: const ig-publicAppBarTitle(
            title: TextConstant.ig-publicMoneyPurchase,
          ),
        ),
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: ColorConfig().white(),
          child: Stack(
            children: [
              // 충전 영역
              SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 결제방법 타이틀 영역
                      purchaseAreaTitleWidget(title: TextConstant.purchaseMethod),
                      // 결제방법 데이터 영역
                      paymentMethod(),
                      // 충전하기 영역
                      Container(
                        width: MediaQuery.of(context).size.width,
                        color: ColorConfig().gray1(),
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 충전하기 타이틀 영역
                            purchaseAreaTitleWidget(title: TextConstant.purchaseChargeMethod, useRow: true),
                            // 충전금액 입력 영역
                            moneyPurchaseInputWidget(),
                            // 충전금액 버튼 영역
                            purchaseInputButtonWidget(),
                          ],
                        ),
                      ),
                      // 이용약관 타이틀 영역
                      purchaseAreaTitleWidget(title: TextConstant.termOfUse),
                      // 쿠폰 이용약관 체크리스트 영역
                      purchaseTermOfUseCheckListWidget(
                        index: 0,
                        text: TextConstant.agreeAllService,
                        onFirst: true,
                        press: () {
                          setState(() {
                            if (checkListStatuses[0]) {
                              checkListStatuses[0] = false;
                              checkListStatuses[1] = false;
                              checkListStatuses[2] = false;
                            } else {
                              checkListStatuses[0] = true;
                              checkListStatuses[1] = true;
                              checkListStatuses[2] = true;
                            }
                          });
                        },
                      ),
                      purchaseTermOfUseCheckListWidget(
                        index: 1,
                        text: TextConstant.agreeServiceTermOfUse,
                        press: () {
                          setState(() {
                            if (checkListStatuses[1]) {
                              checkListStatuses[1] = false;
                            } else {
                              checkListStatuses[1] = true;
                            }

                            if (checkListStatuses[1] && checkListStatuses[2]) {
                              checkListStatuses[0] = true;
                            } else {
                              checkListStatuses[0] = false;
                            }
                          });
                        },
                      ),
                      purchaseTermOfUseCheckListWidget(
                        index: 2,
                        text: TextConstant.agreeThirdPartyProviderInformation,
                        press: () {
                          setState(() {
                            if (checkListStatuses[2]) {
                              checkListStatuses[2] = false;
                            } else {
                              checkListStatuses[2] = true;
                            }

                            if (checkListStatuses[1] && checkListStatuses[2]) {
                              checkListStatuses[0] = true;
                            } else {
                              checkListStatuses[0] = false;
                            }
                          });
                        },
                      ),
                      purchaseFocusNode.hasFocus ? SizedBox(height: 72.0 + 16.0.sp) : Container(),
                    ],
                  ),
                ),
              ),
              // 버튼 영역
              ig-publicMoneyPurchaseButtonWidget(),
            ],
          ),
        ),
      ),
    );
  }

  // 구분자 타이틀 위젯
  Widget purchaseAreaTitleWidget({required String title, bool useRow = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.5),
      child: !useRow ? CustomTextBuilder(
        text: title,
        fontColor: ColorConfig().dark(),
        fontSize: 14.0.sp,
        fontWeight: FontWeight.w700,
      ) : Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomTextBuilder(
            text: title,
            fontColor: ColorConfig().dark(),
            fontSize: 14.0.sp,
            fontWeight: FontWeight.w700,
          ),
          Row(
            children: [
              SVGStringBuilder(
                image: 'assets/icon/money_won.svg',
                width: 16.0.w,
                height: 16.0.w,
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                child: CustomTextBuilder(
                  text: '${SetIntl().numberFormat(ig-publicMoney)}',
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
        ],
      ),
    );
  }

  // 결제수단 위젯
  Widget paymentMethod() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Wrap(
        children: List.generate(purchaseMethodName.length, (index) {
          return InkWell(
            onTap: () {
              setState(() {
                switch (index) {
                  case 0:
                    selectedPurchaseMethod = '신용카드';
                    selectedPurchaseMethodIndex = index;
                    payType = 'nice.entcrowd3m,card';
                    pg = 'nice.entcrowd3m';
                    payMethod = 'card';
                    break;
                  case 1:
                    selectedPurchaseMethod = '계좌이체';
                    selectedPurchaseMethodIndex = index;
                    payType = 'nice.entcrowd3m,vbank';
                    pg = 'nice.entcrowd3m';
                    payMethod = 'vbank';
                    break;
                  case 2:
                    selectedPurchaseMethod = '카카오페이';
                    selectedPurchaseMethodIndex = index;
                    payType = 'kakaopay.CA73G2OS30,card';
                    pg = 'kakaopay.CA73G2OS30';
                    payMethod = 'card';
                    break;
                  case 3:
                    selectedPurchaseMethod = '네이버페이';
                    selectedPurchaseMethodIndex = index;
                    payType = 'naverpay,card';
                    pg = 'naverpay';
                    payMethod = 'card';
                    break;
                }
              });
            },
            child: Container(
              width: (MediaQuery.of(context).size.width - 48.0) / 2,
              margin: index.isEven ? const EdgeInsets.only(right: 8.0, bottom: 8.0) : const EdgeInsets.only(bottom: 8.0),
              padding: const EdgeInsets.symmetric(vertical: 13.0),
              decoration: BoxDecoration(
                color: selectedPurchaseMethodIndex == index ? ColorConfig().primaryLight3() : ColorConfig().white(),
                border: Border.all(
                  width: 1.0,
                  color: selectedPurchaseMethodIndex == index ? ColorConfig().primary() : ColorConfig().gray2(),
                ),
                borderRadius: BorderRadius.circular(4.0.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  purchaseMethodName[index] == '카카오페이' ? Container(
                    width: 45.0.w,
                    height: 18.0.w,
                    margin: const EdgeInsets.only(right: 10.0),
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/img/kakao-payment.png'),
                        filterQuality: FilterQuality.high
                      ),
                    ),
                  ) : Container(),
                  purchaseMethodName[index] == '네이버페이' ? Container(
                    width: 45.0.w,
                    height: 18.0.w,
                    margin: const EdgeInsets.only(right: 10.0),
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/img/naver-payment.png'),
                        filterQuality: FilterQuality.high
                      ),
                    ),
                  ) : Container(),
                  CustomTextBuilder(
                    text: purchaseMethodName[index],
                    fontColor: ColorConfig().gray5(),
                    fontSize: 13.0.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  // 충전금액 입력 위젯
  Widget moneyPurchaseInputWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.5, vertical: 8.0),
      child: TextFormField(
        controller: purchaseTextController,
        focusNode: purchaseFocusNode,
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

  // ig-public머니 충전 이용약관 체크리스트 위젯
  Widget purchaseTermOfUseCheckListWidget({
    required String text,
    required int index,
    bool onFirst = false,
    Function()? press
  }) {
    return InkWell(
      onTap: press,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              width: 1.0,
              color: ColorConfig().gray1(),
            ),
          ),
        ),
        child: Row(
          children: [
            onFirst
              ? Container(
                width: 24.0.w,
                height: 24.0.w,
                decoration: BoxDecoration(
                  color: checkListStatuses[0] ? ColorConfig().primary() : ColorConfig().gray1(),
                  border: Border.all(
                    width: 1.0,
                    color: ColorConfig().gray2(),
                  ),
                  borderRadius: BorderRadius.circular(12.0.r),
                ),
                child: Center(
                  child: SVGBuilder(
                    image: 'assets/icon/check.svg',
                    width: 20.0.w,
                    height: 20.0.w,
                    color: checkListStatuses[0] ? ColorConfig().white() : ColorConfig().gray1(),
                  ),
                ),
              )
              : Container(
                  width: 24.0.w,
                  height: 24.0.w,
                  color: ColorConfig().white(),
                  child: SVGBuilder(
                    image: 'assets/icon/check.svg',
                    width: 20.0.w,
                    height: 20.0.w,
                    color: checkListStatuses[index] ? ColorConfig().gray5() : ColorConfig().gray2(),
                  ),
                ),
            Container(
              margin: const EdgeInsets.only(left: 16.0),
              child: CustomTextBuilder(
                text: text,
                fontColor: ColorConfig().dark(),
                fontSize: 12.0.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ig-public머니 충전하기 버튼 위젯
  Widget ig-publicMoneyPurchaseButtonWidget() {
    return Positioned(
      bottom: 0.0,
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 12.0),
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
        child: SafeArea(
          child: InkWell(
            onTap: () async {
              if (selectedPurchaseMethod.isEmpty) {
                ToastModel().toast('결제방법을 선택해주세요');
              } else if (purchaseTextController.text.isEmpty) {
                ToastModel().toast('충전금액을 입력해주세요');
              } else if (int.parse(purchaseTextController.text) % 1000 != 0) {
                ToastModel().toast('충전단위는 천원입니다');
              } else if (checkListStatuses[0] == false) {
                ToastModel().toast('이용약관을 모두 동의해주세요');
              }

              if (selectedPurchaseMethod.isNotEmpty && purchaseTextController.text.isNotEmpty && checkListStatuses[0] == true) {
                dynamic orderId = 'ig-public_app_mid_${DateTime.now().millisecondsSinceEpoch}';
                
                PaymentOrderAPI().order(accessToken: await SecureStorageConfig().storage.read(key: 'access_token'), orderId: orderId, payType: payType, amount: int.parse(purchaseTextController.text)).then((value) {
                  if (value.result['status'] == 1) {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ig-publicPayment(
                      pg: pg,
                      payMethod: payMethod,
                      amount: int.parse(purchaseTextController.text.replaceAll(',', '')),
                      mid: orderId,
                      buyerName: myProfileData['name'],
                      buyerTel: myProfileData['phone'],
                    )));
                  } else {
                    ToastModel().iconToast(value.result['message'], iconType: 2);
                  }
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 18.0),
              decoration: BoxDecoration(
                color: selectedPurchaseMethod.isNotEmpty && purchaseTextController.text.isNotEmpty && checkListStatuses[0] == true ? ColorConfig().primary() : ColorConfig().gray2(),
                borderRadius: BorderRadius.circular(4.0.r),
              ),
              child: Center(
                child: CustomTextBuilder(
                  text: TextConstant.ig-publicMoneyPurchasing,
                  fontColor: selectedPurchaseMethod.isNotEmpty && purchaseTextController.text.isNotEmpty && checkListStatuses[0] == true ? ColorConfig().white() : ColorConfig().gray3(),
                  fontSize: 16.0.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}