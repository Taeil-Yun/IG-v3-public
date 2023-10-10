import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:ig-public_v3/api/profile/rank.dart';
import 'package:ig-public_v3/component/svg/svg_builder.dart';
import 'package:ig-public_v3/costant/build_config.dart';
import 'package:ig-public_v3/costant/colors.dart';
import 'package:ig-public_v3/costant/text.dart';
import 'package:ig-public_v3/component/appbar/appbar.dart';
import 'package:ig-public_v3/component/appbar/appbar_leading.dart';
import 'package:ig-public_v3/component/appbar/appbar_title.dart';
import 'package:ig-public_v3/util/set_intl.dart';
import 'package:ig-public_v3/widget/custom_text_widget.dart';
import 'package:intl/intl.dart';

class RankingListScreen extends StatefulWidget {
  const RankingListScreen({super.key});

  @override
  State<RankingListScreen> createState() => _RankingListScreenState();
}

class _RankingListScreenState extends State<RankingListScreen> {
  List<dynamic> rankTop3Data = [];

  Map<String, dynamic> rankData = {};
  
  @override
  void initState() {
    super.initState();

    initializeAPI();
  }

  Future<void> initializeAPI() async {
    RankDataAPI().rank(accessToken: await SecureStorageConfig().storage.read(key: 'access_token')).then((value) {
      setState(() {
        rankTop3Data.add(value.result['data']['rank_list'][0]);
        rankTop3Data.add(value.result['data']['rank_list'][1]);
        rankTop3Data.add(value.result['data']['rank_list'][2]);
        rankData = value.result['data'];
        rankData['rank_list'].removeAt(0);
        rankData['rank_list'].removeAt(1);
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
          title: TextConstant.ig-publicRank,
        ),
        actions: [
          TextButton(
            onPressed: () {
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
                  return Column(
                    children: [
                      // 앱바 영역
                      ig-publicAppBar(
                        elevation: 0.0,
                        leadingWidth: 0.0,
                        center: false,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(6.0.r),
                          ),
                        ),
                        title: ig-publicAppBarTitle(
                          onWidget: true,
                          wd: CustomTextBuilder(
                            text: TextConstant.viewRankBenefit,
                            fontColor: ColorConfig().dark(),
                            fontSize: 16.0.sp,
                            fontWeight: FontWeight.w800,
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
                      // 데이터 영역
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: (MediaQuery.of(context).size.height / 1.05) - const ig-publicAppBar().preferredSize.height,
                        color: ColorConfig().white(),
                        child: SafeArea(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                // 혜택 영역
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Column(
                                    children: List.generate(rankData['benefit_info'].length, (benefitIndex) {
                                      return Container(
                                        color: rankData['my_info']['grade'] - 1 == benefitIndex ? ColorConfig().gray1() : null,
                                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                                        child: Column(
                                          children: [
                                            Container(
                                              margin: const EdgeInsets.only(bottom: 8.0),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Container(
                                                        margin: const EdgeInsets.only(right: 8.0),
                                                        child: Image(
                                                          image: benefitIndex == 0
                                                            ? const AssetImage('assets/img/rank-m.png')
                                                            : benefitIndex == 1
                                                              ? const AssetImage('assets/img/rank-d.png')
                                                              : benefitIndex == 2
                                                                ? const AssetImage('assets/img/rank-pl.png')
                                                                : benefitIndex == 3
                                                                  ? const AssetImage('assets/img/rank-r.png')
                                                                  : benefitIndex == 4
                                                                    ? const AssetImage('assets/img/rank-g.png')
                                                                    : benefitIndex == 5
                                                                      ? const AssetImage('assets/img/rank-s.png')
                                                                      : const AssetImage('assets/img/rank-w.png'),
                                                          width: 24.0.w,
                                                          height: 24.0.w,
                                                          filterQuality: FilterQuality.high,
                                                        ),
                                                      ),
                                                      CustomTextBuilder(
                                                        text: benefitIndex == 0
                                                          ? '마스터'
                                                          : benefitIndex == 1
                                                            ? '다이아'
                                                            : benefitIndex == 2
                                                              ? '플래티넘'
                                                              : benefitIndex == 3
                                                                ? '로얄'
                                                                : benefitIndex == 4
                                                                  ? '골드'
                                                                  : benefitIndex == 5
                                                                    ? '실버'
                                                                    : '화이트',
                                                        fontColor: ColorConfig().dark(),
                                                        fontSize: 14.0.sp,
                                                        fontWeight: FontWeight.w800,
                                                      ),
                                                    ],
                                                  ),
                                                  // 나의등급 표시  label 영역
                                                  rankData['my_info']['grade'] - 1 == benefitIndex ? Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                                    decoration: BoxDecoration(
                                                      color: ColorConfig().primaryLight2(),
                                                      borderRadius: BorderRadius.circular(2.0.r),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        CustomTextBuilder(
                                                          text: TextConstant.myRanking,
                                                          fontColor: ColorConfig().primary(),
                                                          fontSize: 12.0.sp,
                                                          fontWeight: FontWeight.w700,
                                                        ),
                                                        Container(
                                                          margin: const EdgeInsets.only(left: 2.0),
                                                          child: SVGBuilder(
                                                            image: 'assets/icon/check.svg',
                                                            width: 16.0.w,
                                                            height: 16.0.w,
                                                            color: ColorConfig().primary(),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ) : Container(),
                                                ],
                                              ),
                                            ),
                                            Column(
                                              children: List.generate(rankData['benefit_info'][benefitIndex].length, (index) {
                                                return Container(
                                                  margin: EdgeInsets.only(left: 20.0, top: index != 0 ? 4.0 : 0.0),
                                                  child: Row(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Container(
                                                        width: 4.0.w,
                                                        height: 4.0.w,
                                                        margin: EdgeInsets.only(right: 10.0, top: 4.0.w * 1.2),
                                                        decoration: BoxDecoration(
                                                          color: ColorConfig().dark(),
                                                          borderRadius: BorderRadius.circular(2.0.r),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: CustomTextBuilder(
                                                          text: '${rankData['benefit_info'][benefitIndex][index]}',
                                                          fontColor: ColorConfig().gray5(),
                                                          fontSize: 12.0.sp,
                                                          fontWeight: FontWeight.w400,
                                                          height: 1.2,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                                const SizedBox(height: 16.0),
                                Container(
                                  height: 8.0,
                                  color: ColorConfig().gray1(),
                                ),
                                const SizedBox(height: 16.0),
                                // 등급 및 랭킹 안내 타이틀 영역
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                                  margin: const EdgeInsets.only(bottom: 8.0),
                                  child: CustomTextBuilder(
                                    text: TextConstant.rankingBenefitTitleInfo,
                                    fontColor: ColorConfig().dark(),
                                    fontSize: 14.0.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                // 안내 텍스트 영역
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                  child: Column(
                                    children: List.generate(TextConstant.rankingBenefitInfo.length, (index) {
                                      return Container(
                                        margin: index != 0 ? const EdgeInsets.only(top: 8.0) : null,
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: 4.0.w,
                                              height: 4.0.w,
                                              margin: EdgeInsets.only(top: 4.0.w * 1.2, right: 10.0),
                                              decoration: BoxDecoration(
                                                color: ColorConfig().dark(),
                                                borderRadius: BorderRadius.circular(2.0.r),
                                              ),
                                            ),
                                            Expanded(
                                              child: CustomTextBuilder(
                                                text: TextConstant.rankingBenefitInfo[index],
                                                fontColor: ColorConfig().gray5(),
                                                fontSize: 12.0.sp,
                                                fontWeight: FontWeight.w400,
                                                height: 1.2,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                                const SizedBox(height: 40.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
            style: ButtonStyle(
              overlayColor: MaterialStateProperty.all(ColorConfig.transparent),
              foregroundColor: MaterialStateProperty.all(ColorConfig.transparent),
              padding: MaterialStateProperty.all(const EdgeInsets.all(8.0)),
            ),
            child: CustomTextBuilder(
              text: TextConstant.showRankBenefit,
              fontColor: ColorConfig().gray3(),
              fontSize: 14.0.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      body: rankData.isNotEmpty ? Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: ColorConfig().primaryLight3(),
        child: Stack(
          children: [
            // 랭킹 리스트 영역
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // // 날짜영역
                // Container(
                //   width: MediaQuery.of(context).size.width,
                //   padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                //   child: CustomTextBuilder(
                //     text: '*2022.2.23 기준',
                //     fontColor: ColorConfig().gray3(),
                //     fontSize: 11.0.sp,
                //     fontWeight: FontWeight.w400,
                //   ),
                // ),
                // 리스트 영역
                Expanded(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: ListView.builder(
                      itemCount: rankData['rank_list'].length,
                      itemBuilder: (context, index) {
                        // top 3 영역
                        if (index == 0) {
                          return Column(
                            children: [
                              // 날짜영역
                              Container(
                                width: MediaQuery.of(context).size.width,
                                padding: const EdgeInsets.symmetric(vertical: 16.0),
                                child: CustomTextBuilder(
                                  text: '*${DateFormat('yyyy.M.d.').format(DateTime.now())} 기준',
                                  fontColor: ColorConfig().gray3(),
                                  fontSize: 11.0.sp,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              // 데이터 영역
                              Row(
                                children: List.generate(rankTop3Data.length, (top3Index) {
                                  return Container(
                                    width: (MediaQuery.of(context).size.width - (40.0 + 24.0.w + (rankData['my_info']['ranking'] != null ? rankData['my_info']['ranking'] == rankData['rank_list'][index]['ranking'] ? 2.0 : 0.0 : 0.0))) / 3,
                                    padding: const EdgeInsets.all(8.0),
                                    margin: top3Index != 0 ? EdgeInsets.only(left: 12.0.w) : null,
                                    decoration: BoxDecoration(
                                      color: rankData['my_info']['ranking'] == rankData['rank_list'][index]['ranking'] ? ColorConfig().primaryLight2() : ColorConfig().white(),
                                      border: rankData['my_info']['ranking'] == rankData['rank_list'][index]['ranking'] ? Border.all(
                                        width: 1.0,
                                        color: ColorConfig().primary(),
                                      ) : null,
                                      borderRadius: BorderRadius.circular(4.0.r),
                                    ),
                                    child: Column(
                                      children: [
                                        // 프로필 이미지, 등수 영역
                                        Container(
                                          padding: const EdgeInsets.fromLTRB(7.0, 0.0, 7.0, 4.0),
                                          child: Column(
                                            children: [
                                              // 프로필 이미지 영역
                                              Stack(
                                                children: [
                                                  Container(
                                                    width: 72.0.w,
                                                    height: 72.0.w,
                                                    margin: const EdgeInsets.only(bottom: 8.0),
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                        width: 2.0,
                                                        color: ColorConfig().borderGray3(),
                                                      ),
                                                      borderRadius: BorderRadius.circular(36.0.r),
                                                      image: rankTop3Data[top3Index]['image'] != null
                                                        ? DecorationImage(
                                                            image: NetworkImage(rankTop3Data[top3Index]['image']),
                                                            fit: BoxFit.cover,
                                                            filterQuality: FilterQuality.high,
                                                          )
                                                        : const DecorationImage(
                                                            image: AssetImage('assets/img/profile_default.png'),
                                                            fit: BoxFit.cover,
                                                            filterQuality: FilterQuality.high,
                                                          ),
                                                    ),
                                                  ),
                                                  top3Index == 1 ? Positioned(
                                                    top: 0.0,
                                                    right: 0.0,
                                                    child: Image(
                                                      image: const AssetImage('assets/img/rank1_crown.png'),
                                                      width: 24.0.w,
                                                      height: 24.0.w,
                                                      filterQuality: FilterQuality.high,
                                                    ),
                                                  ) : Container(),
                                                ],
                                              ),
                                              // 등수 영역
                                              CustomTextBuilder(
                                                text: '${SetIntl().numberFormat(rankTop3Data[top3Index]['ranking'])}',
                                                fontColor: ColorConfig().dark(),
                                                fontSize: 18.0.sp,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ],
                                          ),
                                        ),
                                        // 등급 이미지 영역
                                        Image(
                                          image: rankTop3Data[top3Index]['grade'] == 1
                                            ? const AssetImage('assets/img/rank-m.png')
                                            : rankTop3Data[top3Index]['grade'] == 2
                                              ? const AssetImage('assets/img/rank-d.png')
                                              : rankTop3Data[top3Index]['grade'] == 3
                                                ? const AssetImage('assets/img/rank-pl.png')
                                                : rankTop3Data[top3Index]['grade'] == 4
                                                  ? const AssetImage('assets/img/rank-r.png')
                                                  : rankTop3Data[top3Index]['grade'] == 5
                                                    ? const AssetImage('assets/img/rank-g.png')
                                                    : rankTop3Data[top3Index]['grade'] == 6
                                                      ? const AssetImage('assets/img/rank-s.png')
                                                      : const AssetImage('assets/img/rank-w.png'),
                                          width: 16.0.w,
                                          height: 16.0.w,
                                          filterQuality: FilterQuality.high,
                                        ),
                                        // 이름 영역
                                        Container(
                                          constraints: BoxConstraints(
                                            minHeight: (24.0.sp * 1.2),
                                          ),
                                          alignment: Alignment.center,
                                          child: CustomTextBuilder(
                                            text: '${rankTop3Data[top3Index]['nick']}',
                                            fontColor: ColorConfig().dark(),
                                            fontSize: 12.0.sp,
                                            fontWeight: FontWeight.w700,
                                            textAlign: TextAlign.center,

                                            maxLines: 2,
                                            textOverflow: TextOverflow.ellipsis,
                                            height: 1.2,
                                          ),
                                        ),
                                        // 보유금액 영역
                                        Container(
                                          margin: const EdgeInsets.only(top: 4.0),
                                          child: CustomTextBuilder(
                                            text: '${SetIntl().numberFormat(rankTop3Data[top3Index]['point'])}원',
                                            fontColor: ColorConfig().gray3(),
                                            fontSize: 11.0.sp,
                                            fontWeight: FontWeight.w400,
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

                        // 4등 이상부터의 영역
                        return Container(
                          margin: EdgeInsets.only(top: index == 1 ? 8.0 : 0.0, bottom: 4.0),
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          decoration: BoxDecoration(
                            color: rankData['my_info']['ranking'] == rankData['rank_list'][index]['ranking'] ? ColorConfig().primaryLight2() : ColorConfig().white(),
                            border: rankData['my_info']['ranking'] == rankData['rank_list'][index]['ranking'] ? Border.all(
                              width: 1.0,
                              color: ColorConfig().primary(),
                            ) : null,
                            borderRadius: BorderRadius.circular(4.0.r),
                          ),
                          child: Row(
                            children: [
                              // 프로필 이미지 영역
                              Container(
                                width: 48.0.w,
                                height: 48.0.w,
                                margin: const EdgeInsets.only(right: 16.0),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 1.0,
                                    color: ColorConfig().borderGray1(opacity: 0.3),
                                  ),
                                  borderRadius: BorderRadius.circular(24.0.r),
                                  image: rankData['rank_list'][index]['image'] != null
                                    ? DecorationImage(
                                        image: NetworkImage(rankData['rank_list'][index]['image']),
                                        fit: BoxFit.cover,
                                        filterQuality: FilterQuality.high,
                                      )
                                    : const DecorationImage(
                                        image: AssetImage('assets/img/profile_default.png'),
                                        fit: BoxFit.cover,
                                        filterQuality: FilterQuality.high,
                                      ),
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 등수 영역
                                  Container(
                                    width: MediaQuery.of(context).size.width - (40.0 + 32.0 + 48.0.w + 16.0),
                                    margin: const EdgeInsets.only(bottom: 6.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            CustomTextBuilder(
                                              text: '${index + 3}',
                                              fontColor: ColorConfig().dark(),
                                              fontSize: 16.0.sp,
                                              fontWeight: FontWeight.w800,
                                            ),
                                            // Container(
                                            //   margin: const EdgeInsets.only(left: 6.0),
                                            //   padding: const EdgeInsets.symmetric(horizontal: 6.0),
                                            //   decoration: BoxDecoration(
                                            //     color: ColorConfig().primaryLight2(opacity: 0.5),
                                            //     borderRadius: BorderRadius.circular(4.0.r),
                                            //   ),
                                            //   child: Row(
                                            //     children: [
                                            //       CustomTextBuilder(
                                            //         text: '1',
                                            //         fontColor: ColorConfig().dark(),
                                            //         fontSize: 12.0.sp,
                                            //         fontWeight: FontWeight.w700,
                                            //       ),
                                            //     ],
                                            //   ),
                                            // ),
                                          ],
                                        ),
                                        // ig-public머니 영역
                                        CustomTextBuilder(
                                          text: '${SetIntl().numberFormat(rankData['rank_list'][index]['point'])}원',
                                          fontColor: ColorConfig().gray3(),
                                          fontSize: 12.0.sp,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ],
                                    ),
                                  ),
                                  // 유저등급, 닉네임 영역
                                  Row(
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.only(right: 4.0),
                                        child: Image(
                                          image: rankData['rank_list'][index]['grade'] == 1
                                            ? const AssetImage('assets/img/rank-m.png')
                                            : rankData['rank_list'][index]['grade'] == 2
                                              ? const AssetImage('assets/img/rank-d.png')
                                              : rankData['rank_list'][index]['grade'] == 3
                                                ? const AssetImage('assets/img/rank-pl.png')
                                                : rankData['rank_list'][index]['grade'] == 4
                                                  ? const AssetImage('assets/img/rank-r.png')
                                                  : rankData['rank_list'][index]['grade'] == 5
                                                    ? const AssetImage('assets/img/rank-g.png')
                                                    : rankData['rank_list'][index]['grade'] == 6
                                                      ? const AssetImage('assets/img/rank-s.png')
                                                      : const AssetImage('assets/img/rank-w.png'),
                                          width: 16.0.w,
                                          height: 16.0.w,
                                          filterQuality: FilterQuality.high,
                                        ),
                                      ),
                                      CustomTextBuilder(
                                        text: '${rankData['rank_list'][index]['nick']}',
                                        fontColor: ColorConfig().dark(),
                                        fontSize: 12.0.sp,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(height: 32.0 + 48.0.w + MediaQuery.of(context).padding.bottom),
              ],
            ),
            // 나의 랭킹정보 영역
            Positioned(
              bottom: 0.0,
              child: Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 20.0),
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
                  child: Row(
                    children: [
                      // 프로필 이미지 영역
                      Container(
                        width: 48.0.w,
                        height: 48.0.w,
                        margin: const EdgeInsets.only(right: 16.0),
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1.0,
                            color: ColorConfig().borderGray1(opacity: 0.3),
                          ),
                          borderRadius: BorderRadius.circular(24.0.r),
                          image: rankData['my_info']['image'] != null
                            ? DecorationImage(
                                image: NetworkImage(rankData['my_info']['image']),
                                fit: BoxFit.cover,
                                filterQuality: FilterQuality.high,
                              )
                            : const DecorationImage(
                                image: AssetImage('assets/img/profile_default.png'),
                                fit: BoxFit.cover,
                                filterQuality: FilterQuality.high,
                              ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 등수 영역
                          Container(
                            width: MediaQuery.of(context).size.width - (40.0 + 48.0.w + 16.0),
                            margin: const EdgeInsets.only(bottom: 6.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    CustomTextBuilder(
                                      text: '${SetIntl().numberFormat(rankData['my_info']['ranking'] ?? 9999)}${rankData['my_info']['ranking'] ?? '+'}',
                                      fontColor: ColorConfig().dark(),
                                      fontSize: 16.0.sp,
                                      fontWeight: FontWeight.w800,
                                    ),
                                    // Container(
                                    //   margin: const EdgeInsets.only(left: 6.0),
                                    //   padding: const EdgeInsets.symmetric(horizontal: 6.0),
                                    //   decoration: BoxDecoration(
                                    //     color: ColorConfig().primaryLight2(opacity: 0.5),
                                    //     borderRadius: BorderRadius.circular(4.0.r),
                                    //   ),
                                    //   child: Row(
                                    //     children: [
                                    //       CustomTextBuilder(
                                    //         text: '1',
                                    //         fontColor: ColorConfig().dark(),
                                    //         fontSize: 12.0.sp,
                                    //         fontWeight: FontWeight.w700,
                                    //       ),
                                    //     ],
                                    //   ),
                                    // ),
                                  ],
                                ),
                                // ig-public머니 영역
                                CustomTextBuilder(
                                  text: '${rankData['my_info']['point']}원',
                                  fontColor: ColorConfig().gray3(),
                                  fontSize: 12.0.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ],
                            ),
                          ),
                          // 유저등급, 닉네임 영역
                          Row(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(right: 4.0),
                                child: Image(
                                  image: rankData['my_info']['grade'] == 1
                                    ? const AssetImage('assets/img/rank-m.png')
                                    : rankData['my_info']['grade'] == 2
                                      ? const AssetImage('assets/img/rank-d.png')
                                      : rankData['my_info']['grade'] == 3
                                        ? const AssetImage('assets/img/rank-pl.png')
                                        : rankData['my_info']['grade'] == 4
                                          ? const AssetImage('assets/img/rank-r.png')
                                          : rankData['my_info']['grade'] == 5
                                            ? const AssetImage('assets/img/rank-g.png')
                                            : rankData['my_info']['grade'] == 6
                                              ? const AssetImage('assets/img/rank-s.png')
                                              : const AssetImage('assets/img/rank-w.png'),
                                  width: 16.0.w,
                                  height: 16.0.w,
                                  filterQuality: FilterQuality.high,
                                ),
                              ),
                              CustomTextBuilder(
                                text: '나의 랭킹',
                                fontColor: ColorConfig().dark(),
                                fontSize: 12.0.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ) : Container(),
    );
  }
}