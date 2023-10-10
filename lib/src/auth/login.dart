import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ig-public_v3/component/iamport/certification.dart';
import 'package:ig-public_v3/component/svg/svg_builder.dart';
import 'package:ig-public_v3/main.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:http/http.dart' as http;

import 'package:ig-public_v3/costant/build_config.dart';
import 'package:ig-public_v3/costant/keys.dart';
import 'package:ig-public_v3/costant/enumerated.dart';
import 'package:ig-public_v3/costant/text.dart';
import 'package:ig-public_v3/costant/colors.dart';
import 'package:ig-public_v3/src/auth/component/bottom_widget.dart';
import 'package:ig-public_v3/src/auth/component/login_widget.dart';
import 'package:ig-public_v3/api/auth/google.dart';
import 'package:ig-public_v3/api/auth/kakao.dart';
import 'package:ig-public_v3/api/auth/facebook.dart';
import 'package:ig-public_v3/api/auth/naver.dart';
import 'package:ig-public_v3/api/auth/apple.dart';
import 'package:ig-public_v3/widget/custom_text_widget.dart';

GoogleSignIn _googleSignIn = GoogleSignIn(
  clientId: Platform.isIOS ? ig-publicBuildConfig.instance?.buildType == 'dev' ? ig-publicKeys.googleDevClientIdKey : ig-publicKeys.googleProductClientIdKey : null,
  scopes: <String>[
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
  ],
);

class ig-publicLoginScreen extends StatelessWidget {
  const ig-publicLoginScreen({super.key});

  // 구글 로그인
  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      // if (await SecureStorageConfig().storage.read(key: 'login_type') == 'google') {
      if (_googleSignIn.currentUser != null) {
        await _googleSignIn.signOut();
      }
      // }
      
