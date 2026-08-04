import 'dart:convert';

import 'package:cellphone_doctor/helpers/auth_helper.dart';
import 'package:cellphone_doctor/helpers/cookie_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "https://thecellphonedoctor.com/mobileapp/public/api";
  static const String sanctumCsrfUrl = "https://thecellphonedoctor.com/mobileapp/public/sanctum/csrf-cookie";

  static String? _xsrfToken;
  static String? _cookieHeader;

  /// Fetches Sanctum CSRF cookie and populates _xsrfToken and _cookieHeader
  static Future<void> ensureCsrfToken() async {
    try {
      final response = await http.get(
        Uri.parse(sanctumCsrfUrl),
        headers: {'Accept': 'application/json'},
      );

      final rawCookie = response.headers['set-cookie'];
      if (rawCookie != null && rawCookie.isNotEmpty) {
        final match = RegExp(r'XSRF-TOKEN=([^;]+)').firstMatch(rawCookie);
        if (match != null) {
          _xsrfToken = Uri.decodeComponent(match.group(1)!);
        }

        final cookieParts = rawCookie
            .split(',')
            .map((c) => c.split(';')[0].trim())
            .where((c) => c.isNotEmpty)
            .toList();
        if (cookieParts.isNotEmpty) {
          _cookieHeader = cookieParts.join('; ');
        }
      }

      // Check web document.cookie fallback on Flutter Web
      if (kIsWeb && (_xsrfToken == null || _xsrfToken!.isEmpty)) {
        final webCookieStr = getRawCookieString();
        if (webCookieStr != null && webCookieStr.isNotEmpty) {
          final match = RegExp(r'XSRF-TOKEN=([^;]+)').firstMatch(webCookieStr);
          if (match != null) {
            _xsrfToken = Uri.decodeComponent(match.group(1)!);
          }
          _cookieHeader = webCookieStr;
        }
      }
      debugPrint("CSRF Token initialized: ${_xsrfToken != null}");
    } catch (e) {
      debugPrint("CSRF Cookie fetch error: $e");
    }
  }

  static Map<String, String> _buildHeaders({
    String? contentType,
    String? authorizationToken,
    bool includeXsrf = true,
  }) {
    final Map<String, String> headers = {
      'Accept': 'application/json',
    };
    if (contentType != null) {
      headers['Content-Type'] = contentType;
    }
    if (authorizationToken != null && authorizationToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $authorizationToken';
    }
    if (includeXsrf && _xsrfToken != null && _xsrfToken!.isNotEmpty) {
      headers['X-XSRF-TOKEN'] = _xsrfToken!;
    }
    if (includeXsrf && _cookieHeader != null && _cookieHeader!.isNotEmpty) {
      headers['Cookie'] = _cookieHeader!;
    }
    return headers;
  }

  static Future<dynamic> getRequest(String endpoint) async {
    final url = Uri.parse("$baseUrl/$endpoint");

    try {
      if (_xsrfToken == null) {
        await ensureCsrfToken();
      }

      final response = await http.get(
        url,
        headers: _buildHeaders(),
      );

      return _responseHandler(response);
    } catch (e) {
      return {"status": false, "message": e.toString()};
    }
  }

  static Future<dynamic> postRequest(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse("$baseUrl/$endpoint");

    try {
      if (_xsrfToken == null) {
        await ensureCsrfToken();
      }

      final headers = _buildHeaders(contentType: 'application/json');

      http.Response response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );
      print("POST $url => Status: ${response.statusCode}");

      // Retry attempt if CSRF 419 encountered
      if (response.statusCode == 419) {
        print("CSRF 419 detected. Fetching fresh CSRF token...");
        await ensureCsrfToken();
        final freshHeaders = _buildHeaders(contentType: 'application/json');
        response = await http.post(
          url,
          headers: freshHeaders,
          body: jsonEncode(body),
        );
        print("RETRY POST $url => Status: ${response.statusCode}");
      }

      return _responseHandler(response);
    } catch (e) {
      return {"status": false, "message": e.toString()};
    }
  }

  static dynamic _responseHandler(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return decoded;
      } else {
        if (decoded is Map) {
          return decoded;
        }
        return {
          "status": false,
          "message": "Error: ${response.statusCode}"
        };
      }
    } catch (_) {
      return {
        "status": false,
        "message": "Error: ${response.statusCode}"
      };
    }
  }

  static getData(
      {required String? uri,
        required bool? isAuthorized,
        required context}) async {
    debugPrint("$baseUrl$uri");
    var token = await AuthHelper.getString("token");
    debugPrint(token);
    try {
      if (_xsrfToken == null) {
        await ensureCsrfToken();
      }
      var headers = _buildHeaders(authorizationToken: isAuthorized == true ? token : null);
      
      final response = await http.get(
        Uri.parse("$baseUrl$uri"),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      debugPrint("${response.statusCode}: ${response.body}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        var resultData = json.decode(response.body);
        return resultData;
      } else if (response.statusCode == 401) {
        return "failed";
      } else {
        try {
          var messageToDisplay = json.decode(response.body);
          if (response.statusCode == 400 ) {
            return messageToDisplay;
          }
        } catch (e) {
          debugPrint(response.body);
        }
        return "failed";
      }
    } catch (e) {
      debugPrint(e.toString());
      return "failed";
    }
  }

  static postData(
      {required String? uri,
        required bool? isAuthorized,
        required requestData,
        required context}) async {
    var token = await AuthHelper.getString("token");
    print(token);
    print(requestData);
    try {
      if (_xsrfToken == null) {
        await ensureCsrfToken();
      }

      var headers = isAuthorized == false
          ? _buildHeaders(contentType: 'application/json')
          : requestData == null
          ? _buildHeaders(authorizationToken: token)
          : _buildHeaders(contentType: 'application/json', authorizationToken: token);

      var request = http.Request('POST', Uri.parse("$baseUrl$uri"));
      request.headers.addAll(headers);
      if (requestData != null) request.body = requestData;

      http.StreamedResponse res = await request.send();
      http.Response response = await http.Response.fromStream(res);

      if (response.statusCode == 419) {
        print("CSRF 419 in postData. Retrying with fresh CSRF token...");
        await ensureCsrfToken();
        var freshHeaders = isAuthorized == false
            ? _buildHeaders(contentType: 'application/json')
            : requestData == null
            ? _buildHeaders(authorizationToken: token)
            : _buildHeaders(contentType: 'application/json', authorizationToken: token);

        var retryRequest = http.Request('POST', Uri.parse("$baseUrl$uri"));
        retryRequest.headers.addAll(freshHeaders);
        if (requestData != null) retryRequest.body = requestData;
        http.StreamedResponse retryRes = await retryRequest.send();
        response = await http.Response.fromStream(retryRes);
      }

      debugPrint("${response.statusCode}: ${response.body}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        var resultData = json.decode(response.body);
        return resultData;
      } else if (response.statusCode == 401) {
        return "failed";
      } else {
        return "failed";
      }
    } catch (e, stacktrace) {
      debugPrint(stacktrace.toString());
      return "failed";
    }
  }

  static multipartRequest(
      {required List<MultipartRequestService> multipartRequestFields,
        required context,
        required uri,
        required method,
        isAuthorized}) async {
      debugPrint("URL: ${Uri.parse("$baseUrl$uri")}");
      var token = await AuthHelper.getString("token");
      debugPrint("URL:$token");
      if (_xsrfToken == null) {
        await ensureCsrfToken();
      }
      var headers = _buildHeaders(
        contentType: 'multipart/form-data',
        authorizationToken: isAuthorized == true ? token : null,
      );
      var request = http.MultipartRequest(
          method, Uri.parse("$baseUrl$uri"));
      if (multipartRequestFields.isNotEmpty) {
        for (var item in multipartRequestFields) {
          try{
            debugPrint(
                "value ${item.fieldName} ---- ${item.fieldValue.toString()} ---- ${item.fieldValue.runtimeType}");
            if (item.isField) {
              request.fields["${item.fieldName}"] = item.fieldValue;
            } else if (item.isFile) {
              if (item.isBytes == true && item.fieldValue is List<int>) {
                request.files.add(http.MultipartFile.fromBytes(
                  '${item.fieldName}',
                  item.fieldValue,
                  filename: item.filename ?? 'signature.png',
                ));
              } else {
                request.files.add(await http.MultipartFile.fromPath(
                    '${item.fieldName}', item.fieldValue));
              }
            }
          }catch(e) {
            debugPrint("On multipart request: $e");
          }
        }
      }

      debugPrint("Request Fields: ${request.fields}");
      debugPrint("Request Files: ${request.files}");
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      String responseBody = await response.stream.bytesToString();
      print("Raw API Response: ${response.statusCode}");
      print("Raw API Response: ${responseBody}");

      if (response.statusCode == 401) {
        return "failed";
      }

      var result = json.decode(responseBody);
      print("Decoded result: $result");

      if (response.statusCode == 201 || response.statusCode == 200) {
        return result;
      } else {
        return "failed";
      }
    } 
  }

class MultipartRequestService {
  final dynamic fieldName;
  final dynamic fieldValue;
  final dynamic isField;
  final dynamic isFile;
  final dynamic isBytes;
  final String? filename;

  MultipartRequestService(
      {required this.fieldName,
        required this.isField,
        required this.isFile,
        required this.fieldValue,
        this.isBytes = false,
        this.filename});
}
