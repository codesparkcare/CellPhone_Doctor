import 'dart:convert';

import 'package:cellphone_doctor/helpers/auth_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // Persistent client — reuses TCP/TLS connections across requests
  static final http.Client _client = http.Client();
  static const Duration _timeout = Duration(seconds: 15);

  static const String baseUrl = "https://thecellphonedoctor.com/mobileapp/public/api";

  static Future<dynamic> getRequest(String endpoint) async {
    final url = Uri.parse("$baseUrl/$endpoint");

    try {
      final response = await http.get(
        url,
        headers: {'Accept': 'application/json'},
      );

      return _responseHandler(response);
    } catch (e) {
      return {"status": false, "message": e.toString()};
    }
  }

  static Future<dynamic> postRequest(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse("$baseUrl/$endpoint");

    try {
      // Primary attempt: JSON payload with AJAX headers
      http.Response response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
        },
        body: jsonEncode(body),
      );
      print("POST $url => Status: ${response.statusCode}");

      // Retry attempt: Form-encoded if CSRF 419 encountered
      if (response.statusCode == 419) {
        final Map<String, String> stringBody =
            body.map((k, v) => MapEntry(k, v.toString()));
        response = await http.post(
          url,
          headers: {
            'Accept': 'application/json',
            'X-Requested-With': 'XMLHttpRequest',
          },
          body: stringBody,
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
      {@required String? uri,
        @required bool? isAuthorized,
        @required context}) async {
    debugPrint("$baseUrl$uri");
    var token = await AuthHelper.getString("token");
    debugPrint(token);
    try {
      var headers = {'Accept': 'application/json', 'Authorization': 'Bearer $token'};
      
      // Use direct http.get with timeout to prevent socket-reuse hangs on mobile
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
      {@required String? uri,
        @required bool? isAuthorized,
        @required requestData,
        @required context}) async {
    // debugPrint("${Environment().config?.baseUrl}${uri!} ${requestData}");
    // debugPrint("Connectivity Check: ${await checkConnectivity()}");
    // if (await checkConnectivity() == true) {
    var token = await AuthHelper.getString("token");
    print(token);
    print(requestData);
      try {
        var headers = isAuthorized == false
            ? {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'X-Requested-With': 'XMLHttpRequest',
              }
            : requestData == null
            ? {
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
                'X-Requested-With': 'XMLHttpRequest',
              }
            : {
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json',
                'X-Requested-With': 'XMLHttpRequest',
              };
        var request = http.Request(
            'POST', Uri.parse("$baseUrl$uri"));

        request.headers.addAll(headers);
        if (requestData != null) request.body = requestData;
        http.StreamedResponse res = await request.send();
        final response = await http.Response.fromStream(res);

        debugPrint("${response.statusCode}: ${response.body}");
        if (response.statusCode == 200) {
          var resultData = json.decode(response.body);
          return resultData;
        } else if (response.statusCode == 401) {
          // // Handle unauthorized - clear storage and logout
          // await handleUnauthorized(context);
          return "failed";
        } else {

          return "failed";
        }
      } catch (e, stacktrace) {
        debugPrint(stacktrace.toString());
        // ReUsableWidgets.snackBar(
        //     title: e.toString(), color: Colors.black, context: context);
        return "failed";
      }
    // } else {
    //   // ReUsableWidgets.snackBar(
    //   //     title: "No internet connection, please try again", context: context);
    //   return "failed";
    // }
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
      var headers = {
        'Content-Type': 'multipart/form-data',
        'Accept': '*/*',
        'Authorization': 'Bearer $token'
      };
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
                // Handle bytes (e.g., signature bytes)
                request.files.add(http.MultipartFile.fromBytes(
                  '${item.fieldName}',
                  item.fieldValue,
                  filename: item.filename ?? 'signature.png',
                ));
              } else {
                // Handle file path
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
        // // Handle unauthorized - clear storage and logout
        // await handleUnauthorized(context);
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
  final fieldName;
  final fieldValue;
  final isField;
  final isFile;
  final isBytes;
  final String? filename;

  MultipartRequestService(
      {@required this.fieldName,
        @required this.isField,
        @required this.isFile,
        @required this.fieldValue,
        this.isBytes = false,
        this.filename});
}



