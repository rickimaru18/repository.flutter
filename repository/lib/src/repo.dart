import 'package:repository/repository.dart';
import 'package:repository/src/common/template_requestor.dart';
import 'package:repository/src/db/db_repo.dart';
import 'package:repository/src/http/http_repo.dart';

typedef RequestorBuilder = TemplateRequestor Function();

class Repo {
  static HttpRepo _httpRepo;
  static DBRepo _dbRepo;
  static Map<Type, RequestorBuilder> requestors;

  /// Initialize [HttpRequestor].
  ///
  ///
  static Future<void> init(
    String baseUrl,
    Map<Type, RequestorBuilder> requestors,
    {
      String dbPathAndName,
      Map<String, String> headers,
    }
  ) async {
    Repo.requestors = requestors;
    _httpRepo = HttpRepo(baseUrl, headers);

    if (dbPathAndName != null) {
      _dbRepo = DBRepo(dbPathAndName);
      await _dbRepo.init();

      requestors.forEach((key, value) {
        _dbRepo.createTable(value.call());
      });
    }
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
    Map<String, dynamic> params,
    int retryCount = 5,
  }) async {
    assert(_httpRepo != null, 'Please call Repo.init(...) first.');

    final HttpRequestor requestor = requestors[T]?.call();

    if (requestor == null) {
      return null;
    }

    T result;

    do {
      try {
        result = (await _httpRepo.httpGET<T>(
          requestor,
          endpointExtension: endpointExtension,
          params: params,
        ))?.first;
        retryCount = 0;
      } catch (e) {
        print('>>>>>>>>> GET ERROR = $e... Retrying...');
        retryCount--;
      }
    } while (retryCount > 0);

    return result;
  }

  /// Http GET request.
  ///
  ///
  static Future<List<T>> httpGETList<T extends HttpRequestor>({
    String endpointExtension = '',
    Map<String, dynamic> params,
    int retryCount = 5,
    bool isSaveOffline = true,
  }) async {
    assert(_httpRepo != null, 'Please call Repo.init(...) first.');

    final HttpRequestor requestor = requestors[T]?.call();

    if (requestor == null) {
      return null;
    }

    List<T> result;

    do {
      try {
        result = await _httpRepo.httpGET<T>(
          requestor,
          endpointExtension: endpointExtension,
          params: params,
        );
        retryCount = 0;
      } catch (e) {
        print('>>>>>>>>> GET ERROR = $e... Retrying...');
        retryCount--;
      }
    } while (retryCount > 0);

    if (isSaveOffline && _dbRepo != null) {
      await _dbRepo.putList(result);

      if (result == null && retryCount == 0) {
        result = await _dbRepo.select((requestor as DBRequestor).tableName);
      }
    }

    return result;
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
      Map<String, dynamic> body,
      int retryCount = 5,
      bool isSaveOffline = true,
    }
  ) async {
    assert(_httpRepo != null, 'Please call Repo.init(...) first.');

    T result;

    do {
      try {
        result = await _httpRepo.post<T>(
          PostType.POST,
          requestor,
          endpointExtension: endpointExtension,
          params: params,
          body: body,
        );
        retryCount = 0;
      } catch (e) {
        print('>>>>>>>>> POST ERROR = $e... Retrying...');
        retryCount--;
      }
    } while (retryCount > 0);

    if (isSaveOffline && _dbRepo != null) {
      await _dbRepo.put(result);
    }

    return result;
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
      Map<String, dynamic> body,
      int retryCount = 5,
      bool isSaveOffline = true,
    }
  ) async {
    assert(_httpRepo != null, 'Please call Repo.init(...) first.');

    T result;

    do {
      try {
        result = await _httpRepo.post<T>(
          PostType.PUT,
          requestor,
          endpointExtension: endpointExtension,
          params: params,
          body: body,
        );
        retryCount = 0;
      } catch (e) {
        print('>>>>>>>>> PUT ERROR = $e... Retrying...');
        retryCount--;
      }
    } while (retryCount > 0);

    if (isSaveOffline && _dbRepo != null) {
      await _dbRepo.put(result);
    }

    return result;
  }

  /// Http PATCH request.
  ///
  ///
  static Future<T> httpPATCH<T extends HttpRequestor>(
    HttpRequestor requestor,
    Map<String, dynamic> patch,
    {
      String endpointExtension = '',
      Map<String, dynamic> params,
      int retryCount = 5,
      bool isSaveOffline = true,
    }
  ) async {
    assert(_httpRepo != null, 'Please call Repo.init(...) first.');

    T result;

    do {
      try {
        result = await _httpRepo.post<T>(
          PostType.PATCH,
          requestor,
          endpointExtension: endpointExtension,
          params: params,
          body: patch,
        );
        retryCount = 0;
      } catch (e) {
        print('>>>>>>>>> PATCH ERROR = $e... Retrying...');
        retryCount--;
      }
    } while (retryCount > 0);

    if (isSaveOffline && _dbRepo != null) {
      await _dbRepo.put(result);
    }

    return result;
  }

  /// Http DELETE request.
  ///
  ///
  static Future<T> httpDELETE<T extends HttpRequestor>(
    HttpRequestor requestor,
    {
      String endpointExtension = '',
      Map<String, dynamic> params,
      int retryCount = 5,
      bool isDelteOffline = true,
    }
  ) async {
    assert(_httpRepo != null, 'Please call Repo.init(...) first.');

    T result;

    do {
      try {
        result = await _httpRepo.delete<T>(
          requestor,
          endpointExtension: endpointExtension,
          params: params,
        );
        retryCount = 0;
      } catch (e) {
        print('>>>>>>>>> Delete ERROR = $e... Retrying...');
        retryCount--;
      }
    } while (retryCount > 0);

    if (isDelteOffline && _dbRepo != null && result != null) {
      final DBRequestor dbItem = result as DBRequestor;
      await _dbRepo.delete(dbItem.dbId != null ? dbItem : requestor);
    }

    return result;
  }
}
