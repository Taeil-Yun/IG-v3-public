import 'dart:io';

import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:ig-public_v3/api/write/community_patch.dart';
import 'package:ig-public_v3/src/route_argument.dart';
import 'package:intl/intl.dart';

import 'package:ig-public_v3/costant/build_config.dart';
import 'package:ig-public_v3/costant/text.dart';
import 'package:ig-public_v3/costant/colors.dart';
import 'package:ig-public_v3/api/search/community_review_search.dart';
import 'package:ig-public_v3/api/write/community_write.dart';
import 'package:ig-public_v3/component/image_picker/image_picker.dart';
import 'package:ig-public_v3/component/popup/popup.dart';
import 'package:ig-public_v3/component/appbar/appbar.dart';
import 'package:ig-public_v3/component/appbar/appbar_leading.dart';
import 'package:ig-public_v3/component/appbar/appbar_title.dart';
import 'package:ig-public_v3/component/svg/svg_builder.dart';
import 'package:ig-public_v3/util/set_intl.dart';
import 'package:ig-public_v3/util/toast.dart';
import 'package:ig-public_v3/widget/custom_text_widget.dart';
import 'package:ig-public_v3/widget/sliver_tabbar_widget.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class ReviewWriteScreen extends StatefulWidget {
  const ReviewWriteScreen({super.key});

  @override
  State<ReviewWriteScreen> createState() => _ReviewWriteScreenState();
}

class _ReviewWriteScreenState extends State<ReviewWriteScreen> with TickerProviderStateMixin {
  late TextEditingController castTextController;
  late TextEditingController locationTextController;
  late TextEditingController seatTextController;
  late TextEditingController reviewTextController;
  late TextEditingController searchController;
  late FocusNode castFocusNode;
  late FocusNode locationFocusNode;
  late FocusNode seatFocusNode;
  late FocusNode reviewFocusNode;
  late FocusNode searchFocusNode;
  late AnimationController additionalInfoController;
  late TabController searchTabController;

  String selectedShow = '';
  String searchText = '';
  String selectedType = '';

  double starRating = 0.0;

  int isHideSeat = 1;
  int dataIndex = 0;
  int communityIndex = 0;

  bool additionalInfoState = false;
  bool noSelectDate = false;
  bool hideSeat = false;
  bool onSending = false;

  List imageFiles = [];

  Map<String, dynamic> selectedData = {};
  Map<String, dynamic> searchData = {};

  DateTime? selectedDate;
  
