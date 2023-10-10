import 'dart:io';

import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ig-public_v3/api/search/community_search.dart';
import 'package:ig-public_v3/api/write/community_patch.dart';

import 'package:ig-public_v3/costant/build_config.dart';
import 'package:ig-public_v3/costant/colors.dart';
import 'package:ig-public_v3/costant/exception_data.dart';
import 'package:ig-public_v3/costant/text.dart';
import 'package:ig-public_v3/api/write/community_recommend_list.dart';
import 'package:ig-public_v3/api/write/community_write.dart';
import 'package:ig-public_v3/component/appbar/appbar.dart';
import 'package:ig-public_v3/component/appbar/appbar_leading.dart';
import 'package:ig-public_v3/component/appbar/appbar_title.dart';
import 'package:ig-public_v3/component/svg/svg_builder.dart';
import 'package:ig-public_v3/component/image_picker/image_picker.dart';
import 'package:ig-public_v3/component/popup/popup.dart';
import 'package:ig-public_v3/src/route_argument.dart';
import 'package:ig-public_v3/util/toast.dart';
import 'package:ig-public_v3/widget/custom_text_widget.dart';
import 'package:ig-public_v3/widget/sliver_tabbar_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class CommunityWritingScreen extends StatefulWidget {
  const CommunityWritingScreen({super.key});

  @override
  State<CommunityWritingScreen> createState() => _CommunityWritingScreenState();
}

class _CommunityWritingScreenState extends State<CommunityWritingScreen> with SingleTickerProviderStateMixin {
  late TextEditingController titleController;
  late TextEditingController bodyController;
  late TextEditingController searchController;
  late FocusNode titleFocusNode;
  late FocusNode bodyFocusNode;
  late FocusNode searchFocusNode;
  late TabController searchTabController;

  List imageFiles = [];

  int dataIndex = 0;
  int communityIndex = 0;

  bool onSending = false;

  String selectedType = '';
  String searchText = '';

  Map<String, dynamic> followRecommendList = {};
  Map<String, dynamic> selectedData = {};
  Map<String, dynamic> searchData = {};

  @override
  void initState() {
    super.initState();

    titleController = TextEditingController()..addListener(() {
      setState(() {});
    });
    bodyController = TextEditingController()..addListener(() {
      setState(() {});
    });
    searchController = TextEditingController()..addListener(() {
      setState(() {});
    });

    titleFocusNode = FocusNode();
    bodyFocusNode = FocusNode();
    searchFocusNode = FocusNode();

    searchTabController = TabController(
      length: 2,
      vsync: this,
    );

    Future.delayed(Duration.zero, () async {
      if (RouteGetArguments().getArgs(context)['edit_data'] != null) {
        for (int i=0; i<RouteGetArguments().getArgs(context)['edit_data']['images'].length; i++) {
          if (RouteGetArguments().getArgs(context)['edit_data']['images'][i] != imageException) {
            final response = await http.get(Uri.parse(RouteGetArguments().getArgs(context)['edit_data']['images'][i]));

            final documentDirectory = await getApplicationDocumentsDirectory();

            final file = File(path.join(documentDirectory.path, '${DateTime.now().millisecondsSinceEpoch}.png'));

            file.writeAsBytesSync(response.bodyBytes);

            setState(() {
              imageFiles.add(file.path);
            });
          }
        }
        
        setState(() {
          communityIndex = RouteGetArguments().getArgs(context)['edit_data']['community_index'];
          selectedData['name'] = RouteGetArguments().getArgs(context)['edit_data']['item_name'];
          selectedType = RouteGetArguments().getArgs(context)['edit_data']['type'];
          dataIndex = RouteGetArguments().getArgs(context)['edit_data']['type'] == 'S' ? RouteGetArguments().getArgs(context)['edit_data']['show_index'] : RouteGetArguments().getArgs(context)['edit_data']['artist_index'];
          titleController.text = RouteGetArguments().getArgs(context)['edit_data']['title'];
          bodyController.text = RouteGetArguments().getArgs(context)['edit_data']['content'];
        });

      }
    });

    initializeAPI();
  }

