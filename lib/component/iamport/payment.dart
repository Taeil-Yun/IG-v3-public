// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/* 아임포트 결제 모듈을 불러옵니다. */
import 'package:iamport_flutter/iamport_payment.dart';
/* 아임포트 결제 데이터 모델을 불러옵니다. */
import 'package:iamport_flutter/model/payment_data.dart';
import 'package:ig-public_v3/api/payment/payment_complete.dart';
import 'package:ig-public_v3/component/appbar/appbar.dart';
import 'package:ig-public_v3/component/appbar/appbar_leading.dart';
import 'package:ig-public_v3/component/appbar/appbar_title.dart';
import 'package:ig-public_v3/component/popup/popup.dart';
import 'package:ig-public_v3/costant/build_config.dart';
import 'package:ig-public_v3/costant/colors.dart';
import 'package:ig-public_v3/costant/text.dart';
import 'package:ig-public_v3/main.dart';
import 'package:ig-public_v3/util/toast.dart';
import 'package:ig-public_v3/widget/custom_text_widget.dart';

import 'package:intl/intl.dart';

class ig-publicPayment extends StatefulWidget {
  var pg,
      payMethod,
      amount,
      mid,
      buyerName,
      buyerTel;

  ig-publicPayment(
    {
    Key? key,
    required this.pg,
    this.payMethod,
    this.amount,
    this.mid,
    this.buyerName,
    this.buyerTel,
  }) : super(key: key);

  @override
  State<ig-publicPayment> createState() => _ig-publicPaymentState();
}

class _ig-publicPaymentState extends State<ig-publicPayment> {
  final String dateFormat = "yyyy년 M월 d일 까지";
  var addFor7Days = DateTime.now().add(const Duration(days: 7));

  @override
  void initState() {
    super.initState();

    // FacebookPixelModel().fbLogEvent(name: 'ig-publicMoneyPGModule', params: {
    //   'pg_status': 'ig-public머니 결제모듈 이동',
    //   'pg': '${widget.pg}',
    //   'pay_method': '${widget.payMethod}',
    //   'mid': '${widget.mid}',
    //   'price': '${widget.amount}',
    // });

    // ig-publicAnalyticsEvent().logEvent('ig-publicMoneyPGModule', {
    //   'pg': '${widget.pg}',
    //   'pay_method': '${widget.payMethod}',
    //   'mid': '${widget.mid}',
    //   'price': '${widget.amount}',
    // });
  }

  @override
  Widget build(BuildContext context) {
    return IamportPayment(
      appBar: ig-publicAppBar(
        leading: ig-publicAppBarLeading(
          press: () => Navigator.pop(context),
        ),
        title: const ig-publicAppBarTitle(
          title: 'ig-public 결제하기',
        ),
      ),
      /* 웹뷰 로딩 컴포넌트 */
      initialChild: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image.asset('assets/images/iamport-logo.png'),
            Container(
              padding: const EdgeInsets.fromLTRB(0.0, 30.0, 0.0, 0.0),
              child: const Text('잠시만 기다려주세요...',
                  style: TextStyle(fontSize: 20.0)),
            ),
          ],
        ),
      ),
      /* [필수입력] 가맹점 식별코드 */
      userCode: 'imp93678652',
      /* [필수입력] 결제 데이터 */
      data: PaymentData(
        pg: widget.pg,
        payMethod: widget.payMethod,
        name: 'ig-public머니',
        merchantUid: widget.mid,
        amount: widget.amount,
        buyerName: widget.buyerName,
        buyerTel: widget.buyerTel,
        appScheme: ig-publicBuildConfig.instance?.buildType == 'dev' ? 'ig-publicdeventcrowd' : 'ig-publicentcrowd',
        vbankDue: DateFormat('yyyy.MM.dd HH:mm').format(addFor7Days),
      ),
      /* [필수입력] 콜백 함수 */
      callback: (Map<String, String> result) async {
        if (result['imp_success'] == 'false') {
          PopupBuilder(
            title: '결제취소',
            content: '${result['error_msg']}',
            barrierDismissible: false,
            actions: [
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  decoration: BoxDecoration(
                    color: ColorConfig().dark(),
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
            ],
          ).ig-publicDialog(context);
        } else {
          PaymentCompleteAPI().complete(accessToken: await SecureStorageConfig().storage.read(key: 'access_token'), impUid: result['imp_uid']!).then((value) {
            if (value.result['status'] == 1 || value.result['status'] == 2) {
              PopupBuilder(
                title: value.result['message']['title'],
                content: value.result['message']['content'],
                barrierDismissible: false,
                actions: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => MainBuilder(crnIndex: 2)), (route) => false);
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      decoration: BoxDecoration(
                        color: ColorConfig().dark(),
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
                ],
              ).ig-publicDialog(context);
            } else if (value.result['status'] == -1 || value.result['status'] == -2) {
              PopupBuilder(
                title: value.result['message']['title'],
                content: value.result['message']['content'],
                barrierDismissible: false,
                actions: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      decoration: BoxDecoration(
                        color: ColorConfig().dark(),
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
                ],
              ).ig-publicDialog(context);
            }
          });
            // FacebookPixelModel().fbLogEvent(name: 'ig-publicMoneyPurchaseComplete', params: {
            //   'ig-public_money_purchase': 'ig-public머니 충전 완료',
            // });

            // ig-publicAnalyticsEvent().logEvent('ig-publicMoneyPurchaseComplete', {
            //   'id': 'complete'
            // });

            // KakaoPixelModel().sendKakaoPixelEvent(method: 'moneyPurchaseCom', params: {
            //   'totalQuantity': 1,
            //   'totalPrice': widget.amount,
            //   'currency': 'KRW',
            //   'id': 'ig-public',
            //   'name': 'ig-public머니',
            //   'quantity': 1,
            //   'price': widget.amount,
            // });
        }
      },
    );
  }
}
