import 'package:repository/src/common/template_requestor.dart';

abstract class DBRequestor implements TemplateRequestor {
  /// Database table name.
  ///
  ///
  String get tableName;

  /// Data id/primary key.
  ///
  ///
  String get dbId;
}