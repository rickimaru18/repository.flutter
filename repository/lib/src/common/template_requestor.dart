abstract class TemplateRequestor {
  /// JSON to [TemplateRequestor] parser.
  ///
  ///
  TemplateRequestor fromJson(Map<String, dynamic> json);

  /// [TemplateRequestor] to JSON parser.
  ///
  ///
  Map<String, dynamic> toJson();
}