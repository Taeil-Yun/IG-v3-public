import 'dart:async';
import 'dart:io';

import 'package:app_links/app_links.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_flavorizr/parser/models/flavors/google/firebase/firebase.dart' as flavorfirebase;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ig-public_v3/api/gift/get_gift_check.dart';
import 'package:ig-public_v3/api/gift/receive_gift.dart';
import 'package:ig-public_v3/api/gift/reject_gift.dart';
import 'package:ig-public_v3/api/main/main_myprofile.dart';
import 'package:ig-public_v3/component/appbar/appbar.dart';
import 'package:ig-public_v3/component/appbar/appbar_title.dart';
import 'package:ig-public_v3/component/popup/popup.dart';
import 'package:ig-public_v3/costant/text.dart';
import 'package:ig-public_v3/src/splash/splash.dart';
import 'package:ig-public_v3/util/toast.dart';
import 'package:ig-public_v3/util/url_launcher.dart';
import 'package:ig-public_v3/view/main/community_main.dart';
import 'package:ig-public_v3/widget/custom_text_widget.dart';
import 'package:oktoast/oktoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

import 'package:ig-public_v3/src/auth/login.dart';
import 'package:ig-public_v3/costant/build_config.dart';
import 'package:ig-public_v3/costant/route.dart';
import 'package:ig-public_v3/costant/colors.dart';
import 'package:ig-public_v3/component/bottom_navigator/bottom_navigation.dart';
import 'package:ig-public_v3/component/svg/svg_builder.dart';
import 'package:ig-public_v3/view/main/profile_main.dart';
import 'package:ig-public_v3/view/main/ticket_main.dart';
import 'package:ig-public_v3/widget/end_drawer_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

/*
 이 함수가 라이브러리 외부에서 호출될 가능성이 없는 경우, 
 @pragma('vm:entry-point')로 지정하여 AOT 컴파일러가 해당 함수를 컴파일하지 않도록 하여
 컴파일 시간과 크기를 줄일 수 있음
*/
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  AndroidNotification? android = message.notification?.android;

  // download when get image push
  Future<String> downloadAndSaveFile(String? url, String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName';
    final http.Response response = await http.get(Uri.parse(url!));
    final File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);

    return filePath;
  }

  final String? largeIconPath;
  if (Platform.isAndroid && message.notification!.android!.imageUrl != null) {
    largeIconPath = await downloadAndSaveFile(android!.imageUrl, 'largeIcon_${DateTime.now().millisecondsSinceEpoch.toString()}');
  } else {
    largeIconPath = '';
  }
  final String? bigPicturePath;
  if (Platform.isAndroid && message.notification!.android!.imageUrl != null) {
    bigPicturePath = await downloadAndSaveFile(android!.imageUrl, 'bigPicture_${DateTime.now().millisecondsSinceEpoch.toString()}');
  } else {
    bigPicturePath = '';
  }

  // ignore: unnecessary_null_comparison
  if (message.data != null) {
    // flutterLocalNotificationsPlugin.show(
    //   message.hashCode,
    //   '${message.data['title']}',
    //   '${message.data['body']}',
    //   NotificationDetails(
    //     android: AndroidNotificationDetails(
    //       channel.id,
    //       channel.name,
    //       channelDescription: channel.description,
    //       icon: 'mipmap/ic_launcher_icon',
    //     ),
    //     iOS: const DarwinNotificationDetails(
    //       presentAlert: true,
    //       presentBadge: true,
    //       presentSound: true,
    //     ),
    //   ),
    // );
  }
}

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  description: 'This channel is used for important notifications.',
  importance: Importance.high,
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
    
  // get fcm token
  FirebaseMessaging.instance.getToken().then((token) async {
    if (await SecureStorageConfig().storage.read(key: 'fcm_token') != null || await SecureStorageConfig().storage.read(key: 'fcm_token') != '') {
      SecureStorageConfig().storage.delete(key: 'fcm_token').then((_) {
        SecureStorageConfig().storage.write(key: 'fcm_token', value: token);
      });
    } else {
      SecureStorageConfig().storage.write(key: 'fcm_token', value: token);
    }
  });

  /// App flavor 값 조회
  /// flavor = (dev | product)
  String? flavor = await const MethodChannel('flavor').invokeMethod<String>('getFlavor');

  ig-publicBuildConfig(flavor);

  // 백그라운드 메시징 처리를 초기에 설정
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
    alert: true,
    badge: true,
    sound: true,
  );

  runApp(const OKToast(child: ig-publicMain()));
}

class ig-publicMain extends StatefulWidget {
  const ig-publicMain({super.key});

  @override
  State<ig-publicMain> createState() => _ig-publicMainState();
}

class _ig-publicMainState extends State<ig-publicMain> {
  bool hasAccessToken = true;

