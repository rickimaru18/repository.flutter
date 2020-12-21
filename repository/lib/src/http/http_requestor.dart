import 'package:repository/src/common/template_requestor.dart';

abstract class HttpRequestor implements TemplateRequestor {
  /// Get endpoint.
  ///
  ///
  String get endpoint;

  /// Get endpoint ID.
  ///
  ///
  String get endpointId => '';

  /// Get PUT url endpoint extension.
  ///
  ///
  String get putUrlExtension => '';

  /// Get PATCH url endpoint extension.
  ///
  ///
  String get patchUrlExtension => '';

  /// Get DELETE url endpoint extension.
  ///
  ///
  String get deleteUrlExtension => '';
}