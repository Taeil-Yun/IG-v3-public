import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:ig-public_v3/api/ticket/ticket_cancel.dart';
import 'package:ig-public_v3/component/popup/popup.dart';
import 'package:ig-public_v3/costant/build_config.dart';
import 'package:ig-public_v3/costant/colors.dart';
import 'package:ig-public_v3/costant/text.dart';
import 'package:ig-public_v3/component/appbar/appbar.dart';
import 'package:ig-public_v3/component/appbar/appbar_leading.dart';
import 'package:ig-public_v3/component/appbar/appbar_title.dart';
import 'package:ig-public_v3/component/svg/svg_builder.dart';
import 'package:ig-public_v3/src/route_argument.dart';
import 'package:ig-public_v3/util/set_intl.dart';
import 'package:ig-public_v3/util/toast.dart';
import 'package:ig-public_v3/widget/custom_text_widget.dart';
import 'package:intl/intl.dart';

class TicketCancelScreen extends StatefulWidget {
  const TicketCancelScreen({super.key});

  @override
  State<TicketCancelScreen> createState() => _TicketCancelScreenState();
}

class _TicketCancelScreenState extends State<TicketCancelScreen> {
  Map<String, dynamic> ticketData = {};

  List checkBoxStatus = [];
  List cancelSeatList = [];

