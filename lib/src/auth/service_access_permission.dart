import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ig-public_v3/api/auth/signup.dart';
import 'package:ig-public_v3/component/appbar/appbar.dart';
import 'package:ig-public_v3/component/appbar/appbar_leading.dart';
import 'package:ig-public_v3/component/appbar/appbar_title.dart';
import 'package:ig-public_v3/component/iamport/certification.dart';
import 'package:ig-public_v3/component/svg/svg_builder.dart';
import 'package:ig-public_v3/costant/build_config.dart';
import 'package:ig-public_v3/costant/colors.dart';
import 'package:ig-public_v3/costant/text.dart';
import 'package:ig-public_v3/util/toast.dart';
import 'package:ig-public_v3/widget/custom_text_widget.dart';
import 'package:permission_handler/permission_handler.dart';

class ServiceAccessPermissionScreen extends StatefulWidget {
  ServiceAccessPermissionScreen({
    super.key,
    required this.email,
    required this.password,
    required this.isMarketing,
  });

  String email;
  String password;
  int isMarketing;

  @override
  State<ServiceAccessPermissionScreen> createState() => _ServiceAccessPermissionScreenState();
}

class _ServiceAccessPermissionScreenState extends State<ServiceAccessPermissionScreen> {
  String fcmToken = '';

  List iconImages = [
    'assets/icon/folder-sign.svg',
    'assets/icon/profile-sign.svg',
    'assets/icon/message-sign.svg',
    'assets/icon/camera-sign.svg',
    'assets/icon/mic-sign.svg',
  ];

  @override
  void initState () {
    super.initState();

    getFCMToken();  
  }

  Future<void> getFCMToken() async {
    String? token = await SecureStorageConfig().storage.read(key: 'fcm_token');

    setState(() {
      fcmToken = token!;
    });
  }

  Future<bool> requiredPermission() async {
    // ignore: unused_local_variable
    Map<Permission, PermissionStatus> status = await [Permission.storage, Permission.contacts].request(); // [] 권한배열에 권한을 작성

    if (await Permission.storage.isGranted && await Permission.contacts.isGranted) {
      optionalPermission().then((_) {
        SignUpAPI().signup(
          email: widget.email,
          password: widget.password,
          fcmToken: fcmToken,
          isMarketing: widget.isMarketing,
        ).then((value) async {
          if (value.result['access_token'] != null && value.result['refresh_token'] != null) {
            Future.wait([
              SecureStorageConfig().storage.write(key: 'is_auth', value: '0'),
              SecureStorageConfig().storage.write(key: 'access_token', value: value.result['access_token']),
              SecureStorageConfig().storage.write(key: 'refresh_token', value: value.result['refresh_token']),
              SecureStorageConfig().storage.write(key: 'token_status', value: 'false'),
              SecureStorageConfig().storage.write(key: 'login_type', value: 'ig-public'),
            ]).then((_) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const PhoneCertification()));
            });
          } else {
            ToastModel().iconToast(value.result['message'], iconType: 2);
          }
        });
      });
      return Future.value(true);
    } else {
      openAppSettings();
      return Future.value(false);
    }
  }

  Future<bool> optionalPermission() async {
    // ignore: unused_local_variable
    Map<Permission, PermissionStatus> status = await [Permission.sms, Permission.camera, Permission.microphone, Permission.mediaLibrary].request(); // [] 권한배열에 권한을 작성
    
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ig-publicAppBar(
        leading: ig-publicAppBarLeading(
          press: () => Navigator.pop(context),
        ),
        title: const ig-publicAppBarTitle(
          title: TextConstant.terms,
        ),
      ),
      body: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: ColorConfig().white(),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 24.0),
                      // 안내 텍스트
                      Container(
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.only(bottom: 16.0),
                        padding: const EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 6.0),
                        child: CustomTextBuilder(
                          text: TextConstant.signTermsDescription,
                          fontColor: ColorConfig().dark(),
                          fontSize: 14.0.sp,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
                      // 권한 영역
                      Column(
                        children: List.generate(TextConstant.signupAccessPermissionDescList.length, (permissionIndex) {
                          return Container(
                            width: MediaQuery.of(context).size.width,
                            margin: permissionIndex != 0 ? const EdgeInsets.only(top: 12.0) : null,
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Row(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(right: 16.0),
                                  padding: const EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    color: ColorConfig().primaryLight3(),
                                    borderRadius: BorderRadius.circular(4.0.r),
                                  ),
                                  child: SVGBuilder(
                                    image: iconImages[permissionIndex],
                                    width: 24.0.w,
                                    height: 24.0.w,
                                    color: ColorConfig().primaryLight(),
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.only(bottom: 4.0),
                                        child: Row(
                                          children: [
                                            CustomTextBuilder(
                                              text: TextConstant.signupAccessPermissionTitleList[permissionIndex],
                                              fontColor: ColorConfig().dark(),
                                              fontSize: 14.0.sp,
                                              fontWeight: FontWeight.w700,
                                            ),
                                            CustomTextBuilder(
                                              text: ' ${permissionIndex == 0 || permissionIndex == 1 ? '(필수)' : '(선택)'}',
                                              fontColor: permissionIndex == 0 || permissionIndex == 1 ? ColorConfig().primary() : ColorConfig().gray3(),
                                              fontSize: 14.0.sp,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ],
                                        ),
                                      ),
                                      CustomTextBuilder(
                                        text: TextConstant.signupAccessPermissionDescList[permissionIndex],
                                        fontColor: ColorConfig().gray5(),
                                        fontSize: 12.0.sp,
                                        fontWeight: FontWeight.w400,
                                        height: 1.2,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                      // 하단 설명문구 영역
                      Container(
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.only(top: 16.0),
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
                          decoration: BoxDecoration(
                            color: ColorConfig().gray1(),
                            borderRadius: BorderRadius.circular(4.0.r),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(right: 6.0),
                                child: SVGBuilder(
                                  image: 'assets/icon/info.svg',
                                  width: 16.0.w,
                                  height: 16.0.w,
                                  color: ColorConfig().gray5(),
                                ),
                              ),
                              Expanded(
                                child: CustomTextBuilder(
                                  text: TextConstant.signupAccessPermissionInfoText,
                                  fontColor: ColorConfig().gray5(),
                                  fontSize: 12.0.sp,
                                  fontWeight: FontWeight.w700,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 48.0),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                child: InkWell(
                  onTap: () {
                    requiredPermission();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 18.0),
                    decoration: BoxDecoration(
                      color: ColorConfig().primary(),
                      borderRadius: BorderRadius.circular(4.0.r),
                    ),
                    child: Center(
                      child: CustomTextBuilder(
                        text: TextConstant.next,
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
      ),
    );
  }
}