  @override
  void initState() {
    super.initState();

    castTextController = TextEditingController()..addListener(() {
      setState(() {});
    });
    locationTextController = TextEditingController()..addListener(() {
      setState(() {});
    });
    seatTextController = TextEditingController()..addListener(() {
      setState(() {});
    });
    reviewTextController = TextEditingController()..addListener(() {
      setState(() {});
    });
    searchController = TextEditingController()..addListener(() {
      setState(() {});
    });

    castFocusNode = FocusNode();
    locationFocusNode = FocusNode();
    seatFocusNode = FocusNode();
    reviewFocusNode = FocusNode();
    searchFocusNode = FocusNode();

    additionalInfoController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    searchTabController = TabController(
      length: 2,
      vsync: this,
    );

    Future.delayed(Duration.zero, () async {
      if (RouteGetArguments().getArgs(context)['edit_data'] != null) {
        setState(() {
          communityIndex = RouteGetArguments().getArgs(context)['edit_data']['community_index'];
          selectedData['tmp'] = 'tmp';
          selectedShow = RouteGetArguments().getArgs(context)['edit_data']['item_name'];
          selectedType = RouteGetArguments().getArgs(context)['edit_data']['type'];
          dataIndex = RouteGetArguments().getArgs(context)['edit_data']['type'] == 'R' ? RouteGetArguments().getArgs(context)['edit_data']['show_index'] : RouteGetArguments().getArgs(context)['edit_data']['ticket_index'];
          reviewTextController.text = RouteGetArguments().getArgs(context)['edit_data']['content'];
          starRating = double.parse(RouteGetArguments().getArgs(context)['edit_data']['star'].toString()) / 10;
          castTextController.text = RouteGetArguments().getArgs(context)['edit_data']['casting'];
          isHideSeat = RouteGetArguments().getArgs(context)['edit_data']['is_hide'] == false ? 0 : 1;
          locationTextController.text = RouteGetArguments().getArgs(context)['edit_data']['location'];
          seatTextController.text = RouteGetArguments().getArgs(context)['edit_data']['seat'];
          selectedDate = RouteGetArguments().getArgs(context)['edit_data']['watch_date'] != null ? DateTime.parse(RouteGetArguments().getArgs(context)['edit_data']['watch_date']).toLocal() : null;
        });

        for (int i=0; i<RouteGetArguments().getArgs(context)['edit_data']['images'].length; i++) {
          final response = await http.get(Uri.parse(RouteGetArguments().getArgs(context)['edit_data']['images'][i]));

          final documentDirectory = await getApplicationDocumentsDirectory();

          final file = File(path.join(documentDirectory.path, '${DateTime.now().millisecondsSinceEpoch}.png'));

          file.writeAsBytesSync(response.bodyBytes);

          setState(() {
            imageFiles.add(file.path);
          });
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();

    castTextController.dispose();
    locationTextController.dispose();
    seatTextController.dispose();
    reviewTextController.dispose();
    searchController.dispose();
    castFocusNode.dispose();
    locationFocusNode.dispose();
    seatFocusNode.dispose();
    reviewFocusNode.dispose();
    searchFocusNode.dispose();
    additionalInfoController.dispose();
    searchTabController.dispose();
  }

  Color sendButtonColor() {
    if (selectedShow.isNotEmpty && selectedData.isNotEmpty && (reviewTextController.text.trim().isNotEmpty || imageFiles.isNotEmpty) && starRating != 0.0 && castTextController.text.trim().isNotEmpty) {
      return ColorConfig().primary();
    } else {
      return ColorConfig().gray3();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (castFocusNode.hasFocus) {
          castFocusNode.unfocus();
        }

        if (locationFocusNode.hasFocus) {
          locationFocusNode.unfocus();
        }

        if (seatFocusNode.hasFocus) {
          seatFocusNode.unfocus();
        }

        if (reviewFocusNode.hasFocus) {
          reviewFocusNode.unfocus();
        }
      },
      child: Scaffold(
        appBar: ig-publicAppBar(
          leading: ig-publicAppBarLeading(
            press: () => Navigator.pop(context),
          ),
          title: const ig-publicAppBarTitle(
            title: TextConstant.writeReview,
          ),
          actions: [
            TextButton(
              onPressed: selectedShow.isNotEmpty && selectedData.isNotEmpty && (reviewTextController.text.trim().isNotEmpty || imageFiles.isNotEmpty) && starRating != 0.0 && castTextController.text.trim().isNotEmpty ? () async {
                if (onSending == false) {
                  setState(() {
                    onSending = true;
                  });

                  if (dataIndex != 0) {
                    CommunityWritingPatchAPI().patch(
                      accessToken: await SecureStorageConfig().storage.read(key: 'access_token') ?? '',
                      type: selectedType,
                      communityIndex: communityIndex,
                      index: dataIndex != 0 ? dataIndex : selectedType == 'R' ? selectedData['show_index'] : selectedData['ticket_index'],
                      content: reviewTextController.text.trim(),
                      images: imageFiles,
                      star: (starRating * 10).toInt(),
                      casting: castTextController.text.trim(),
                      isHide: hideSeat == true ? 0 : isHideSeat,
                      location: locationTextController.text.trim(),
                      seat: seatTextController.text.trim(),
                      watchDate: noSelectDate == false ? selectedDate?.toLocal().toIso8601String() : null,
                    ).then((value) {
                      setState(() {
                        onSending = false;
                      });
                      
                      if (value.result['status'] == 1) {
                        ToastModel().iconToast(TextConstant.articleHasBeenRegistered);
                        Navigator.pop(context, {'res: true'});
                      } else {
                        ToastModel().iconToast(value.result['message']);
                      }
                    });
                  } else {
                    CommunityWritingAPI().writing(
                      accessToken: await SecureStorageConfig().storage.read(key: 'access_token') ?? '',
                      type: selectedType == 'shows' ? "R" : "T",
                      index: selectedType == 'shows' ? selectedData['show_index'] : selectedData['ticket_index'],
                      content: reviewTextController.text.trim(),
                      images: imageFiles,
                      star: (starRating * 10).toInt(),
                      casting: castTextController.text.trim(),
                      isHide: hideSeat == true ? 0 : isHideSeat,
                      location: locationTextController.text.trim(),
                      seat: seatTextController.text.trim(),
                      watchDate: noSelectDate == false ? selectedDate?.toLocal().toIso8601String() : null,
                    ).then((value) {
                      setState(() {
                        onSending = false;
                      });
                      
                      ToastModel().iconToast(TextConstant.articleHasBeenRegisteredForReview);

                      Navigator.pop(context, {'res: true'});
                    });
                  }
                }
              } : null,
              child: CustomTextBuilder(
                text: TextConstant.regist,
                fontColor: sendButtonColor(),
                fontSize: 14.0.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: ColorConfig().gray1(),
          child: Stack(
            children: [
              Container(
                margin: EdgeInsets.only(bottom: 32.0.w + 16.0 + MediaQuery.of(context).padding.bottom + (imageFiles.isNotEmpty ? 16.0 + 50.0.w : 0.0)),
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Column(
                    children: [
                      // 공연 선택 박스 위젯 영역
                      selectShowBoxWidget(),
                      // 여백
                      Container(
                        height: 4.0,
                        color: ColorConfig().white(),
                      ),
                      // 출연진 입력 위젯 영역
                      castInputWidget(),
                      // 추가정보 입력 버튼 위젯 영역
                      additionalInformationButtonWidget(),
                      // 추가정보 입력 위젯 영역
                      additionalInformationWidget(),
                      // 별점선택 위젯 영역
                      starRatingWidget(),
                      // 후기 작성 위젯 영역
                      Container(
                        height: MediaQuery.of(context).size.height - (16.0 + 14.0 + 2.0 + 24.0.w + 16.0 + 20.0.w + 16.0 + 20.0.w + 32.0 + 1.0 + 40.0.w + 4.0 + 44.0 + 32.0.w + 16.0 + MediaQuery.of(context).padding.bottom + (imageFiles.isNotEmpty ? 16.0 + 50.0.w : 0.0)),
                        padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 28.0),
                        child: TextFormField(
                          controller: reviewTextController,
                          focusNode: reviewFocusNode,
                          maxLines: null,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.zero,
                            isDense: true,
                            hintText: TextConstant.freeWriteShowReviewPlaceholder,
                            hintStyle: TextStyle(
                              color: ColorConfig().gray3(),
                              fontSize: 14.0.sp,
                              fontWeight: FontWeight.w400,
                            ),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: const UnderlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                          ),
                          style: TextStyle(
                            color: ColorConfig().dark(),
                            fontSize: 14.0.sp,
                            fontWeight: FontWeight.w400,
                          ),
                          cursorColor: ColorConfig().dark(),
                          keyboardType: TextInputType.multiline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // tool 영역
              toolBoxWidget(),
            ],
          ),
        ),
      ),
    );
  }

  // 공연 선택 박스 위젯
  Widget selectShowBoxWidget() {
    return Container(
      color: ColorConfig().white(),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: InkWell(
        onTap: () async {
          searchController.clear();
          searchTabController.index = 0;
          
          setState(() {
            searchData.clear();
            searchText = '';
          });

          CommunityReviewSearchAPI().reviewSearch(accessToken: await SecureStorageConfig().storage.read(key: 'access_token')).then((value) {
            setState(() {
              searchData = value.result['data'];  
            });

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
                return GestureDetector(
                  onTap: () {
                    if (searchFocusNode.hasFocus) {
                      searchFocusNode.unfocus();
                    }
                  },
                  child: StatefulBuilder(
                    builder: (context, state) {
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
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ig-publicAppBarTitle(
                                  onWidget: true,
                                  wd: CustomTextBuilder(
                                    text: TextConstant.showReview,
                                    fontColor: ColorConfig().dark(),
                                    fontSize: 16.0.sp,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(top: 4.0),
                                  child: CustomTextBuilder(
                                    text: TextConstant.wantSelectShowReview,
                                    fontColor: ColorConfig().dark(),
                                    fontSize: 12.0.sp,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
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
                            child: Column(
                              children: [
                                // 탭바 영역
                                Container(
                                  height: 46.0.w,
                                  decoration: BoxDecoration(
                                    border:  Border(
                                      bottom: BorderSide(
                                        width: 1.0,
                                        color: ColorConfig().gray2(),
                                      ),
                                    ),
                                  ),
                                  child: TabBar(
                                    controller: searchTabController,
                                    isScrollable: false,
                                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                    labelColor: ColorConfig().dark(),
                                    labelStyle: TextStyle(
                                      fontSize: 14.0.sp,
                                      fontWeight: FontWeight.w800,
                                    ),
                                    unselectedLabelColor: ColorConfig().gray3(),
                                    unselectedLabelStyle: TextStyle(
                                      fontSize: 14.0.sp,
                                      fontWeight: FontWeight.w800,
                                    ),
                                    indicator: CustomTabIndicator(
                                      color: ColorConfig().dark(),
                                      height: 4.0,
                                      tabPosition: TabPosition.bottom,
                                      horizontalPadding: 12.0,
                                    ),
                                    tabs: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          CustomTextBuilder(
                                            text: '${TextConstant.watchedShow} ',
                                            fontColor: ColorConfig().dark(),
                                            fontSize: 14.0.sp,
                                            fontWeight: FontWeight.w800,
                                          ),
                                          CustomTextBuilder(
                                            text: '${searchData['tickets'].length}',
                                            fontColor: ColorConfig().primary(),
                                            fontSize: 14.0.sp,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ],
                                      ),
                                      const Tab(
                                        text: TextConstant.allShow,
                                      ),
                                    ],
                                  ),
                                ),
                                // 검색창 영역
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                                  child: TextFormField(
                                    controller: searchController,
                                    focusNode: searchFocusNode,
                                    onEditingComplete: () async {
                                      CommunityReviewSearchAPI().reviewSearch(accessToken: await SecureStorageConfig().storage.read(key: 'access_token'), keyword: searchController.text.trim()).then((result) {
                                        state(() {
                                          searchData = result.result['data'];
                                          searchText = searchController.text.trim();
                                        });

                                        searchFocusNode.unfocus();
                                      });
                                    },
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: ColorConfig().gray1(),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius: BorderRadius.circular(4.0.r),
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius: BorderRadius.circular(4.0.r),
                                      ),
                                      hintText: TextConstant.search,
                                      hintStyle: TextStyle(
                                        color: ColorConfig().gray3(),
                                        fontSize: 12.0.sp,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      prefixIcon: Container(
                                        margin: const EdgeInsets.only(left: 12.0, right: 4.0),
                                        child: SVGBuilder(
                                          image: 'assets/icon/search.svg',
                                          width: 24.0.w,
                                          height: 24.0.w,
                                          color: searchController.text.isEmpty ? ColorConfig().gray3() : ColorConfig().dark(),
                                        ),
                                      ),
                                      prefixIconConstraints: BoxConstraints(
                                        maxWidth: 24.0.w + 12.0,
                                        maxHeight: 24.0.w,
                                      ),
                                      suffixIcon: searchController.text.isNotEmpty ? InkWell(
                                        onTap: () {
                                          state(() {
                                            searchController.clear();
                                          });
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.only(left: 4.0, right: 12.0),
                                          child: SVGBuilder(
                                            image: 'assets/icon/close_normal.svg',
                                            width: 24.0.w,
                                            height: 24.0.w,
                                            color: ColorConfig().gray3(),
                                          ),
                                        ),
                                      ) : null,
                                      suffixIconConstraints: BoxConstraints(
                                        maxWidth: 24.0.w + 12.0,
                                        maxHeight: 24.0.w,
                                      ),
                                    ),
                                    style: TextStyle(
                                      color: ColorConfig().dark(),
                                      fontSize: 12.0.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    cursorHeight: 12.0.sp,
                                    cursorColor: ColorConfig().primary(),
                                    keyboardType: TextInputType.text,
                                  ),
                                ),
                                // 검색 데이터 영역
                                Expanded(
                                  child: TabBarView(
                                    controller: searchTabController,
                                    children: [
                                      // 관람한 공연 리스트 영역
                                      SingleChildScrollView(
                                        child: Column(
                                          children: [
                                            // 상단 텍스트 영역
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    margin: const EdgeInsets.only(right: 8.0),
                                                    child: SVGStringBuilder(
                                                      image: 'assets/icon/cms_management.svg',
                                                      width: 24.0.w,
                                                      height: 24.0.w,
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: CustomTextBuilder(
                                                      text: TextConstant.reviewBedgeText,
                                                      fontColor: ColorConfig().primary(),
                                                      fontSize: 12.0.sp,
                                                      fontWeight: FontWeight.w700,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            // 공연 영역
                                            SizedBox(
                                              width: MediaQuery.of(context).size.width,
                                              child: searchData['tickets'].isNotEmpty ? Wrap(
                                                children: List.generate(searchData['tickets'].length, (tickets) {
                                                  return InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        selectedData = searchData['tickets'][tickets];
                                                        selectedShow = searchData['tickets'][tickets]['name'];
                                                        selectedType = 'tickets';
                                                        if (selectedType == 'tickets') {
                                                          castTextController.text = selectedData['casting'];
                                                          locationTextController.text = selectedData['location'];
                                                          seatTextController.text = selectedData['seat'];
                                                          selectedDate = DateTime.parse(selectedData['open_date']).toLocal();
                                                        }
                                                        Navigator.pop(context);
                                                      });
                                                    },
                                                    child: Container(
                                                      width: (MediaQuery.of(context).size.width - (12.0 + 32.0 + 4.0)) / 2,
                                                      margin: EdgeInsets.fromLTRB(tickets.isEven ? 16.0 : 4.0, 8.0, tickets.isOdd ? 16.0 : 0.0, 8.0),
                                                      padding: const EdgeInsets.symmetric(horizontal: 6.0),
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          // 포스터 영역
                                                          Container(
                                                            width: 152.0.w,
                                                            height: 204.0.w,
                                                            decoration: BoxDecoration(
                                                              color: searchData['tickets'][tickets]['image'] == null ? ColorConfig().gray2() : null,
                                                              borderRadius: BorderRadius.circular(4.0.r),
                                                              image: searchData['tickets'][tickets]['image'] != null ? DecorationImage(
                                                                image: NetworkImage(searchData['tickets'][tickets]['image']),
                                                                fit: BoxFit.cover,
                                                                filterQuality: FilterQuality.high,
                                                              ) : null,
                                                            ),
                                                            child: searchData['tickets'][tickets]['image'] == null ? Center(
                                                              child: SVGBuilder(
                                                                image: 'assets/icon/album.svg',
                                                                width: 40.0.w,
                                                                height: 40.0.w,
                                                                color: ColorConfig().white(),
                                                              ),
                                                            ) : Container(),
                                                          ),
                                                          Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              // 공연명 영역
                                                              Container(
                                                                margin: const EdgeInsets.only(top: 12.0),
                                                                child: CustomTextBuilder(
                                                                  text: '${searchData['tickets'][tickets]['name']}',
                                                                  fontColor: ColorConfig().dark(),
                                                                  fontSize: 14.0.sp,
                                                                  fontWeight: FontWeight.w800,
                                                                ),
                                                              ),
                                                              // 관람날짜 영역
                                                              Container(
                                                                margin: const EdgeInsets.only(top: 4.0, bottom: 16.0),
                                                                child: CustomTextBuilder(
                                                                  text: DateFormat('yyyy.M.d hh:mm 관람').format(DateTime.parse(searchData['tickets'][tickets]['open_date']).toLocal()),
                                                                  fontColor: ColorConfig().gray4(),
                                                                  fontSize: 11.0.sp,
                                                                  fontWeight: FontWeight.w700,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                }),
                                              ) : Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    width: 60.0.w,
                                                    height: 60.0.w,
                                                    margin: const EdgeInsets.only(top: 131.0, bottom: 24.0),
                                                    decoration: const BoxDecoration(
                                                      image: DecorationImage(
                                                        image: AssetImage('assets/img/no-data-search.png'),
                                                        filterQuality: FilterQuality.high,
                                                      ),
                                                    ),
                                                  ),
                                                  CustomTextBuilder(
                                                    text: '"${searchController.text}"\n검색 결과를 찾을 수 없습니다.\n다시한번 검색해주세요.',
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
                                      // 공연 전체 영역
                                      SingleChildScrollView(
                                        child: searchData['shows'].isNotEmpty ? Column(
                                          children: [
                                            // 상단 텍스트 영역
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    margin: const EdgeInsets.only(right: 4.0),
                                                    child: CustomTextBuilder(
                                                      text: searchController.text.isEmpty ? TextConstant.ingShow : TextConstant.searchResult,
                                                      fontColor: ColorConfig().dark(),
                                                      fontSize: 14.0.sp,
                                                      fontWeight: FontWeight.w700,
                                                    ),
                                                  ),
                                                  CustomTextBuilder(
                                                    text: '${SetIntl().numberFormat(searchData['shows'].length)}',
                                                    fontColor: ColorConfig().primary(),
                                                    fontSize: 12.0.sp,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            // 공연 영역
                                            SizedBox(
                                              width: MediaQuery.of(context).size.width,
                                              child: Wrap(
                                                children: List.generate(searchData['shows'].length, (tickets) {
                                                  return InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        selectedData = searchData['shows'][tickets];
                                                        selectedShow = searchData['shows'][tickets]['name'];
                                                        selectedType = 'shows';
                                                        
                                                        Navigator.pop(context);
                                                      });
                                                    },
                                                    child: Container(
                                                      width: (MediaQuery.of(context).size.width - (12.0 + 32.0 + 4.0)) / 2,
                                                      margin: EdgeInsets.fromLTRB(tickets.isEven ? 16.0 : 4.0, 8.0, tickets.isOdd ? 16.0 : 0.0, 8.0),
                                                      padding: const EdgeInsets.symmetric(horizontal: 6.0),
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          // 포스터 영역
                                                          Container(
                                                            width: 152.0.w,
                                                            height: 204.0.w,
                                                            decoration: BoxDecoration(
                                                              color: searchData['shows'][tickets]['image'] == null ? ColorConfig().gray2() : null,
                                                              borderRadius: BorderRadius.circular(4.0.r),
                                                              image: searchData['shows'][tickets]['image'] != null ? DecorationImage(
                                                                image: NetworkImage(searchData['shows'][tickets]['image']),
                                                                fit: BoxFit.cover,
                                                                filterQuality: FilterQuality.high,
                                                              ) : null,
                                                            ),
                                                            child: searchData['shows'][tickets]['image'] == null ? Center(
                                                              child: SVGBuilder(
                                                                image: 'assets/icon/album.svg',
                                                                width: 40.0.w,
                                                                height: 40.0.w,
                                                                color: ColorConfig().white(),
                                                              ),
                                                            ) : Container(),
                                                          ),
                                                          Container(
                                                            margin: const EdgeInsets.only(top: 12.0, bottom: 16.0),
                                                            child: CustomTextBuilder(
                                                              text: '${searchData['shows'][tickets]['name']}',
                                                              fontColor: ColorConfig().dark(),
                                                              fontSize: 14.0.sp,
                                                              fontWeight: FontWeight.w800,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                }),
                                              ),
                                            ),
                                          ],
                                        ) : Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              width: 60.0.w,
                                              height: 60.0.w,
                                              margin: const EdgeInsets.only(top: 131.0, bottom: 24.0),
                                              decoration: const BoxDecoration(
                                                image: DecorationImage(
                                                  image: AssetImage('assets/img/no-data-search.png'),
                                                  filterQuality: FilterQuality.high,
                                                ),
                                              ),
                                            ),
                                            CustomTextBuilder(
                                              text: '"${searchController.text}"\n검색 결과를 찾을 수 없습니다.\n다시한번 검색해주세요.',
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
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                );
              },
            );
          });
        },
        child: Container(
          padding: const EdgeInsets.fromLTRB(20.0, 12.0, 12.0, 12.0),
          decoration: BoxDecoration(
            color: ColorConfig().primaryLight3(),
            border: Border.all(
              width: 1.0,
              color: ColorConfig().primary(),
            ),
            borderRadius: BorderRadius.circular(4.0.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomTextBuilder(
                text: selectedShow,
                fontColor: ColorConfig().gray5(),
                fontSize: 14.0.sp,
                fontWeight: FontWeight.w700,
              ),
              Container(
                margin: const EdgeInsets.only(left: 8.0),
                child: SVGBuilder(
                  image: 'assets/icon/triangle-down.svg',
                  width: 24.0.w,
                  height: 24.0.w,
                  color: ColorConfig().gray5(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 출연진 입력 위젯
  Widget castInputWidget() {
    return Container(
      width: MediaQuery.of(context).size.width,
      color: ColorConfig().white(),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Row(
        children: [
          Container(
            margin: const EdgeInsets.only(right: 12.0),
            child: SVGBuilder(
              image: 'assets/icon/cast.svg',
              width: 20.0.w,
              height: 20.0.w,
              color: ColorConfig().dark(),
            ),
          ),
          Expanded(
            child: TextFormField(
              controller: castTextController,
              focusNode: castFocusNode,
              readOnly: selectedType == 'tickets' ? true : false,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.zero,
                isDense: true,
                hintText: TextConstant.inputCastPlaceholder,
                hintStyle: TextStyle(
                  color: ColorConfig().gray3(),
                  fontSize: 14.0.sp,
                  fontWeight: FontWeight.w400,
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide.none,
                ),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(
                color: ColorConfig().dark(),
                fontSize: 14.0.sp,
                fontWeight: FontWeight.w700,
              ),
              cursorColor: ColorConfig().primary(),
              cursorHeight: 14.0.sp,
              keyboardType: TextInputType.text,
            ),
          ),
        ],
      ),
    );
  }

  // 추가정보 입력 버튼 위젯
  Widget additionalInformationButtonWidget() {
    return InkWell(
      onTap: () {
        setState(() {
          if (additionalInfoState == false) {
            additionalInfoController.forward();
            additionalInfoState = true;
          } else {
            additionalInfoController.reverse();
            additionalInfoState = false;
          }
        });
      },
      child: Container(
        color: ColorConfig().white(),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 12.0),
                  child: SVGBuilder(
                    image: 'assets/icon/info-not-bg.svg',
                    width: 20.0.w,
                    height: 20.0.w,
                    color: ColorConfig().dark(),
                  ),
                ),
                CustomTextBuilder(
                  text: TextConstant.additionalInformation,
                  fontColor: ColorConfig().dark(),
                  fontSize: 14.0.sp,
                  fontWeight: FontWeight.w700,
                ),
              ],
            ),
            Container(
              margin: const EdgeInsets.only(left: 12.0),
              child: RotationTransition(
                turns: Tween(begin: 0.0, end: 0.5).animate(additionalInfoController),
                child: SVGBuilder(
                  image: 'assets/icon/arrow_down_bold.svg',
                  width: 20.0.w,
                  height: 20.0.w,
                  color: ColorConfig().dark(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 추가정보 입력 위젯
  Widget additionalInformationWidget() {
    return SizeTransition(
      sizeFactor: CurvedAnimation(
        parent: additionalInfoController,
        curve: Curves.easeIn,
      ),
      child: Column(
        children: [
          // 날짜 선택 영역
          InkWell(
            onTap: () {
              showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000, 1, 1),
                lastDate: DateTime.now(),
                initialEntryMode: DatePickerEntryMode.calendar,
              ).then((sd) {
                showTimePicker(
                  context: context, initialTime: TimeOfDay(hour: DateTime.now().hour, minute: DateTime.now().minute),
                ).then((time) {
                  int lyear = sd!.year;
                  int lmonth = sd.month;
                  int lday = sd.day;
                  int lhour = time!.hour;
                  int lminute = time.minute;

                  setState(() {
                    selectedDate = DateTime(lyear, lmonth, lday, lhour, lminute);
                  });
                });
              });
            },
            child: Container(
              color: ColorConfig().white(),
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(right: 12.0),
                        child: SVGBuilder(
                          image: 'assets/icon/calendar.svg',
                          width: 20.0.w,
                          height: 20.0.w,
                          color: ColorConfig().gray5(),
                        ),
                      ),
                      CustomTextBuilder(
                        text: selectedDate == null ? TextConstant.selectReviewDate : DateFormat('yyyy년 M월 d일(E) HH:mm', 'ko').format(selectedDate!.toLocal()),
                        fontColor: selectedDate == null ? ColorConfig().gray3() : ColorConfig().dark(),
                        fontSize: 14.0.sp,
                        fontWeight: selectedDate == null ? FontWeight.w400 : FontWeight.w700,
                      ),
                    ],
                  ),
                  selectedType != 'tickets' ? Container(
                    margin: const EdgeInsets.only(left: 12.0),
                    child: SVGBuilder(
                      image: 'assets/icon/arrow_right_light.svg',
                      width: 16.0.w,
                      height: 16.0.w,
                      color: ColorConfig().gray3(),
                    ),
                  ) : Container(),
                ],
              ),
            ),
          ),
          // 날짜 선택안함 영역
          selectedType != 'tickets' ? InkWell(
            onTap: () {
              setState(() {
                noSelectDate = !noSelectDate;
              });
            },
            child: Container(
              color: ColorConfig().white(),
              padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 4.0),
              child: Row(
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 12.0),
                    child: SVGBuilder(
                      image: 'assets/icon/check.svg',
                      width: 20.0.w,
                      height: 20.0.w,
                      color: noSelectDate == true ? ColorConfig().dark() : ColorConfig().gray2(),
                    ),
                  ),
                  CustomTextBuilder(
                    text: TextConstant.dontSelectReviewDate,
                    fontColor: ColorConfig().dark(),
                    fontSize: 11.0.sp,
                    fontWeight: FontWeight.w400,
                  ),
                  Tooltip(
                    message: TextConstant.dontSelectReviewDateToolTip,
                    padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color: ColorConfig().dark(),
                      borderRadius: BorderRadius.circular(8.0.r),
                    ),
                    textStyle: TextStyle(
                      color: ColorConfig().white(),
                      fontSize: 12.0.sp,
                      fontWeight: FontWeight.w400,
                    ),
                    triggerMode: TooltipTriggerMode.tap,
                    child: Container(
                      margin: const EdgeInsets.only(left: 4.0),
                      child: SVGBuilder(
                        image: 'assets/icon/info-not-bg.svg',
                        width: 16.0.w,
                        height: 16.0.w,
                        color: ColorConfig().dark(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ) : Container(),
          // 장소 입력 영역
          Container(
            color: ColorConfig().white(),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: Row(
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 12.0),
                  child: SVGBuilder(
                    image: 'assets/icon/location.svg',
                    width: 20.0.w,
                    height: 20.0.w,
                    color: ColorConfig().gray5(),
                  ),
                ),
                Expanded(
                  child: TextFormField(
                    controller: locationTextController,
                    focusNode: locationFocusNode,
                    readOnly: selectedType == 'tickets' ? true : false,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                      hintText: TextConstant.inputLocation,
                      hintStyle: TextStyle(
                        color: ColorConfig().gray3(),
                        fontSize: 14.0.sp,
                        fontWeight: FontWeight.w400,
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: TextStyle(
                      color: ColorConfig().dark(),
                      fontSize: 14.0.sp,
                      fontWeight: FontWeight.w700,
                    ),
                    cursorColor: ColorConfig().primary(),
                    cursorHeight: 14.0.sp,
                    keyboardType: TextInputType.text,
                  ),
                ),
              ],
            ),
          ),
          // 좌석번호 입력 영역
          Container(
            color: ColorConfig().white(),
            margin: const EdgeInsets.symmetric(vertical: 1.0),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: Row(
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 12.0),
                  child: SVGBuilder(
                    image: 'assets/icon/seat.svg',
                    width: 20.0.w,
                    height: 20.0.w,
                    color: ColorConfig().gray5(),
                  ),
                ),
                Expanded(
                  child: TextFormField(
                    controller: seatTextController,
                    focusNode: seatFocusNode,
                    readOnly: selectedType == 'tickets' ? true : false,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                      hintText: TextConstant.inputSeatNumber,
                      hintStyle: TextStyle(
                        color: ColorConfig().gray3(),
                        fontSize: 14.0.sp,
                        fontWeight: FontWeight.w400,
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: TextStyle(
                      color: ColorConfig().dark(),
                      fontSize: 14.0.sp,
                      fontWeight: FontWeight.w700,
                    ),
                    cursorColor: ColorConfig().primary(),
                    cursorHeight: 14.0.sp,
                    keyboardType: TextInputType.text,
                  ),
                ),
              ],
            ),
          ),
          // 좌석번호 숨기기 영역
          InkWell(
            onTap: () {
              setState(() {
                hideSeat = !hideSeat;
              });
            },
            child: Container(
              color: ColorConfig().white(),
              padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 4.0),
              child: Row(
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 12.0),
                    child: SVGBuilder(
                      image: 'assets/icon/check.svg',
                      width: 20.0.w,
                      height: 20.0.w,
                      color: hideSeat == true ? ColorConfig().dark() : ColorConfig().gray2(),
                    ),
                  ),
                  CustomTextBuilder(
                    text: TextConstant.hideSeatNumber,
                    fontColor: ColorConfig().dark(),
                    fontSize: 11.0.sp,
                    fontWeight: FontWeight.w400,
                  ),
                  Tooltip(
                    message: TextConstant.hideSeatNumberToolTip,
                    padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color: ColorConfig().dark(),
                      borderRadius: BorderRadius.circular(8.0.r),
                    ),
                    textStyle: TextStyle(
                      color: ColorConfig().white(),
                      fontSize: 12.0.sp,
                      fontWeight: FontWeight.w400,
                    ),
                    triggerMode: TooltipTriggerMode.tap,
                    child: Container(
                      margin: const EdgeInsets.only(left: 4.0),
                      child: SVGBuilder(
                        image: 'assets/icon/info-not-bg.svg',
                        width: 16.0.w,
                        height: 16.0.w,
                        color: ColorConfig().dark(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 별점선택 위젯
  Widget starRatingWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 1.0,
            color: ColorConfig().gray2(),
          ),
        ),
      ),
      child: Center(
        child: RatingBar.builder(
          initialRating: dataIndex != 0 ? starRating : 0,
          minRating: 0.5,
          direction: Axis.horizontal,
          allowHalfRating: true,
          itemCount: 5,
          itemSize: 40.0.w,
          unratedColor: ColorConfig().gray2(),
          glow: false,
          itemBuilder: (context, _) => SVGBuilder(
            image: 'assets/icon/star.svg',
            color: ColorConfig().primary(),
          ),
          onRatingUpdate: (rating) {
            setState(() {
              starRating = rating;
            });
          },
        ),
      ),
    );
  }

  // 도구함 위젯
  Widget toolBoxWidget() {
    return Positioned(
      bottom: 0.0,
      child: Column(
        children: [
          // 선택된 이미지 영역
          imageFiles.isNotEmpty ? Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.fromLTRB(20.0, 4.0, 20.0, 8.0),
            decoration: BoxDecoration(
              color: ColorConfig().white(),
              boxShadow: [
                BoxShadow(
                  offset: const Offset(0.0, 0.0),
                  color: ColorConfig().overlay(opacity: 0.12),
                  blurRadius: 8.0,
                ),
              ],
            ),
            child: Row(
              children: List.generate(imageFiles.length, (imageIndex) {
                return Container(
                  width: 50.0.w + 4.0,
                  height: 50.0.w + 4.0,
                  margin: imageIndex != imageFiles.length - 1 ? const EdgeInsets.only(right: 8.0) : null,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0.0,
                        bottom: 0.0,
                        child: Container(
                          width: 50.0.w,
                          height: 50.0.w,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6.0.r),
                            image: DecorationImage(
                              image: FileImage(File(imageFiles[imageIndex])),
                              fit: BoxFit.cover,
                              filterQuality: FilterQuality.high,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0.0,
                        right: 0.0,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              imageFiles.removeAt(imageIndex);
                            });
                          },
                          child: Container(
                            width: 16.0.w,
                            height: 16.0.w,
                            decoration: BoxDecoration(
                              color: ColorConfig().white(),
                              borderRadius: BorderRadius.circular(8.0.r),
                              boxShadow: [
                                BoxShadow(
                                  offset: const Offset(0.0, 0.0),
                                  color: ColorConfig().overlay(opacity: 0.12),
                                  blurRadius: 8.0,
                                ),
                              ],
                            ),
                            child: Center(
                              child: SVGBuilder(
                                image: 'assets/icon/close_small.svg',
                                width: 12.0.w,
                                height: 12.0.w,
                                color: ColorConfig().dark(),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ) : Container(),
          // tool 영역
          Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            color: ColorConfig().white(),
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          if (imageFiles.length > 3) {
                            PopupBuilder(
                              title: TextConstant.imageLimitOver,
                              content: TextConstant.imageLimitOverDescription,
                              actions: [
                                InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    color: ColorConfig().dark(),
                                    padding: const EdgeInsets.symmetric(vertical: 16.0),
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
                            ImagePickerSelector().getCamera().then((img) {
                              setState(() {
                                imageFiles.add(img.path);
                              });
                            });
                          }
                        },
                        icon: SVGStringBuilder(
                          image: 'assets/icon/camera.svg',
                          color: ColorConfig().gray5(),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          ImagePickerSelector().multiImagePicker().then((imgs) {
                            if (imgs.length > 3 || imageFiles.length + imgs.length > 3) {
                              PopupBuilder(
                                title: TextConstant.imageLimitOver,
                                content: TextConstant.imageLimitOverDescription,
                                actions: [
                                  InkWell(
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                    child: Container(
                                      color: ColorConfig().dark(),
                                      padding: const EdgeInsets.symmetric(vertical: 16.0),
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
                              setState(() {  
                                for (int i=0; i<imgs.length; i++) {
                                  imageFiles.add(imgs[i].path);
                                }
                              });
                            }
                          });
                        },
                        icon: SVGStringBuilder(
                          image: 'assets/icon/album.svg',
                          color: ColorConfig().gray5(),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () {
                      if (castFocusNode.hasFocus) {
                        castFocusNode.unfocus();
                      }

                      if (locationFocusNode.hasFocus) {
                        locationFocusNode.unfocus();
                      }

                      if (seatFocusNode.hasFocus) {
                        seatFocusNode.unfocus();
                      }

                      if (reviewFocusNode.hasFocus) {
                        reviewFocusNode.unfocus();
                      }
                    },
                    icon: SVGStringBuilder(
                      image: 'assets/icon/keyboard.svg',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}