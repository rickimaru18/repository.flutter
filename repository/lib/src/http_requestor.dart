import 'dart:convert';

import 'package:repository/src/http_repo.dart';

typedef RequestorBuilder = HttpRequestor Function();

enum PostType {
  POST,
  PUT,
  PATCH
}

abstract class HttpRequestor {
  static HttpRepo _httpRepo;
  static Map<Type, RequestorBuilder> _requestors;

  /// Initialize [HttpRequestor].
  ///
  ///
  static void init(
    String baseUrl,
    Map<Type, RequestorBuilder> requestors,
    {
      Map<String, String> headers,
    }
  ) {
    _httpRepo = HttpRepo(baseUrl, headers);
    _requestors = requestors;
  }

  /// Http GET request.
  ///
  ///
  static Future<T> get<T extends HttpRequestor>({
    String endpointExtension = '',
    Map<String, dynamic> params
  }) async {
    final HttpRequestor requestor = _requestors[T]?.call();
    return (await requestor._httpGet<T>(
      endpointExtension: endpointExtension,
      params: params
    )).first;
  }

  /// Http GET request with list response.
  ///
  ///
  static Future<List<T>> getList<T extends HttpRequestor>({
    String endpointExtension = '',
    Map<String, dynamic> params
  }) async {
    final HttpRequestor requestor = _requestors[T]?.call();
    return await requestor._httpGet<T>(
      endpointExtension: endpointExtension,
      params: params
    );
  }

  /// Http POST request.
  ///
  ///
  static Future<T> post<T extends HttpRequestor>(
    T data,
    {
      String endpointExtension = '',
      Map<String, dynamic> params
    }
  ) => _post<T>(
    PostType.POST,
    data.toJson(),
    endpointExtension: endpointExtension,
    params: params
  );

  /// Http PUT request.
  ///
  ///
  static Future<T> put<T extends HttpRequestor>(
    HttpRequestor data,
    {
      String endpointExtension = '',
      Map<String, dynamic> params
    }
  ) => _post<T>(
    PostType.PUT,
    data.toJson(),
    endpointExtension: data.endpointId.isEmpty
        ? endpointExtension
        : '${data.endpointId}/$endpointExtension',
    params: params
  );

  /// Http PATCH request.
  ///
  ///
  static Future<T> patch<T extends HttpRequestor>(
    HttpRequestor data,
    Map<String, dynamic> patch,
    {
      String endpointExtension = '',
      Map<String, dynamic> params
    }
  ) => _post<T>(
    PostType.PATCH,
    patch,
    endpointExtension: data.endpointId.isEmpty
        ? endpointExtension
        : '${data.endpointId}/$endpointExtension',
    params: params
  );

  /// Http POST/PUT/PATCH request.
  ///
  ///
  static Future<T> _post<T extends HttpRequestor>(
    PostType type,
    Map<String, dynamic> body,
    {
      String endpointExtension = '',
      Map<String, dynamic> params
    }
  ) async {
    final HttpRequestor requestor = _requestors[T]?.call();
    return await requestor._httpPost<T>(
      type,
      body,
      endpointExtension: endpointExtension,
      params: params
    );
  }

  /// Get endpoint.
  ///
  ///
  String get endpoint;

  /// Get endpoint ID.
  ///
  ///
  String get endpointId => '';

  /// JSON to [HttpRequestor] parser.
  ///
  ///
  HttpRequestor fromJson(Map<String, dynamic> json);

  /// [HttpRequestor] to JSON parser.
  ///
  ///
  Map<String, dynamic> toJson();

  /// Http GET request implementation.
  ///
  ///
  Future<List<T>> _httpGet<T>({
    String endpointExtension,
    Map<String, dynamic> params
  }) async {
    if (_httpRepo == null) {
      return null;
    }

    final String jsonResponse = await _httpRepo.get(
      '$endpoint/$endpointExtension',
      params: params
    );

    if (jsonResponse == null) {
      return null;
    }

    final response = jsonDecode(jsonResponse);

    if (response is List) {
      final List<T> listResponse = <T>[];

      for (final Map<String, dynamic> item in response) {
        listResponse.add(fromJson(item) as T);
      }

      return listResponse;
    }

    return <T>[fromJson(response) as T];
  }

  /// Http POST/PUT/PATCH request implementation.
  ///
  ///
  Future<T> _httpPost<T>(
    PostType type,
    Map<String, dynamic> body,
    {
      String endpointExtension,
      Map<String, dynamic> params
    }
  ) async {
    if (_httpRepo == null) {
      return null;
    }

    final String jsonResponse = await _httpRepo.post(
      type,
      '$endpoint/$endpointExtension',
      params: params,
      body: body,
    );

    if (jsonResponse == null) {
      return null;
    }

    return fromJson(jsonDecode(jsonResponse)) as T;
  }
}