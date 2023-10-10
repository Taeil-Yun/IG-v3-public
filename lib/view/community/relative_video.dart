import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ig-public_v3/component/appbar/appbar.dart';
import 'package:ig-public_v3/component/appbar/appbar_leading.dart';
import 'package:ig-public_v3/component/appbar/appbar_title.dart';
import 'package:ig-public_v3/component/svg/svg_builder.dart';
import 'package:ig-public_v3/costant/colors.dart';
import 'package:ig-public_v3/costant/text.dart';
import 'package:ig-public_v3/util/url_launcher.dart';
import 'package:ig-public_v3/widget/custom_text_widget.dart';
import 'package:intl/intl.dart';

class RelativeVideoScreen extends StatelessWidget {
  RelativeVideoScreen({
    super.key,
    required this.videos,
  });
  
  List videos = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ig-publicAppBar(
        leading: ig-publicAppBarLeading(
          press: () => Navigator.pop(context),
        ),
        title: const ig-publicAppBarTitle(
          title: TextConstant.relationshipVideo,
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: ColorConfig().white(),
        child: SafeArea(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 40.0),
            shrinkWrap: true,
            itemCount: videos.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  UrlLauncherBuilder().launchURL(videos[index]['url']);
                },
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 이미지 영역
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 180.0.w,
                        decoration: BoxDecoration(
                          color: videos[index]['thumbnail'] == null ? ColorConfig().gray2() : null,
                          borderRadius: BorderRadius.circular(4.0.r),
                          image: videos[index]['thumbnail'] != null ? DecorationImage(
                            image: NetworkImage(videos[index]['thumbnail']),
                            fit: BoxFit.cover,
                            filterQuality: FilterQuality.high,
                          ) : null,
                        ),
                        child: videos[index]['thumbnail'] == null ? Center(
                          child: SVGBuilder(
                            image: 'assets/icon/album.svg',
                            width: 24.0.w,
                            height: 24.0.w,
                            color: ColorConfig().white(),
                          ),
                        ) : Container(),
                      ),
                      // 제목 영역
                      Container(
                        margin: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                        child: CustomTextBuilder(
                          text: '${videos[index]['title']}',
                          fontColor: ColorConfig().dark(),
                          fontSize: 14.0.sp,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
                      // // 작성자, 등록일 영역
                      // Row(
                      //   children: [
                      //     // 작성자 영역
                      //     CustomTextBuilder(
                      //       text: '${videos[index]['nick']}',
                      //       fontColor: ColorConfig().gray4(),
                      //       fontSize: 12.0.sp,
                      //       fontWeight: FontWeight.w400,
                      //     ),
                      //     // 구분자
                      //     Container(
                      //       margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      //       child: CustomTextBuilder(
                      //         text: '|',
                      //         fontColor: ColorConfig().gray2(),
                      //         fontSize: 12.0.sp,
                      //         fontWeight: FontWeight.w400,
                      //       ),
                      //     ),
                      //     // 날짜 영역
                      //     CustomTextBuilder(
                      //       text: videos[index]['create_dt'] == videos[index]['modify_dt'] ? DateFormat('yyyy.MM').format(DateTime.parse(videos[index]['create_dt']).toLocal()) : DateFormat('yyyy.MM').format(DateTime.parse(videos[index]['modify_dt']).toLocal()),
                      //       fontColor: ColorConfig().gray4(),
                      //       fontSize: 12.0.sp,
                      //       fontWeight: FontWeight.w400,
                      //     ),
                      //   ],
                      // ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}