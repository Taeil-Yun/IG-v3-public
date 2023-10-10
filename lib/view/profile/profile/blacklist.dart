import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ig-public_v3/api/profile/blacklist.dart';
import 'package:ig-public_v3/api/profile/delete_blacklist.dart';
import 'package:ig-public_v3/component/appbar/appbar.dart';
import 'package:ig-public_v3/component/appbar/appbar_leading.dart';
import 'package:ig-public_v3/component/appbar/appbar_title.dart';
import 'package:ig-public_v3/costant/build_config.dart';
import 'package:ig-public_v3/costant/colors.dart';
import 'package:ig-public_v3/costant/text.dart';
import 'package:ig-public_v3/util/toast.dart';
import 'package:ig-public_v3/widget/custom_text_widget.dart';

class BlackListScreen extends StatefulWidget {
  const BlackListScreen({super.key});

  @override
  State<BlackListScreen> createState() => _BlackListScreenState();
}

class _BlackListScreenState extends State<BlackListScreen> {
  List blacklistData = [];

  @override
  void initState() {
    super.initState();

    initializeAPI();
  }

  Future<void> initializeAPI() async {
    BlackListDataAPI().blacklist(accessToken: await SecureStorageConfig().storage.read(key: 'access_token')).then((value) {
      setState(() {
        blacklistData = value.result['data'];
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
          title: TextConstant.blacklist,
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: ColorConfig().gray1(),
        child: SafeArea(
          child: blacklistData.isNotEmpty ? ListView.builder(
            itemCount: blacklistData.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  Navigator.pushNamed(context, 'otherUserProfile', arguments: {
                    'user_index': blacklistData[index]['user_index'],
                  }).then((rt) async {
                    BlackListDataAPI().blacklist(accessToken: await SecureStorageConfig().storage.read(key: 'access_token')).then((value) {
                      setState(() {
                        blacklistData = value.result['data'];
                      });
                    });
                  });
                },
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8.0),
                  color: ColorConfig().white(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(right: 12.0),
                          child: Row(
                            children: [
                              Container(
                                width: 46.0.w,
                                height: 46.0.w,
                                margin: const EdgeInsets.only(right: 12.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100.0.r),
                                  image: blacklistData[index]['image'] != null
                                    ? DecorationImage(
                                        image: NetworkImage(blacklistData[index]['image']),
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
                              Expanded(
                                child: CustomTextBuilder(
                                  text: '${blacklistData[index]['nick']}',
                                  fontColor: ColorConfig().gray5(),
                                  fontSize: 12.0.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () async {
                          DeleteBlackListAPI().blacklistDelete(accessToken: await SecureStorageConfig().storage.read(key: 'access_token'), userIndex: blacklistData[index]['user_index']).then((value) {
                            if (value.result['status'] == 1) {
                              ToastModel().iconToast(value.result['message']);
              
                              setState(() {
                                blacklistData.removeAt(index);
                              });
                            }
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
                            text: TextConstant.unblock,
                            fontColor: ColorConfig().gray5(),
                            fontSize: 12.0.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ) : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60.0.w,
                height: 60.0.w,
                margin: const EdgeInsets.only(bottom: 24.0),
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/img/no-data-person.png'),
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),
              CustomTextBuilder(
                text: '차단한 회원이 없습니다.',
                fontColor: ColorConfig().gray4(),
                fontSize: 14.0.sp,
                fontWeight: FontWeight.w400,
                height: 1.2,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}