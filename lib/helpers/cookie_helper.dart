import 'cookie_helper_stub.dart'
    if (dart.library.html) 'cookie_helper_web.dart';

String? getRawCookieString() {
  return getWebCookieString();
}
