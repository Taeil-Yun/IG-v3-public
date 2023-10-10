import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ig-public_v3/api/payment/money_report.dart';
import 'package:ig-public_v3/costant/build_config.dart';

import 'package:ig-public_v3/costant/colors.dart';
import 'package:ig-public_v3/costant/text.dart';
import 'package:ig-public_v3/component/appbar/appbar.dart';
import 'package:ig-public_v3/component/appbar/appbar_leading.dart';
import 'package:ig-public_v3/component/appbar/appbar_title.dart';
import 'package:ig-public_v3/component/svg/svg_builder.dart';
import 'package:ig-public_v3/util/set_intl.dart';
import 'package:ig-public_v3/widget/custom_text_widget.dart';
import 'package:intl/intl.dart';

class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  List moneyReport = [];

  @override
  void initState() {
    super.initState();

    initializeAPI();
  }

  Future<void> initializeAPI() async {
    MoneyReportAPI().report(accessToken: await SecureStorageConfig().storage.read(key: 'access_token')).then((value) {
      setState(() {
        moneyReport = value.result['data']['report'];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ig-publicAppBar(
        leading: ig-publicAppBarLeading(
          press: () => Navigator.pop(context),
        ),
        title: const ig-publicAppBarTitle(
          title: TextConstant.earnAndPaymentHistory,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, 'moneyRefund');
            },
            child: CustomTextBuilder(
              text: TextConstant.doRefund,
              fontColor: ColorConfig().accent(),
              fontSize: 14.0.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: ColorConfig().white(),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 결제 및 적립 내역 영역
                moneyReport.isNotEmpty ? Column(
                  children: List.generate(moneyReport.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 내역 영역
                                CustomTextBuilder(
                                  text: moneyReport[index]['kind'] == -2
                                    ? 'ig-public머니 환불'
                                    : moneyReport[index]['kind'] == -1
                                      ? 'ig-public머니 충전'
                                      : moneyReport[index]['kind'] == 0
                                        ? '${moneyReport[index]['name']} 예매'
                                        : moneyReport[index]['kind'] == 1
                                          ? '${moneyReport[index]['name']} 예매취소'
                                          : moneyReport[index]['kind'] == 2
                                            ? '${moneyReport[index]['name']} 경매'
                                            : moneyReport[index]['kind'] == 3
                                              ? '${moneyReport[index]['name']} 경매실패'
                                              : moneyReport[index]['kind'] == 4
                                                ? '${moneyReport[index]['name']} 경매취소'
                                                : moneyReport[index]['kind'] == 5
                                                  ? '${moneyReport[index]['name']} 경매 취소수수료'
                                                  : moneyReport[index]['kind'] == 6
                                                    ? '${moneyReport[index]['name']} 경매 금액 올리기'
                                                    : moneyReport[index]['kind'] == 7
                                                      ? '${moneyReport[index]['name']} 예매 취소수수료'
                                                      : '',
                                  fontColor: ColorConfig().dark(),
                                  fontSize: 14.0.sp,
                                  fontWeight: FontWeight.w800,
                                ),
                                // 공연일 영역
                                moneyReport[index]['kind'] != -2 || moneyReport[index]['kind'] != - 1 ? Container(
                                  margin: const EdgeInsets.only(top: 2.0),
                                  child: CustomTextBuilder(
                                    text: DateFormat('M월 d일 a h시 m분', 'ko').format(DateTime.parse(moneyReport[index]['open_date']).toLocal()),
                                    fontColor: ColorConfig().dark(),
                                    fontSize: 12.0.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ) : Container(),
                                // 날짜 영역
                                Container(
                                  margin: const EdgeInsets.only(top: 8.0),
                                  child: CustomTextBuilder(
                                    text: DateFormat('yyyy. M. d. · a h:m', 'ko').format(DateTime.parse(moneyReport[index]['create_dt']).toLocal()),
                                    fontColor: ColorConfig().gray3(),
                                    fontSize: 11.0.sp,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // 금액 영역
                          Container(
                            margin: const EdgeInsets.only(left: 16.0),
                            child: Row(
                              children: [
                                CustomTextBuilder(
                                  text: moneyReport[index]['type'] == 'M' ? '-' : '+',
                                  fontColor: moneyReport[index]['type'] == 'M' ? ColorConfig().accent() : ColorConfig().gray3(),
                                  fontSize: 14.0.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                                Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                                  child: SVGStringBuilder(
                                    image: 'assets/icon/money_won.svg',
                                    width: 16.0.w,
                                    height: 16.0.w,
                                  ),
                                ),
                                CustomTextBuilder(
                                  text: '${SetIntl().numberFormat(moneyReport[index]['price'].abs())}',
                                  fontColor: moneyReport[index]['type'] == 'M' ? ColorConfig().accent() : ColorConfig().dark(),
                                  fontSize: 14.0.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ) : SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 1.5,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80.0.w,
                        height: 80.0.w,
                        margin: const EdgeInsets.only(bottom: 24.0),
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/img/no-data-payment.png'),
                            filterQuality: FilterQuality.high,
                          ),
                        ),
                      ),
                      CustomTextBuilder(
                        text: '결제내역이 없습니다.',
                        fontColor: ColorConfig().gray4(),
                        fontSize: 14.0.sp,
                        fontWeight: FontWeight.w400,
                        height: 1.2,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}