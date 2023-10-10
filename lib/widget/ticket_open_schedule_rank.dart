import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ig-public_v3/component/popup/popup.dart';
import 'package:ig-public_v3/costant/colors.dart';
import 'package:ig-public_v3/costant/text.dart';
import 'package:ig-public_v3/widget/custom_text_widget.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class TicketOpenScheduleRanking extends StatelessWidget {
  TicketOpenScheduleRanking({
    super.key,
    required this.myRank,
    required this.startDateList,
  });

  int myRank;
  List startDateList;

  List<String> rankImage = [
    'assets/img/rank-m.png',
    'assets/img/rank-d.png',
    'assets/img/rank-pl.png',
    'assets/img/rank-r.png',
    'assets/img/rank-g.png',
    'assets/img/rank-s.png',
    'assets/img/rank-w.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 티켓 오픈 일정 타이틀 영역
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: CustomTextBuilder(
            text: TextConstant.ticketOpenSchedule,
            fontColor: ColorConfig().dark(),
            fontSize: 16.0.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
        // 티켓 오픈 일정 subject 영역
        Container(
          margin: const EdgeInsets.only(bottom: 16.0),
          child: CustomTextBuilder(
            text: TextConstant.ticketOpenScheduleSubject,
            fontColor: ColorConfig().gray4(),
            fontSize: 12.0.sp,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),
        // 랭킹 등급별 오픈시간 영역
        Column(
          children: List.generate(TextConstant.rankGrade.length, (grade) {
            return Container(
              width: MediaQuery.of(context).size.width,
              margin: grade != 0 ? const EdgeInsets.only(top: 8.0) : null,
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
              decoration: BoxDecoration(
                color: myRank - 1 == grade ? ColorConfig().gray2() : null,
                borderRadius: BorderRadius.circular(4.0.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(right: 4.0),
                          child: Image(
                            image: AssetImage(rankImage[grade]),
                            width: 16.0.w,
                            height: 16.0.w,
                            filterQuality: FilterQuality.high,
                          ),
                        ),
                        CustomTextBuilder(
                          text: TextConstant.rankGrade[grade],
                          fontColor: ColorConfig().gray5(),
                          fontSize: 14.0.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: CustomTextBuilder(
                        text: DateFormat('yyyy. MM. dd. (E) · aa HH:mm', 'ko')
                            .format(
                                DateTime.parse(startDateList[grade]).toLocal()),
                        fontColor: ColorConfig().gray5(),
                        fontSize: 12.0.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }
}

Future<void> ticketOpenScheduleRankingPopup(BuildContext context,
    {required int myRanking, required List openDates}) async {
  return PopupBuilder(
        title: '',
        titlePadding: EdgeInsets.zero,
        content: '',
        insetPadding:
            const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        useScrollBar: false,
        scrollBarPadding: EdgeInsets.zero,
        onContentWidget: TicketOpenScheduleRanking(
            myRank: myRanking, startDateList: openDates),
        actions: [
          InkWell(
            onTap: () {
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
      ).ig -
      publicDialog(context);
}