      await _googleSignIn.signIn().then((value) async {
        await value?.authentication.then((va) async {
          log('----------------------------------------');
          log('${va.idToken?.split('.')[0]}.');
          log('${va.idToken?.split('.')[1]}');
          log('.${va.idToken?.split('.')[2]}');
          log('----------------------------------------');

          String? fcmToken = await SecureStorageConfig().storage.read(key: 'fcm_token');
          
          ig-publicLoginWithGoogleAPI().google(idToken: va.idToken!, fcmToken: fcmToken!).then((value) async {
            Future.wait([
              SecureStorageConfig().storage.write(key: 'is_auth', value: '${value.result['is_auth']}'),
              SecureStorageConfig().storage.write(key: 'access_token', value: value.result['access_token']),
              SecureStorageConfig().storage.write(key: 'refresh_token', value: value.result['refresh_token']),
              SecureStorageConfig().storage.write(key: 'token_status', value: 'false'),
              SecureStorageConfig().storage.write(key: 'login_type', value: 'google'),
            ]).then((_) {
              if (value.result['is_auth'] == 0) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const PhoneCertification()));
              } else {
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => MainBuilder()), (route) => false);
              }
            });
          });
        });
      });
    } catch (error) {
      log(error.toString());
    }
  }

  // 카카오 로그인
  Future<void> signInWithKakao(BuildContext context) async {
    if (ig-publicBuildConfig.instance?.buildType == 'dev') {
      KakaoSdk.init(
        nativeAppKey: ig-publicKeys.kakaoDevNativeKey,
        javaScriptAppKey: ig-publicKeys.kakaoDevJavaScriptKey,
        loggingEnabled: false,
      );
    } else {
      KakaoSdk.init(
        nativeAppKey: ig-publicKeys.kakaoProductNativeKey,
        javaScriptAppKey: ig-publicKeys.kakaoProductJavaScriptKey,
        loggingEnabled: true,
      );
    }

    String? fcmToken = await SecureStorageConfig().storage.read(key: 'fcm_token');

    if (await isKakaoTalkInstalled()) {
      if (await AuthApi.instance.hasToken()) {
        try {
          await UserApi.instance.logout();
          
          await UserApi.instance.revokeScopes(scopes: ['account_email', 'openid', 'gender', 'birthday']);
          
          AccessTokenInfo tokenInfo = await UserApi.instance.accessTokenInfo();
          log('토큰 유효성 체크 성공 ${tokenInfo.id} ${tokenInfo.expiresIn}');

          try {
            User user = await UserApi.instance.me();
            OAuthToken scope = await UserApi.instance.loginWithNewScopes(['account_email', 'openid', 'gender', 'birthday'], nonce: ig-publicBuildConfig.instance?.buildType == 'dev' ? 'dev_ig-public' : 'product_ig-public');
            log(scope.idToken!);
            log(
              '사용자 정보 요청 성공'
              '\n회원번호: ${user.id}'
              '\n닉네임: ${user.kakaoAccount?.profile?.nickname}'
              '\n이메일: ${user.kakaoAccount?.email}'
              '\n이름: ${user.kakaoAccount?.profile?.toJson()['nickname']}'
              '\n프로퍼티: ${user.properties}'
            );
          } catch (error) {
            log('사용자 정보 요청 실패 $error');
          }
        } catch (error) {
          if (error is KakaoException && error.isInvalidTokenError()) {
            log('토큰 만료 $error');
          } else {
            log('토큰 정보 조회 실패 $error');
          }

          try {
            // 카카오 계정으로 로그인
            await UserApi.instance.loginWithKakaoTalk(nonce: ig-publicBuildConfig.instance?.buildType == 'dev' ? 'dev_ig-public' : 'product_ig-public').then((result) async {
              log('로그인 성공 ${result.accessToken}');
              log('로그인 성공 ${result.idToken}');

              var prof = await UserApi.instance.me();

              ig-publicLoginWithKakaoAPI().kakao(idToken: result.idToken, fcmToken: fcmToken!, profile: prof.kakaoAccount).then((value) {
                Future.wait([
                  SecureStorageConfig().storage.write(key: 'is_auth', value: '${value.result['is_auth']}'),
                  SecureStorageConfig().storage.write(key: 'access_token', value: value.result['access_token']),
                  SecureStorageConfig().storage.write(key: 'refresh_token', value: value.result['refresh_token']),
                  SecureStorageConfig().storage.write(key: 'token_status', value: 'false'),
                  SecureStorageConfig().storage.write(key: 'login_type', value: 'kakao'),
                ]).then((_) {
                  if (value.result['is_auth'] == 0) {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const PhoneCertification()));
                  } else {
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => MainBuilder()), (route) => false);
                  }
                });
              });
            });
          } catch (error) {
            log('로그인 실패 $error');
          }
        }
      } else {
        log('발급된 토큰 없1음');
        try {
          await UserApi.instance.loginWithKakaoTalk(serviceTerms: ['account_email', 'openid', 'gender', 'birthday'], nonce: ig-publicBuildConfig.instance?.buildType == 'dev' ? 'dev_ig-public' : 'product_ig-public').then((result) async {            
            User prof = await UserApi.instance.me();

            ig-publicLoginWithKakaoAPI().kakao(idToken: result.idToken, fcmToken: fcmToken!, profile: prof.kakaoAccount).then((value) {
              Future.wait([
                SecureStorageConfig().storage.write(key: 'is_auth', value: '${value.result['is_auth']}'),
                SecureStorageConfig().storage.write(key: 'access_token', value: value.result['access_token']),
                SecureStorageConfig().storage.write(key: 'refresh_token', value: value.result['refresh_token']),
                SecureStorageConfig().storage.write(key: 'token_status', value: 'false'),
                SecureStorageConfig().storage.write(key: 'login_type', value: 'kakao'),
              ]).then((_) {
                if (value.result['is_auth'] == 0) {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const PhoneCertification()));
                } else {
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => MainBuilder()), (route) => false);
                }
              });
            });
          });
        } catch (error) {
          log('로그인 실패 $error');
        }
      }
    } else {
      if (await AuthApi.instance.hasToken()) {
        try {
          await UserApi.instance.loginWithKakaoAccount(nonce: ig-publicBuildConfig.instance?.buildType == 'dev' ? 'dev_ig-public' : 'product_ig-public').then((result) async {
            var prof = await UserApi.instance.me();

            ig-publicLoginWithKakaoAPI().kakao(idToken: result.idToken, fcmToken: fcmToken!, profile: prof.kakaoAccount).then((value) {
              Future.wait([
                SecureStorageConfig().storage.write(key: 'is_auth', value: '${value.result['is_auth']}'),
                SecureStorageConfig().storage.write(key: 'access_token', value: value.result['access_token']),
                SecureStorageConfig().storage.write(key: 'refresh_token', value: value.result['refresh_token']),
                SecureStorageConfig().storage.write(key: 'token_status', value: 'false'),
                SecureStorageConfig().storage.write(key: 'login_type', value: 'kakao'),
              ]).then((_) {
                if (value.result['is_auth'] == 0) {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const PhoneCertification()));
                } else {
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => MainBuilder()), (route) => false);
                }
              });
            });
          });

          try {
            // User user = await UserApi.instance.me();
          } catch (error) {
            log('사용자 정보 요청 실패 $error');
          }
        } catch (error) {
          if (error is KakaoException && error.isInvalidTokenError()) {
            log('토큰 만료 $error');
          } else {
            log('토큰 정보 조회 실패 $error');
          }

          try {
            // 카카오 계정으로 로그인
            await UserApi.instance.loginWithKakaoAccount(nonce: ig-publicBuildConfig.instance?.buildType == 'dev' ? 'dev_ig-public' : 'product_ig-public').then((result) async {
              var prof = await UserApi.instance.me();

              ig-publicLoginWithKakaoAPI().kakao(idToken: result.idToken, fcmToken: fcmToken!, profile: prof.kakaoAccount).then((value) {
                Future.wait([
                  SecureStorageConfig().storage.write(key: 'is_auth', value: '${value.result['is_auth']}'),
                  SecureStorageConfig().storage.write(key: 'access_token', value: value.result['access_token']),
                  SecureStorageConfig().storage.write(key: 'refresh_token', value: value.result['refresh_token']),
                  SecureStorageConfig().storage.write(key: 'token_status', value: 'false'),
                  SecureStorageConfig().storage.write(key: 'login_type', value: 'kakao'),
                ]).then((_) {
                  if (value.result['is_auth'] == 0) {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const PhoneCertification()));
                  } else {
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => MainBuilder()), (route) => false);
                  }
                });
              });
            });

          } catch (error) {
            log('로그인 실패 $error');
          }
        }
      } else {
        log('발급된 토큰 없음');
        try {
          await UserApi.instance.loginWithKakaoAccount(nonce: ig-publicBuildConfig.instance?.buildType == 'dev' ? 'dev_ig-public' : 'product_ig-public').then((result) async {
            var prof = await UserApi.instance.me();

            ig-publicLoginWithKakaoAPI().kakao(idToken: result.idToken, fcmToken: fcmToken!, profile: prof.kakaoAccount).then((value) {
              Future.wait([
                SecureStorageConfig().storage.write(key: 'is_auth', value: '${value.result['is_auth']}'),
                SecureStorageConfig().storage.write(key: 'access_token', value: value.result['access_token']),
                SecureStorageConfig().storage.write(key: 'refresh_token', value: value.result['refresh_token']),
                SecureStorageConfig().storage.write(key: 'token_status', value: 'false'),
                SecureStorageConfig().storage.write(key: 'login_type', value: 'kakao'),
              ]).then((_) {
                if (value.result['is_auth'] == 0) {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const PhoneCertification()));
                } else {
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => MainBuilder()), (route) => false);
                }
              });
            });
          });
        } catch (error) {
          log('로그인 실패 $error');
        }
      }
    }
  }

  // 페이스북 로그인
  Future<void> signInWithFacebook(BuildContext context) async {
    try {
      // Future.wait([
      //   SecureStorageConfig().storage.delete(key: 'access_token'),
      //   SecureStorageConfig().storage.delete(key: 'refresh_token'),
      // ]).then((_) async {
        // 로그인 트리거
        final LoginResult result = await FacebookAuth.instance.login();

        String? fcmToken = await SecureStorageConfig().storage.read(key: 'fcm_token');
        
        ig-publicLoginWithFacebookAPI().facebook(fbToken: result.accessToken!.token, fcmToken: fcmToken!).then((value) async {
          //   // ig-publicAnalyticsEvent().logEvent('Login', {'type': 'facebook'});

          //   // KakaoPixelModel().sendKakaoPixelEvent(method: 'login');

          Future.wait([
            SecureStorageConfig().storage.write(key: 'is_auth', value: '${value.result['is_auth']}'),
            SecureStorageConfig().storage.write(key: 'access_token', value: value.result['access_token']),
            SecureStorageConfig().storage.write(key: 'refresh_token', value: value.result['refresh_token']),
            SecureStorageConfig().storage.write(key: 'token_status', value: 'false'),
            SecureStorageConfig().storage.write(key: 'login_type', value: 'naver'),
          ]).then((_) {
            if (value.result['is_auth'] == 0) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const PhoneCertification()));
            } else {
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => MainBuilder()), (route) => false);
            }
          });
        });
      // });
    } catch (e) {
      log(e.toString(), name: 'error');
    }
  }

  // 네이버 로그인
  Future<void> signInWithNaver(BuildContext context) async {
    // if (await SecureStorageConfig().storage.read(key: 'access_token') != null && await SecureStorageConfig().storage.read(key: 'login_type') == 'naver') {
    //   Future.wait([
    //     SecureStorageConfig().storage.delete(key: 'access_token'),
    //     SecureStorageConfig().storage.delete(key: 'refresh_token'),
    //   ]).then((_) async {
    //     await FlutterNaverLogin.logOutAndDeleteToken().then((_) async {
    //       await FlutterNaverLogin.logIn().then((loginData) async {
    //         NaverAccessToken res = await FlutterNaverLogin.currentAccessToken;
    //         String? fcmToken = await SecureStorageConfig().storage.read(key: 'fcm_token');

    //         ig-publicLoginWithNaverAPI().naver(naverToken: res.accessToken, fcmToken: fcmToken!).then((value) {
    //           Future.wait([
    //             SecureStorageConfig().storage.write(key: 'is_auth', value: '${value.result['is_auth']}'),
    //             SecureStorageConfig().storage.write(key: 'access_token', value: value.result['access_token']),
    //             SecureStorageConfig().storage.write(key: 'refresh_token', value: value.result['refresh_token']),
    //             SecureStorageConfig().storage.write(key: 'token_status', value: 'false'),
    //             SecureStorageConfig().storage.write(key: 'login_type', value: 'naver'),
    //           ]).then((_) {
    //             if (value.result['is_auth'] == 0) {
    //               Navigator.push(context, MaterialPageRoute(builder: (context) => const PhoneCertification()));
    //             } else {
    //               Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => MainBuilder()), (route) => false);
    //             }
    //           });
    //         });
    //       });
    //     });
    //   });
    // } else {
      if (await FlutterNaverLogin.isLoggedIn == true) {
        await FlutterNaverLogin.logOutAndDeleteToken();
      }

      await FlutterNaverLogin.logIn().then((loginData) async {
        NaverAccessToken res = await FlutterNaverLogin.currentAccessToken;
        String? fcmToken = await SecureStorageConfig().storage.read(key: 'fcm_token');

        ig-publicLoginWithNaverAPI().naver(naverToken: res.accessToken, fcmToken: fcmToken!).then((value) {
          Future.wait([
            SecureStorageConfig().storage.write(key: 'is_auth', value: '${value.result['is_auth']}'),
            SecureStorageConfig().storage.write(key: 'access_token', value: value.result['access_token']),
            SecureStorageConfig().storage.write(key: 'refresh_token', value: value.result['refresh_token']),
            SecureStorageConfig().storage.write(key: 'token_status', value: 'false'),
            SecureStorageConfig().storage.write(key: 'login_type', value: 'naver'),
          ]).then((_) {
            if (value.result['is_auth'] == 0) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const PhoneCertification()));
            } else {
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => MainBuilder()), (route) => false);
            }
          });
        });
      });
    // }
  }

  Future<void> signInWithApple(BuildContext context) async {
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: ig-publicBuildConfig.instance?.buildType == 'dev' ? 'dev_ig-public' : 'product_ig-public',
      webAuthenticationOptions: WebAuthenticationOptions(
        clientId: 'de.lunaone.flutter.signinwithappleexample.service',
        redirectUri: Uri.parse(
          'https://flutter-sign-in-with-apple-example.glitch.me/callbacks/sign_in_with_apple',
        ),
      ),
      // state: 'example-state',
    );

    SignInWithApple.isAvailable().then((value) {
      // print('af: $value');
    });

    String? fcmToken = await SecureStorageConfig().storage.read(key: 'fcm_token');

    ig-publicLoginWithAppleAPI().apple(idToken: credential.identityToken, fcmToken: fcmToken!).then((value) async {
      Future.wait([
        SecureStorageConfig().storage.write(key: 'is_auth', value: '${value.result['is_auth']}'),
        SecureStorageConfig().storage.write(key: 'access_token', value: value.result['access_token']),
        SecureStorageConfig().storage.write(key: 'refresh_token', value: value.result['refresh_token']),
        SecureStorageConfig().storage.write(key: 'token_status', value: 'false'),
        SecureStorageConfig().storage.write(key: 'login_type', value: 'apple'),
      ]).then((_) {
        if (value.result['is_auth'] == 0) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const PhoneCertification()));
        } else {
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => MainBuilder()), (route) => false);
        }
      });
    });

    final signInWithAppleEndpoint = Uri(
      scheme: 'https',
      host: 'flutter-sign-in-with-apple-example.glitch.me',
      path: '/sign_in_with_apple',
      queryParameters: <String, String>{
        'code': credential.authorizationCode,
        if (credential.givenName != null) 'firstName': credential.givenName!,
        if (credential.familyName != null) 'lastName': credential.familyName!,
        'useBundleId': !kIsWeb && (Platform.isIOS || Platform.isMacOS)
          ? 'true'
          : 'false',
        if (credential.state != null) 'state': credential.state!,
      },
    );

    final session = await http.Client().post(
      signInWithAppleEndpoint,
    );

    if (session.isRedirect) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: ColorConfig().white(),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 72.0),
                  child: SVGStringBuilder(
                    image: 'assets/img/login-logo.svg',
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 16.0),
                  child: CustomTextBuilder(
                    text: '슬기로운 뮤지컬 생활',
                    fontColor: ColorConfig().primary(),
                    fontSize: 16.0.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 90.0),
                LoginButtonWidget().loginWidget(
                  context,
                  title: TextConstant.loginByKakao,
                  logo: 'assets/icon/kakao-logo.svg',
                  press: () {
                    signInWithKakao(context);
                  },
                  type: LoginType.kakao
                ),
                LoginButtonWidget().loginWidget(
                  context,
                  title: TextConstant.loginByGoogle,
                  logo: 'assets/icon/google-logo.svg',
                  press: () {
                    signInWithGoogle(context);
                  },
                  type: LoginType.google
                ),
                LoginButtonWidget().loginWidget(
                  context,
                  title: TextConstant.loginByApple,
                  logo: 'assets/icon/apple-logo.svg',
                  press: () {
                    signInWithApple(context);
                  },
                  type: LoginType.apple
                ),
                LoginButtonWidget().loginWidget(
                  context,
                  title: TextConstant.loginByNaver,
                  logo: 'assets/icon/naver-logo.svg',
                  press: () {
                    signInWithNaver(context);
                  },
                  type: LoginType.naver
                ),
                LoginButtonWidget().loginWidget(
                  context,
                  title: TextConstant.loginByFacebook,
                  logo: 'assets/icon/facebook-logo.svg',
                  press: () {
                    signInWithFacebook(context);
                  },
                  type: LoginType.facebook
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 40.0),
                  padding: const EdgeInsets.symmetric(horizontal: 22.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1.0,
                          color: ColorConfig().gray3(),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12.0),
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: CustomTextBuilder(
                          text: TextConstant.orText,
                          fontColor: ColorConfig().gray3(),
                          fontSize: 11.0.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1.0,
                          color: ColorConfig().gray3(),
                        ),
                      ),
                    ],
                  ),
                ),
                LoginButtonWidget().loginWidget(
                  context,
                  title: TextConstant.loginByEmail,
                  logo: 'assets/icon/email-logo.svg',
                  press: () {
                    Navigator.pushNamed(context, 'email_login');
                  },
                  type: LoginType.email
                ),
                const SignupORFindPassword(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}