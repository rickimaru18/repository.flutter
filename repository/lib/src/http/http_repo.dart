import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:repository/src/http/http_requestor.dart';

enum PostType {
  POST,
  PUT,
  PATCH
}

class HttpRepo {
  HttpRepo(this._baseUrl, this._headers);

  Map<String, String> _headers;
  String _baseUrl;

  /// Get Http request headers.
  ///
  ///
  Map<String, String> get headers => _headers;

  /// Get Http request base URL.
  ///
  ///
  String get baseUrl => _baseUrl;

  /// Update [headers].
  ///
  ///
  set headers(Map<String, String> newHeaders) {
    if (newHeaders == null) {
      return;
    }
    _headers = newHeaders;
  }

  /// Update [baseUrl].
  ///
  ///
  set baseUrl(String newBaseUrl) {
    if (newBaseUrl == null || newBaseUrl.isEmpty) {
      return;
    }
    _baseUrl = newBaseUrl;
  }

  /// Http GET request.
  ///
  ///
  Future<List<T>> httpGET<T>(
    HttpRequestor requestor,
    {
      String endpointExtension = '',
      Map<String, dynamic> params
    }
  ) async {
    final String url = _getUrl(
      requestor.endpoint,
      endpointExtension: endpointExtension,
      params: params
    );
    final http.Response httpResponse = await http.get(
      url,
      headers: headers
    );
    final String jsonResponse = _getResponseBody(httpResponse);

    if (jsonResponse == null) {
      return null;
    }

    final response = jsonDecode(jsonResponse);

    if (response is List) {
      final List<T> listResponse = <T>[];

      for (final Map<String, dynamic> item in response) {
        listResponse.add(requestor.fromJson(item) as T);
      }

      return listResponse;
    }

    return <T>[requestor.fromJson(response) as T];
  }

  /// Http POST/PUT/PATCH request.
  ///
  ///
  Future<T> post<T>(
    PostType type,
    HttpRequestor requestor,
    {
      String endpointExtension = '',
      bool isEndpointExtensionAppended = true,
      Map<String, dynamic> params,
      Map<String, dynamic> body
    }
  ) async {
    if (isEndpointExtensionAppended) {
      final String appendedEndpointExtension = endpointExtension.isNotEmpty
          ? '/$endpointExtension'
          : endpointExtension;
      switch (type) {
        case PostType.PUT:
          endpointExtension = '${requestor.putUrlExtension}$appendedEndpointExtension';
          break;

        case PostType.PATCH:
          endpointExtension = '${requestor.patchUrlExtension}$appendedEndpointExtension';
          break;

        default:
          break;
      }
    }

    final String url = _getUrl(
      requestor.endpoint,
      endpointExtension: endpointExtension,
      params: params
    );
    http.Response response;

    switch (type) {
      case PostType.POST:
        response = await http.post(
          url,
          headers: headers,
          body: jsonEncode(body ?? requestor.toJson()),
        );
        break;

      case PostType.PUT:
        response = await http.put(
          url,
          headers: headers,
          body: jsonEncode(body ?? requestor.toJson()),
        );
        break;

      case PostType.PATCH:
        response = await http.patch(
          url,
          headers: headers,
          body: jsonEncode(body ?? requestor.toJson()),
        );
        break;

      default:
        break;
    }

    final String jsonResponse = _getResponseBody(response);

    if (jsonResponse == null) {
      return null;
    }

    return requestor.fromJson(jsonDecode(jsonResponse)) as T;
  }

  /// Http DELETE request.
  ///
  ///
  Future<T> delete<T>(
    HttpRequestor requestor,
    {
      String endpointExtension = '',
      bool isEndpointExtensionAppended = true,
      Map<String, dynamic> params,
    }
  ) async {
    if (isEndpointExtensionAppended) {
      final String appendedEndpointExtension = endpointExtension.isNotEmpty
          ? '/$endpointExtension'
          : endpointExtension;
      endpointExtension = '${requestor.deleteUrlExtension}$appendedEndpointExtension';
    }

    final String url = _getUrl(
      requestor.endpoint,
      endpointExtension: endpointExtension,
      params: params
    );
    final http.Response response = await http.delete(
      url,
      headers: headers,
    );
    final String jsonResponse = _getResponseBody(response);

    if (jsonResponse == null) {
      return null;
    }

    return requestor.fromJson(jsonDecode(jsonResponse)) as T;
  }

  /// Get full URL.
  ///
  ///
  String _getUrl(
    String endpoint,
    {
      String endpointExtension = '',
      Map<String, dynamic> params
    }
  ) {
    StringBuffer url = StringBuffer('$baseUrl/$endpoint');

    if (endpointExtension.isNotEmpty) {
      url.write('/');
      url.write(endpointExtension);
    }

    final String query = _toQueryString(params);

    if (query.isNotEmpty) {
      url.write(query);
    }

    return url.toString();
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