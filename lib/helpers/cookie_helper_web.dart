import 'dart:html' as html;

String? getWebCookieString() {
  return html.document.cookie;
}
