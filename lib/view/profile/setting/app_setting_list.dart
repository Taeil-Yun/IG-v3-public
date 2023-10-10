import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ig-public_v3/api/main/main_myprofile.dart';
import 'package:ig-public_v3/component/appbar/appbar.dart';
import 'package:ig-public_v3/component/appbar/appbar_leading.dart';
import 'package:ig-public_v3/component/appbar/appbar_title.dart';
import 'package:ig-public_v3/component/channel_talk/channel_talk.dart';
import 'package:ig-public_v3/component/svg/svg_builder.dart';
import 'package:ig-public_v3/costant/build_config.dart';
import 'package:ig-public_v3/costant/colors.dart';
import 'package:ig-public_v3/costant/text.dart';
import 'package:ig-public_v3/util/url_launcher.dart';
import 'package:ig-public_v3/widget/custom_text_widget.dart';
import 'package:yaml/yaml.dart';

class AppSettingListScreen extends StatefulWidget {
  const AppSettingListScreen({super.key});

  @override
  State<AppSettingListScreen> createState() => _AppSettingListScreenState();
}

class _AppSettingListScreenState extends State<AppSettingListScreen> {
  String appVersion = '';

  @override
  void initState() {
    super.initState();

    getAppVersion().then((value) {
      setState(() {
        appVersion = value;
      });
    });
  }

  Future<String> getAppVersion() async {
    dynamic yaml = await rootBundle.loadString('pubspec.yaml');
    dynamic localYaml = loadYaml(yaml);

    if (Platform.isAndroid) {
      return localYaml['version'].toString().split('+')[0];
    } else {
      return localYaml['ios_version'].toString().split('+')[0];
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
          title: TextConstant.setting,
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: ColorConfig().white(),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                settingList(
                  title: TextConstant.appVersion,
                  useArrow: false,
                  subject: 'v$appVersion 최신버전',
                  press: () {},
                ),
                settingList(
                  title: TextConstant.notificationSetting,
                  press: () {
                    Navigator.pushNamed(context, 'notificationSetting');
                  },
                ),
                settingList(
                  title: TextConstant.termOfUse,
                  press: () {
                    UrlLauncherBuilder().launchURL(
                        'https://c.ig-public.link/document/terms-of-service.html');
                  },
                ),
                settingList(
                  title: TextConstant.serviceCenter,
                  subject: TextConstant.oneToOneChatConsultation,
                  press: () async {
                    MainMyProfileAPI()
                        .myProfile(
                            accessToken: await SecureStorageConfig()
                                .storage
                                .read(key: 'access_token'))
                        .then((value) {
                      getChannelTalk(
                        nickname: value.result['data']['nick'],
                        name: value.result['data']['name'],
                        email: value.result['data']['email'],
                        phoneNumber: value.result['data']['phone'],
                      );
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget settingList(
      {required String title,
      bool useArrow = true,
      String? subject,
      required Function() press}) {
    return InkWell(
      onTap: press,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 22.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomTextBuilder(
              text: title,
              fontColor: ColorConfig().dark(),
              fontSize: 14.0.sp,
              fontWeight: FontWeight.w700,
            ),
            // [useArrow]만 사용할 때
            useArrow && subject == null
                ? SVGBuilder(
                    image: 'assets/icon/arrow_right_light.svg',
                    width: 16.0.w,
                    height: 16.0.w,
                    color: ColorConfig().gray3(),
                  )
                // [useArrow]를 사용하지않고 [subject]만 사용할 때
                : !useArrow && subject != null
                    ? CustomTextBuilder(
                        text: subject,
                        fontColor: ColorConfig().gray3(),
                        fontSize: 12.0.sp,
                        fontWeight: FontWeight.w700,
                      )
                    // [useArrow]를 사용하며 [subject]를 같이 사용할 때
                    : useArrow && subject != null
                        ? Row(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(right: 4.0),
                                child: CustomTextBuilder(
                                  text: subject,
                                  fontColor: ColorConfig().gray3(),
                                  fontSize: 12.0.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SVGBuilder(
                                image: 'assets/icon/arrow_right_light.svg',
                                width: 16.0.w,
                                height: 16.0.w,
                                color: ColorConfig().gray3(),
                              ),
                            ],
                          )
                        : Container(),
          ],
        ),
      ),
    );
  }
}