  @override
  void initState() {
    super.initState();

    checkAccessToken();

    setNotificationSetting();
  }

  Future<void> setNotificationSetting() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.getBool('allNotification') == null) {
      prefs.setBool('allNotification', true);
    }

    if (prefs.getBool('ticketingViewNotification') == null) {
      prefs.setBool('ticketingViewNotification', true);
    }

    if (prefs.getBool('auctionNotification') == null) {
      prefs.setBool('auctionNotification', true);
    }

    if (prefs.getBool('ticketingNewsNotification') == null) {
      prefs.setBool('ticketingNewsNotification', true);
    }

    if (prefs.getBool('newPostOrReviewNotification') == null) {
      prefs.setBool('newPostOrReviewNotification', true);
    }

    if (prefs.getBool('newFollowerNotification') == null) {
      prefs.setBool('newFollowerNotification', true);
    }

    if (prefs.getBool('newReplyNotification') == null) {
      prefs.setBool('newReplyNotification', true);
    }

    if (prefs.getBool('newLikeNotification') == null) {
      prefs.setBool('newLikeNotification', true);
    }
  }

  Future<void> checkAccessToken() async {
    if (await SecureStorageConfig().storage.read(key: 'access_token') == null) {
      // navigatorKey.currentState?.pushNamedAndRemoveUntil('login', (route) => false);
      setState(() {
        hasAccessToken = false;
      });
    } else {
      setState(() {
        hasAccessToken = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return ScreenUtilInit(
      minTextAdapt: true,
      designSize: const Size(360, 640),
      splitScreenMode: true,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          title: 'ig-public',
          theme: ThemeData(
            appBarTheme: const AppBarTheme(
              systemOverlayStyle: SystemUiOverlayStyle.dark,
            ),
            scaffoldBackgroundColor: ColorConfig.defaultWhite,
            fontFamily: 'NanumSquareNeo',
          ),
          darkTheme: ThemeData(
            appBarTheme: const AppBarTheme(
              systemOverlayStyle: SystemUiOverlayStyle.dark,
            ),
            scaffoldBackgroundColor: ColorConfig.defaultWhite,
            fontFamily: 'NanumSquareNeo',
          ),
          home: const SplashScreen(),
          routes: routes,
          navigatorKey: navigatorKey,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', 'US'),
            Locale('ko', 'KR'),
          ],
          locale: const Locale('ko', 'KR'),
        );
      },
      // child: SplachScreen,
    );
  }
}

// ignore: must_be_immutable
class MainBuilder extends StatefulWidget {
  MainBuilder({
    super.key,
    this.crnIndex,
  });

  int? crnIndex;

  @override
  State<MainBuilder> createState() => _MainBuilderState();
}

class _MainBuilderState extends State<MainBuilder> {
  late final List<dynamic> children;
  late AppLinks appLinks;
  FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;
  StreamSubscription<Uri>? linkSubscription;

  Map<String, dynamic> myProfileData = {};

  int currentIndex = 0;
  // int pointTooltipCount = 0;

  // bool pointTooltipState = false;

