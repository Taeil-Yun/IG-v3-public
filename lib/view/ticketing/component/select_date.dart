import 'package:flutter/material.dart';
import 'package:ig-public_v3/costant/enumerated.dart';

import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:ig-public_v3/costant/text.dart';
import 'package:ig-public_v3/costant/default_value.dart';
import 'package:ig-public_v3/costant/colors.dart';
import 'package:ig-public_v3/component/appbar/appbar.dart';
import 'package:ig-public_v3/component/appbar/appbar_title.dart';
import 'package:ig-public_v3/component/svg/svg_builder.dart';
import 'package:ig-public_v3/widget/custom_text_widget.dart';
import 'package:ig-public_v3/widget/month_pn.dart';

class SelectTicketDate {
  void modalDatePicker(BuildContext context, PageController controller, {dynamic data, required int minYear, required int minMonth, required int maxYear, required int maxMonth, required int showContentIndex, bool selectInDetail = false, ShowDataType dataType = ShowDataType.ticket}) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height / 1.05,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(6.0.r),
        ),
      ),
      builder: (context) {
        int year = minYear;
        int month = minMonth;
        int scrollCount = 2;
        int beforeIndex = 0;
        int selectedDate = -1;
        int selectedShowIndex = -1;
        List selectedData = [];

        return StatefulBuilder(
          builder: (context, state) {
            DateTime firstDate = DateTime(year, month, 1);
            DateTime lastDate = DateTime(year, month + 1, 0);

            return Column(
              children: [
                ig-publicAppBar(
                  elevation: 0.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(6.0.r),
                    ),
                  ),
                  title: ig-publicAppBarTitle(
                    onWidget: true,
                    wd: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        PreviousMonthWidget(pageController: controller, year: year, month: month, minimumYear: minYear, minumumMonth: minMonth,),
                        CustomTextBuilder(
                          text: '$year년 $month월',
                          fontColor: ColorConfig().dark(),
                          fontSize: 18.0.sp,
                          fontWeight: FontWeight.w800,
                        ),
                        NextMonthWidget(pageController: controller, year: year, month: month, maximumYear: maxYear, maximumMonth: maxMonth),
                      ],
                    ),
                  ),
                  actions: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: SVGBuilder(
                        image: 'assets/icon/close_normal.svg',
                        color: ColorConfig().gray3(),
                      ),
                    ),
                  ],
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: (MediaQuery.of(context).size.height / 1.05) - const ig-publicAppBar().preferredSize.height,
                  color: ColorConfig().white(),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14.0, 0.0, 14.0, 8.0),
                        child: Row(
                          children: List.generate(GetDefaultValue.weekTextList.length, (index) {
                            return Container(
                              width: ((MediaQuery.of(context).size.width - (28.0 + 28.0)) / 7.01),
                              alignment: Alignment.center,
                              margin: const EdgeInsets.symmetric(horizontal: 2.0),
                              padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                              child: CustomTextBuilder(
                                text: GetDefaultValue.weekTextList[index],
                                fontColor: ColorConfig().gray4(),
                                fontSize: 12.0.sp,
                                fontWeight: FontWeight.w400,
                              ),
                            );
                          }),
                        ),
                      ),
                      Expanded(
                        flex: 5,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14.0),
                          child: PageView.builder(
                            controller: controller,
                            itemCount: scrollCount,
                            physics: const NeverScrollableScrollPhysics(),
                            onPageChanged: (value) {
                              if (value > beforeIndex) {
                                state(() {
                                  month++;
                              
                                  if (month > 12) {
                                    month = 1;
                                    year++;
                                  }
                              
                                  if (DateTime(year, month).millisecondsSinceEpoch > DateTime(GetDefaultValue.minimumYear, GetDefaultValue.minimumMonth).millisecondsSinceEpoch) {
                                    scrollCount++;
                                  }
                              
                                  beforeIndex = value;
                                });
                              } else {
                                state(() {
                                  month--;
                              
                                  if (month < 1) {
                                    month = 12;
                                    year--;
                                  }
                              
                                  scrollCount--;
                              
                                  if (value == 0) {
                                    scrollCount = 2;
                                  }
                              
                                  beforeIndex = value;
                                });
                              }
                            },
                            itemBuilder: (context, index) {
                              return Wrap(
                                children: List.generate(lastDate.day + firstDate.weekday - 1, (index) {
                                  index = ((index - (firstDate.weekday)) + firstDate.weekday) + 1;

                                  // 공연이 있는 날짜 계산
                                  dynamic onDate = data.firstWhere((e) => DateTime(DateTime.parse(e['open_date']).toLocal().year, DateTime.parse(e['open_date']).toLocal().month, DateTime.parse(e['open_date']).toLocal().day) == DateTime(year, month, index - (firstDate.weekday) + 1).toLocal(), orElse: () => null,);

                                  // 앞의 빈자리를 계산해준다.
                                  if (index < firstDate.weekday) {
                                    return Container(
                                      width: (MediaQuery.of(context).size.width - (28.0 + 28.0)) / 7.01,
                                      height: ((MediaQuery.of(context).size.width - (28.0 + 28.0)) / 7.01),
                                      margin: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 4.0),
                                    );
                                  }

                                  // 실제 달력 요일 부분
                                  return InkWell(
                                    onTap: onDate != null ? () {
                                      state(() {
                                        selectedDate = index - (firstDate.weekday) + 1;

                                        if (dataType == ShowDataType.ticket) {
                                          selectedShowIndex = -1;
                                          selectedData.clear();
                                          selectedData.addAll(data.where((e) => DateTime(DateTime.parse(e['open_date']).toLocal().year, DateTime.parse(e['open_date']).toLocal().month, DateTime.parse(e['open_date']).toLocal().day) == DateTime(year, month, index - (firstDate.weekday) + 1).toLocal()));
                                        }
                                      });

                                      if (dataType == ShowDataType.auction) {
                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          enableDrag: false,
                                          builder: (context) {
                                            dynamic sameAlternate = data.where((e) => DateTime.parse(e['open_date']).toLocal().day == selectedDate &&
                                                                                      DateTime.parse(e['open_date']).toLocal().month == month &&
                                                                                      DateTime.parse(e['open_date']).toLocal().year == year).toList();
                                            int currentAlternateIndex = 0;

                                            return StatefulBuilder(
                                              builder: (context, state) {
                                                return Container(
                                                  color: ColorConfig().white(),
                                                  constraints: BoxConstraints(
                                                    maxHeight: MediaQuery.of(context).size.height * 0.85
                                                  ),
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Container(
                                                        padding: const EdgeInsets.only(top: 8.0),
                                                        child: Column(
                                                          children: [
                                                            SizedBox(
                                                              height: (24.0 + 16.0.sp + 14.0.sp + 16.0 + 14.0.sp) + (32.0.w *  sameAlternate[currentAlternateIndex]['seats'].length) + 4.0 * sameAlternate[currentAlternateIndex]['seats'].length,
                                                              child: PageView.builder(
                                                                itemCount: sameAlternate.length,
                                                                onPageChanged: (value) {
                                                                  state(() {
                                                                    currentAlternateIndex = value;
                                                                  });
                                                                },
                                                                itemBuilder: (context, snapshot) {
                                                                  return Column(
                                                                    children: [
                                                                      // 공연날짜
                                                                      Padding(
                                                                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                                                                        child: Row(
                                                                          mainAxisSize: MainAxisSize.min,
                                                                          children: [
                                                                            CustomTextBuilder(
                                                                              text: DateFormat('yyyy. M. d (E)', 'ko').format(DateTime.parse(sameAlternate[currentAlternateIndex]['open_date']).toLocal()),
                                                                              fontColor: ColorConfig().dark(),
                                                                              fontSize: 16.0.sp,
                                                                              fontWeight: FontWeight.w800,
                                                                            ),
                                                                            Container(
                                                                              margin: const EdgeInsets.only(left: 4.0),
                                                                              child: CustomTextBuilder(
                                                                                text: '${DateFormat('aa hh:mm', 'ko').format(DateTime.parse(sameAlternate[currentAlternateIndex]['open_date']).toLocal())} 회차',
                                                                                fontColor: ColorConfig().gray3(),
                                                                                fontSize: 14.0.sp,
                                                                                fontWeight: FontWeight.w700,
                                                                              ),
                                                                            )
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      // 출연진
                                                                      Padding(
                                                                        padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 16.0),
                                                                        child: Center(
                                                                          child: RichText(
                                                                            text: TextSpan(
                                                                              children: <TextSpan> [
                                                                                TextSpan(
                                                                                  text: '출연',
                                                                                  style: TextStyle(
                                                                                    color: ColorConfig().gray3(),
                                                                                    fontSize: 14.0.sp,
                                                                                    fontWeight: FontWeight.w700,
                                                                                  ),
                                                                                ),
                                                                                TextSpan(
                                                                                  text: ' | ',
                                                                                  style: TextStyle(
                                                                                    color: ColorConfig().gray3(),
                                                                                    fontSize: 14.0.sp,
                                                                                    fontWeight: FontWeight.w400,
                                                                                    height: 0.0,
                                                                                  ),
                                                                                ),
                                                                                TextSpan(
                                                                                  text: sameAlternate[currentAlternateIndex]['artists'].toString().replaceAll('[', '')
                                                                                                                                                  .replaceAll('{', '')
                                                                                                                                                  .replaceAll('}', '')
                                                                                                                                                  .replaceAll('artist_name: ', '')
                                                                                                                                                  .replaceAll(']', ''),
                                                                                  style: TextStyle(
                                                                                    color: ColorConfig().dark(),
                                                                                    fontSize: 14.0.sp,
                                                                                    fontWeight: FontWeight.w700,
                                                                                    overflow: TextOverflow.ellipsis,
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                            maxLines: 1,
                                                                            overflow: TextOverflow.ellipsis,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      // 좌석
                                                                      Padding(
                                                                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                                                        child: Column(
                                                                          children: List.generate(sameAlternate[currentAlternateIndex]['seats'].length, (seatIndex) {
                                                                            return Container(
                                                                              height: 32.0.w,
                                                                              margin: seatIndex !=  sameAlternate[currentAlternateIndex]['seats'].length - 1 ? const EdgeInsets.only(bottom: 4.0) : null,
                                                                              decoration: BoxDecoration(
                                                                                color: ColorConfig().gray1(),
                                                                                borderRadius: BorderRadius.circular(4.0.r),
                                                                              ),
                                                                              child: Stack(
                                                                                children: [
                                                                                  SizedBox(
                                                                                    height: 32.0.w,
                                                                                    child: Row(
                                                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                      children: [
                                                                                        Row(
                                                                                          children: [
                                                                                            Container(
                                                                                              width: 40.0.w,
                                                                                              margin: const EdgeInsets.only(left: 8.0),
                                                                                              child: CustomTextBuilder(
                                                                                                text: '${sameAlternate[currentAlternateIndex]['seats'][seatIndex]['seat_name']}',
                                                                                                fontColor: ColorConfig().dark(),
                                                                                                fontSize: 14.0.sp,
                                                                                                fontWeight: FontWeight.w900,
                                                                                              ),
                                                                                            ),
                                                                                            Container(
                                                                                              margin: const EdgeInsets.only(left: 8.0, right: 4.0),
                                                                                              child: CustomTextBuilder(
                                                                                                text: '1,000원',
                                                                                                fontColor: ColorConfig().dark(),
                                                                                                fontSize: 12.0.sp,
                                                                                                fontWeight: FontWeight.w800,
                                                                                              ),
                                                                                            ),
                                                                                            CustomTextBuilder(
                                                                                              text: '부터',
                                                                                              style: TextStyle(
                                                                                                color: ColorConfig().gray3(),
                                                                                                fontSize: 11.0.sp,
                                                                                                fontWeight: FontWeight.w400,
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                        Container(
                                                                                          margin: const EdgeInsets.only(right: 8.0),
                                                                                          child: CustomTextBuilder(
                                                                                            text: '${sameAlternate[currentAlternateIndex]['seats'][seatIndex]['participant_count']}명 경매중',
                                                                                            fontColor: ColorConfig().gray5(),
                                                                                            fontSize: 12.0.sp,
                                                                                            fontWeight: FontWeight.w700,
                                                                                          ),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            );
                                                                          }),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  );
                                                                }
                                                              ),
                                                            ),
                                                            // dots pagination
                                                            Padding(
                                                              padding: const EdgeInsets.symmetric(vertical: 16.0),
                                                              child: Row(
                                                                mainAxisSize: MainAxisSize.min,
                                                                children: List.generate(sameAlternate.length, (dotsIndex) {
                                                                  return Container(
                                                                    width: 6.0,
                                                                    height: 6.0,
                                                                    margin: dotsIndex != 2 ? const EdgeInsets.only(right: 4.0) : null,
                                                                    decoration: BoxDecoration(
                                                                      color: currentAlternateIndex == dotsIndex ? ColorConfig().gray5() : ColorConfig().gray2(),
                                                                      borderRadius: BorderRadius.circular(3.0),
                                                                    ),
                                                                  );
                                                                }),
                                                              ),
                                                            ),
                                                            // 경매 참여하기 버튼
                                                            Padding(
                                                              padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 20.0),
                                                              child: InkWell(
                                                                onTap: () {
                                                                  Navigator.pop(context);
                                                                  Navigator.pop(context);

                                                                  if (selectInDetail == true) {
                                                                    Navigator.pushReplacementNamed(context, 'auctionDetail', arguments: {
                                                                      'show_detail_index': sameAlternate[currentAlternateIndex]['show_detail_index'],
                                                                      'show_content_index': showContentIndex,
                                                                    });
                                                                  } else {
                                                                    Navigator.pushNamed(context, 'auctionDetail', arguments: {
                                                                      'show_detail_index': sameAlternate[currentAlternateIndex]['show_detail_index'],
                                                                      'show_content_index': showContentIndex,
                                                                    });
                                                                  }
                                                                },
                                                                child: Container(
                                                                  padding: const EdgeInsets.symmetric(vertical: 18.0),
                                                                  decoration: BoxDecoration(
                                                                    color: ColorConfig().primary(),
                                                                    borderRadius: BorderRadius.circular(4.0.r),
                                                                  ),
                                                                  child: Center(
                                                                    child: CustomTextBuilder(
                                                                      text: TextConstant.doJoinedAuction,
                                                                      fontColor: ColorConfig().white(),
                                                                      fontSize: 16.0.sp,
                                                                      fontWeight: FontWeight.w800,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }
                                            );
                                          },
                                        ).then((value) {
                                          state(() {
                                            selectedDate = -1;
                                          });
                                        });
                                      }
                                    } : null,
                                    child: Container(
                                      width: (MediaQuery.of(context).size.width - (28.0 + 28.0)) / 7.01,
                                      height: ((MediaQuery.of(context).size.width - (28.0 + 28.0)) / 7.01),
                                      margin: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 4.0),
                                      decoration: BoxDecoration(
                                        color: onDate != null && selectedDate == index - (firstDate.weekday) + 1
                                          ? ColorConfig().primary()
                                          : null,
                                        borderRadius: BorderRadius.circular(4.0.r),
                                      ),
                                      child: Center(
                                        child: CustomTextBuilder(
                                          text: '${index - (firstDate.weekday) + 1}',
                                          // 오늘날짜 이전 gray2, 오늘날짜 이후 gray3
                                          fontColor: onDate != null && selectedDate == index - (firstDate.weekday) + 1
                                            ? ColorConfig().white()
                                            : year == DateTime.now().year && month == DateTime.now().month
                                              ? index - (firstDate.weekday) + 1 >= DateTime.now().day
                                                ? onDate != null
                                                  ? ColorConfig().dark()
                                                  : ColorConfig().gray2()
                                                : ColorConfig().gray2()
                                              : onDate != null
                                                ? ColorConfig().dark()
                                                : ColorConfig().gray2(),
                                          fontSize: 14.0.sp,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              );
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: selectedData.isNotEmpty ? Column(
                              children: List.generate(selectedData.length, (index) {
                                return InkWell(
                                  onTap: () {
                                    state(() {
                                      selectedShowIndex = index;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 12.0),
                                    margin: const EdgeInsets.only(bottom: 8.0),
                                    decoration: BoxDecoration(
                                      color: selectedShowIndex == index ? ColorConfig().primaryLight3() : ColorConfig().gray1(),
                                      border: selectedShowIndex == index ? Border.all(
                                        width: 2.0,
                                        color: ColorConfig().primary(),
                                      ) : null,
                                      borderRadius: BorderRadius.circular(4.0.r),
                                    ),
                                    child: Column(
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.only(bottom: 8.0),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                margin: const EdgeInsets.only(right: 4.0),
                                                child: CustomTextBuilder(
                                                  text: DateFormat('yyyy. M. dd (E)', 'ko').format(DateTime.parse(selectedData[index]['open_date']).toLocal()),
                                                  fontColor: ColorConfig().dark(),
                                                  fontSize: 16.0.sp,
                                                  fontWeight: FontWeight.w800,
                                                  height: 0.0,
                                                ),
                                              ),
                                              CustomTextBuilder(
                                                text: DateFormat('aa hh:mm', 'ko').format(DateTime.parse(selectedData[index]['open_date']).toLocal()),
                                                fontColor: ColorConfig().gray3(),
                                                fontSize: 14.0.sp,
                                                fontWeight: FontWeight.w700,
                                                height: 0.0,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            CustomTextBuilder(
                                              text: '출연  |  ',
                                              fontColor: ColorConfig().gray3(),
                                              fontSize: 14.0.sp,
                                              fontWeight: FontWeight.w700,
                                            ),
                                            Container(
                                              constraints: BoxConstraints(
                                                maxWidth: MediaQuery.of(context).size.width - (20.0 + (15.0.sp * 5) + 20.0 + 4.0 + 2.0),
                                              ),
                                              child: CustomTextBuilder(
                                                text: selectedData[index]['artists'].toString()
                                                                                    .replaceAll('[', '')
                                                                                    .replaceAll('{', '')
                                                                                    .replaceAll('}', '')
                                                                                    .replaceAll('artist_name: ', '')
                                                                                    .replaceAll(']', ''),
                                                fontColor: ColorConfig().dark(),
                                                fontSize: 14.0.sp,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),
                                        selectedShowIndex == index ? Container(
                                          margin: const EdgeInsets.only(top: 4.0),
                                          child: Wrap(
                                            alignment: WrapAlignment.center,
                                            children: List.generate(selectedData[index]['seats'].length, (seats) {
                                              return Container(
                                                margin: const EdgeInsets.only(right: 8.0),
                                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Container(
                                                      margin: const EdgeInsets.only(right: 4.0),
                                                      child: CustomTextBuilder(
                                                        text: '${selectedData[index]['seats'][seats]['seat_name']}',
                                                        fontColor: ColorConfig().dark(),
                                                        fontSize: 12.0.sp,
                                                        fontWeight: FontWeight.w800,
                                                      ),
                                                    ),
                                                    CustomTextBuilder(
                                                      text: int.parse(selectedData[index]['seats'][seats]['ticket_total'].toString()) - int.parse(selectedData[index]['seats'][seats]['sell_ticket_count']) == 0
                                                        ? TextConstant.soldout
                                                        : '${int.parse(selectedData[index]['seats'][seats]['ticket_total'].toString()) - int.parse(selectedData[index]['seats'][seats]['sell_ticket_count'])}${TextConstant.ticketRemainingCountText}',
                                                      fontColor: int.parse(selectedData[index]['seats'][seats]['ticket_total'].toString()) - int.parse(selectedData[index]['seats'][seats]['sell_ticket_count']) == 0
                                                        ? ColorConfig().accent()
                                                        : ColorConfig().primary(),
                                                      fontSize: 12.0.sp,
                                                      fontWeight: FontWeight.w700,
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }),
                                          ),
                                        ) : Container(),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ) : Container(),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: InkWell(
                          onTap: selectedShowIndex != -1 ? () {
                            Navigator.pop(context);
                            if (selectInDetail == true) {
                              Navigator.pushReplacementNamed(context, 'ticketingDetail', arguments: {
                                'show_detail_index': selectedData[selectedShowIndex]['show_detail_index'],
                                'show_content_index': showContentIndex,
                              });
                            } else {
                              Navigator.pushNamed(context, 'ticketingDetail', arguments: {
                                'show_detail_index': selectedData[selectedShowIndex]['show_detail_index'],
                                'show_content_index': showContentIndex,
                              });
                            }
                          } : null,
                          child: Container(
                            height: 54.0.w,
                            decoration: BoxDecoration(
                              color: selectedShowIndex != -1 ? ColorConfig().primary() : ColorConfig().gray2(),
                              borderRadius: BorderRadius.circular(4.0.r),
                            ),
                            child: Center(
                              child: CustomTextBuilder(
                                text: selectedShowIndex != -1 ? TextConstant.selectComplete : TextConstant.selectShowDate,
                                fontColor: selectedShowIndex != -1 ? ColorConfig().white() : ColorConfig().gray3(),
                                fontSize: 16.0.sp,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
        );
      },
    );
  }
}