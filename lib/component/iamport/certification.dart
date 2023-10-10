// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';

/* 아임포트 휴대폰 본인인증 모듈을 불러옵니다. */
import 'package:iamport_flutter/iamport_certification.dart';
/* 아임포트 휴대폰 본인인증 데이터 모델을 불러옵니다. */
import 'package:iamport_flutter/model/certification_data.dart';
import 'package:ig-public_v3/api/auth/phone_certification.dart';
import 'package:ig-public_v3/component/appbar/appbar.dart';
import 'package:ig-public_v3/component/appbar/appbar_leading.dart';
import 'package:ig-public_v3/component/appbar/appbar_title.dart';
import 'package:ig-public_v3/costant/build_config.dart';
import 'package:ig-public_v3/main.dart';
import 'package:ig-public_v3/src/auth/login.dart';
import 'package:ig-public_v3/util/toast.dart';

class PhoneCertification extends StatefulWidget {
  const PhoneCertification({Key? key}) : super(key: key);

  @override
  State<PhoneCertification> createState() => _PhoneCertificationState();
}

class _PhoneCertificationState extends State<PhoneCertification> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return IamportCertification(
      appBar: ig-publicAppBar(
        leading: ig-publicAppBarLeading(
          using: false,
          press: () {},
        ),
        title: const ig-publicAppBarTitle(
          title: '휴대폰 본인인증',
        ),
      ),
      /* 웹뷰 로딩 컴포넌트 */
      initialChild: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image.asset('assets/images/iamport-logo.png'),
            Container(
              padding: const EdgeInsets.fromLTRB(0.0, 30.0, 0.0, 0.0),
              child: const Text('잠시만 기다려주세요...',
                  style: TextStyle(fontSize: 20.0)),
            ),
          ],
        ),
      ),
      /* [필수입력] 가맹점 식별코드 */
      userCode: 'imp93678652',
      /* [필수입력] 본인인증 데이터 */
      data: CertificationData(
        merchantUid: 'ig-public_app_mid${DateTime.now().millisecondsSinceEpoch}',
      ),
      /* [필수입력] 콜백 함수 */
      callback: (Map<String, String> result) async {
        PhoneCertificateAPI().certificate(accessToken: await SecureStorageConfig().storage.read(key: 'access_token'), impUid: result['imp_uid']!).then((value) async {
          if (value.result['status'] == 1) {
            await SecureStorageConfig().storage.write(key: 'is_auth', value: '1').then((_) {
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => MainBuilder()), (route) => false);
            });
          } else {
            ToastModel().iconToast(value.result['message'], iconType: 2);
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const ig-publicLoginScreen()), (route) => false);
          }
        });
      },
    );
  }
}
