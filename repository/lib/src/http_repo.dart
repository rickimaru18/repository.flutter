import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:repository/src/http_requestor.dart';

class HttpRepo {
  HttpRepo(this.baseUrl, this.headers);

  final Map<String, String> headers;
  final String baseUrl;

  /// Http GET request.
  ///
  ///
  Future<String> get(
    String endpoint,
    {
      Map<String, dynamic> params
    }
  ) async {
    final String query = _toQueryString(params);
    final http.Response response = await http.get(
      '$baseUrl/$endpoint$query',
      headers: headers
    );
    return _getResponseBody(response);
  }

  /// Http POST/PUT/PATCH request.
  ///
  ///
  Future<String> post(
    PostType type,
    String endpoint,
    {
      Map<String, dynamic> params,
      Map<String, dynamic> body
    }
  ) async {
    final String query = _toQueryString(params);
    http.Response response;
    
    switch (type) {
      case PostType.POST:
        response = await http.post(
          '$baseUrl/$endpoint$query',
          headers: headers,
          body: jsonEncode(body),
        );
        break;
      
      case PostType.PUT:
        response = await http.put(
          '$baseUrl/$endpoint$query',
          headers: headers,
          body: jsonEncode(body),
        );
        break;

      case PostType.PATCH:
        response = await http.patch(
          '$baseUrl/$endpoint$query',
          headers: headers,
          body: jsonEncode(body),
        );
        break;
        
      default:
        break;
    }

    return _getResponseBody(response);
  }

  /// Http DELETE request.
  ///
  ///
  Future<String> delete(
    String endpoint,
    {
      Map<String, dynamic> params
    }
  ) async {
    final String query = _toQueryString(params);
    final http.Response response = await http.delete(
      '$baseUrl/$endpoint$query',
      headers: headers,
    );
    return _getResponseBody(response);
  }

  /// Convert [params] to URL query string.
  ///
  ///
  String _toQueryString(Map<String, dynamic> params) {
    if (params != null && params.isNotEmpty) {
      final List<String> list = <String>[];

      params.forEach((String k, dynamic v) => list.add('$k=$v'));

      return '?' + list.join('&');
    } else {
      return '';
    }
  }

  /// Get response body string.
  ///
  ///
  String _getResponseBody(http.Response response) {
    String responseBody;

    switch (response.statusCode) {
      case HttpStatus.ok:
      case HttpStatus.created:
      case HttpStatus.accepted:
        responseBody = response.body;
        break;
    }

    return responseBody;
  }
}