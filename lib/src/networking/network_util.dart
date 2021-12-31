import 'dart:async';
import 'dart:convert';
import 'package:robin_flutter/src/controllers/robin_controller.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

/// A network helper class to do all the back end request
class NetworkHelper {
  /// next three lines makes this class a Singleton
  static final NetworkHelper _instance = NetworkHelper.internal();

  NetworkHelper.internal();

  factory NetworkHelper() => _instance;

  /// An object for decoding json values
  final JsonDecoder _decoder = const JsonDecoder();

  final RobinController rc = Get.find();

  /// A function to do any get request with the [url] and [headers]
  /// then sends back a json decoded result
  Future<dynamic> get(String url, {Map<String, String>? headers}) async {
    try {
      headers ??= {
        'Content-Type': 'application/json',
        'x-api-key': rc.apiKey.toString(),
      };
      return http
          .get(Uri.parse(url), headers: headers)
          .then((http.Response response) {
        final String res = response.body;
        final int statusCode = response.statusCode;
        var result = _decoder.convert(res);
        if (statusCode < 200 || statusCode > 400) {
          throw 'Error occurred, please try again';
        }
        return result;
      });
    } catch (e) {
      rethrow;
    }
  }

  /// A function to do any post request with the [url], [headers], [body] and
  /// [encoding] then sends back a json decoded result
  Future<dynamic> post(String url, Map body, {Map<String, String>? headers}) {
    try {
      headers ??= {
        'Content-Type': 'application/json',
        'x-api-key': rc.apiKey.toString(),
      };
      return http
          .post(Uri.parse(url), body: json.encode(body), headers: headers)
          .then((http.Response response) {
        final String res = response.body;
        final int statusCode = response.statusCode;
        var result = _decoder.convert(res);
        if (statusCode < 200 || statusCode > 400) throw result['msg'];
        return result;
      });
    } catch (e) {
      rethrow;
    }
  }

  /// A function to do any put request with the [url], [headers], [body] and
  /// [encoding] then sends back a json decoded result
  Future<dynamic> put(String url, {Map<String, String>? headers, Map? body}) {
    try {
      headers ??= {
        'Content-Type': 'application/json',
        'x-api-key': rc.apiKey.toString(),
      };
      return http
          .put(Uri.parse(url), body: json.encode(body), headers: headers)
          .then((http.Response response) {
        final String res = response.body;
        final int statusCode = response.statusCode;
        var result = _decoder.convert(res);
        if (statusCode < 200 || statusCode > 400) throw result['msg'];
        return result;
      });
    } catch (e) {
      rethrow;
    }
  }

  /// A function to do any post request of form data with the [url], [files],
  /// [header], [body] and [encoding] then sends back a json decoded result
  Future<dynamic> postForm(String url, List<http.MultipartFile> files,
      {Map<String, String>? header, body, encoding}) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll(header!);
      request.fields.addAll(body!);
      request.files.addAll(files);

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final int statusCode = response.statusCode;
      final dynamic res = json.decode(response.body);
      if (statusCode < 200 || statusCode > 400) throw res['message'];
      return res;
    } catch (e) {
      rethrow;
    }
  }

  /// A function to do any delete request with the [url] and [headers]
  /// then sends back a json decoded result
  Future<dynamic> delete(String url,
      {Map<String, String>? headers, Map? body}) {
    try {
      headers ??= {
        'Content-Type': 'application/json',
        'x-api-key': rc.apiKey.toString(),
      };
      return http
          .delete(Uri.parse(url), body: json.encode(body), headers: headers)
          .then((http.Response response) {
        final String res = response.body;
        final int statusCode = response.statusCode;
        var result = _decoder.convert(res);
        if (statusCode < 200 || statusCode > 400) throw result['msg'];
        return result;
      });
    } catch (e) {
      rethrow;
    }
  }
}
