import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:ig-public_v3/costant/build_config.dart';
import 'package:ig-public_v3/costant/colors.dart';
import 'package:ig-public_v3/costant/text.dart';
import 'package:ig-public_v3/api/bbs/faq.dart';
import 'package:ig-public_v3/component/appbar/appbar.dart';
import 'package:ig-public_v3/component/appbar/appbar_leading.dart';
import 'package:ig-public_v3/component/appbar/appbar_title.dart';
import 'package:ig-public_v3/component/svg/svg_builder.dart';
import 'package:ig-public_v3/widget/custom_text_widget.dart';

class FAQListScreen extends StatefulWidget {
  const FAQListScreen({super.key});

  @override
  State<FAQListScreen> createState() => _FAQListScreenState();
}

class _FAQListScreenState extends State<FAQListScreen> with TickerProviderStateMixin {
  final List<AnimationController> expandTileControllers = [];
  List faqList = [];

  @override
  void initState() {
    super.initState();

    initializeAPI();
  }

  Future<void> initializeAPI() async {
    FAQListAPI().faq(accessToken: await SecureStorageConfig().storage.read(key: 'access_token')).then((value) {
      setState(() {
        faqList = value.result['data'];

        for (int i=0; i<value.result['data'].length; i++) {
          expandTileControllers.add(
            AnimationController(
              duration: const Duration(milliseconds: 200),
              vsync: this,
            ),
          );
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();

    for(int i=0; i<faqList.length; i++) {
      expandTileControllers[i].dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ig-publicAppBar(
        leading: ig-publicAppBarLeading(
          press: () => Navigator.pop(context),
        ),
        title: const ig-publicAppBarTitle(
          title: TextConstant.faq,
        ),
      ),
      body: faqList.isNotEmpty ? Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: ColorConfig().gray1(),
        child: ListView.builder(
          itemCount: faqList.length,
          itemBuilder: (context, index) {
            if (index == faqList.length - 1) {
              return Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: ColorConfig().white(),
                      border: Border(
                        bottom: BorderSide(
                          width: 1.0,
                          color: ColorConfig().gray1(),
                        ),
                      ),
                    ),
                    child: ExpansionTile(
                      backgroundColor: ColorConfig().white(),
                      collapsedBackgroundColor: ColorConfig().white(),
                      tilePadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                      trailing: RotationTransition(
                        turns: Tween(begin: 0.0, end: 0.5).animate(expandTileControllers[index]),  //_animation,
                        child: SVGBuilder(
                          image: 'assets/icon/arrow_down_bold.svg',
                          width: 16.0.w,
                          height: 16.0.w,
                          color: ColorConfig().gray5(),
                        ),
                      ),
                      onExpansionChanged: (isOpen) {
                        // 선택되었을때 icon animation
                        if (isOpen) {
                          expandTileControllers[index].forward();
                        } else {
                          expandTileControllers[index].reverse();
                        }
                      },
                      title: CustomTextBuilder(
                        text: '${faqList[index]['question']}',
                        fontColor: ColorConfig().dark(),
                        fontSize: 14.0.sp,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width,
                          color: ColorConfig().gray1(),
                          padding: const EdgeInsets.all(20.0),
                          child: Html(
                            data: faqList[index]['answer'],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // empty space
                  const SizedBox(height: 16.0),
                  // 1:1채팅 문의 영역
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 13.0),
                    child: Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 10.0),
                          child: Row(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(right: 6.0),
                                child: SVGBuilder(
                                  image: 'assets/icon/info.svg',
                                  width: 16.0.w,
                                  height: 16.0.w,
                                ),
                              ),
                              CustomTextBuilder(
                                text: TextConstant.notFoundWantInformation,
                                fontColor: ColorConfig().dark(),
                                fontSize: 12.0.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () {},
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 13.0),
                            decoration: BoxDecoration(
                              color: ColorConfig().white(),
                              border: Border.all(
                                width: 1.0,
                                color: ColorConfig().gray2(),
                              ),
                              borderRadius: BorderRadius.circular(4.0.r),
                            ),
                            child: Center(
                              child: CustomTextBuilder(
                                text: TextConstant.oneToOneChatInquiry,
                                fontColor: ColorConfig().gray5(),
                                fontSize: 13.0.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // empty space
                  const SizedBox(height: 40.0),
                ],
              );
            }

            return Container(
              decoration: BoxDecoration(
                color: ColorConfig().white(),
                border: Border(
                  bottom: BorderSide(
                    width: 1.0,
                    color: ColorConfig().gray1(),
                  ),
                ),
              ),
              child: ExpansionTile(
                backgroundColor: ColorConfig().white(),
                collapsedBackgroundColor: ColorConfig().white(),
                tilePadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                trailing: RotationTransition(
                  turns: Tween(begin: 0.0, end: 0.5).animate(expandTileControllers[index]),  //_animation,
                  child: SVGBuilder(
                    image: 'assets/icon/arrow_down_bold.svg',
                    width: 16.0.w,
                    height: 16.0.w,
                    color: ColorConfig().gray5(),
                  ),
                ),
                onExpansionChanged: (isOpen) {
                  // 선택되었을때 icon animation
                  if (isOpen) {
                    expandTileControllers[index].forward();
                  } else {
                    expandTileControllers[index].reverse();
                  }
                },
                title: CustomTextBuilder(
                  text: '${faqList[index]['question']}',
                  fontColor: ColorConfig().dark(),
                  fontSize: 14.0.sp,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    color: ColorConfig().gray1(),
                    padding: const EdgeInsets.all(20.0),
                    child: Html(
                      data: faqList[index]['answer'],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ) : Container(),
    );
  }
}