  int cancelTotalPrice = 0;
  int cancelFee = 0;
  int showCouponTotalPrice = 0;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      setState(() {
        if (RouteGetArguments().getArgs(context)['ticket_data'] != null) {
          ticketData = RouteGetArguments().getArgs(context)['ticket_data'];
          
          for (int i=0; i<ticketData['tickets'].length; i++) {
            checkBoxStatus.add(false);
          }

          if (ticketData['coupon'].isNotEmpty) {
            for (int i=0; i<ticketData['coupon'].length; i++) {
              if (ticketData['coupon'][i]['type'] == 1) {
                showCouponTotalPrice += int.parse(ticketData['coupon'][i]['point'].toString());
              }
            }
          }
        }
      });
    });
  }

  dynamic cancelFeesCalculator(data, checks, usedPrice) {
    int lUsePrice = usedPrice;
    List activeList = [];

    for(int i=0; i<ticketData['tickets'].length; i++ ){
      if(checks[i]){
        activeList.add(ticketData['tickets'][i]);
      }
    }

    for (var e in activeList) {
      if(lUsePrice >= e['price']) {
        e['paid_price'] = e['price'];
        lUsePrice = int.parse((lUsePrice - e['price']).toString());
      } else {
        e['paid_price'] = lUsePrice;
      }
    }

    for (var e in activeList) {
      int deadlineDate = int.parse(DateTime.parse(ticketData['show']['open_date']).toLocal().difference(DateTime.now()).inDays.toString()) + 1;

      e['fees'] = 0;
    
      if (deadlineDate >= 10) {
        e['fees'] = e['paid_price'] >= 4000 ? 4000 : e['paid_price'];
      } else if (deadlineDate < 10 && deadlineDate >= 7) {
        if ((int.parse(e['price'].toString()) * 0.1).toInt() < 4000) {
          e['fees'] = e['paid_price'] >= 4000 ? 4000 : e['paid_price'];
        } else {
          if(e['paid_price'] >= (int.parse(e['price'].toString()) * 0.1).toInt()) {
            e['fees'] = (int.parse(e['price'].toString()) * 0.1).toInt();
          } else {
            e['fees'] = e['paid_price'];
          }
        }
      } else if (deadlineDate < 7 && deadlineDate >= 3) {
        if ((int.parse(e['price'].toString()) * 0.2).toInt() < 4000) {
          e['fees'] = e['paid_price'] >= 4000 ? 4000 : e['paid_price'];
        } else {
          if(e['paid_price'] >= (int.parse(e['price'].toString()) * 0.2).toInt()) {
            e['fees'] = (int.parse(e['price'].toString()) * 0.2).toInt();
          } else {
            e['fees'] = e['paid_price'];
          }
        }
      } else if (deadlineDate < 3 && deadlineDate >= 2 && DateTime.parse(ticketData['show']['open_date']).toLocal().millisecondsSinceEpoch > DateTime.now().millisecondsSinceEpoch) {
        if ((int.parse(e['price'].toString()) * 0.3).toInt() < 4000) {
          e['fees'] = e['paid_price'] >= 4000 ? 4000 : e['paid_price'];
        } else {
          if(e['paid_price'] >= (int.parse(e['price'].toString()) * 0.3).toInt()) {
            e['fees'] = (int.parse(e['price'].toString()) * 0.3).toInt();
          } else {
            e['fees'] = e['paid_price'];
          }
        }
      }
    }

    int cancelFees = activeList.fold(0, (total, element) {
      return total + int.parse(element['fees'].toString());
    });

    int cancelMoney = activeList.fold(0, (total, element) {
      return total + int.parse(element['paid_price'].toString());
    });

    int totalMoney = activeList.fold(0, (total, element) {
      return cancelMoney - cancelFees;
    });

    return {
      'cancelMoney': cancelMoney,
      'cancelFees': cancelFees,
      'totalMoney': totalMoney
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ig-publicAppBar(
        leading: ig-publicAppBarLeading(
          press: () => Navigator.pop(context),
        ),
        title: const ig-publicAppBarTitle(
          title: TextConstant.ticketCancel,
        ),
      ),
      body: ticketData.isNotEmpty ? Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: ColorConfig().white(),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  const SizedBox(height: 8.0),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: Column(
                        children: [
                          // 선택한 공연 타이틀 영역
                          Container(
                            width: MediaQuery.of(context).size.width,
                            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                            child: CustomTextBuilder(
                              text: TextConstant.selectedShow,
                              fontColor: ColorConfig().dark(),
                              fontSize: 14.0.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          // 공연 정보 영역
                          Container(
                            width: MediaQuery.of(context).size.width,
                            padding: const EdgeInsets.fromLTRB(20.0, 4.0, 20.0, 16.0),
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
                              decoration: BoxDecoration(
                                color: ColorConfig().white(),
                                borderRadius: BorderRadius.circular(4.0.r),
                                boxShadow: [
                                  BoxShadow(
                                    offset: const Offset(0.0, 1.0),
                                    blurRadius: 4.0,
                                    color: ColorConfig.defaultBlack.withOpacity(0.04),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // 포스터 영역
                                    Container(
                                      width: 80.0.w,
                                      height: 114.0.w,
                                      margin: const EdgeInsets.only(right: 16.0),
                                      decoration: BoxDecoration(
                                        color: ticketData['show']['image'] == null ? ColorConfig().gray2() : null,
                                        borderRadius: BorderRadius.circular(4.0.r),
                                        image: ticketData['show']['image'] != null ? DecorationImage(
                                          image: NetworkImage(ticketData['show']['image']),
                                          fit: BoxFit.cover,
                                          filterQuality: FilterQuality.high,
                                        ) : null,
                                      ),
                                      child: ticketData['show']['image'] == null ? Center(
                                        child: SVGBuilder(
                                          image: 'assets/icon/album.svg',
                                          width: 24.0.w,
                                          height: 24.0.w,
                                          color: ColorConfig().white(),
                                        ),
                                      ) : Container(),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // 공연 제목 영역
                                          Container(
                                            margin: const EdgeInsets.only(bottom: 8.0),
                                            child: CustomTextBuilder(
                                              text: '${ticketData['show']['name']}',
                                              fontColor: ColorConfig().dark(),
                                              fontSize: 14.0.sp,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          // 공연일 영역
                                          CustomTextBuilder(
                                            text: DateFormat('yyyy. M. d. · a H시 m분', 'ko').format(DateTime.parse(ticketData['show']['open_date']).toLocal()),
                                            fontColor: ColorConfig().gray5(),
                                            fontSize: 12.0.sp,
                                            fontWeight: FontWeight.w700,
                                          ),
                                          // 좌석 영역
                                          Container(
                                            margin: const EdgeInsets.symmetric(vertical: 4.0),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  margin: const EdgeInsets.only(right: 8.0),
                                                  child: CustomTextBuilder(
                                                    text: TextConstant.seat,
                                                    fontColor: ColorConfig().gray4(),
                                                    fontSize: 12.0.sp,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: List.generate(ticketData['tickets'].length, (seatIndex) {
                                                      return CustomTextBuilder(
                                                        text: '${ticketData['tickets'][seatIndex]['seat_name']}석 ${ticketData['tickets'][seatIndex]['name']}',
                                                        fontColor: ColorConfig().dark(),
                                                        fontSize: 12.0.sp,
                                                        fontWeight: FontWeight.w700,
                                                        height: seatIndex != 0 ? 1.15 : null,
                                                      );
                                                    }),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // 선택한 공연 타이틀 영역
                          Container(
                            width: MediaQuery.of(context).size.width,
                            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                            child: CustomTextBuilder(
                              text: TextConstant.wantCancelSelect,
                              fontColor: ColorConfig().dark(),
                              fontSize: 14.0.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          // 취소할 좌석 선택 영역
                          Column(
                            children: List.generate(ticketData['tickets'].length, (seatIndex) {
                              return InkWell(
                                onTap: () {
                                  // int deadlineDate = int.parse(DateTime.parse(ticketData['show']['end_date']).toLocal().difference(DateTime.now()).inDays.toString());

                                  setState(() {
                                    checkBoxStatus[seatIndex] = !checkBoxStatus[seatIndex];

                                    if (checkBoxStatus[seatIndex] == true) {
                                      cancelSeatList.add(ticketData['tickets'][seatIndex]['ticket_print_index']);

                                      // cancelTotalPrice += int.parse(ticketData['tickets'][seatIndex]['price'].toString());

                                      // if (ticketData['coupon'].isEmpty) {
                                      //   if (deadlineDate >= 10) {
                                      //     cancelFee += 4000;
                                      //   } else if (deadlineDate < 10 && deadlineDate >= 7) {
                                      //     if ((int.parse(ticketData['tickets'][seatIndex]['price'].toString()) * 0.1).toInt() < 4000) {
                                      //       cancelFee += 4000;
                                      //     } else {
                                      //       cancelFee += (int.parse(ticketData['tickets'][seatIndex]['price'].toString()) * 0.1).toInt();
                                      //     }
                                      //   } else if (deadlineDate < 7 && deadlineDate >= 3) {
                                      //     if ((int.parse(ticketData['tickets'][seatIndex]['price'].toString()) * 0.2).toInt() < 4000) {
                                      //       cancelFee += 4000;
                                      //     } else {
                                      //       cancelFee += (int.parse(ticketData['tickets'][seatIndex]['price'].toString()) * 0.2).toInt();
                                      //     }
                                      //   } else if (deadlineDate < 3 && deadlineDate >= 2 && DateTime.parse(ticketData['show']['end_date']).toLocal().millisecondsSinceEpoch > DateTime.now().millisecondsSinceEpoch) {
                                      //     if ((int.parse(ticketData['tickets'][seatIndex]['price'].toString()) * 0.3).toInt() < 4000) {
                                      //       cancelFee += 4000;
                                      //     } else {
                                      //       cancelFee += (int.parse(ticketData['tickets'][seatIndex]['price'].toString()) * 0.3).toInt();
                                      //     }
                                      //   }
                                      // } else {
                                      //   if (ticketData['tickets'][0]['paid_price'] >= ticketData['totla_coupon_point']) {
                                      //     ticketData['tickets'][0]['paid_price'] -= ticketData['tickets'][seatIndex]['price'];

                                      //     if (deadlineDate >= 10) {
                                      //       cancelFee += 4000;
                                      //     } else if (deadlineDate < 10 && deadlineDate >= 7) {
                                      //       if ((int.parse(ticketData['tickets'][seatIndex]['price'].toString()) * 0.1).toInt() < 4000) {
                                      //         cancelFee += 4000;
                                      //       } else {
                                      //         cancelFee += (int.parse(ticketData['tickets'][seatIndex]['price'].toString()) * 0.1).toInt();
                                      //       }
                                      //     } else if (deadlineDate < 7 && deadlineDate >= 3) {
                                      //       if ((int.parse(ticketData['tickets'][seatIndex]['price'].toString()) * 0.2).toInt() < 4000) {
                                      //         cancelFee += 4000;
                                      //       } else {
                                      //         cancelFee += (int.parse(ticketData['tickets'][seatIndex]['price'].toString()) * 0.2).toInt();
                                      //       }
                                      //     } else if (deadlineDate < 3 && deadlineDate >= 2 && DateTime.parse(ticketData['show']['end_date']).toLocal().millisecondsSinceEpoch > DateTime.now().millisecondsSinceEpoch) {
                                      //       if ((int.parse(ticketData['tickets'][seatIndex]['price'].toString()) * 0.3).toInt() < 4000) {
                                      //         cancelFee += 4000;
                                      //       } else {
                                      //         cancelFee += (int.parse(ticketData['tickets'][seatIndex]['price'].toString()) * 0.3).toInt();
                                      //       }
                                      //     }
                                      //   }
                                      // }

                                      // if (ticketData['coupon'].isNotEmpty && (checkBoxStatus.contains(false) == false)) {
                                      //   if (showCouponTotalPrice > cancelTotalPrice) {
                                          
                                      //   } else {
                                      //     cancelTotalPrice -= showCouponTotalPrice;
                                      //   }
                                      // }
                                    } else {
                                      cancelSeatList.remove(ticketData['tickets'][seatIndex]['ticket_print_index']);

                                      // cancelTotalPrice -= int.parse(ticketData['tickets'][seatIndex]['price'].toString());

                                      // if (ticketData['coupon'].isEmpty) {
                                      //   if (deadlineDate >= 10) {
                                      //     cancelFee -= 4000;
                                      //   } else if (deadlineDate < 10 && deadlineDate >= 7) {
                                      //     if ((int.parse(ticketData['tickets'][seatIndex]['price'].toString()) * 0.1).toInt() < 4000) {
                                      //       cancelFee -= 4000;
                                      //     } else {
                                      //       cancelFee -= (int.parse(ticketData['tickets'][seatIndex]['price'].toString()) * 0.1).toInt();
                                      //     }
                                      //   } else if (deadlineDate < 7 && deadlineDate >= 3) {
                                      //     if ((int.parse(ticketData['tickets'][seatIndex]['price'].toString()) * 0.2).toInt() < 4000) {
                                      //       cancelFee -= 4000;
                                      //     } else {
                                      //       cancelFee -= (int.parse(ticketData['tickets'][seatIndex]['price'].toString()) * 0.2).toInt();
                                      //     }
                                      //   } else if (deadlineDate < 3 && deadlineDate >= 2 && DateTime.parse(ticketData['show']['end_date']).toLocal().millisecondsSinceEpoch > DateTime.now().millisecondsSinceEpoch) {
                                      //     if ((int.parse(ticketData['tickets'][seatIndex]['price'].toString()) * 0.3).toInt() < 4000) {
                                      //       cancelFee -= 4000;
                                      //     } else {
                                      //       cancelFee -= (int.parse(ticketData['tickets'][seatIndex]['price'].toString()) * 0.3).toInt();
                                      //     }
                                      //   }
                                      // } else {
                                      //   if (ticketData['tickets'][0]['paid_price'] != 0) {
                                      //     if (deadlineDate >= 10) {
                                      //       cancelFee -= 4000;
                                      //     } else if (deadlineDate < 10 && deadlineDate >= 7) {
                                      //       if ((int.parse(ticketData['tickets'][seatIndex]['price'].toString()) * 0.1).toInt() < 4000) {
                                      //         cancelFee -= 4000;
                                      //       } else {
                                      //         cancelFee -= (int.parse(ticketData['tickets'][seatIndex]['price'].toString()) * 0.1).toInt();
                                      //       }
                                      //     } else if (deadlineDate < 7 && deadlineDate >= 3) {
                                      //       if ((int.parse(ticketData['tickets'][seatIndex]['price'].toString()) * 0.2).toInt() < 4000) {
                                      //         cancelFee -= 4000;
                                      //       } else {
                                      //         cancelFee -= (int.parse(ticketData['tickets'][seatIndex]['price'].toString()) * 0.2).toInt();
                                      //       }
                                      //     } else if (deadlineDate < 3 && deadlineDate >= 2 && DateTime.parse(ticketData['show']['end_date']).toLocal().millisecondsSinceEpoch > DateTime.now().millisecondsSinceEpoch) {
                                      //       if ((int.parse(ticketData['tickets'][seatIndex]['price'].toString()) * 0.3).toInt() < 4000) {
                                      //         cancelFee -= 4000;
                                      //       } else {
                                      //         cancelFee -= (int.parse(ticketData['tickets'][seatIndex]['price'].toString()) * 0.3).toInt();
                                      //       }
                                      //     }
                                      //   }
                                        
                                      //   if (ticketData['tickets'][0]['paid_price'] < ticketData['use_money']) {
                                      //     ticketData['tickets'][0]['paid_price'] += ticketData['tickets'][seatIndex]['price'];
                                      //   }
                                      // }

                                      // if (ticketData['coupon'].isNotEmpty) {
                                      //   List falseCheckL = checkBoxStatus.where((element) => element == false).toList();

                                      //   if (falseCheckL.length == 1) {
                                      //     cancelTotalPrice += showCouponTotalPrice;
                                      //   }
                                      // }
                                    }
                                  });
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                    decoration: BoxDecoration(
                                      color: ColorConfig().white(),
                                      border: Border.all(
                                        width: 1.0,
                                        color: ColorConfig().gray2(),
                                      ),
                                      borderRadius: BorderRadius.circular(6.0.r),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 24.0.w,
                                          height: 24.0.w,
                                          margin: const EdgeInsets.only(right: 10.0),
                                          child: Checkbox(
                                            activeColor: ColorConfig().primary(),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(100.0.r),
                                            ),
                                            value: checkBoxStatus[seatIndex],
                                            onChanged: (e) {
                                              setState(() {
                                                checkBoxStatus[seatIndex] = e;
                                              });
                                            },
                                          ),
                                        ),
                                        Expanded(
                                          child: CustomTextBuilder(
                                            text: '${ticketData['tickets'][seatIndex]['seat_name']}석 ${ticketData['tickets'][seatIndex]['name']}',
                                            fontColor: ColorConfig().dark(),
                                            fontSize: 12.0.sp,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 8.0),
                          // 결제정보 타이틀 영역
                          Container(
                            width: MediaQuery.of(context).size.width,
                            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                            child: CustomTextBuilder(
                              text: TextConstant.purchaseInformation,
                              fontColor: ColorConfig().dark(),
                              fontSize: 14.0.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          // 총 금액 영역
                          Container(
                            width: MediaQuery.of(context).size.width,
                            padding: const EdgeInsets.fromLTRB(20.0, 4.0, 20.0, 1.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CustomTextBuilder(
                                  text: TextConstant.totalPrice,
                                  fontColor: ColorConfig().gray4(),
                                  fontSize: 12.0.sp,
                                  fontWeight: FontWeight.w700,
                                  height: 1.2,
                                ),
                                CustomTextBuilder(
                                  text: '${SetIntl().numberFormat(ticketData['total_price'])} 원',
                                  fontColor: ColorConfig().dark(),
                                  fontSize: 12.0.sp,
                                  fontWeight: FontWeight.w700,
                                  height: 1.2,
                                ),
                              ],
                            ),
                          ),
                          // ig-public머니 사용 영역
                          Container(
                            width: MediaQuery.of(context).size.width,
                            padding: const EdgeInsets.fromLTRB(20.0, 4.0, 20.0, 1.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CustomTextBuilder(
                                  text: TextConstant.useig-publicMoney,
                                  fontColor: ColorConfig().gray4(),
                                  fontSize: 12.0.sp,
                                  fontWeight: FontWeight.w700,
                                  height: 1.2,
                                ),
                                CustomTextBuilder(
                                  text: '${SetIntl().numberFormat(ticketData['use_money'])} 원',
                                  fontColor: ColorConfig().dark(),
                                  fontSize: 12.0.sp,
                                  fontWeight: FontWeight.w700,
                                  height: 1.2,
                                ),
                              ],
                            ),
                          ),
                          // 쿠폰사용 영역
                          Container(
                            width: MediaQuery.of(context).size.width,
                            padding: const EdgeInsets.fromLTRB(20.0, 4.0, 20.0, 1.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CustomTextBuilder(
                                  text: TextConstant.useCoupon,
                                  fontColor: ColorConfig().gray4(),
                                  fontSize: 12.0.sp,
                                  fontWeight: FontWeight.w700,
                                  height: 1.2,
                                ),
                                CustomTextBuilder(
                                  text: '${SetIntl().numberFormat(ticketData['totla_coupon_point'])} 원',
                                  fontColor: ColorConfig().dark(),
                                  fontSize: 12.0.sp,
                                  fontWeight: FontWeight.w700,
                                  height: 1.2,
                                ),
                              ],
                            ),
                          ),
                          // 사용한 쿠폰 영역
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: List.generate(ticketData['coupon'].length, (useCouponIndex) {
                              return Container(
                                width: MediaQuery.of(context).size.width,
                                padding: const EdgeInsets.fromLTRB(20.0, 4.0, 20.0, 1.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    CustomTextBuilder(
                                      text: 'ㄴ${ticketData['coupon'][useCouponIndex]['name']}',
                                      fontColor: ColorConfig().gray4(),
                                      fontSize: 12.0.sp,
                                      fontWeight: FontWeight.w700,
                                      height: 1.2,
                                    ),
                                    CustomTextBuilder(
                                      text: '-${SetIntl().numberFormat(ticketData['coupon'][useCouponIndex]['point'])} 원',
                                      fontColor: ColorConfig().dark(),
                                      fontSize: 12.0.sp,
                                      fontWeight: FontWeight.w700,
                                      height: 1.2,
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 8.0),
                          // 환불내역 타이틀 영역
                          Container(
                            width: MediaQuery.of(context).size.width,
                            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                            child: CustomTextBuilder(
                              text: TextConstant.refundHistory,
                              fontColor: ColorConfig().dark(),
                              fontSize: 14.0.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          // 취소금액 영역
                          Container(
                            width: MediaQuery.of(context).size.width,
                            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CustomTextBuilder(
                                  text: TextConstant.cancelPrice,
                                  fontColor: ColorConfig().dark(),
                                  fontSize: 14.0.sp,
                                  fontWeight: FontWeight.w800,
                                ),
                                CustomTextBuilder(
                                  text: '${SetIntl().numberFormat(cancelFeesCalculator(ticketData['tickets'], checkBoxStatus, ticketData['use_money'])['cancelMoney'])} 원',
                                  fontColor: ColorConfig().dark(),
                                  fontSize: 14.0.sp,
                                  fontWeight: FontWeight.w800,
                                ),
                              ],
                            ),
                          ),
                          // 취소수수료 영역
                          Container(
                            width: MediaQuery.of(context).size.width,
                            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(right: 4.0),
                                      child: CustomTextBuilder(
                                        text: TextConstant.cancelFee,
                                        fontColor: ColorConfig().dark(),
                                        fontSize: 14.0.sp,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    SVGBuilder(
                                      image: 'assets/icon/info.svg',
                                      width: 20.0.w,
                                      height: 20.0.w,
                                      color: ColorConfig().gray3(),
                                    ),
                                  ],
                                ),
                                CustomTextBuilder(
                                  text: '-${SetIntl().numberFormat(cancelFeesCalculator(ticketData['tickets'], checkBoxStatus, ticketData['use_money'])['cancelFees'])} 원',
                                  fontColor: ColorConfig().dark(),
                                  fontSize: 14.0.sp,
                                  fontWeight: FontWeight.w800,
                                ),
                              ],
                            ),
                          ),
                          // 취소수수료 영역
                          Container(
                            width: MediaQuery.of(context).size.width,
                            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CustomTextBuilder(
                                  text: TextConstant.totalRefundPrice,
                                  fontColor: ColorConfig().dark(),
                                  fontSize: 14.0.sp,
                                  fontWeight: FontWeight.w800,
                                ),
                                CustomTextBuilder(
                                  text: '${SetIntl().numberFormat(cancelFeesCalculator(ticketData['tickets'], checkBoxStatus, ticketData['use_money'])['totalMoney'])} 원',
                                  fontColor: ColorConfig().accent(),
                                  fontSize: 14.0.sp,
                                  fontWeight: FontWeight.w800,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 40.0),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24.0 + 36.0 + 16.0.sp,),  // 선택좌석 환불하기 박스 높이값만큼 올려주기
                ],
              ),
              Positioned(
                bottom: 0.0,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                  decoration: BoxDecoration(
                    color: ColorConfig().white(),
                    boxShadow: [
                      BoxShadow(
                        offset: const Offset(0.0, -8.0),
                        blurRadius: 8.0,
                        color: ColorConfig.defaultBlack.withOpacity(0.12),
                      ),
                    ],
                  ),
                  child: InkWell(
                    onTap: checkBoxStatus.contains(true) == true ? () {
                      PopupBuilder(
                        title: TextConstant.refundPopupTitle,
                        content: TextConstant.refundPopupContent,
                        actions: [
                          Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  width: (MediaQuery.of(context).size.width - 112.0.w) / 2,
                                  margin: EdgeInsets.only(right: 8.0.w),
                                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                                  decoration: BoxDecoration(
                                    color: ColorConfig().gray3(),
                                    borderRadius: BorderRadius.circular(4.0.r),
                                  ),
                                  child: Center(
                                    child: CustomTextBuilder(
                                      text: TextConstant.cancel,
                                      fontColor: ColorConfig().white(),
                                      fontSize: 14.0.sp,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () async {
                                  TicketCancelAPI().ticketCancel(accessToken: await SecureStorageConfig().storage.read(key: 'access_token'), ticketIndex: cancelSeatList).then((cancelData) {
                                    if (cancelData.result['status'] == 1) {
                                      ToastModel().iconToast(cancelData.result['message']);

                                      Navigator.pop(context);
                                      Navigator.pop(context, 'cancelComplete');
                                    }
                                  });
                                },
                                child: Container(
                                  width: (MediaQuery.of(context).size.width - 112.0.w) / 2,
                                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                                  decoration: BoxDecoration(
                                    color: ColorConfig().dark(),
                                    borderRadius: BorderRadius.circular(4.0.r),
                                  ),
                                  child: Center(
                                    child: CustomTextBuilder(
                                      text: TextConstant.doRefund,
                                      fontColor: ColorConfig().white(),
                                      fontSize: 14.0.sp,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ).ig-publicDialog(context);
                    } : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 18.0),
                      decoration: BoxDecoration(
                        color: checkBoxStatus.contains(true) == true ? ColorConfig().primary() : ColorConfig().gray2(),
                        borderRadius: BorderRadius.circular(4.0.r),
                      ),
                      child: Center(
                        child: CustomTextBuilder(
                          text: TextConstant.selectSeatRefund,
                          fontColor: checkBoxStatus.contains(true) == true ? ColorConfig().white() : ColorConfig().gray3(),
                          fontSize: 16.0.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ) : Container(),
    );
  }
}