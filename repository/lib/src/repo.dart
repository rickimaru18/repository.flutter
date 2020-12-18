import 'package:repository/repository.dart';
import 'package:repository/src/http/http_repo.dart';
// import 'package:repository/src/db/db_repo.dart';

typedef RequestorBuilder = HttpRequestor Function();

class Repo {
  static HttpRepo _httpRepo;
  // static DBRepo _dbRepo;
  static Map<Type, RequestorBuilder> _requestors;

  /// Initialize [HttpRequestor].
  ///
  ///
  static Future<void> init(
    String baseUrl,
    // String dbName,
    Map<Type, RequestorBuilder> requestors, {
    Map<String, String> headers,
  }) async {
    _requestors = requestors;
    _httpRepo = HttpRepo(baseUrl, headers);
    // _dbRepo = dbName != null && dbName.isNotEmpty
    //     ? DBRepo(
    //       dbName,
    //       onDBCreated: () async {
    //         for (final Type key in requestors.keys) {
    //           if (key is DBRequestor) {
    //             await _dbRepo.createTable(requestors[key]() as DBRequestor);
    //           }
    //         }
    //       }
    //     )
    //     : null;
  }

  /// Update base Http URL.
  ///
  ///
  static void updateBaseUrl(String baseUrl) {
    assert(_httpRepo != null, 'Please call Repo.init(...) first.');
    _httpRepo.baseUrl = baseUrl;
  }

  /// Update Http request headers.
  ///
  ///
  static void updateHttpHeaders(Map<String, String> headers) {
    assert(_httpRepo != null, 'Please call Repo.init(...) first.');
    _httpRepo.headers = headers;
  }

  /// Http GET request.
  ///
  ///
  static Future<T> httpGET<T extends HttpRequestor>({
    String endpointExtension = '',
    Map<String, dynamic> params
  }) async {
    assert(_httpRepo != null, 'Please call Repo.init(...) first.');

    final HttpRequestor requestor = _requestors[T]?.call();
    
    return requestor != null
        ? (await _httpRepo.httpGET(
          requestor,
          endpointExtension: endpointExtension,
          params: params
        )).first
        : null;
  }

  /// Http GET request.
  ///
  ///
  static Future<List<T>> httpGETList<T extends HttpRequestor>({
    String endpointExtension = '',
    Map<String, dynamic> params
  }) async {
    assert(_httpRepo != null, 'Please call Repo.init(...) first.');

    final HttpRequestor requestor = _requestors[T]?.call();
    
    return requestor != null
        ? await _httpRepo.httpGET(
          requestor,
          endpointExtension: endpointExtension,
          params: params
        )
        : null;
  }

  /// Http POST request.
  ///
  /// If [body] is null, [requestor] will be used as the
  /// Http request body.
  static Future<T> httpPOST<T extends HttpRequestor>(
    HttpRequestor requestor,
    {
      String endpointExtension = '',
      Map<String, dynamic> params,
      Map<String, dynamic> body
    }
  ) async {
    assert(_httpRepo != null, 'Please call Repo.init(...) first.');

    return await _httpRepo.post(
      PostType.POST,
      requestor,
      endpointExtension: endpointExtension,
      params: params,
      body: body,
    );
  }

  /// Http PUT request.
  ///
  /// If [body] is null, [requestor] will be used as the
  /// Http request body.
  static Future<T> httpPUT<T extends HttpRequestor>(
    HttpRequestor requestor,
    {
      String endpointExtension = '',
      Map<String, dynamic> params,
      Map<String, dynamic> body
    }
  ) async {
    assert(_httpRepo != null, 'Please call Repo.init(...) first.');

    return await _httpRepo.post(
      PostType.PUT,
      requestor,
      endpointExtension: endpointExtension,
      params: params,
      body: body,
    );
  }

  /// Http PATCH request.
  ///
  ///
  static Future<T> httpPATCH<T extends HttpRequestor>(
    HttpRequestor requestor,
    Map<String, dynamic> patch,
    {
      String endpointExtension = '',
      Map<String, dynamic> params
    }
  ) async {
    assert(_httpRepo != null, 'Please call Repo.init(...) first.');

    return await _httpRepo.post(
      PostType.PATCH,
      requestor,
      endpointExtension: endpointExtension,
      params: params,
      body: patch,
    );
  }
}