  @override
  void initState() {
    super.initState();

    firebaseCloudMessagingListener();

    children = [
      const MainTicketingScreen(),
      const MainCommunityScreen(),
      // const MainEarnPointScreen(),
      // Container(),
      MainMyProfileScreen(),
    ];

    if (widget.crnIndex != null) {
      currentIndex = widget.crnIndex!;
    }

    initializeAPI();

    if (Platform.isIOS) {
      initDeepLinks();
    } else {
      initDynamicLinks();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _redirectScreen(PendingDynamicLinkData dynamicLinkData) async {
    if (dynamicLinkData.link.queryParameters.containsKey('id')) {
      String link = dynamicLinkData.link.path.split('/').last;
      String id = dynamicLinkData.link.query;

      switch (link) {
        case 'review':
          break;
        case 'share':
          if (id.split('type=').last == 'community') {
            Navigator.pushNamed(context, 'postDetail', arguments: {
              'community_index': int.parse(id.split('id=').last.split('&').first),
            });
          } else if (id.split('type=').last == 'artist') {
            Navigator.pushNamed(context, 'artistCommunity', arguments: {
              'artist_index': int.parse(id.split('id=').last.split('&').first),
            });
          } else if (id.split('type=').last == 'show') {
            Navigator.pushNamed(context, 'showCommunity', arguments: {
              'show_index': int.parse(id.split('id=').last.split('&').first),
            });
          } else if (id.split('type=').last == 'user') {
            Navigator.pushNamed(context, 'otherUserProfile', arguments: {
              'user_index': int.parse(id.split('id=').last.split('&').first),
            });
          }
          break;
        case 'gift':
          // String userId = dynamicLinkData.link.queryParameters['userId'] ?? '';
          GetGiftCheckAPI().giftCheck(accessToken: await SecureStorageConfig().storage.read(key: 'access_token'), giftCode: Uri.decodeFull(id).substring(3)).then((giftCheck) {
            if (giftCheck.result['status'] == 1 && giftCheck.result['data']['is_receive'] == 0) {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                enableDrag: false,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height / 1.2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(4.0.r),
                    topRight: Radius.circular(4.0.r),
                  ),
                ),
                builder: (context) {
                  return Column(
                    children: [
                      ig-publicAppBar(
                        elevation: 0.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(6.0.r),
                          ),
                        ),
                        center: false,
                        leadingWidth: 0.0,
                        title: const ig-publicAppBarTitle(
                          title: '선물확인',
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
                      SafeArea(
                        child: Stack(
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width,
                              height: (MediaQuery.of(context).size.height / 1.2) - const ig-publicAppBar().preferredSize.height - MediaQuery.of(context).padding.bottom,
                              padding: const EdgeInsets.symmetric(horizontal: 20.0),
                              color: ColorConfig().white(),
                              child: Column(
                                children: [
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: (MediaQuery.of(context).size.height / 1.2) - const ig-publicAppBar().preferredSize.height - MediaQuery.of(context).padding.bottom - 48.0 - (24.0 + 40.0 + 14.sp),
                                    margin: const EdgeInsets.only(top: 24.0),
                                    decoration: BoxDecoration(
                                      color: ColorConfig().white(),
                                      borderRadius: BorderRadius.circular(4.0.r),
                                      boxShadow: [
                                        BoxShadow(
                                          offset: const Offset(0.0, 0.1),
                                          color: ColorConfig().overlay(opacity: 0.06),
                                          blurRadius: 4.0,
                                        ),
                                      ],
                                    ),
                                    child: SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.symmetric(vertical: 16.0),
                                            child: Image(
                                              image: const AssetImage('assets/img/receive-gift-img.png'),
                                              width: 150.0.w,
                                              height: 190.0.w,
                                              filterQuality: FilterQuality.high,
                                            ),
                                          ),
                                          Container(
                                            margin: const EdgeInsets.only(bottom: 20.0),
                                            child: CustomTextBuilder(
                                              text: '${giftCheck.result['data']['name']}님이 보낸\n티켓을 확인해보세요!',
                                              fontColor: ColorConfig().primary(),
                                              fontSize: 18.0.sp,
                                              fontWeight: FontWeight.w800,
                                              height: 1.2,
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          Container(
                                            width: MediaQuery.of(context).size.width,
                                            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                                              decoration: BoxDecoration(
                                                color: ColorConfig().gray1(),
                                                borderRadius: BorderRadius.circular(4.0.r),
                                              ),
                                              child: CustomTextBuilder(
                                                text: '${giftCheck.result['data']['message']}',
                                                fontColor: ColorConfig().gray3(),
                                                fontSize: 14.0.sp,
                                                fontWeight: FontWeight.w700,
                                                height: 1.2,
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            margin: const EdgeInsets.only(top: 16.0),
                                            child: Text.rich(
                                              TextSpan(
                                                children: <TextSpan> [
                                                  TextSpan(
                                                    text: '*이 티켓은 취소시에 선물을 ',
                                                    style: TextStyle(
                                                      color: ColorConfig().accent(),
                                                      fontSize: 12.0.sp,
                                                      fontWeight: FontWeight.w400,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: giftCheck.result['data']['is_refund'] == 0 ? '보낸분께' : '받는분께',
                                                    style: TextStyle(
                                                      color: ColorConfig().accent(),
                                                      fontSize: 12.0.sp,
                                                      fontWeight: FontWeight.w800,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: ' 환불됩니다.',
                                                    style: TextStyle(
                                                      color: ColorConfig().accent(),
                                                      fontSize: 12.0.sp,
                                                      fontWeight: FontWeight.w400,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              bottom: 0.0,
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                                color: ColorConfig().white(),
                                child: Row(
                                  children: [
                                    InkWell(
                                      onTap: () async {
                                        PopupBuilder(
                                          title: TextConstant.rejectGift,
                                          content: TextConstant.rejectGiftContent,
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
                                                    Navigator.pop(context);

                                                    RejectGiftAPI().rejectGift(accessToken: await SecureStorageConfig().storage.read(key: 'access_token'), giftCode: Uri.decodeFull(id).substring(3)).then((value) {
                                                      if (value.result['status'] == 1) {
                                                        Navigator.pop(context);
                                                        ToastModel().iconToast(value.result['message']);
                                                      } else {
                                                        Navigator.pop(context);
                                                        ToastModel().iconToast(value.result['message'], iconType: 2);
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
                                                        text: TextConstant.doReject,
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
                                      child: Container(
                                        width: (MediaQuery.of(context).size.width / 2) - 24.0,
                                        margin: const EdgeInsets.only(right: 4.0),
                                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                                        decoration: BoxDecoration(
                                          color: ColorConfig().dark(),
                                          borderRadius: BorderRadius.circular(4.0.r),
                                        ),
                                        child: Center(
                                          child: CustomTextBuilder(
                                            text: TextConstant.rejectGift,
                                            fontColor: ColorConfig().white(),
                                            fontSize: 14.0.sp,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () async {
                                        ReceiveGiftAPI().receiveGift(accessToken: await SecureStorageConfig().storage.read(key: 'access_token'), giftCode: Uri.decodeFull(id).substring(3)).then((value) {
                                          if (value.result['status'] == 1) {
                                            Navigator.pop(context);
                                            Navigator.pushNamed(context, 'giftBox');
                                          } else {
                                            Navigator.pop(context);
                                            ToastModel().iconToast(value.result['message'], iconType: 2);
                                          }
                                        });
                                      },
                                      child: Container(
                                        width: (MediaQuery.of(context).size.width / 2) - 24.0,
                                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                                        decoration: BoxDecoration(
                                          color: ColorConfig().primary(),
                                          borderRadius: BorderRadius.circular(4.0.r),
                                        ),
                                        child: Center(
                                          child: CustomTextBuilder(
                                            text: TextConstant.getReceiveGift,
                                            fontColor: ColorConfig().white(),
                                            fontSize: 14.0.sp,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
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
                  );
                },
              );
            }
          });
          break;
        case 'ig-publicRank':
          break;
      }
    } else {
      String link = dynamicLinkData.link.path.split('/').last;
      switch (link) {
        case 'ranking':
          break;
        case 'my_groups':
          break;
        case 'my_coupons':
          break;
        case 'mypage':
          break;
      }
    }
  }

  Future<void> initDynamicLinks() async {
    dynamicLinks.onLink.listen((dynamicLinkData) {
      _redirectScreen(dynamicLinkData);
    }).onError((error) {
      if (kDebugMode) {
        print(error.message);
      }
    });
    final PendingDynamicLinkData? data = await FirebaseDynamicLinks.instance.getInitialLink();

    // deepLink.queryParameters
    // print(deepLink);
    if (data != null) {
      _redirectScreen(data);
    }
  }

  Future<void> initDeepLinks() async {
    appLinks = AppLinks();
    // Check initial link if app was in cold state (terminated)
    final appLink = await appLinks.getInitialAppLink();
    if (appLink != null) {
      final PendingDynamicLinkData? data = await FirebaseDynamicLinks.instance.getDynamicLink(appLink);
      try {
        _redirectScreen(data!);
      } catch (err) {
        if (kDebugMode) {
          print(err);
        }
      }
      // openAppLink(appLink);
    }
    // Handle link when app is in warm state (front or background)
    linkSubscription = appLinks.uriLinkStream.listen((uri) async {
      final PendingDynamicLinkData? data = await FirebaseDynamicLinks.instance.getDynamicLink(uri);
      _redirectScreen(data!);
    });
  }

  Future<void> initializeAPI() async {
    print(await SecureStorageConfig().storage.read(key: 'access_token'));
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    MainMyProfileAPI().myProfile(accessToken: await SecureStorageConfig().storage.read(key: 'access_token')).then((value) async {
      setState(() {
        myProfileData = value.result['data'];

        prefs.setInt('myRank', value.result['data']['rank']);
      });
    });
  }

  Future<void> firebaseCloudMessagingListener() async {
    await Firebase.initializeApp();
    
    // get fcm token
    FirebaseMessaging.instance.getToken().then((token) async {
      print('FCM token: $token');
      if (await SecureStorageConfig().storage.read(key: 'fcm_token') != null || await SecureStorageConfig().storage.read(key: 'fcm_token') != '') {
        SecureStorageConfig().storage.delete(key: 'fcm_token').then((_) {
          SecureStorageConfig().storage.write(key: 'fcm_token', value: token);
        });
      } else {
        SecureStorageConfig().storage.write(key: 'fcm_token', value: token);
      }
    });

    // 종료된 상태에서 클릭이벤트
    FirebaseMessaging.instance.getInitialMessage().then((message) async {
      if (message?.data['ig-public_type'] == 'auction_success') {
        Navigator.pushNamed(context, 'ticketHistory', arguments: {
          "tabIndex": 0,
        });
      } else if (message?.data['ig-public_type'] == 'auction_failed') {
        Navigator.pushNamed(context, 'ticketHistory', arguments: {
          "tabIndex": 1,
        });
      } else if (message?.data['ig-public_type'] == 'show_yesterday') {
        Navigator.pushNamed(context, 'ticketHistory', arguments: {
          "tabIndex": 0,
        });
      } else if (message?.data['ig-public_type'] == 'ticket_yesterday_follow') {
        Navigator.pushReplacementNamed(context, 'ticketingDetail', arguments: {
          'show_detail_index': int.parse(message?.data['ig-public_id']),
          'show_content_index': int.parse(message?.data['ig-public_id1']),
        });
      } else if (message?.data['ig-public_type'] == 'auction_yesterday_follow') {
        Navigator.pushReplacementNamed(context, 'auctionDetail', arguments: {
          'show_detail_index': int.parse(message?.data['ig-public_id']),
          'show_content_index': int.parse(message?.data['ig-public_id1']),
        });
      } else if (message?.data['ig-public_type'] == 'ticket_artist_yesterday_follow') {
        Navigator.pushReplacementNamed(context, 'ticketingDetail', arguments: {
          'show_detail_index': int.parse(message?.data['ig-public_id']),
          'show_content_index': int.parse(message?.data['ig-public_id1']),
        });
      } else if (message?.data['ig-public_type'] == 'auction_artist_yesterday_follow') {
        Navigator.pushReplacementNamed(context, 'auctionDetail', arguments: {
          'show_detail_index': int.parse(message?.data['ig-public_id']),
          'show_content_index': int.parse(message?.data['ig-public_id1']),
        });
      } else if (message?.data['ig-public_type'] == 'auction_finish_1day') {
        Navigator.pushReplacementNamed(context, 'auctionDetail', arguments: {
          'show_detail_index': int.parse(message?.data['ig-public_id']),
          'show_content_index': int.parse(message?.data['ig-public_id1']),
        });
      } else if (message?.data['ig-public_type'] == 'auction_recommend_price_up') {
        Navigator.pushReplacementNamed(context, 'auctionDetail', arguments: {
          'show_detail_index': int.parse(message?.data['ig-public_id']),
          'show_content_index': int.parse(message?.data['ig-public_id1']),
        });
      } else if (message?.data['ig-public_type'] == 'mypage') {
        setState(() {
          currentIndex = 2;
        });
      } else if (message?.data['ig-public_type'] == 'my_ticket') {
        Navigator.pushNamed(context, 'ticketHistory', arguments: {
          "tabIndex": 0,
        });
      } else if (message?.data['ig-public_type'] == 'my_auction') {
        Navigator.pushNamed(context, 'ticketHistory', arguments: {
          "tabIndex": 1,
        });
      } else if (message?.data['ig-public_type'] == 'notice') {
        Navigator.pushNamed(context, 'noticeList');
      } else if (message?.data['ig-public_type'] == 'community_show_new_write') {
        Navigator.pushNamed(context, 'showCommunity', arguments: {
          'show_index': int.parse(message?.data['ig-public_id']),
        });
      } else if (message?.data['ig-public_type'] == 'community_artist_new_write') {
        Navigator.pushNamed(context, 'artistCommunity', arguments: {
          'artist_index': int.parse(message?.data['ig-public_id']),
        });
      } else if (message?.data['ig-public_type'] == 'reply') {
        Navigator.pushNamed(context, 'postDetail', arguments: {
          'community_index': int.parse(message?.data['ig-public_id']),
        });
      } else if (message?.data['ig-public_type'] == 'like') {
        Navigator.pushNamed(context, 'postDetail', arguments: {
          'community_index': int.parse(message?.data['ig-public_id']),
        });
      } else if (message?.data['ig-public_type'] == 'follow') {
        Navigator.pushNamed(context, 'otherUserProfile', arguments: {
          'user_index': int.parse(message?.data['ig-public_id']),
        });
      } else if (message?.data['ig-public_type'] == 'link') {
        UrlLauncherBuilder().launchURL(message?.data['ig-public_id']);
      } else if (message?.data['ig-public_type'] == 'ask_review_write') {
        setState(() {
          currentIndex = 2;
          Navigator.pushNamed(context, 'ticketHistory', arguments: {
            "tabIndex": 0,
          });
        });
      } else if (message?.data['ig-public_type'] == 'community_show_new_write') {
        Navigator.pushNamed(context, 'showCommunity', arguments: {
          'show_index': int.parse(message?.data['ig-public_id']),
        });
      }
    });

    // app on foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      // RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      // download when get image push
      Future<String> downloadAndSaveFile(String? url, String fileName) async {
        final Directory directory = await getApplicationDocumentsDirectory();
        final String filePath = '${directory.path}/$fileName';
        final http.Response response = await http.get(Uri.parse(url!));
        final File file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        return filePath;
      }

      final String? largeIconPath;
      if (Platform.isAndroid && message.notification!.android!.imageUrl != null) {
        largeIconPath = await downloadAndSaveFile(android!.imageUrl, 'largeIcon_${DateTime.now().millisecondsSinceEpoch.toString()}');
      } else {
        largeIconPath = '';
      }
      final String? bigPicturePath;
      if (Platform.isAndroid && message.notification!.android!.imageUrl != null) {
        bigPicturePath = await downloadAndSaveFile(android!.imageUrl, 'bigPicture_${DateTime.now().millisecondsSinceEpoch.toString()}');
      } else {
        bigPicturePath = '';
      }

      flutterLocalNotificationsPlugin.show(
        message.hashCode,
        '${message.data['title']}',
        '${message.data['body']}',
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            icon: 'mipmap/ic_launcher_icon',
            largeIcon: android?.imageUrl != null
              ? FilePathAndroidBitmap(largeIconPath)
              : null,
            styleInformation: android?.imageUrl != null
              ? BigPictureStyleInformation(
                  FilePathAndroidBitmap(bigPicturePath),
                  largeIcon: FilePathAndroidBitmap(largeIconPath),
                )
              : BigTextStyleInformation(
                  message.data['body'],
                ),
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );

      // 앱이 포그라운드에 있을 때 호출
      var adn = const AndroidInitializationSettings('@mipmap/ic_launcher_icon');
      var ios = const DarwinInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
      );
      var initializationSettings = InitializationSettings(android: adn, iOS: ios);
      // 포그라운드에서 클릭이벤트
      await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        // onDidReceiveBackgroundNotificationResponse: (details) => _firebaseMessagingBackgroundHandler(message),
        onDidReceiveNotificationResponse: (payload) async {
          // ignore: unnecessary_null_comparison
          if (payload != null) {
            if (message.data['ig-public_type'] == 'auction_success') {
              Navigator.pushNamed(context, 'ticketHistory', arguments: {
                "tabIndex": 0,
              });
            } else if (message.data['ig-public_type'] == 'auction_failed') {
              Navigator.pushNamed(context, 'ticketHistory', arguments: {
                "tabIndex": 1,
              });
            } else if (message.data['ig-public_type'] == 'show_yesterday') {
              Navigator.pushNamed(context, 'ticketHistory', arguments: {
                "tabIndex": 0,
              });
            } else if (message.data['ig-public_type'] == 'ticket_yesterday_follow') {
              Navigator.pushReplacementNamed(context, 'ticketingDetail', arguments: {
                'show_detail_index': int.parse(message.data['ig-public_id']),
                'show_content_index': int.parse(message.data['ig-public_id1']),
              });
            } else if (message.data['ig-public_type'] == 'auction_yesterday_follow') {
              Navigator.pushReplacementNamed(context, 'auctionDetail', arguments: {
                'show_detail_index': int.parse(message.data['ig-public_id']),
                'show_content_index': int.parse(message.data['ig-public_id1']),
              });
            } else if (message.data['ig-public_type'] == 'ticket_artist_yesterday_follow') {
              Navigator.pushReplacementNamed(context, 'ticketingDetail', arguments: {
                'show_detail_index': int.parse(message.data['ig-public_id']),
                'show_content_index': int.parse(message.data['ig-public_id1']),
              });
            } else if (message.data['ig-public_type'] == 'auction_artist_yesterday_follow') {
              Navigator.pushReplacementNamed(context, 'auctionDetail', arguments: {
                'show_detail_index': int.parse(message.data['ig-public_id']),
                'show_content_index': int.parse(message.data['ig-public_id1']),
              });
            } else if (message.data['ig-public_type'] == 'auction_finish_1day') {
              Navigator.pushReplacementNamed(context, 'auctionDetail', arguments: {
                'show_detail_index': int.parse(message.data['ig-public_id']),
                'show_content_index': int.parse(message.data['ig-public_id1']),
              });
            } else if (message.data['ig-public_type'] == 'auction_recommend_price_up') {
              Navigator.pushReplacementNamed(context, 'auctionDetail', arguments: {
                'show_detail_index': int.parse(message.data['ig-public_id']),
                'show_content_index': int.parse(message.data['ig-public_id1']),
              });
            } else if (message.data['ig-public_type'] == 'mypage') {
              setState(() {
                currentIndex = 2;
              });
            } else if (message.data['ig-public_type'] == 'my_ticket') {
              Navigator.pushNamed(context, 'ticketHistory', arguments: {
                "tabIndex": 0,
              });
            } else if (message.data['ig-public_type'] == 'my_auction') {
              Navigator.pushNamed(context, 'ticketHistory', arguments: {
                "tabIndex": 1,
              });
            } else if (message.data['ig-public_type'] == 'notice') {
              Navigator.pushNamed(context, 'noticeList');
            } else if (message.data['ig-public_type'] == 'community_show_new_write') {
              Navigator.pushNamed(context, 'showCommunity', arguments: {
                'show_index': int.parse(message.data['ig-public_id']),
              });
            } else if (message.data['ig-public_type'] == 'community_artist_new_write') {
              Navigator.pushNamed(context, 'artistCommunity', arguments: {
                'artist_index': int.parse(message.data['ig-public_id']),
              });
            } else if (message.data['ig-public_type'] == 'reply') {
              Navigator.pushNamed(context, 'postDetail', arguments: {
                'community_index': int.parse(message.data['ig-public_id']),
              });
            } else if (message.data['ig-public_type'] == 'like') {
              Navigator.pushNamed(context, 'postDetail', arguments: {
                'community_index': int.parse(message.data['ig-public_id']),
              });
            } else if (message.data['ig-public_type'] == 'follow') {
              Navigator.pushNamed(context, 'otherUserProfile', arguments: {
                'user_index': int.parse(message.data['ig-public_id']),
              });
            } else if (message.data['ig-public_type'] == 'link') {
              UrlLauncherBuilder().launchURL(message.data['ig-public_id']);
            } else if (message.data['ig-public_type'] == 'ask_review_write') {
              setState(() {
                currentIndex = 2;
                Navigator.pushNamed(context, 'ticketHistory', arguments: {
                  "tabIndex": 0,
                });
              });
            } else if (message.data['ig-public_type'] == 'community_show_new_write') {
              Navigator.pushNamed(context, 'showCommunity', arguments: {
                'show_index': int.parse(message.data['ig-public_id']),
              });
            }
          }
        },
      );
    });

    // 백그라운드에서 클릭이벤트
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message.data['ig-public_type'] == 'auction_success') {
        Navigator.pushNamed(context, 'ticketHistory', arguments: {
          "tabIndex": 0,
        });
      } else if (message.data['ig-public_type'] == 'auction_failed') {
        Navigator.pushNamed(context, 'ticketHistory', arguments: {
          "tabIndex": 1,
        });
      } else if (message.data['ig-public_type'] == 'show_yesterday') {
        Navigator.pushNamed(context, 'ticketHistory', arguments: {
          "tabIndex": 0,
        });
      } else if (message.data['ig-public_type'] == 'ticket_yesterday_follow') {
        Navigator.pushReplacementNamed(context, 'ticketingDetail', arguments: {
          'show_detail_index': int.parse(message.data['ig-public_id']),
          'show_content_index': int.parse(message.data['ig-public_id1']),
        });
      } else if (message.data['ig-public_type'] == 'auction_yesterday_follow') {
        Navigator.pushReplacementNamed(context, 'auctionDetail', arguments: {
          'show_detail_index': int.parse(message.data['ig-public_id']),
          'show_content_index': int.parse(message.data['ig-public_id1']),
        });
      } else if (message.data['ig-public_type'] == 'ticket_artist_yesterday_follow') {
        Navigator.pushReplacementNamed(context, 'ticketingDetail', arguments: {
          'show_detail_index': int.parse(message.data['ig-public_id']),
          'show_content_index': int.parse(message.data['ig-public_id1']),
        });
      } else if (message.data['ig-public_type'] == 'auction_artist_yesterday_follow') {
        Navigator.pushReplacementNamed(context, 'auctionDetail', arguments: {
          'show_detail_index': int.parse(message.data['ig-public_id']),
          'show_content_index': int.parse(message.data['ig-public_id1']),
        });
      } else if (message.data['ig-public_type'] == 'auction_finish_1day') {
        Navigator.pushReplacementNamed(context, 'auctionDetail', arguments: {
          'show_detail_index': int.parse(message.data['ig-public_id']),
          'show_content_index': int.parse(message.data['ig-public_id1']),
        });
      } else if (message.data['ig-public_type'] == 'auction_recommend_price_up') {
        Navigator.pushReplacementNamed(context, 'auctionDetail', arguments: {
          'show_detail_index': int.parse(message.data['ig-public_id']),
          'show_content_index': int.parse(message.data['ig-public_id1']),
        });
      } else if (message.data['ig-public_type'] == 'mypage') {
        setState(() {
          currentIndex = 2;
        });
      } else if (message.data['ig-public_type'] == 'my_ticket') {
        Navigator.pushNamed(context, 'ticketHistory', arguments: {
          "tabIndex": 0,
        });
      } else if (message.data['ig-public_type'] == 'my_auction') {
        Navigator.pushNamed(context, 'ticketHistory', arguments: {
          "tabIndex": 1,
        });
      } else if (message.data['ig-public_type'] == 'notice') {
        Navigator.pushNamed(context, 'noticeList');
      } else if (message.data['ig-public_type'] == 'community_show_new_write') {
        Navigator.pushNamed(context, 'showCommunity', arguments: {
          'show_index': int.parse(message.data['ig-public_id']),
        });
      } else if (message.data['ig-public_type'] == 'community_artist_new_write') {
        Navigator.pushNamed(context, 'artistCommunity', arguments: {
          'artist_index': int.parse(message.data['ig-public_id']),
        });
      } else if (message.data['ig-public_type'] == 'reply') {
        Navigator.pushNamed(context, 'postDetail', arguments: {
          'community_index': int.parse(message.data['ig-public_id']),
        });
      } else if (message.data['ig-public_type'] == 'like') {
        Navigator.pushNamed(context, 'postDetail', arguments: {
          'community_index': int.parse(message.data['ig-public_id']),
        });
      } else if (message.data['ig-public_type'] == 'follow') {
        Navigator.pushNamed(context, 'otherUserProfile', arguments: {
          'user_index': int.parse(message.data['ig-public_id']),
        });
      } else if (message.data['ig-public_type'] == 'link') {
        UrlLauncherBuilder().launchURL(message.data['ig-public_id']);
      } else if (message.data['ig-public_type'] == 'ask_review_write') {
        setState(() {
          currentIndex = 2;
          Navigator.pushNamed(context, 'ticketHistory', arguments: {
            "tabIndex": 0,
          });
        });
      } else if (message.data['ig-public_type'] == 'community_show_new_write') {
        Navigator.pushNamed(context, 'showCommunity', arguments: {
          'show_index': int.parse(message.data['ig-public_id']),
        });
      }
    });
  }

  void onTap(int index) {
    setState(() {
      // if (index == 3 && pointTooltipCount == 0) {
      //   pointTooltipCount++;
      //   pointTooltipState = true;

      //   Timer(const Duration(milliseconds: 2000), () {
      //     setState(() => pointTooltipState = false);
      //   });
      // }

      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: children[currentIndex],
      endDrawer: const ig-publicEndDrawerWidget(),
      onEndDrawerChanged: (isDrawerOpen) async {
        if(!isDrawerOpen) {}
      },
      bottomNavigationBar: Stack(
        clipBehavior: Clip.none,
        children: [
          ig-publicBottomNavigationBarBuilder().bottomNavigation(
            context,
            itemLength: children.length,
            onTap: onTap,
            currentIndex: currentIndex,
            backgroundColor: ColorConfig().primary(),
            selectedItemColor: ColorConfig().white(),
            unselectedItemColor: ColorConfig().primaryLight(),
            items: [
              BottomNavigationBarItem(
                icon: currentIndex != 0
                  ? SVGBuilder(
                    image: 'assets/icon/nav-ticket.svg',
                    color: ColorConfig().primaryLight(),
                  )
                  : SVGStringBuilder(
                    image: 'assets/icon/nav-ticket-active.svg',
                  ),
                label: '티켓팅',
              ),
              BottomNavigationBarItem(
                icon: currentIndex != 1
                  ? SVGBuilder(
                    image: 'assets/icon/nav-community.svg',
                    color: ColorConfig().primaryLight(),
                  )
                  : SVGStringBuilder(
                    image: 'assets/icon/nav-community-active.svg',
                  ),
                label: '커뮤니티',
              ),
              // BottomNavigationBarItem(
              //   icon: currentIndex != 2
              //     ? SVGBuilder(
              //       image: 'assets/icon/nav-point.svg',
              //       color: ColorConfig().primaryLight(),
              //     )
              //     : SVGStringBuilder(
              //       image:  'assets/icon/nav-point-active.svg',
              //     ),
              //   label: '포인트 적립',
              // ),
              // const BottomNavigationBarItem(
              //   icon: Icon(Icons.add),
              //   label: '쇼핑',
              // ),
              BottomNavigationBarItem(
                icon: Container(
                  width: 24.0,
                  height: 24.0,
                  margin: const EdgeInsets.only(bottom: 5.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    image: myProfileData['image'] != null
                      ? DecorationImage(
                          image: NetworkImage(myProfileData['image']),
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
                label: '마이페이지',
              ),
            ],
          ),
          // pointTooltip(),
        ],
      ),
    );
  }

  // Widget pointTooltip() {
  //   if (pointTooltipState) {
  //     return Positioned(
  //       left: (MediaQuery.of(context).size.width / 2) - (170.0.w / 2),
  //       bottom: (kBottomNavigationBarHeight + MediaQuery.of(context).padding.bottom) - 12.0,
  //       child: Container(
  //         width: 170.0.w,
  //         height: 60.0.w,
  //         color: Colors.red,
  //       ),
  //     );
  //   } else {
  //     return const SizedBox(
  //       width: 0.0,
  //       height: 0.0,
  //     );
  //   }
  // }
}
