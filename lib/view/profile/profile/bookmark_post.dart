import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ig-public_v3/api/profile/delete_scrap.dart';
import 'package:ig-public_v3/api/profile/scrap_list.dart';
import 'package:ig-public_v3/component/popup/popup.dart';
import 'package:ig-public_v3/costant/build_config.dart';

import 'package:ig-public_v3/costant/text.dart';
import 'package:ig-public_v3/costant/colors.dart';
import 'package:ig-public_v3/component/appbar/appbar.dart';
import 'package:ig-public_v3/component/appbar/appbar_leading.dart';
import 'package:ig-public_v3/component/appbar/appbar_title.dart';
import 'package:ig-public_v3/component/svg/svg_builder.dart';
import 'package:ig-public_v3/widget/custom_text_widget.dart';
import 'package:intl/intl.dart';

class BookmarkPostScreen extends StatefulWidget {
  const BookmarkPostScreen({super.key});

  @override
  State<BookmarkPostScreen> createState() => _BookmarkPostScreenState();
}

class _BookmarkPostScreenState extends State<BookmarkPostScreen> {
  List scrapList = [];

  @override
  void initState () {
    super.initState();

    initializeAPI();
  }

  Future<void> initializeAPI() async {
    ScrapListAPI().scrapList(accessToken: await SecureStorageConfig().storage.read(key: 'access_token')).then((value) {
      setState(() {
        scrapList = value.result['data'];
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
          title: TextConstant.bookmarkPost,
        ),
      ),
      body: scrapList.isNotEmpty ? Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: ColorConfig().white(),
        child: SafeArea(
          child: ListView.builder(
            itemCount: scrapList.length,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Column(
                  children: [
                    // // sorting 영역
                    // sortingWidget(),
                    // 데이터 영역
                    bookmarkPostDataWidget(index),
                  ],
                );
              }

              return bookmarkPostDataWidget(index);
            },
          ),
        ),
      ) : Container(),
    );
  }

  // sorting 위젯
  Widget sortingWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: IntrinsicWidth(
          child: Container(
            padding: const EdgeInsets.fromLTRB(10.0, 8.0, 8.0, 8.0),
            decoration: BoxDecoration(
              color: ColorConfig().white(),
              border: Border.all(
                width: 1.0,
                color: ColorConfig().gray2(),
              ),
              borderRadius: BorderRadius.circular(4.0.r),
            ),
            child: Row(
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 4.0),
                  child: CustomTextBuilder(
                    text: TextConstant.sortByRecently,
                    fontColor: ColorConfig().gray5(),
                    fontSize: 12.0.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SVGBuilder(
                  image: 'assets/icon/arrow_down_light.svg',
                  width: 16.0.w,
                  height: 16.0.w,
                  color: ColorConfig().gray5(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // data 위젯
  Widget bookmarkPostDataWidget(int index) {
    return Dismissible(
      key: UniqueKey(),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        PopupBuilder(
          title: TextConstant.saveCancelPopupTitle,
          content: TextConstant.saveCancelPopupDescription,
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  splashColor: ColorConfig.transparent,
                  child: Container(
                    width: (MediaQuery.of(context).size.width - 120.0.w) / 2,
                    padding: const EdgeInsets.symmetric(vertical: 16.5),
                    margin: const EdgeInsets.only(right: 8.0),
                    decoration: BoxDecoration(
                      color: ColorConfig().gray3(),
                      borderRadius: BorderRadius.circular(4.0.r),
                    ),
                    child: Center(
                      child: CustomTextBuilder(
                        text: TextConstant.close,
                        fontColor: ColorConfig().white(),
                        fontSize: 14.0.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    DeleteScrapAPI().scrapDelete(accessToken: await SecureStorageConfig().storage.read(key: 'access_token'), scrapIndex: scrapList[index]['scrap_index']).then((value) {
                      if (value.result['status'] == 1) {
                        Navigator.pop(context);
                        
                        setState(() {
                          scrapList.removeAt(index);
                        });
                      }
                    });
                  },
                  splashColor: ColorConfig.transparent,
                  child: Container(
                    width: (MediaQuery.of(context).size.width - 120.0.w) / 2,
                    padding: const EdgeInsets.symmetric(vertical: 16.5),
                    decoration: BoxDecoration(
                      color: ColorConfig().dark(),
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
              ],
            ),
          ],
        ).ig-publicDialog(context);
      },
      background: Container(
        width: MediaQuery.of(context).size.width,
        color: ColorConfig().accent(),
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        alignment: Alignment.centerRight,
        child: CustomTextBuilder(
          text: TextConstant.saveCancel,
          fontColor: ColorConfig().white(),
          fontSize: 14.0.sp,
          fontWeight: FontWeight.w400,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, 'postDetail', arguments: {
            'community_index': scrapList[index]['community_index'],
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                width: 1.0,
                color: ColorConfig().gray1(),
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: MediaQuery.of(context).size.width - ((scrapList[index]['image1'] != null ? 62.0.w : 0.0) + 40.0 + 16.0),
                constraints: BoxConstraints(
                  minHeight: 62.0.w,
                ),
                margin: const EdgeInsets.only(right: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 커뮤니티 영역
                    CustomTextBuilder(
                      text: '${scrapList[index]['item_name']}',
                      fontColor: ColorConfig().dark(),
                      fontSize: 12.0.sp,
                      fontWeight: FontWeight.w900,
                    ),
                    scrapList[index]['type'] == 'R' || scrapList[index]['type'] == 'T' ? Container(
                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                      child: RatingBar.builder(
                        initialRating: scrapList[index]['star'] / 10,
                        minRating: 1,
                        ignoreGestures: true,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemSize: 18.0.w,
                        unratedColor: ColorConfig().gray2(),
                        // itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                        itemBuilder: (context, _) => SVGBuilder(
                          image: 'assets/icon/star.svg',
                          width: 18.0.w,
                          height: 18.0.w,
                          color: ColorConfig().primaryLight(),
                        ),
                        onRatingUpdate: (rating) {},
                      ),
                    ) : Container(),
                    // 제목 영역
                    scrapList[index]['title'] != null ? Container(
                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                      child: CustomTextBuilder(
                        text: '${scrapList[index]['title']}',
                        fontColor: ColorConfig().dark(),
                        fontSize: 14.0.sp,
                        fontWeight: FontWeight.w700,
                        maxLines: 2,
                        textOverflow: TextOverflow.ellipsis,
                      ),
                    ) : Container(),
                    // 작성자, 날짜, 댓글 영역
                    Row(
                      children: [
                        // 작성자 영역
                        CustomTextBuilder(
                          text: '${scrapList[index]['nick']}',
                          fontColor: ColorConfig().gray4(),
                          fontSize: 12.0.sp,
                          fontWeight: FontWeight.w400,
                        ),
                        // 구분자
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: CustomTextBuilder(
                            text: '|',
                            fontColor: ColorConfig().gray2(),
                            fontSize: 12.0.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        // 날짜 영역
                        CustomTextBuilder(
                          text: scrapList[index]['create_dt'] == scrapList[index]['modify_dt'] ? DateFormat('yyyy.MM').format(DateTime.parse(scrapList[index]['create_dt']).toLocal()) : DateFormat('yyyy.MM').format(DateTime.parse(scrapList[index]['modify_dt']).toLocal()),
                          fontColor: ColorConfig().gray4(),
                          fontSize: 12.0.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ],
                    )
                  ],
                ),
              ),
              scrapList[index]['image1'] != null ? Container(
                width: 62.0.w,
                height: 62.0.w,
                decoration: BoxDecoration(
                  color: ColorConfig().gray2(),
                  borderRadius: BorderRadius.circular(4.0.r),
                  image: scrapList[index]['image1'] != null ? DecorationImage(
                    image: NetworkImage(scrapList[index]['image1']),
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.high,
                  ) : null,
                ),
                // child: index == 0 || index == 1 ? Align(
                //   alignment: Alignment.topRight,
                //   child: SVGStringBuilder(
                //     image: 'assets/icon/New-rnd.svg',
                //     width: 16.0.w,
                //     height: 16.0.w,
                //   ),
                // ) : Container(),
              ) : Container(),
              // : index == 0 || index == 1 ? SVGStringBuilder(
              //   image: 'assets/icon/New-rnd.svg',
              //   width: 16.0.w,
              //   height: 16.0.w,
              // ) : Container(),
            ],
          ),
        ),
      ),
    );
  }
}