  @override
  void dispose() {
    super.dispose();

    titleController.dispose();
    bodyController.dispose();
    searchController.dispose();
    titleFocusNode.dispose();
    bodyFocusNode.dispose();
    searchFocusNode.dispose();
    searchTabController.dispose();
  }

  Future<void> initializeAPI() async {
    CommunityRecommendListAPI().list(accessToken: await SecureStorageConfig().storage.read(key: 'access_token')).then((value) {
      setState(() {
        followRecommendList = value.result['data'];
      });
    });
  }

  Color sendButtonColor() {
    if (selectedData.isNotEmpty && selectedType != '' && titleController.text.trim().isNotEmpty && (bodyController.text.trim().isNotEmpty || imageFiles.isNotEmpty)) {
      return ColorConfig().primary();
    } else {
      return ColorConfig().gray3();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (titleFocusNode.hasFocus) {
          titleFocusNode.unfocus();
        }

        if (bodyFocusNode.hasFocus) {
          bodyFocusNode.unfocus();
        }
      },
      child: Scaffold(
        appBar: ig-publicAppBar(
          leading: ig-publicAppBarLeading(
            press: () {
              if (selectedData.isNotEmpty || selectedType != '' || titleController.text.trim().isNotEmpty || (bodyController.text.trim().isNotEmpty || imageFiles.isNotEmpty)) {
                PopupBuilder(
                  title: TextConstant.toBack,
                  content: TextConstant.toBackDescription,
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
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            margin: const EdgeInsets.only(right: 8.0),
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
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                          splashColor: ColorConfig.transparent,
                          child: Container(
                            width: (MediaQuery.of(context).size.width - 120.0.w) / 2,
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            decoration: BoxDecoration(
                              color: ColorConfig().dark(),
                              borderRadius: BorderRadius.circular(4.0.r),
                            ),
                            child: Center(
                              child: CustomTextBuilder(
                                text: TextConstant.delete,
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
              } else {
                Navigator.pop(context);
              }
            },
          ),
          title: const ig-publicAppBarTitle(
            title: TextConstant.write,
          ),
          actions: [
            TextButton(
              onPressed: selectedData.isNotEmpty || selectedType != '' || titleController.text.trim().isNotEmpty || (bodyController.text.trim().isNotEmpty || imageFiles.isNotEmpty) ? () async {
                if (onSending == false) {
                  setState(() {
                    onSending = true;
                  });

                  if (dataIndex != 0) {

                    CommunityWritingPatchAPI().patch(
                      accessToken: await SecureStorageConfig().storage.read(key: 'access_token') ?? '',
                      type: selectedType,
                      communityIndex: communityIndex,
                      index: dataIndex != 0 ? dataIndex : selectedType == 'S' ? selectedData['show_index'] : selectedData['artist_index'],
                      title: titleController.text.trim(),
                      content: bodyController.text.trim(),
                      images: imageFiles,
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
                      type: selectedType,
                      index: selectedType == 'S' ? selectedData['show_index'] : selectedData['artist_index'],
                      title: titleController.text.trim(),
                      content: bodyController.text.trim(),
                      images: imageFiles,
                    ).then((value) {
                      setState(() {
                        onSending = false;
                      });
                      
                      ToastModel().iconToast(TextConstant.articleHasBeenRegistered);
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
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(16.0 + 2.0 + 24.0 + 24.0.w),
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              color: ColorConfig().white(),
              child: InkWell(
                onTap: () {
                  searchController.clear();
                  searchTabController.index = 0;
                  
                  setState(() {
                    searchData.clear();
                    searchText = '';
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
                                  title: ig-publicAppBarTitle(
                                    onWidget: true,
                                    wd: CustomTextBuilder(
                                      text: TextConstant.selectCommunity,
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
                                  child: Column(
                                    children: [
                                      // 검색창 영역
                                      Container(
                                        width: MediaQuery.of(context).size.width,
                                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                                        decoration: BoxDecoration(
                                          border:  Border(
                                            bottom: BorderSide(
                                              width: 1.0,
                                              color: ColorConfig().gray2(),
                                            ),
                                          ),
                                        ),
                                        child: TextFormField(
                                          controller: searchController,
                                          focusNode: searchFocusNode,
                                          onEditingComplete: () async {
                                            CommunitySearchAPI().communitySearch(accessToken: await SecureStorageConfig().storage.read(key: 'access_token'), keyword: searchController.text.trim()).then((value) {
                                              state(() {
                                                searchData = value.result['data'];
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
                                      // 탭바 영역
                                      SizedBox(
                                        height: 46.0.w,
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
                                          tabs: const [
                                            Tab(
                                              text: TextConstant.show,
                                            ),
                                            Tab(
                                              text: TextConstant.artist,
                                            ),
                                          ],
                                        ),
                                      ),
                                      // 검색 데이터 영역
                                      Expanded(
                                        child: TabBarView(
                                          controller: searchTabController,
                                          children: [
                                            // 공연 리스트 영역
                                            searchData.isEmpty
                                              ? SingleChildScrollView(
                                                  child: Column(
                                                    children: [
                                                      // 팔로우 공연 리스트 영역
                                                      Column(
                                                        children: List.generate(followRecommendList['follow_show'].length, (followShowIndex) {
                                                          return Container(
                                                            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                                                            child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              children: [
                                                                Expanded(
                                                                  child: Row(
                                                                    children: [
                                                                      Container(
                                                                        width: 42.0.w + 6.0,
                                                                        height: 48.0.w,
                                                                        margin: const EdgeInsets.only(right: 8.0),
                                                                        padding: const EdgeInsets.symmetric(horizontal: 3.0),
                                                                        child: Container(
                                                                          width: 42.0.w,
                                                                          height: 48.0.w,
                                                                          decoration: BoxDecoration(
                                                                            color: followRecommendList['follow_show'][followShowIndex]['image'] == null ? ColorConfig().gray2() : null,
                                                                            borderRadius: BorderRadius.circular(10.0.r),
                                                                            image: followRecommendList['follow_show'][followShowIndex]['image'] != null ? DecorationImage(
                                                                              image: NetworkImage(followRecommendList['follow_show'][followShowIndex]['image']),
                                                                              fit: BoxFit.cover,
                                                                              filterQuality: FilterQuality.high,
                                                                            ) : null,
                                                                          ),
                                                                          child: followRecommendList['follow_show'][followShowIndex]['image'] == null ? Center(
                                                                            child: SVGBuilder(
                                                                              image: 'assets/icon/album.svg',
                                                                              width: 22.0.w,
                                                                              height: 22.0.w,
                                                                              color: ColorConfig().white(),
                                                                            ),
                                                                          ) : Container(),
                                                                        ),
                                                                      ),
                                                                      Expanded(
                                                                        child: CustomTextBuilder(
                                                                          text: '${followRecommendList['follow_show'][followShowIndex]['name']}',
                                                                          fontColor: ColorConfig().primary(),
                                                                          fontSize: 14.0.sp,
                                                                          fontWeight: FontWeight.w800,
                                                                          maxLines: 1,
                                                                          textOverflow: TextOverflow.ellipsis,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                Container(
                                                                  margin: const EdgeInsets.only(left: 12.0),
                                                                  child: InkWell(
                                                                    onTap: () {
                                                                      setState(() {
                                                                        selectedData = followRecommendList['follow_show'][followShowIndex];
                                                                        selectedType = 'S';
                                                                        Navigator.pop(context);
                                                                      });
                                                                    },
                                                                    child: Container(
                                                                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                                                                      decoration: BoxDecoration(
                                                                        color: ColorConfig().white(),
                                                                        border: Border.all(
                                                                          width: 1.0,
                                                                          color: ColorConfig().gray3(),
                                                                        ),
                                                                        borderRadius: BorderRadius.circular(4.0.r),
                                                                      ),
                                                                      child: CustomTextBuilder(
                                                                        text: TextConstant.select,
                                                                        fontColor: ColorConfig().gray5(),
                                                                        fontSize: 12.0.sp,
                                                                        fontWeight: FontWeight.w700,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                        }),
                                                      ),
                                                      // 추천 커뮤니티 타이틀 영역
                                                      Container(
                                                        width: MediaQuery.of(context).size.width,
                                                        margin: const EdgeInsets.only(top: 4.0),
                                                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                                                        child: CustomTextBuilder(
                                                          text: TextConstant.recommendCommunity,
                                                          fontColor: ColorConfig().dark(),
                                                          fontSize: 14.0.sp,
                                                          fontWeight: FontWeight.w800,
                                                        ),
                                                      ),
                                                      // 추천 커뮤니티 공연 리스트 영역
                                                      Column(
                                                        children: List.generate(followRecommendList['shows_recommend'].length, (recommendShowIndex) {
                                                          return Container(
                                                            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                                                            child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              children: [
                                                                Expanded(
                                                                  child: Row(
                                                                    children: [
                                                                      Container(
                                                                        width: 42.0.w + 6.0,
                                                                        height: 48.0.w,
                                                                        margin: const EdgeInsets.only(right: 8.0),
                                                                        padding: const EdgeInsets.symmetric(horizontal: 3.0),
                                                                        child: Container(
                                                                          width: 42.0.w,
                                                                          height: 48.0.w,
                                                                          decoration: BoxDecoration(
                                                                            color: followRecommendList['shows_recommend'][recommendShowIndex]['image'] == null ? ColorConfig().gray2() : null,
                                                                            borderRadius: BorderRadius.circular(10.0.r),
                                                                            image: followRecommendList['shows_recommend'][recommendShowIndex]['image'] != null ? DecorationImage(
                                                                              image: NetworkImage(followRecommendList['shows_recommend'][recommendShowIndex]['image']),
                                                                              fit: BoxFit.cover,
                                                                              filterQuality: FilterQuality.high,
                                                                            ) : null,
                                                                          ),
                                                                          child: followRecommendList['shows_recommend'][recommendShowIndex]['image'] == null ? Center(
                                                                            child: SVGBuilder(
                                                                              image: 'assets/icon/album.svg',
                                                                              width: 22.0.w,
                                                                              height: 22.0.w,
                                                                              color: ColorConfig().white(),
                                                                            ),
                                                                          ) : Container(),
                                                                        ),
                                                                      ),
                                                                      Expanded(
                                                                        child: CustomTextBuilder(
                                                                          text: '${followRecommendList['shows_recommend'][recommendShowIndex]['name']}',
                                                                          fontColor: ColorConfig().primary(),
                                                                          fontSize: 14.0.sp,
                                                                          fontWeight: FontWeight.w800,
                                                                          maxLines: 1,
                                                                          textOverflow: TextOverflow.ellipsis,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                Container(
                                                                  margin: const EdgeInsets.only(left: 12.0),
                                                                  child: InkWell(
                                                                    onTap: () {
                                                                      setState(() {
                                                                        selectedData = followRecommendList['shows_recommend'][recommendShowIndex];
                                                                        selectedType = 'S';
                                                                        Navigator.pop(context);
                                                                      });
                                                                    },
                                                                    child: Container(
                                                                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                                                                      decoration: BoxDecoration(
                                                                        color: ColorConfig().white(),
                                                                        border: Border.all(
                                                                          width: 1.0,
                                                                          color: ColorConfig().gray3(),
                                                                        ),
                                                                        borderRadius: BorderRadius.circular(4.0.r),
                                                                      ),
                                                                      child: CustomTextBuilder(
                                                                        text: TextConstant.select,
                                                                        fontColor: ColorConfig().gray5(),
                                                                        fontSize: 12.0.sp,
                                                                        fontWeight: FontWeight.w700,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                        }),
                                                      ),
                                                      const SizedBox(height: 58.0),
                                                    ],
                                                  ),
                                                )
                                              : searchData['shows'].isNotEmpty
                                                  ? SingleChildScrollView(
                                                      child: Column(
                                                        children: List.generate(searchData['shows'].length, (searchShowIndex) {
                                                          return Container(
                                                            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                                                            child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              children: [
                                                                Expanded(
                                                                  child: Row(
                                                                    children: [
                                                                      Container(
                                                                        width: 42.0.w + 6.0,
                                                                        height: 48.0.w,
                                                                        margin: const EdgeInsets.only(right: 8.0),
                                                                        padding: const EdgeInsets.symmetric(horizontal: 3.0),
                                                                        child: Container(
                                                                          width: 42.0.w,
                                                                          height: 48.0.w,
                                                                          decoration: BoxDecoration(
                                                                            color: searchData['shows'][searchShowIndex]['image'] == null ? ColorConfig().gray2() : null,
                                                                            borderRadius: BorderRadius.circular(10.0.r),
                                                                            image: searchData['shows'][searchShowIndex]['image'] != null ? DecorationImage(
                                                                              image: NetworkImage(searchData['shows'][searchShowIndex]['image']),
                                                                              fit: BoxFit.cover,
                                                                              filterQuality: FilterQuality.high,
                                                                            ) : null,
                                                                          ),
                                                                          child: searchData['shows'][searchShowIndex]['image'] == null ? Center(
                                                                            child: SVGBuilder(
                                                                              image: 'assets/icon/album.svg',
                                                                              width: 22.0.w,
                                                                              height: 22.0.w,
                                                                              color: ColorConfig().white(),
                                                                            ),
                                                                          ) : Container(),
                                                                        ),
                                                                      ),
                                                                      Expanded(
                                                                        child: CustomTextBuilder(
                                                                          text: '${searchData['shows'][searchShowIndex]['name']}',
                                                                          fontColor: ColorConfig().primary(),
                                                                          fontSize: 14.0.sp,
                                                                          fontWeight: FontWeight.w800,
                                                                          maxLines: 1,
                                                                          textOverflow: TextOverflow.ellipsis,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                Container(
                                                                  margin: const EdgeInsets.only(left: 12.0),
                                                                  child: InkWell(
                                                                    onTap: () {
                                                                      setState(() {
                                                                        selectedData = searchData['shows'][searchShowIndex];
                                                                        selectedType = 'S';
                                                                        Navigator.pop(context);
                                                                      });
                                                                    },
                                                                    child: Container(
                                                                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                                                                      decoration: BoxDecoration(
                                                                        color: ColorConfig().white(),
                                                                        border: Border.all(
                                                                          width: 1.0,
                                                                          color: ColorConfig().gray3(),
                                                                        ),
                                                                        borderRadius: BorderRadius.circular(4.0.r),
                                                                      ),
                                                                      child: CustomTextBuilder(
                                                                        text: TextConstant.select,
                                                                        fontColor: ColorConfig().gray5(),
                                                                        fontSize: 12.0.sp,
                                                                        fontWeight: FontWeight.w700,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                        }),
                                                      ),
                                                    )
                                                  : Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Center(
                                                          child: Image(
                                                            image: const AssetImage('assets/img/noresult.png'),
                                                            fit: BoxFit.cover,
                                                            filterQuality: FilterQuality.high,
                                                            width: 60.0.w,
                                                            height: 60.0.w,
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                                                          child: CustomTextBuilder(
                                                            text: '"$searchText"\n검색 결과를 찾을 수 없습니다.\n다시 한번 검색해주세요.',
                                                            fontColor: ColorConfig().gray4(),
                                                            fontSize: 14.0.sp,
                                                            fontWeight: FontWeight.w400,
                                                            textAlign: TextAlign.center,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                            // 아티스트 리스트 영역
                                            searchData.isEmpty
                                              ? SingleChildScrollView(
                                                  child: Column(
                                                    children: [
                                                      // 팔로우 아티스트 리스트 영역
                                                      Column(
                                                        children: List.generate(followRecommendList['follow_artist'].length, (followArtistIndex) {
                                                          return Container(
                                                            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                                                            child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              children: [
                                                                Expanded(
                                                                  child: Row(
                                                                    children: [
                                                                      Container(
                                                                        margin: const EdgeInsets.only(right: 8.0),
                                                                        padding: const EdgeInsets.symmetric(horizontal: 3.0),
                                                                        child: Container(
                                                                          width: 48.0.w,
                                                                          height: 48.0.w,
                                                                          decoration: BoxDecoration(
                                                                            borderRadius: BorderRadius.circular(24.0.r),
                                                                            image: followRecommendList['follow_artist'][followArtistIndex]['image'] != null
                                                                              ? DecorationImage(
                                                                                  image: NetworkImage(followRecommendList['follow_artist'][followArtistIndex]['image']),
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
                                                                      ),
                                                                      Expanded(
                                                                        child: CustomTextBuilder(
                                                                          text: '${followRecommendList['follow_artist'][followArtistIndex]['name']}',
                                                                          fontColor: ColorConfig().primary(),
                                                                          fontSize: 14.0.sp,
                                                                          fontWeight: FontWeight.w800,
                                                                          maxLines: 1,
                                                                          textOverflow: TextOverflow.ellipsis,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                Container(
                                                                  margin: const EdgeInsets.only(left: 12.0),
                                                                  child: InkWell(
                                                                    onTap: () {
                                                                      setState(() {
                                                                        selectedData = followRecommendList['follow_artist'][followArtistIndex];
                                                                        selectedType = 'A';
                                                                        Navigator.pop(context);
                                                                      });
                                                                    },
                                                                    child: Container(
                                                                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                                                                      decoration: BoxDecoration(
                                                                        color: ColorConfig().white(),
                                                                        border: Border.all(
                                                                          width: 1.0,
                                                                          color: ColorConfig().gray3(),
                                                                        ),
                                                                        borderRadius: BorderRadius.circular(4.0.r),
                                                                      ),
                                                                      child: CustomTextBuilder(
                                                                        text: TextConstant.select,
                                                                        fontColor: ColorConfig().gray5(),
                                                                        fontSize: 12.0.sp,
                                                                        fontWeight: FontWeight.w700,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                        }),
                                                      ),
                                                      // 추천 커뮤니티 아티스트 타이틀 영역
                                                      Container(
                                                        width: MediaQuery.of(context).size.width,
                                                        margin: const EdgeInsets.only(top: 4.0),
                                                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                                                        child: CustomTextBuilder(
                                                          text: TextConstant.recommendArtist,
                                                          fontColor: ColorConfig().dark(),
                                                          fontSize: 14.0.sp,
                                                          fontWeight: FontWeight.w800,
                                                        ),
                                                      ),
                                                      // 추천 커뮤니티 아티스트 리스트 영역
                                                      Column(
                                                        children: List.generate(followRecommendList['artists_recommend'].length, (recommendArtistIndex) {
                                                          return Container(
                                                            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                                                            child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              children: [
                                                                Expanded(
                                                                  child: Row(
                                                                    children: [
                                                                      Container(
                                                                        margin: const EdgeInsets.only(right: 8.0),
                                                                        padding: const EdgeInsets.symmetric(horizontal: 3.0),
                                                                        child: Container(
                                                                          width: 48.0.w,
                                                                          height: 48.0.w,
                                                                          decoration: BoxDecoration(
                                                                            color: followRecommendList['artists_recommend'][recommendArtistIndex]['image'] == null ? ColorConfig().gray2() : null,
                                                                            borderRadius: BorderRadius.circular(24.0.r),
                                                                            image: followRecommendList['artists_recommend'][recommendArtistIndex]['image'] != null
                                                                            ? DecorationImage(
                                                                                image: NetworkImage(followRecommendList['artists_recommend'][recommendArtistIndex]['image']),
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
                                                                      ),
                                                                      Expanded(
                                                                        child: CustomTextBuilder(
                                                                          text: '${followRecommendList['artists_recommend'][recommendArtistIndex]['name']}',
                                                                          fontColor: ColorConfig().primary(),
                                                                          fontSize: 14.0.sp,
                                                                          fontWeight: FontWeight.w800,
                                                                          maxLines: 1,
                                                                          textOverflow: TextOverflow.ellipsis,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                Container(
                                                                  margin: const EdgeInsets.only(left: 12.0),
                                                                  child: InkWell(
                                                                    onTap: () {
                                                                      setState(() {
                                                                        selectedData = followRecommendList['artists_recommend'][recommendArtistIndex];
                                                                        selectedType = 'A';
                                                                        Navigator.pop(context);
                                                                      });
                                                                    },
                                                                    child: Container(
                                                                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                                                                      decoration: BoxDecoration(
                                                                        color: ColorConfig().white(),
                                                                        border: Border.all(
                                                                          width: 1.0,
                                                                          color: ColorConfig().gray3(),
                                                                        ),
                                                                        borderRadius: BorderRadius.circular(4.0.r),
                                                                      ),
                                                                      child: CustomTextBuilder(
                                                                        text: TextConstant.select,
                                                                        fontColor: ColorConfig().gray5(),
                                                                        fontSize: 12.0.sp,
                                                                        fontWeight: FontWeight.w700,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                        }),
                                                      ),
                                                      const SizedBox(height: 58.0),
                                                    ],
                                                  ),
                                                )
                                              : searchData['artists'].isNotEmpty
                                                  ? SingleChildScrollView(
                                                      child: Column(
                                                          children: List.generate(searchData['artists'].length, (searchArtistIndex) {
                                                            return Container(
                                                              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                children: [
                                                                  Expanded(
                                                                    child: Row(
                                                                      children: [
                                                                        Container(
                                                                          margin: const EdgeInsets.only(right: 8.0),
                                                                          padding: const EdgeInsets.symmetric(horizontal: 3.0),
                                                                          child: Container(
                                                                            width: 48.0.w,
                                                                            height: 48.0.w,
                                                                            decoration: BoxDecoration(
                                                                              borderRadius: BorderRadius.circular(24.0.r),
                                                                              image: searchData['artists'][searchArtistIndex]['image'] != null
                                                                                ? DecorationImage(
                                                                                    image: NetworkImage(searchData['artists'][searchArtistIndex]['image']),
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
                                                                        ),
                                                                        Expanded(
                                                                          child: CustomTextBuilder(
                                                                            text: '${searchData['artists'][searchArtistIndex]['name']}',
                                                                            fontColor: ColorConfig().primary(),
                                                                            fontSize: 14.0.sp,
                                                                            fontWeight: FontWeight.w800,
                                                                            maxLines: 1,
                                                                            textOverflow: TextOverflow.ellipsis,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    margin: const EdgeInsets.only(left: 12.0),
                                                                    child: InkWell(
                                                                      onTap: () {
                                                                        setState(() {
                                                                          selectedData = searchData['artists'][searchArtistIndex];
                                                                          selectedType = 'A';
                                                                          Navigator.pop(context);
                                                                        });
                                                                      },
                                                                      child: Container(
                                                                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                                                                        decoration: BoxDecoration(
                                                                          color: ColorConfig().white(),
                                                                          border: Border.all(
                                                                            width: 1.0,
                                                                            color: ColorConfig().gray3(),
                                                                          ),
                                                                          borderRadius: BorderRadius.circular(4.0.r),
                                                                        ),
                                                                        child: CustomTextBuilder(
                                                                          text: TextConstant.select,
                                                                          fontColor: ColorConfig().gray5(),
                                                                          fontSize: 12.0.sp,
                                                                          fontWeight: FontWeight.w700,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            );
                                                          }),
                                                        ),
                                                    )
                                                  : Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Center(
                                                          child: Image(
                                                            image: const AssetImage('assets/img/noresult.png'),
                                                            fit: BoxFit.cover,
                                                            filterQuality: FilterQuality.high,
                                                            width: 60.0.w,
                                                            height: 60.0.w,
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                                                          child: CustomTextBuilder(
                                                            text: '"$searchText"\n검색 결과를 찾을 수 없습니다.\n다시 한번 검색해주세요.',
                                                            fontColor: ColorConfig().gray4(),
                                                            fontSize: 14.0.sp,
                                                            fontWeight: FontWeight.w400,
                                                            textAlign: TextAlign.center,
                                                          ),
                                                        ),
                                                      ],
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
                },
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20.0, 12.0, 12.0, 12.0),
                  decoration: BoxDecoration(
                    color: selectedData.isEmpty ? ColorConfig().gray1() : ColorConfig().primaryLight3(),
                    border: Border.all(
                      width: 1.0,
                      color: selectedData.isEmpty ? ColorConfig().gray4() : ColorConfig().primary(),
                    ),
                    borderRadius: BorderRadius.circular(4.0.r),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: CustomTextBuilder(
                          text: selectedData.isEmpty ? TextConstant.wantSelectCommunity : selectedData['name'],
                          fontColor: selectedData.isEmpty ? ColorConfig().gray4() : ColorConfig().dark(),
                          fontSize: 14.0.sp,
                          fontWeight: selectedData.isEmpty ? FontWeight.w400 : FontWeight.w700,
                        ),
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
            ),
          ),
        ),
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: ColorConfig().gray1(),
          child: Stack(
            children: [
              // 글 쓰는 영역
              Container(
                margin: EdgeInsets.only(bottom: 32.0.w + 16.0 + MediaQuery.of(context).padding.bottom + (imageFiles.isNotEmpty ? 16.0 + 50.0.w : 0.0)),
                child: Column(
                  children: [
                    // 제목 입력창 영역
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                      child: TextFormField(
                        controller: titleController,
                        focusNode: titleFocusNode,
                        decoration: InputDecoration(
                          hintText: TextConstant.title,
                          hintStyle: TextStyle(
                            color: ColorConfig().gray3(),
                            fontSize: 16.0.sp,
                            fontWeight: FontWeight.w800,
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              width: 1.0,
                              color: ColorConfig().dark(),
                            ),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              width: 1.0,
                              color: ColorConfig().gray3(),
                            ),
                          ),
                        ),
                        style: TextStyle(
                          color: ColorConfig().dark(),
                          fontSize: 16.0.sp,
                          fontWeight: FontWeight.w800,
                        ),
                        cursorColor: ColorConfig().dark(),
                        keyboardType: TextInputType.text,
                      ),
                    ),
                    // 내용 입력창 영역
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                        child: TextFormField(
                          controller: bodyController,
                          focusNode: bodyFocusNode,
                          maxLines: null,
                          decoration: InputDecoration(
                            hintText: TextConstant.inputBody,
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
                    ),
                  ],
                ),
              ),
              // tool 영역
              Positioned(
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
                          if (imageFiles[imageIndex] == 'N') {
                            return Container();
                          }

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
                                        imageFiles[imageIndex] = 'N';
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
                                    // width: 32.0.w,
                                    // height: 32.0.w,
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
                                    // width: 32.0.w,
                                    // height: 32.0.w,
                                    color: ColorConfig().gray5(),
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              onPressed: () {
                                if (titleFocusNode.hasFocus) {
                                  titleFocusNode.unfocus();
                                } else {
                                  titleFocusNode.requestFocus();
                                }

                                if (bodyFocusNode.hasFocus) {
                                  bodyFocusNode.unfocus();
                                } else {
                                  if (titleFocusNode.hasFocus == false && titleController.text.isNotEmpty) {
                                    bodyFocusNode.requestFocus();
                                  }
                                }
                              },
                              icon: SVGStringBuilder(
                                image: 'assets/icon/keyboard.svg',
                                // width: 32.0.w,
                                // height: 32.0.w,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}