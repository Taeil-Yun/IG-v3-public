import 'package:http_interceptor/http_interceptor.dart';

import 'package:ig-public_v3/component/interceptor/autenticate_interceptor.dart';

class InterceptorHelper {
  final client = InterceptedClient.build(
    interceptors: [AuthenticateInterceptor()],
    retryPolicy: ExpiredTokenRetryPolicy(),
  );
}
